# PRD — Restaurant Owner Portal
**Platform:** Restaurant Direct  
**App:** `apps/owner-portal` (Next.js)  
**Stage:** MVP Core + Phase 2 defined  
**Audience:** AI Coding Agents — treat every rule here as a strict contract

> **Related PRDs:**
> - Platform Super-Admin Panel → `/docs/PRD_Platform_Admin.md`
> - Restaurant Dashboard (operational) → `/docs/PRD_Dashboard.md`
> - Driver App → `/docs/PRD_Driver.md`
> - Core product → `/docs/PRD_Core.md`
> - Customer App → `/docs/PRD_Customer_App.md`

---

## Table of Contents

1. [Purpose & Scope](#1-purpose--scope)
2. [Canonical Role Definitions](#2-canonical-role-definitions)
3. [Scope & Access](#3-scope--access)
4. [Module: Restaurant Settings](#4-module-restaurant-settings)
5. [Module: Opening Hours](#5-module-opening-hours)
6. [Module: Menu Management](#6-module-menu-management)
7. [Module: Staff Account Management](#7-module-staff-account-management)
8. [Module: Driver Management](#8-module-driver-management)
9. [Phase 2 — Promotions & Discount Codes](#9-phase-2--promotions--discount-codes)
10. [Phase 2 — Loyalty Program Configuration](#10-phase-2--loyalty-program-configuration)
11. [Phase 2 — Analytics](#11-phase-2--analytics)
12. [Technical Placement](#12-technical-placement)
13. [Auth Architecture](#13-auth-architecture)
14. [API Contract](#14-api-contract)
15. [Screen & Route Map](#15-screen--route-map)
16. [Frontend Architecture Rules](#16-frontend-architecture-rules)
17. [Domain Invariants](#17-domain-invariants)
18. [Out of Scope](#18-out-of-scope)

---

## 1. Purpose & Scope

The Restaurant Owner Portal is a **configuration tool**. Restaurant owners use it outside of live service to set up and manage their restaurant — menu, staff, hours, drivers, promotions, and loyalty.

It is **not** the operational dashboard. The Restaurant Dashboard (`apps/web`) is the operational tool staff use during a live service to manage orders in real time. There is no overlap in functionality between these two apps. If a feature appears in both, that is an architectural error.

It is **not** the Platform Super-Admin Panel. That is a completely separate app (`apps/platform-admin`) for managing the platform itself.

### MVP Core Modules
- Restaurant Settings (profile, logo)
- Opening Hours + Default Ready Time
- Menu Management (categories, items, modifiers)
- Staff Account Management
- Driver Management

### Phase 2 Modules (specced here, not built in MVP)
- Promotions & Discount Codes
- Loyalty Program Configuration
- Analytics & Revenue Reporting

---

## 2. Canonical Role Definitions

**This is the single source of truth for all user roles across the entire platform.** All PRDs, JWT payloads, middleware, API guards, and UI role checks must use exactly these values. No aliases, no alternate spellings.

```typescript
// /packages/types/src/roles.ts
export enum UserRole {
  PLATFORM_ADMIN     = 'platform_admin',     // Platform operator — manages all tenants
  RESTAURANT_OWNER   = 'restaurant_owner',   // Tenant owner — manages their restaurant
  RESTAURANT_STAFF   = 'restaurant_staff',   // Operational staff — uses Dashboard only
  DRIVER             = 'driver',             // Delivery driver — uses Driver App only
  CUSTOMER           = 'customer',           // End customer — uses Customer App only
}
```

### Role Capabilities Summary

| Role | App Access |
|---|---|
| `platform_admin` | Platform Super-Admin Panel + read-only audit of Owner Portal |
| `restaurant_owner` | Restaurant Owner Portal + Restaurant Dashboard |
| `restaurant_staff` | Restaurant Dashboard only |
| `driver` | Driver App only |
| `customer` | Customer App only |

### JWT Role Claim Rules

- All JWTs must include a `role` claim using the exact string values above.
- `restaurant_owner` and `restaurant_staff` JWTs must include `restaurant_id`.
- `driver` JWTs must include `restaurant_id` and `driver_id`.
- `platform_admin` JWTs must **not** include `restaurant_id`.
- `customer` JWTs must include `customer_id`.

**Rule for AI agents:** Never invent a new role. If a new role is required, update this section and `architecture.md` first.

---

## 3. Scope & Access

**Who uses it:** `restaurant_owner` role only.  
**Authentication:** JWT with `role = restaurant_owner` and `restaurant_id` claim.  
**Data scope:** All data is strictly scoped to the JWT's `restaurant_id`. The backend must enforce this on every endpoint — an owner can never read or write another restaurant's data.

### Route Guard Rule

Every portal route must verify:
1. Valid JWT present.
2. `role = restaurant_owner` (canonical value from `UserRole` enum).
3. `restaurant_id` in JWT matches the resource being accessed.

If any check fails → redirect to `/owner/login`.

**Rule:** Route guards are a UI convenience only. The backend must independently validate the JWT `role` and `restaurant_id` on every request. Frontend enforcement is never sufficient.

---

## 4. Module: Restaurant Settings

**Route:** `/owner/settings/profile`

Allows the owner to update their restaurant's public profile.

### Editable Fields

| Field | Type | Validation |
|---|---|---|
| Restaurant name | text | Required, max 100 chars |
| Description | textarea | Optional, max 500 chars |
| Phone number | text | Required, valid phone format |
| Email address | text | Required, valid email format |
| Street address | text | Required |
| City | text | Required |
| Postal code | text | Required |
| Restaurant logo | image upload | JPG/PNG, max 2MB |

**Save behaviour:** Explicit Save button. No auto-save. Success toast on save. Error toast on failure — form retains attempted values.

**Image upload:** Logo uploaded to Supabase Storage. Backend returns `logo_url` stored in `restaurants.logo_url`. Frontend displays a preview before save.

**API:** `PATCH /api/restaurants/:id/profile`

---

## 5. Module: Opening Hours

**Route:** `/owner/settings/hours`

> This module was explicitly removed from the Restaurant Dashboard. It lives here only.

### Hours Editor

One row per day (Monday–Sunday):
- Day label
- Open / Closed toggle
- If Open: time range inputs — 24h format, 15-minute increments
- If Closed: inputs disabled and greyed out

**Save behaviour:** Explicit Save Hours button. No auto-save. Success toast on save. Error toast on failure.

### Data Model

```
restaurants.opening_hours  JSONB  NOT NULL

Example value:
{
  "monday":    { "is_open": true,  "open": "11:00", "close": "20:00" },
  "tuesday":   { "is_open": true,  "open": "11:00", "close": "20:00" },
  "wednesday": { "is_open": true,  "open": "11:00", "close": "20:00" },
  "thursday":  { "is_open": true,  "open": "11:00", "close": "20:00" },
  "friday":    { "is_open": true,  "open": "11:00", "close": "20:30" },
  "saturday":  { "is_open": true,  "open": "11:00", "close": "20:30" },
  "sunday":    { "is_open": true,  "open": "11:00", "close": "20:00" }
}
```

**Type is `JSONB` not `JSON`.** This is a hard requirement — do not use a plain string or generic JSON column.

### Default Ready Time

Below the hours editor:

**Default order ready time:** `[ 20 ] minutes`

Maps to `restaurants.default_ready_time_minutes  INTEGER  DEFAULT 20`. Saved on the same Save Hours button press.

### Restaurant Open/Closed Toggle

A prominent toggle at the top: **Restaurant is OPEN / CLOSED**.

- Sets `restaurants.is_active` immediately (instant PATCH — no Save button required).
- When `is_active = false`, the customer app blocks new orders. Enforced server-side on the order creation endpoint.
- In-progress orders are never affected — closing only blocks new orders (see Domain Invariant #6).

**APIs:**
```
PATCH /api/restaurants/:id/hours   ← saves opening_hours + default_ready_time_minutes
PATCH /api/restaurants/:id/active  ← instant open/close toggle
```

---

## 6. Module: Menu Management

**Route:** `/owner/menu`

The most complex module in the portal. The owner manages the full menu hierarchy from this screen.

### Menu Structure

```
Restaurant
  └── Category (e.g. Burgers)
        └── Menu Item (e.g. Double Burger)
              └── Modifier Group (e.g. "Extras")
                    └── Modifier Option (e.g. "+ Cheese R5")
```

### Category Management

Displayed as a left-side list. Actions:
- Create category (name, display order)
- Rename category
- Reorder categories (drag and drop — updates `display_order`)
- Delete category — only permitted if no active items. If items exist: *"Remove all items from this category before deleting."*

**Data model:**
```
menu_categories
  id                UUID
  restaurant_id     UUID      NOT NULL
  name              TEXT      NOT NULL
  display_order     INTEGER   NOT NULL
  is_active         BOOLEAN   DEFAULT true
  created_at        TIMESTAMP
```

### Menu Item Management

Selecting a category shows its items on the right. Each item card shows name, price, and availability toggle.

**Create / Edit Item form:**

| Field | Type | Validation |
|---|---|---|
| Name | text | Required, max 100 chars |
| Description | textarea | Optional, max 300 chars |
| Price | decimal | Required, min R0.01 |
| Category | select | Required |
| Image | image upload | JPG/PNG, max 2MB, optional |
| Available | toggle | Default true |

**Availability toggle:** Sets `menu_items.is_available`. Instant PATCH — no Save button required. When `false`, item is hidden from the customer app immediately.

**Delete item:** Soft delete only — sets `menu_items.is_available = false` and `menu_items.deleted_at = now()`. Items are **never hard deleted** — they may exist in historical `order_items` snapshots (Domain Invariant #2).

### Modifier Groups & Options

Each menu item can have one or more modifier groups.

**Modifier Group fields:**
- Name (e.g. "Extras")
- Selection type: `single` (radio) or `multiple` (checkbox)
- Required: boolean — if true, customer must select at least one option
- Min selections / Max selections (integers, optional)

**Modifier Option fields:**
- Name (e.g. "Extra Cheese")
- Price adjustment: decimal (R0.00 for free extras)
- Available toggle

**Data model:**
```
menu_modifier_groups
  id                UUID
  menu_item_id      UUID      NOT NULL
  restaurant_id     UUID      NOT NULL   ← required per architecture §4.4
  name              TEXT      NOT NULL
  selection_type    ENUM ('single', 'multiple')
  is_required       BOOLEAN   NOT NULL
  min_selections    INTEGER   NULLABLE
  max_selections    INTEGER   NULLABLE
  display_order     INTEGER   NOT NULL

menu_modifier_options
  id                UUID
  modifier_group_id UUID      NOT NULL
  restaurant_id     UUID      NOT NULL   ← required per architecture §4.4
  name              TEXT      NOT NULL
  price_adjustment  DECIMAL   DEFAULT 0.00
  is_available      BOOLEAN   DEFAULT true
  display_order     INTEGER   NOT NULL
```

### Menu Item Price History

When a menu item's price is updated, historical `order_items` records must remain unchanged — they snapshot `item_price` at purchase time. Changing `menu_items.price` only affects future orders. AI agents must not backfill or recalculate historical order item prices.

**APIs:**
```
GET    /api/menu/categories?restaurant_id=
POST   /api/menu/categories
PATCH  /api/menu/categories/:id
DELETE /api/menu/categories/:id

GET    /api/menu/items?category_id=&restaurant_id=
POST   /api/menu/items
PATCH  /api/menu/items/:id
PATCH  /api/menu/items/:id/availability
DELETE /api/menu/items/:id              ← soft delete only

POST   /api/menu/modifier-groups
PATCH  /api/menu/modifier-groups/:id
DELETE /api/menu/modifier-groups/:id

POST   /api/menu/modifier-options
PATCH  /api/menu/modifier-options/:id
DELETE /api/menu/modifier-options/:id
```

---

## 7. Module: Staff Account Management

**Route:** `/owner/staff`

The owner creates and manages staff accounts scoped to their own `restaurant_id`.

### Staff List

Table columns: Name, Email, Role badge, Status, Date added, Actions (Edit / Deactivate).

### Create Staff Account

Form fields: Full name (required), Email (required, unique across platform), Role (`restaurant_staff` or `restaurant_owner`).

On creation:
1. Backend creates a `users` record with `role`, `restaurant_id`, `must_reset_password = true`.
2. Temporary password auto-generated, shown to owner once.
3. Welcome email sent with login instructions.

### Edit Staff Account

Owner can update: name, role. Email is immutable after creation in MVP.

### Deactivate Staff Account

Sets `users.is_active = false`. The deactivated member's JWT is invalidated on next request via server-side check. They cannot log in.

**Rule:** An owner cannot deactivate themselves. Backend must reject requests where `target_user_id = requesting_user_id` (Domain Invariant #5).

### Manager PIN

Owner sets their own manager PIN — used for confirmed-order cancellations in the Restaurant Dashboard.

- 4–6 numeric digits
- Stored as bcrypt hash in `users.manager_pin`
- Form: New PIN + Confirm PIN
- If no PIN set, Dashboard shows a warning but does not block cancellation in MVP

**Data model additions:**
```
users.is_active              BOOLEAN    DEFAULT true
users.must_reset_password    BOOLEAN    DEFAULT false
users.manager_pin            TEXT       NULLABLE   ← bcrypt hashed
```

**APIs:**
```
GET    /api/staff?restaurant_id=
POST   /api/staff
PATCH  /api/staff/:id
POST   /api/staff/:id/deactivate
POST   /api/owner/manager-pin
```

---

## 8. Module: Driver Management

**Route:** `/owner/drivers`

The owner manages their restaurant's driver roster. Drivers are **restaurant-owned** — there is no shared platform driver pool in MVP.

```
drivers.restaurant_id  UUID  NOT NULL
```

### Driver List

Table columns: Name, Phone, Status (Active/Inactive), Online/offline status (read-only — set by Driver App), Date added.

### Create Driver

Form fields: Full name (required), Phone (required), Email (required).

On creation:
1. A `drivers` record is created with `restaurant_id`.
2. A linked `users` record with `role = driver` is created for Driver App authentication.
3. Temporary password auto-generated, shown once.

### Edit Driver

Owner can update: name, phone. Email immutable after creation.

### Deactivate Driver

Sets `drivers.is_active = false`. Driver cannot log into the Driver App.

**Rule:** A driver cannot be deactivated while they have a delivery in `assigned`, `picked_up`, or `on_the_way` state. Backend returns a warning and blocks deactivation until the active delivery is resolved (Domain Invariant #4).

**Data model:**
```
drivers
  id                UUID
  restaurant_id     UUID       NOT NULL
  user_id           UUID       NOT NULL   ← links to users table for auth
  name              TEXT       NOT NULL
  phone             TEXT       NOT NULL
  is_active         BOOLEAN    DEFAULT true
  current_location  JSONB      NULLABLE   ← { latitude, longitude }
  last_location_at  TIMESTAMP  NULLABLE
  created_at        TIMESTAMP
```

**APIs:**
```
GET    /api/drivers?restaurant_id=
POST   /api/drivers
PATCH  /api/drivers/:id
POST   /api/drivers/:id/deactivate
```

---

## 9. Phase 2 — Promotions & Discount Codes

> **AI Agent Rule:** Do not implement this section during MVP. Schema tables should be created in migrations but no UI, API routes, or service logic is to be built until Phase 2 is explicitly initiated.

**Route:** `/owner/promotions`

### Promotions List

Table columns: Code, Type, Value, Min order, Usage count, Expiry date, Status.

### Create Promotion

| Field | Type | Validation |
|---|---|---|
| Code | text | Required, uppercase, max 20 chars, unique per restaurant |
| Discount type | select | `percent` or `fixed` |
| Discount value | decimal | If percent: 1–100. If fixed: min R1.00 |
| Minimum order amount | decimal | Optional, default R0.00 |
| Expiry date | date picker | Optional — must be future date if set |
| Active | toggle | Default true |
| Usage limit | integer | Optional. Max total redemptions |

**Code uniqueness:** Scoped per `restaurant_id` — same code may exist across different restaurants.

### Edit / Disable Promotion

If `usage_count = 0`: all fields editable.  
If `usage_count > 0`: only `is_active` and `expires_at` may be changed (Domain Invariant #3).

**Data model:**
```
promotions
  id                UUID
  restaurant_id     UUID       NOT NULL
  code              TEXT       NOT NULL
  discount_type     ENUM ('percent', 'fixed')
  discount_value    DECIMAL    NOT NULL
  min_order_amount  DECIMAL    DEFAULT 0.00
  expires_at        TIMESTAMP  NULLABLE
  usage_limit       INTEGER    NULLABLE
  usage_count       INTEGER    DEFAULT 0
  is_active         BOOLEAN    DEFAULT true
  created_at        TIMESTAMP
```

**APIs (Phase 2 only):**
```
GET    /api/promotions?restaurant_id=
POST   /api/promotions
PATCH  /api/promotions/:id
POST   /api/promotions/:id/disable
```

---

## 10. Phase 2 — Loyalty Program Configuration

> **AI Agent Rule:** Do not implement this section during MVP.

**Route:** `/owner/loyalty`

Each restaurant configures one loyalty program. Two models supported.

### Model A — Points-Based

Customer earns points per rand spent and redeems points against future orders.

| Config Field | Description |
|---|---|
| Rands per point | e.g. `10` = 1 point per R10 spent |
| Redemption rate | e.g. `10` = R10 value per 100 points |
| Minimum points to redeem | Minimum balance required before redemption |
| Points expiry (days) | Optional — expires after N days of inactivity |

### Model B — Stamp Card

Customer earns one stamp per qualifying order. After N stamps, receives a reward.

| Config Field | Description |
|---|---|
| Stamps required | How many stamps to earn the reward |
| Reward description | e.g. "Free meal up to R80" |
| Minimum order for stamp | Minimum order value to qualify for a stamp |

### Switching Models

Switching models resets all customer `loyalty_accounts` balances. A confirmation modal must appear: *"Switching loyalty models will reset all customer points and stamps. This cannot be undone."* (Domain Invariant #7).

**Data model:**
```
loyalty_config
  id                        UUID
  restaurant_id             UUID       NOT NULL  UNIQUE
  model                     ENUM ('points', 'stamp_card')
  is_active                 BOOLEAN    DEFAULT false
  rands_per_point           INTEGER    NULLABLE
  points_per_redemption     INTEGER    NULLABLE
  redemption_value          DECIMAL    NULLABLE
  min_redemption_points     INTEGER    NULLABLE
  points_expiry_days        INTEGER    NULLABLE
  stamps_required           INTEGER    NULLABLE
  reward_description        TEXT       NULLABLE
  min_order_for_stamp       DECIMAL    NULLABLE
  created_at                TIMESTAMP
  updated_at                TIMESTAMP
```

**APIs (Phase 2 only):**
```
GET    /api/loyalty/config?restaurant_id=
PUT    /api/loyalty/config/:restaurant_id   ← upsert
POST   /api/loyalty/config/:restaurant_id/toggle
```

---

## 11. Phase 2 — Analytics

> **AI Agent Rule:** Do not implement this section during MVP.

**Route:** `/owner/analytics`

### Summary Cards

| Card | Metric |
|---|---|
| Orders Today | Count where `created_at = today` and `status != cancelled` |
| Revenue Today | Sum of `total_price` where `status = delivered` and `created_at = today` |
| Average Order Value | Revenue Today ÷ Orders Today |
| Pending Orders | Count where `status IN (pending, confirmed, preparing, ready_for_pickup)` |

### Charts

**Orders Over Time** — Line chart, last 7 days, excludes cancelled.  
**Revenue Over Time** — Bar chart, last 7 days, delivered orders only.

### Top Items Table

Top 10 most ordered menu items for current week. Columns: Item name, Order count, Revenue. Sorted by order count descending.

### Fulfillment Breakdown

Pie/donut chart — Delivery vs Pickup split by order count, current week.

**Rules:**
- All analytics computed server-side. Frontend never calculates from raw order data.
- Analytics endpoints must be cached server-side (60-second TTL minimum). Never run unbounded aggregate queries on every page load.

**APIs (Phase 2 only):**
```
GET /api/analytics/summary?restaurant_id=&date=today
GET /api/analytics/orders-over-time?restaurant_id=&days=7
GET /api/analytics/revenue-over-time?restaurant_id=&days=7
GET /api/analytics/top-items?restaurant_id=&period=week
GET /api/analytics/fulfillment-split?restaurant_id=&period=week
```

---

## 12. Technical Placement

```
/apps
  /web              ← existing: Customer App + Restaurant Dashboard
  /owner-portal     ← THIS APP
  /platform-admin   ← separate app, see PRD_Platform_Admin.md
```

**Shared packages (may import):**
```
/packages/types     ← shared TypeScript interfaces including UserRole enum
/packages/config    ← shared ESLint, Prettier, TS configs
```

**Rule:** `/apps/owner-portal` must not import from `/apps/web` or `/apps/platform-admin`. Shared code belongs in `/packages` only.

---

## 13. Auth Architecture

**Login endpoint:** `POST /api/auth/owner/login`  
**Required role:** `restaurant_owner`  
**JWT storage:** `httpOnly` cookie via Next.js Route Handler. Never `localStorage`.

### Audit Token (read-only access by Platform Admin)

When a Platform Admin initiates an audit session, the Owner Portal may be loaded with an `X-Audit-Token` header. In this mode:
- A visible banner is shown: *"You are viewing this portal in read-only audit mode as Platform Admin."*
- All write actions (Save, Create, Delete, Deactivate) are hidden from the UI.
- All write API endpoints reject audit tokens with `403 Forbidden` server-side.
- Audit tokens never grant access to payment endpoints.

---

## 14. API Contract

All requests include `Authorization: Bearer <jwt>`.  
All responses use the global envelope:
```json
{ "success": true, "data": { ... } }
{ "success": false, "data": null, "error": { "code": "...", "message": "..." } }
```

### MVP Core APIs

| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/auth/owner/login` | Owner login |
| POST | `/api/auth/owner/logout` | Invalidate session |
| GET | `/api/restaurants/:id` | Get restaurant profile |
| PATCH | `/api/restaurants/:id/profile` | Update profile + logo |
| PATCH | `/api/restaurants/:id/hours` | Update opening hours + default ready time |
| PATCH | `/api/restaurants/:id/active` | Instant open/close toggle |
| GET | `/api/menu/categories?restaurant_id=` | List categories |
| POST | `/api/menu/categories` | Create category |
| PATCH | `/api/menu/categories/:id` | Update category |
| DELETE | `/api/menu/categories/:id` | Delete empty category |
| GET | `/api/menu/items?restaurant_id=` | List items |
| POST | `/api/menu/items` | Create item |
| PATCH | `/api/menu/items/:id` | Update item |
| PATCH | `/api/menu/items/:id/availability` | Toggle availability (instant) |
| DELETE | `/api/menu/items/:id` | Soft delete item |
| POST | `/api/menu/modifier-groups` | Create modifier group |
| PATCH | `/api/menu/modifier-groups/:id` | Update modifier group |
| DELETE | `/api/menu/modifier-groups/:id` | Delete modifier group |
| POST | `/api/menu/modifier-options` | Create modifier option |
| PATCH | `/api/menu/modifier-options/:id` | Update modifier option |
| DELETE | `/api/menu/modifier-options/:id` | Delete modifier option |
| GET | `/api/staff?restaurant_id=` | List staff |
| POST | `/api/staff` | Create staff account |
| PATCH | `/api/staff/:id` | Update staff |
| POST | `/api/staff/:id/deactivate` | Deactivate staff |
| POST | `/api/owner/manager-pin` | Set manager PIN |
| GET | `/api/drivers?restaurant_id=` | List drivers |
| POST | `/api/drivers` | Create driver |
| PATCH | `/api/drivers/:id` | Update driver |
| POST | `/api/drivers/:id/deactivate` | Deactivate driver |

### Phase 2 APIs (do not build in MVP)

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/promotions?restaurant_id=` | List promotions |
| POST | `/api/promotions` | Create promotion |
| PATCH | `/api/promotions/:id` | Update promotion |
| POST | `/api/promotions/:id/disable` | Disable promotion |
| GET | `/api/loyalty/config?restaurant_id=` | Get loyalty config |
| PUT | `/api/loyalty/config/:restaurant_id` | Upsert loyalty config |
| POST | `/api/loyalty/config/:restaurant_id/toggle` | Enable/disable loyalty |
| GET | `/api/analytics/summary?restaurant_id=` | KPI cards |
| GET | `/api/analytics/orders-over-time?restaurant_id=&days=7` | Orders chart |
| GET | `/api/analytics/revenue-over-time?restaurant_id=&days=7` | Revenue chart |
| GET | `/api/analytics/top-items?restaurant_id=&period=week` | Top items |
| GET | `/api/analytics/fulfillment-split?restaurant_id=&period=week` | Fulfillment split |

---

## 15. Screen & Route Map

```
/owner
  /owner/login
  /owner/dashboard                  ← owner home: quick stats (Phase 2: full analytics)
  /owner/menu                       ← menu management (MVP)
  /owner/staff                      ← staff accounts (MVP)
  /owner/drivers                    ← driver management (MVP)
  /owner/promotions                 ← (Phase 2)
  /owner/loyalty                    ← (Phase 2)
  /owner/analytics                  ← (Phase 2)
  /owner/settings
    /owner/settings/profile         ← restaurant name, address, contact (MVP)
    /owner/settings/hours           ← opening hours + default ready time (MVP)
```

**Redirect logic:**
- Unauthenticated access to any `/owner/*` → redirect to `/owner/login`
- Authenticated access to `/owner` → redirect to `/owner/dashboard`
- Phase 2 routes must return 404 in MVP — do not build placeholder pages

---

## 16. Frontend Architecture Rules

### Component Structure

```
/apps/owner-portal/app/
  layout.tsx                    ← Auth guard, sidebar, header
  dashboard/
    page.tsx
  menu/
    page.tsx
    components/
      CategoryList.tsx
      MenuItemGrid.tsx
      MenuItemForm.tsx
      ModifierGroupForm.tsx
      ModifierOptionForm.tsx
  staff/
    page.tsx
    components/
      StaffTable.tsx
      CreateStaffModal.tsx
      ManagerPinForm.tsx
  drivers/
    page.tsx
    components/
      DriverTable.tsx
      CreateDriverModal.tsx
  settings/
    profile/
      page.tsx
    hours/
      page.tsx
      components/
        HoursEditor.tsx
        ReadyTimeInput.tsx
        RestaurantToggle.tsx
```

### React Query Keys (Strict — do not deviate)

```
['restaurant', restaurantId]
['menu-categories', restaurantId]
['menu-items', categoryId]
['menu-modifier-groups', menuItemId]
['staff', restaurantId]
['drivers', restaurantId]
['promotions', restaurantId]          ← Phase 2
['loyalty-config', restaurantId]      ← Phase 2
['analytics-summary', restaurantId]   ← Phase 2
['analytics-orders', restaurantId]    ← Phase 2
['analytics-revenue', restaurantId]   ← Phase 2
['analytics-top-items', restaurantId] ← Phase 2
```

### Rules

- No direct Supabase DB queries from the frontend. All data fetches go through the Backend REST API.
- No business logic in UI components. Logic lives in custom hooks or utility functions.
- Server state managed by React Query. Global UI state (sidebar open, toast queue) managed by Zustand.

---

## 17. Domain Invariants

These laws must never be violated. AI agents must not generate code that breaks them.

```
1.  A restaurant owner can only access data belonging to their own restaurant_id.
    Backend must validate JWT restaurant_id on every request.

2.  Menu items must never be hard deleted.
    Soft delete only: is_available = false + deleted_at = now().
    Reason: historical order_items snapshot item names and prices at purchase time.

3.  A promotion with usage_count > 0 cannot have its discount_value or
    discount_type changed. Only is_active and expires_at may be updated.

4.  A driver cannot be deactivated while they have a delivery in
    assigned, picked_up, or on_the_way state.
    Backend must check and reject, returning a clear error message.

5.  An owner cannot deactivate their own account.
    Backend must reject requests where target_user_id = requesting_user_id.

6.  restaurants.is_active (open/closed daily toggle) and restaurants.status
    (platform lifecycle: active/inactive/suspended) are separate fields.
    They must never be merged or conflated.
    Closing is_active only blocks new orders — it never affects in-progress orders.

7.  Switching loyalty models resets all customer loyalty_accounts balances.
    Requires explicit owner confirmation. Cannot be undone.
    loyalty_config changes are forward-only — they do not alter existing
    loyalty_transactions records.

8.  All user roles must use the canonical UserRole enum defined in Section 2.
    No aliases or alternate strings anywhere in the codebase.

9.  Phase 2 schema tables (promotions, loyalty_config) must be created in
    database migrations but must have no application logic wired to them in MVP.
```

---

## 18. Out of Scope

### Deferred to Phase 2 (specced in this PRD — schema ready, no application logic in MVP)
- Promotions & discount code management (Section 9)
- Loyalty program configuration (Section 10)
- Analytics & revenue reporting (Section 11)

### Post-MVP (not yet specced)
- Multi-location management (schema has `restaurant_id` everywhere — no UI yet)
- Platform billing / subscription management
- Restaurant self-registration
- Ratings and reviews management
- Customer account management
- CSV / Excel export
- Push notifications to owners
- Bulk menu import
- Menu item copy / clone
- Refund management UI (handled via payment provider dashboard)
- Driver pay / earnings tracking

---

*End of Restaurant Owner Portal PRD*
