# Schema Drift Report

> **Status:** Point-in-time audit. This file compares PRD intent to an earlier Prisma state and is not canonical schema truth.
>
> Some findings below have already been addressed by later migrations, especially `database/prisma/migrations/20260308162610_patch1_mvp_schema_alignment/migration.sql`.
>
> For current implementation truth, check:
>
> - `database/prisma/schema.prisma`
> - `database/prisma/migrations/*`
> - `Docs/audits/schema_migration_plan.md`
> - `Docs/audits/schema_patch_1.md`

## Status After Patch 1

Based on checked-in Prisma schema and migration history:

- **Resolved by patch1:** `driver_devices`, `driver_earnings_config`, `menu_modifier_groups`, `menu_modifier_options`, `orders.fulfillment_type`, `orders.special_instructions`, `orders.version`, cancellation fields on `orders`, restaurant operational/profile fields, `users.is_active`, `users.must_reset_password`, `users.manager_pin`, `deliveries.failure_reason`, driver latest-location naming alignment, and the listed supporting indexes.
- **Still open from repo evidence:** `audit_sessions`, `promotions`, `order_promotions`, `loyalty_accounts`, `loyalty_transactions`, and `loyalty_config` are still absent from `database/prisma/schema.prisma`.

---

## 1. Tables Missing From Schema
The following tables are mandated by the PRDs but are completely missing from the existing Prisma schema:

```text
driver_devices            (Driver App PRD - FCM token management)
driver_earnings_config    (Driver App PRD - per-delivery flat fee)
audit_sessions            (Platform Admin PRD - impersonation tracking)
menu_modifier_groups      (Owner Portal PRD - required modifier taxonomy)
menu_modifier_options     (Owner Portal PRD - replaces flat MenuItemOption)
promotions                (PRD_Core.md & Owner Portal Phase 2)
order_promotions          (PRD_Core.md & Owner Portal Phase 2)
loyalty_accounts          (PRD_Core.md & Owner Portal Phase 2)
loyalty_transactions      (PRD_Core.md & Owner Portal Phase 2)
loyalty_config            (Owner Portal Phase 2)
```

---

## 2. Missing Columns
The following data points are required to power state transitions and UI logic, but are missing:

**`orders` table:**
```text
orders.fulfillment_type          (Enum: 'pickup', 'delivery' required by Dashboard PRD)
orders.special_instructions      (Required by Driver App PRD)
orders.version                   (Required by Dashboard PRD for optimistic locking)
orders.cancellation_reason       (Required by Dashboard PRD cancel flow)
orders.cancelled_by_user_id      (Required by Dashboard PRD)
orders.cancelled_at              (Required by Dashboard PRD)
```

**`restaurants` table:**
```text
restaurants.default_ready_time_minutes  (Owner Portal PRD)
restaurants.logo_url                    (Owner Portal PRD - Profile settings)
restaurants.status                      (Platform Admin PRD - active/inactive/suspended)
restaurants.suspension_reason           (Platform Admin PRD)
restaurants.suspended_at                (Platform Admin PRD)
restaurants.suspended_by                (Platform Admin PRD)
restaurants.features                    (Platform Admin PRD - JSONB feature flags)
```

**`users` table:**
```text
users.is_active                  (Owner Portal PRD - Deactivate staff)
users.must_reset_password        (Owner Portal PRD)
users.manager_pin                (Dashboard PRD - Hashed PIN to approve cancellations)
```

**`deliveries` table:**
```text
deliveries.failure_reason        (Dashboard PRD - Mandated when 'Mark Failed' is clicked)
```

**`drivers` table:**
```text
drivers.last_location_at         (Mismatch: schema calls this `locationRecordedAt`)
```

---

## 3. Type Mismatches
```text
UserRole Enum               Schema uses: customer, staff, admin, driver. 
                            Canonical PRD values are: platform_admin, restaurant_owner, restaurant_staff, driver, customer.

OrderType Enum              Schema uses `delivery` and `collection`.
                            Dashboard PRD mandates `pickup` and `delivery`.

restaurants.opening_hours   Schema uses `String?` ("Structured text, not Json"). 
                            Owner Portal PRD strictly mandates `JSONB`.
```

---

