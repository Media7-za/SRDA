# PRD — Platform Super-Admin Panel
**Platform:** Restaurant Direct  
**App:** `apps/platform-admin` (Next.js)  
**Stage:** MVP  
**Audience:** AI Coding Agents — treat every rule here as a strict contract

> **Related PRDs:**
> - Restaurant Owner Portal → `/docs/PRD_Owner_Portal.md`
> - Restaurant Dashboard (operational) → `/docs/PRD_Dashboard.md`
> - Driver App → `/docs/PRD_Driver.md`
> - Core product → `/docs/PRD_Core.md`

---

## Table of Contents

1. [Purpose & Scope](#1-purpose--scope)
2. [Canonical Role Definitions](#2-canonical-role-definitions)
3. [Scope & Access](#3-scope--access)
4. [Module: Restaurant Onboarding](#4-module-restaurant-onboarding)
5. [Module: Restaurant Management](#5-module-restaurant-management)
6. [Module: Feature Flags](#6-module-feature-flags)
7. [Module: Platform Revenue Overview](#7-module-platform-revenue-overview)
8. [Module: Impersonation & Audit](#8-module-impersonation--audit)
9. [Technical Placement](#9-technical-placement)
10. [Auth Architecture](#10-auth-architecture)
11. [API Contract](#11-api-contract)
12. [Screen & Route Map](#12-screen--route-map)
13. [Frontend Architecture Rules](#13-frontend-architecture-rules)
14. [Domain Invariants](#14-domain-invariants)
15. [Out of Scope](#15-out-of-scope)

---

## 1. Purpose & Scope

The Platform Super-Admin Panel is the **platform operator's control centre**. It is used exclusively by `platform_admin` users to manage the platform itself — not individual restaurants.

Responsibilities:
- Onboard new restaurant tenants
- Suspend or activate restaurants
- Monitor all restaurants' activity
- Control per-tenant feature flags
- View platform-wide revenue
- Audit restaurant Owner Portals in read-only mode

This app has **no overlap** with the Restaurant Owner Portal. If a feature appears in both, that is an architectural error.

**Security posture:** This app must be deployed on a separate, non-publicly-discoverable subdomain (e.g. `admin.restaurantdirect.com`). It must never share session state or route structure with the Owner Portal.

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
- `platform_admin` JWTs must **not** include `restaurant_id`.
- `restaurant_owner` and `restaurant_staff` JWTs must include `restaurant_id`.
- `driver` JWTs must include `restaurant_id` and `driver_id`.
- `customer` JWTs must include `customer_id`.

**Rule for AI agents:** Never invent a new role. Update this section and `architecture.md` first.

---

## 3. Scope & Access

**Who uses it:** `platform_admin` role only. This role is not assignable by restaurant owners — it is seeded directly in the database by the platform operator.

**Authentication:** Separate JWT with `role = platform_admin`. No `restaurant_id` in this JWT.

**No cross-contamination rule:** `platform_admin` JWTs must never be accepted by restaurant-scoped API endpoints (menu management, order status, etc.). Restaurant-scoped endpoints must reject any JWT where `restaurant_id` is absent, regardless of role.

### Route Guard Rule

Every platform admin route must verify:
1. Valid JWT present.
2. `role = platform_admin` (canonical value from `UserRole` enum).

If any check fails → redirect to `/platform/login`.

---

## 4. Module: Restaurant Onboarding

**Route:** `/platform/restaurants/new`

The platform admin creates new restaurant tenants. Restaurants cannot self-register in MVP.

### Create Restaurant Form

| Field | Type | Validation |
|---|---|---|
| Restaurant name | text | Required, max 100 chars |
| Owner name | text | Required |
| Owner email | text | Required, unique across platform |
| Owner phone | text | Required |
| Street address | text | Required |
| City | text | Required |
| Postal code | text | Required |
| Plan / tier | select | MVP: `standard` only |

### On Submission

1. Creates a `restaurants` record with `status = inactive` and `is_active = false`.
2. Creates a `users` record for the owner with `role = restaurant_owner` and `must_reset_password = true`.
3. Sends a welcome email to the owner with login credentials and a setup link.
4. Creates a default `loyalty_config` record with `is_active = false` (schema ready for Phase 2).
5. Sets `restaurants.features` to default values (see Section 6).

**Rule:** The restaurant is not visible to customers until both `restaurants.status = active` AND `restaurants.is_active = true`. The platform admin activates status; the owner controls the daily open/close toggle.

**API:**
```
POST /api/platform/restaurants
```

---

## 5. Module: Restaurant Management

**Route:** `/platform/restaurants`

Full visibility and control over all restaurants on the platform.

### Restaurant List Table

| Column | Source |
|---|---|
| Restaurant name | `restaurants.name` |
| Owner name + email | joined from `users` |
| City | `restaurants.city` |
| Status | `restaurants.status` (active / inactive / suspended) |
| Orders today | count from `orders` |
| Date onboarded | `restaurants.created_at` |
| Actions | View, Edit, Suspend, Activate |

### Restaurant Detail View

**Route:** `/platform/restaurants/:id`

Read-only profile + live stats:
- Profile: name, address, contact
- Orders today (count), this week's revenue
- Feature flags currently enabled (from `restaurants.features`)
- Staff count, Driver count, Active promotions count

### Suspend Restaurant

Sets `restaurants.status = suspended`. A suspended restaurant:
- Cannot accept new orders (enforced server-side on order creation endpoint)
- Cannot log in via the Owner Portal (JWT validation fails — backend checks `restaurants.status`)
- Sees a suspension notice on login attempt

**Suspension requires a mandatory reason** (free text, max 500 chars).

A suspended restaurant can be reinstated by the platform admin via the **Activate** action.

**Data model additions:**
```
restaurants.status             ENUM ('active', 'inactive', 'suspended')  DEFAULT 'inactive'
restaurants.suspension_reason  TEXT       NULLABLE
restaurants.suspended_at       TIMESTAMP  NULLABLE
restaurants.suspended_by       UUID       NULLABLE  ← platform_admin user id
```

**Critical distinction:** `restaurants.is_active` (owner-controlled daily open/close toggle) and `restaurants.status` (platform-level lifecycle) are **separate fields with separate purposes**. They must never be merged (Domain Invariant #6).

**APIs:**
```
GET    /api/platform/restaurants
GET    /api/platform/restaurants/:id
PATCH  /api/platform/restaurants/:id
POST   /api/platform/restaurants/:id/suspend
POST   /api/platform/restaurants/:id/activate
```

---

## 6. Module: Feature Flags

**Route:** `/platform/feature-flags`

Per-tenant feature control. The platform admin enables or disables features for individual restaurants.

### Simplified Feature Flag Model (MVP)

Feature flags are stored directly on the `restaurants` table as a `JSONB` column. This avoids premature infrastructure complexity. A dedicated `feature_flags` table system with global defaults and per-tenant overrides will be introduced post-MVP when the number of flags warrants it.

**Data model:**
```
restaurants.features  JSONB  NOT NULL  DEFAULT '{
  "loyalty_enabled":    false,
  "promotions_enabled": false,
  "delivery_enabled":   true,
  "pickup_enabled":     true,
  "analytics_enabled":  false
}'
```

### Defined Feature Keys (MVP)

| Key | Description | Default |
|---|---|---|
| `loyalty_enabled` | Restaurant can activate loyalty program | `false` |
| `promotions_enabled` | Restaurant can create discount codes | `false` |
| `delivery_enabled` | Restaurant accepts delivery orders | `true` |
| `pickup_enabled` | Restaurant accepts pickup orders | `true` |
| `analytics_enabled` | Analytics visible in Owner Portal | `false` |

**Rule for AI agents:** Feature flag keys must only be the values in this table. Do not add new keys without updating this section. Feature flag resolution is always server-side — frontend must never gate features on locally cached flag state alone.

### Feature Flag UI

A table with one row per restaurant. Each row shows the restaurant name and a toggle per feature key. Toggling calls `PATCH /api/platform/restaurants/:id/features`.

**APIs:**
```
GET    /api/platform/restaurants/:id/features
PATCH  /api/platform/restaurants/:id/features
```

---

## 7. Module: Platform Revenue Overview

**Route:** `/platform/analytics`

High-level financial visibility across all restaurants.

### Summary Cards

| Card | Metric |
|---|---|
| Total Orders Today | Count across all active restaurants, today |
| Total Platform Revenue Today | Sum of `orders.total_price` where `status = delivered`, today |
| Active Restaurants | Count of `restaurants.status = active` |
| New Restaurants This Month | Count of `restaurants.created_at` within current calendar month |

### Per-Restaurant Revenue Table

Current week performance, sorted by revenue descending:

| Column | Description |
|---|---|
| Restaurant name | — |
| Order count (week) | Excludes cancelled |
| Total revenue (week) | Delivered orders only |
| Average order value | Revenue ÷ order count |
| Status | `restaurants.status` |

**Caching rule:** These are cross-tenant aggregate queries. They must be cached server-side with a minimum 60-second TTL. Never run unbounded aggregate queries across all restaurants on every page load.

**APIs:**
```
GET /api/platform/analytics/summary
GET /api/platform/analytics/restaurants?period=week
```

---

## 8. Module: Impersonation & Audit

**Route:** `/platform/restaurants/:id/audit`

The platform admin can view a restaurant's Owner Portal in read-only mode for support or compliance purposes.

### Impersonation Rules (Strict)

- Impersonation generates a **short-lived read-only audit token** (TTL: 30 minutes) scoped to the target `restaurant_id`.
- The audit token grants **read access only**. All write endpoints (POST, PATCH, DELETE) must reject audit tokens with `403 Forbidden`.
- **Audit tokens must never grant access to payment endpoints** — this includes `GET /api/payments/*`, `POST /api/orders/:id/mark-paid`, and any endpoint returning payment method details, card metadata, or Stripe identifiers.
- Every impersonation session is logged: `platform_admin_id`, `target_restaurant_id`, `started_at`, `ended_at`.
- The Owner Portal must display a visible banner when loaded in audit mode: *"You are viewing this portal in read-only audit mode as Platform Admin."*

### Audit Token Auth

Audit sessions use a separate token passed as a request header:  
`X-Audit-Token: <token>`

The backend resolves `restaurant_id` from the `audit_sessions` record — the token itself does not embed `restaurant_id` in its payload (prevents forgery).

### Data Model

```
audit_sessions
  id                   UUID
  platform_admin_id    UUID       NOT NULL
  restaurant_id        UUID       NOT NULL
  token                TEXT       NOT NULL   ← bcrypt hashed
  expires_at           TIMESTAMP  NOT NULL
  started_at           TIMESTAMP  NOT NULL
  ended_at             TIMESTAMP  NULLABLE
```

**APIs:**
```
POST   /api/platform/restaurants/:id/audit-session    ← create audit token
DELETE /api/platform/restaurants/:id/audit-session    ← end session
GET    /api/platform/audit-log?restaurant_id=          ← view session history
```

---

## 9. Technical Placement

```
/apps
  /web              ← existing: Customer App + Restaurant Dashboard
  /owner-portal     ← Restaurant Owner Portal (separate PRD)
  /platform-admin   ← THIS APP
```

**Shared packages (may import):**
```
/packages/types     ← shared TypeScript interfaces including UserRole enum
/packages/config    ← shared ESLint, Prettier, TS configs
```

**Rule:** `/apps/platform-admin` must not import from `/apps/web` or `/apps/owner-portal`. Shared code belongs in `/packages` only.

---

## 10. Auth Architecture

**Login endpoint:** `POST /api/auth/platform/login`  
**Required role:** `platform_admin`  
**JWT storage:** `httpOnly` cookie via Next.js Route Handler. Never `localStorage`.

`platform_admin` JWTs contain no `restaurant_id`. Any endpoint that receives a `platform_admin` JWT and requires `restaurant_id` must reject it immediately.

---

## 11. API Contract

All requests include `Authorization: Bearer <jwt>`.  
All responses use the global envelope:
```json
{ "success": true, "data": { ... } }
{ "success": false, "data": null, "error": { "code": "...", "message": "..." } }
```

| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/auth/platform/login` | Platform admin login |
| POST | `/api/auth/platform/logout` | Invalidate session |
| POST | `/api/platform/restaurants` | Onboard new restaurant |
| GET | `/api/platform/restaurants` | List all restaurants |
| GET | `/api/platform/restaurants/:id` | Restaurant detail + stats |
| PATCH | `/api/platform/restaurants/:id` | Update restaurant profile |
| POST | `/api/platform/restaurants/:id/suspend` | Suspend restaurant |
| POST | `/api/platform/restaurants/:id/activate` | Activate restaurant |
| GET | `/api/platform/restaurants/:id/features` | Get feature flags |
| PATCH | `/api/platform/restaurants/:id/features` | Update feature flags |
| GET | `/api/platform/analytics/summary` | Platform-wide summary cards |
| GET | `/api/platform/analytics/restaurants?period=week` | Per-restaurant performance |
| POST | `/api/platform/restaurants/:id/audit-session` | Start audit session |
| DELETE | `/api/platform/restaurants/:id/audit-session` | End audit session |
| GET | `/api/platform/audit-log?restaurant_id=` | View audit log |

---

## 12. Screen & Route Map

```
/platform
  /platform/login
  /platform/dashboard                    ← platform-wide summary cards
  /platform/restaurants                  ← all restaurants list
  /platform/restaurants/new              ← onboard new restaurant
  /platform/restaurants/:id              ← restaurant detail + stats
  /platform/restaurants/:id/audit        ← read-only audit view of Owner Portal
  /platform/feature-flags                ← per-tenant feature flag toggles
  /platform/analytics                    ← platform revenue overview
```

**Redirect logic:**
- Unauthenticated access to any `/platform/*` → redirect to `/platform/login`
- Authenticated access to `/platform` → redirect to `/platform/dashboard`

---

## 13. Frontend Architecture Rules

### Component Structure

```
/apps/platform-admin/app/
  layout.tsx                        ← Auth guard, sidebar, header
  dashboard/
    page.tsx
  restaurants/
    page.tsx
    new/
      page.tsx
    [id]/
      page.tsx
      audit/
        page.tsx
    components/
      RestaurantTable.tsx
      OnboardingForm.tsx
      SuspendModal.tsx
      RestaurantDetailCard.tsx
  feature-flags/
    page.tsx
    components/
      FeatureFlagTable.tsx
      FeatureFlagToggle.tsx
  analytics/
    page.tsx
    components/
      PlatformKPICards.tsx
      RestaurantRevenueTable.tsx
  audit/
    components/
      AuditBanner.tsx               ← shown when viewing Owner Portal in audit mode
```

### React Query Keys (Strict — do not deviate)

```
['platform-restaurants']
['platform-restaurant', restaurantId]
['platform-restaurant-features', restaurantId]
['platform-analytics-summary']
['platform-analytics-restaurants']
['platform-audit-log', restaurantId]
```

### Rules

- No direct Supabase DB queries from the frontend. All data through Backend REST API.
- No business logic in UI components.
- Server state via React Query. Global UI state via Zustand.

---

## 14. Domain Invariants

These laws must never be violated. AI agents must not generate code that breaks them.

```
1.  platform_admin JWTs must be rejected by all restaurant-scoped API endpoints.
    Restaurant-scoped endpoints must reject any JWT where restaurant_id is absent,
    regardless of role claim.

2.  restaurants.is_active (owner-controlled daily open/close toggle) and
    restaurants.status (platform lifecycle: active/inactive/suspended) are
    separate fields with separate purposes. Never merge or conflate them.

3.  Audit sessions are strictly read-only. All write endpoints (POST, PATCH, DELETE)
    must reject audit tokens with 403 Forbidden.

4.  Audit tokens must never grant access to payment endpoints. This includes
    GET /api/payments/*, POST /api/orders/:id/mark-paid, and any endpoint
    returning payment method details, card metadata, or Stripe identifiers.

5.  Every audit session must be logged with platform_admin_id, restaurant_id,
    started_at, and ended_at. Unlogged impersonation is not permitted.

6.  Feature flags are resolved server-side only via FeatureFlagService reading
    from restaurants.features JSONB. Frontend must never gate features on
    locally cached state alone.

7.  The defined feature flag keys are the canonical list. No new keys may be
    added to restaurants.features without updating Section 6 of this document.

8.  All user roles must use the canonical UserRole enum defined in Section 2.
    No aliases, abbreviations, or alternate strings anywhere in the codebase.

9.  Suspension requires a mandatory reason stored in restaurants.suspension_reason.
    Suspensions without a reason must be rejected by the backend.

10. A restaurant with status = suspended must have its Owner Portal JWT
    invalidated. Backend auth middleware must check restaurants.status on
    every request from restaurant_owner and restaurant_staff JWTs.
```

---

## 15. Out of Scope

### Post-MVP (not yet specced)
- Platform billing / subscription management
- Restaurant self-registration / self-onboarding
- Multi-location management per tenant
- Platform-level promotions (cross-restaurant discount codes)
- Global feature flag defaults + per-tenant override table system (JSONB in MVP)
- Platform admin account management UI (seeded directly in DB for MVP)
- Bulk restaurant import
- SLA monitoring / uptime dashboards
- Platform audit log export (CSV)
- Role-based access tiers within `platform_admin` (single admin role in MVP)

---

*End of Platform Super-Admin Panel PRD*