## 4. Relationship Problems
```text
menu_items hierarchy              Schema maps menu_items directly to MenuItemOption. Owner Portal PRD mandates a grouping layer: menu_items → menu_modifier_groups → menu_modifier_options.

orders.cancelled_by_user_id       Missing completely, severing the audit trail for who cancelled an order.

deliveries → failure tracking     Missing failure_reason restricts the ability to trace why the Restaurant Dashboard marked the Delivery as failed.
```

---

## 5. Missing Indices
Required indices based on lookup efficiency required by the UIs:

```text
orders(id, version)               Required to efficiently process the Dashboard PRD optimistic UI concurrency check.
drivers(restaurant_id, is_available)  Required by the Dashboard PRD to quickly fetch available drivers for the Assignment Modal.
restaurants(status)               Required by the Platform Admin PRD to filter active vs suspended tenants.
users(restaurant_id, role)        Required by Owner Portal PRD to fetch staff rapidly.
```

---

## 6. Projection Risks
```text
Order summary compilation         Dashboard PRD displays a concise item summary (e.g. "2x Burger (+Cheese)"). To project this without a stored `order_summary_text` field in the `orders` table, the API must perform a deep join (`orders` → `order_items` → `order_item_options`) on every Realtime payload update, creating high serialization overhead.

Top-N items calculation           Requires joining `orders` and `order_items` and aggregating by item ID, filtered by date and `orders.status = delivered`. Without a materialized view or background aggregation table, this scales poorly.
```

---

## 7. API Contract Risks
```text
PATCH /api/orders/:id/status      The contract demands optimistic concurrency checking (`version` expected in body). Without `orders.version`, DB overwrites will occur across identical order cards open on multiple staff tablets.

POST /api/orders/:id/cancel       Requires `manager_pin` validation to cancel `confirmed` orders. Missing `manager_pin` in the DB means this cannot be verified server-side.

GET /api/menu/categories          Owner Portal expects grouped modifiers. Flat `MenuItemOption` schema will cause the frontend configuration UI to fail entirely.
```

---

## 8. Domain Conflicts Between PRDs
```text
JSONB vs String Requirement       Schema comment explicitly dictates: "openingHours String? // Structured text, not Json". However, Owner Portal PRD states: "Type is JSONB not JSON. This is a hard requirement." 

Phase 2 vs Core Schema Migration  Owner Portal PRD states Promotions/Loyalty are "Phase 2". However, the foundational `PRD_Core.md` explicitly demands `promotions`, `loyalty_accounts` and `loyalty_transactions` be part of the initial "12-table core schema" built immediately to prevent redesign.

Collection vs Pickup              The schema uses the term `collection` internally, while the canonical UI PRDs reference `pickup` for all API variables and `fulfillment_type`.

Naming convention on timestamps   Driver App PRD dictates updating `last_location_at`. The schema created `locationRecordedAt` which mismatches the expected application entity mapping.
```

---

## 9. Recommended Schema Patch
To quickly map the backend to the five PRDs using minimal, non-breaking SQL / Prisma changes:

```prisma
1. Refactor Enum:
   Rename `collection` to `pickup` in `OrderType` (or change Enum name to `FulfillmentType`).
   Replace `UserRole` values with canonical identifiers (`restaurant_owner`, `platform_admin`, etc.).

2. Add Missing Tables:
   - `DriverDevice` (fcm_token, platform)
   - `DriverEarningsConfig`
   - `AuditSession`
   - `MenuModifierGroup` (and migrate `MenuItemOption` to act as `MenuModifierOption` with relationships to the group table)
   - Promos + Loyalty (`Promotion`, `OrderPromotion`, `LoyaltyAccount`, `LoyaltyTransaction`, `LoyaltyConfig`)

3. Add Columns on `Order`:
   - `version Int @default(1)`
   - `specialInstructions String?`
   - `cancellationReason String?`
   - `cancelledById String?`
   - `cancelledAt DateTime?`

4. Adjust `Restaurant` Fields:
   - Change `openingHours` to `Json?`
   - Add `status String @default("inactive")` (or an enum)
   - Add `features Json`
   - Add `defaultReadyTimeMinutes Int @default(20)`
   - Add `logoUrl String?`

5. Adjust `User` Fields:
   - `isActive Boolean @default(true)`
   - `mustResetPassword Boolean @default(false)`
   - `managerPin String?`

6. Adjust `Delivery` Fields:
   - Add `failureReason String?`

7. Generate new compound Indices as specified.
```
