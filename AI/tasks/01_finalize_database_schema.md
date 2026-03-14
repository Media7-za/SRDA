# 1. Task Metadata

## Task Name
Finalize Database Schema

## File Path
`/ai/tasks/01_finalize_database_schema.md`

## Assigned Agent
- Architect Agent (schema design, ER diagram, relationship & deletion rules)
- Backend Agent (Prisma installation, initialization, client generation, migration execution)

## Priority
- Critical (blocking — all subsequent tasks depend on this)

## Status
- ✅ Complete

---

# 2. Objective

Define and freeze the **complete MVP database schema**. This task produces the Prisma schema file, the initial migration, an ER diagram, and the final table/relationship/index/deletion-policy definitions.

This is the single most important task in the project. Every major system — authentication, restaurants, menus, cart validation, orders, payments, delivery, analytics, and future multi-restaurant SaaS — depends on this schema. If it changes later, half the codebase must be refactored.

> **Freeze Policy:** The schema is frozen for MVP after this task completes. Changes are only permitted via explicit architecture review and update to `/ai/architecture.md`.

---

# 3. Business Context

The database is the foundation of the entire platform. Incorrect or incomplete schema design creates cascading rework across services, repositories, APIs, and frontend. By locking the schema before any implementation begins, all agents can build with confidence against a single, canonical data model.

**Why schema comes before auth:** Authentication depends on the `users` table, the `role` model, restaurant-admin relationships, and driver identity. The schema must exist first.

---

# 4. Required Context Files

The assigned agent must read these before doing any work:

- `/ai/context.md` — project overview, entities, tech stack
- `/ai/architecture.md` — §3 Module Ownership, §4 Commerce Rules, §5 State Machines, §3.10 Location Storage
- `/ai/agent_rules.md` — engineering rules, naming conventions
- `/ai/implementation_decisions.md` — payment modes, pay-in-store fields
- `/docs/PRD_Core.md` — §5 Core Database Schema, §8 Delivery Logic

If any required file is missing, stop and report the blocker.

---

# 5. Dependencies

- Task 00 (Project Scaffolding) — ✅ Complete
- `database/schema/` directory exists — ✅
- `pnpm` workspace functional — ✅

---

# 6. Scope

## Prisma Monorepo Ownership

Prisma schema and migrations live in `database/` as a **workspace package**. The Prisma Client is generated from `database/` and consumed by `backend/` via a workspace dependency.

```
database/                  ← workspace package: @restaurant-direct/database
  package.json             ← owns prisma + @prisma/client
  prisma/
    schema.prisma          ← schema source of truth
  migrations/              ← generated migration SQL
backend/
  package.json             ← depends on @restaurant-direct/database
```

This separation ensures:
- Schema ownership is isolated in `database/`
- `backend/` imports the generated Prisma Client without owning the schema
- Future services (e.g., analytics workers) can also depend on `database/`

**Import convention for backend:**
```typescript
import { prisma } from "@restaurant-direct/database/client";
```

This prevents Prisma from being accidentally installed inside `backend/`.

## Core Tables (≈ 14 tables)

| # | Table | Owner Module | Notes |
|---|-------|-------------|-------|
| 1 | `users` | Auth | `role` enum, `password_hash`, `email` (unique), `deleted_at` (nullable — soft delete) |
| 2 | `addresses` | Auth | Multiple per user, lat/lng for delivery distance |
| 3 | `restaurants` | Menu | Profile, opening hours, `is_active` |
| 4 | `menu_categories` | Menu | `restaurant_id`, `display_order` |
| 5 | `menu_items` | Menu | `restaurant_id`, `category_id`, price, `is_available` (soft delete via flag) |
| 6 | `menu_item_options` | Menu | Modifiers/extras per item, `restaurant_id` |
| 7 | `orders` | Order | `restaurant_id`, `order_type`, `payment_status`, snapshot totals, `delivery_distance_meters`, `delivery_fee_band`, `delivery_fee` |
| 8 | `order_items` | Order | **Snapshot:** `item_name`, `item_price`, `quantity`, `line_total` |
| 9 | `order_item_options` | Order | **Snapshot:** `option_name`, `option_price`, `source_menu_item_option_id` (nullable, analytics only) |
| 10 | `payments` | Payment | Canonical ledger (many-per-order). Stripe AND in-store. `provider`, `method`, `collected_by_user_id` |
| 11 | `drivers` | Delivery | **1:1 extension of `users`** via `user_id` (unique FK). Current location fields. |
| 12 | `deliveries` | Delivery | Links order to driver, delivery status, `restaurant_id` |
| 13 | `driver_locations` | Delivery | Append-only history, `delivery_id` (nullable) |
| 14 | `order_status_history` | Order | Audit trail: `order_id`, `status`, `changed_by` (nullable), `created_at` |

## Enums

| Enum | Values | Source |
|------|--------|--------|
| `UserRole` | `customer`, `staff`, `admin`, `driver` | architecture §3.1 |
| `OrderStatus` | `pending`, `confirmed`, `preparing`, `ready_for_pickup`, `out_for_delivery`, `delivered`, `cancelled` | architecture §5.1 |
| `OrderType` | `delivery`, `collection` | architecture §4.7 |
| `OrderPaymentStatus` | `unpaid`, `paid` | architecture §5.3 |
| `PaymentStatus` | `pending`, `processing`, `succeeded`, `failed`, `refunded` | architecture §5.2 (extended) |
| `PaymentProvider` | `stripe`, `in_store` | implementation_decisions §1 |
| `PaymentMethod` | `card_online`, `cash`, `card_in_store` | implementation_decisions §2 |
| `DeliveryStatus` | `unassigned`, `assigned`, `picked_up`, `on_the_way`, `delivered`, `failed` | architecture §3.9 |

## Critical Schema Rules

### Rule 1: Order Snapshots (Mandatory)
`order_items` and `order_item_options` must store the price and name at time of purchase. Historical orders must never change if menu prices change later.

Snapshot fields on `order_items`:
- `item_name` (copied from `menu_items.name`)
- `item_price` (copied from `menu_items.price`)
- `quantity`
- `line_total` (calculated: `item_price × quantity + option totals`)

Snapshot fields on `order_item_options`:
- `option_name` (copied from `menu_item_options.name`)
- `option_price` (copied from `menu_item_options.price`)
- `source_menu_item_option_id` (nullable) — optional back-reference for analytics/debugging only. **Must never be used to derive pricing.**

### Rule 2: `restaurant_id` Scoping (Mandatory)
Every business entity must include `restaurant_id` for future multi-restaurant SaaS support.

Entities **with** `restaurant_id`:
- `menu_categories`, `menu_items`, `menu_item_options`
- `orders`, `deliveries`

Entities **without** `restaurant_id`:
- `users` (platform-level identity)
- `addresses` (user-owned, not restaurant-scoped)
- `drivers` (platform-level, can serve multiple restaurants in future)
- `payments` (linked via `order_id`, which already has `restaurant_id`)

### Rule 3: Payments as a Ledger (One-to-Many)
The `payments` table is a **ledger** — multiple records per order are expected. This supports:
- Initial payment intent + final settlement (Stripe)
- Refunds as negative ledger entries
- Retry/failure records
- In-store collection as a separate record type

**Constraint:** Only one payment record per order may have `status = succeeded`. This is enforced at the application layer.

Fields for all payment records:
- `provider`: `stripe` | `in_store`
- `method`: `card_online` | `cash` | `card_in_store`
- `provider_payment_id`: nullable (null for in-store)
- `collected_by_user_id`: nullable (null for Stripe) — staff accountability
- `collected_at`: nullable (null for Stripe)

`orders.payment_status` remains a synchronized summary field (`unpaid` | `paid`).

### Rule 4: `drivers` as 1:1 Extension of `users`
A driver is always a `user` with `role = driver`. The `drivers` table extends the user record with delivery-specific fields:
- `drivers.user_id` → `users.id` (unique FK, 1:1)
- `drivers` holds: `vehicle_type`, `is_available`, current location fields
- Identity, auth, and contact info live on `users`

This avoids modeling driver identity in two places.

### Rule 5: Delivery Distance Snapshot on Orders
Each delivery order must store the delivery context at checkout time:
- `delivery_distance_meters` (Integer, nullable — null for collection orders)
- `delivery_fee_band` (String, nullable — e.g. "0-5km", "5-10km"; null for collection)
- `delivery_fee` (Decimal, nullable — the fee charged for this order; null for collection)

These are snapshot values — delivery fees must **never be recalculated for historical orders**.

### Rule 6: Delivery Support (Full Model)
Even if drivers are simple at MVP, include the full delivery model:
- `drivers` with current location fields (lat, lng, `location_recorded_at` — all nullable)
- `deliveries` linking orders to drivers
- `driver_locations` as append-only location history

## Relationships, Indexes & Constraints

### Deletion Policies

**Hard Delete Rules (FK ON DELETE):**

| Parent | Child | On Delete |
|--------|-------|-----------|
| `users` | `addresses` | `CASCADE` (user deleted → addresses deleted) |
| `users` | `orders` | `RESTRICT` (cannot delete user with orders) |
| `users` | `drivers` | `RESTRICT` (cannot delete user who is a driver) |
| `restaurants` | `menu_categories` | `CASCADE` |
| `restaurants` | `menu_items` | `CASCADE` |
| `restaurants` | `orders` | `RESTRICT` (cannot delete restaurant with orders) |
| `menu_categories` | `menu_items` | `SET NULL` (category deleted → items uncategorized) |
| `menu_items` | `menu_item_options` | `CASCADE` |
| `orders` | `order_items` | `CASCADE` |
| `orders` | `order_item_options` (via `order_items`) | `CASCADE` |
| `orders` | `payments` | `RESTRICT` (cannot delete order with payment records) |
| `orders` | `order_status_history` | `CASCADE` |
| `orders` | `deliveries` | `RESTRICT` |
| `drivers` | `deliveries` | `RESTRICT` (cannot delete driver with delivery history) |
| `drivers` | `driver_locations` | `CASCADE` |

**Soft Delete Rules (application-level):**

| Entity | Strategy | Field |
|--------|----------|-------|
| `users` | Soft delete | `deleted_at` (nullable timestamp) |
| `menu_items` | Availability flag | `is_available` (boolean) |
| `orders` | **Never deleted** | — |
| `payments` | **Never deleted** | — |
| `restaurants` | Availability flag | `is_active` (boolean) |

### Unique Constraints
- `users.email` — unique
- `drivers.user_id` — unique (enforces 1:1 with `users`)

### Indexes
- All foreign keys: `restaurant_id`, `user_id`, `order_id`, `driver_id`, `category_id`
- Composite: `driver_locations(driver_id, recorded_at)` — time-range queries
- Composite: `order_status_history(order_id, created_at)` — audit queries
- Partial index: `deliveries(driver_id) WHERE status IN ('assigned', 'picked_up', 'on_the_way')` — active delivery lookups for driver dashboards

## Out of Scope

- `promotions`, `order_promotions` — deferred (Growth phase)
- `loyalty_accounts`, `loyalty_transactions` — deferred (Growth phase)
- `reviews`, `ratings` — deferred (Growth phase)
- `carts` table — cart state is managed frontend-side for MVP; validated at checkout boundary
- `payment_intents` — tracked as a field on `payments`, not a separate table
- `sessions` table — managed by auth system (JWT, stateless for MVP)
- Seed data
- Repository or API implementation

---

# 7. Inputs

- PRD §5 — Core Database Schema (12-Table design)
- PRD §5 "Hidden Scaling Trick" — `order_status_history`
- Architecture §3 — Module Ownership & table boundaries
- Architecture §4 — Commerce Rules (snapshots, server-side pricing, `restaurant_id` requirement)
- Architecture §3.10 — Dual Location Model (current + history)
- Architecture §5 — State Machines (order, payment, delivery)
- Implementation Decisions §1–§2 — Fulfillment + payment modes, pay-in-store execution block

---

# 8. Required Outputs

| Deliverable | Location |
|-------------|----------|
| ER diagram (Mermaid) | Included in deliverable report or `/docs/er_diagram.md` |
| Final table definitions | `database/prisma/schema.prisma` |
| Relationships, FKs & deletion policies | Defined in Prisma schema |
| Indexes & constraints | Defined in Prisma schema |
| Initial migration SQL | `database/migrations/` (generated) |
| Prisma Client | Generated via `prisma generate` |
| `database/package.json` | New workspace package with `prisma` + `@prisma/client` |
| `backend/package.json` | Updated to depend on `@restaurant-direct/database` |

---

# 9. Acceptance Criteria

- [ ] `prisma validate` passes with no errors
- [ ] `prisma generate` produces a typed Prisma Client
- [ ] `prisma migrate dev` creates the initial migration successfully
- [ ] All 14 tables from the scope are present
- [ ] All 8 enums match canonical values
- [ ] `order_items` contains snapshot fields: `item_name`, `item_price`, `quantity`, `line_total`
- [ ] `order_item_options` contains snapshot fields: `option_name`, `option_price`, `source_menu_item_option_id` (nullable)
- [ ] `payments` is one-to-many with `orders` (ledger model, not 1:1)
- [ ] `payments` includes both Stripe and in-store fields
- [ ] `restaurant_id` present on correct entities; absent from `users`, `addresses`, `drivers`, `payments`
- [ ] `drivers.user_id` is a unique FK to `users.id` (1:1 extension)
- [ ] `drivers` has nullable current-location fields
- [ ] `driver_locations` has nullable `delivery_id`
- [ ] `order_status_history` exists with `order_id`, `status`, `changed_by` (nullable), `created_at`
- [ ] `orders` includes `delivery_distance_meters`, `delivery_fee_band`, and `delivery_fee` (all nullable)
- [ ] Only one payment per order may have `status = succeeded` (application-layer constraint)
- [ ] Soft delete patterns applied: `users.deleted_at`, `menu_items.is_available`, orders/payments never deleted
- [ ] Deletion policies are explicitly defined on all FKs per the rules table
- [ ] `users.email` has a unique constraint
- [ ] `drivers.user_id` has a unique constraint
- [ ] Foreign key indexes and composite indexes are defined
- [ ] ER diagram matches the Prisma schema
- [ ] Prisma schema lives in `database/` as workspace package `@restaurant-direct/database`

---

# 10. Implementation Rules

- PostgreSQL as the database provider
- UUIDs for all primary keys (`@id @default(uuid())`)
- `snake_case` for all table and column names (use `@@map` / `@map` if Prisma model names differ)
- Timestamps: `created_at` uses `@default(now())`, `updated_at` uses `@updatedAt` where applicable
- Strict typing — no `Json` field type; use explicit columns
- Single `schema.prisma` file for MVP simplicity
- Deletion policies must be explicit on every relation (no implicit Prisma defaults)
- Do not add tables, columns, or relationships not defined in approved context files
- Do not skip any field defined in the PRD or architecture

---

# 11. API / Data Contracts

Not applicable (schema-only task).

---

# 12. Edge Cases

- `menu_item_options` belong to a specific `menu_item` AND carry `restaurant_id` for multi-restaurant queries
- `order_item_options` store snapshotted data; `source_menu_item_option_id` is optional and must never be used for pricing
- `payments.provider_payment_id`: nullable (null for in-store payments)
- `payments.collected_by_user_id` and `collected_at`: nullable (null for Stripe payments)
- `payments`: multiple records per order (intent, settlement, refund) — ledger model
- `drivers` current location fields: all nullable (driver may not have reported yet)
- `driver_locations.delivery_id`: nullable (recorded outside active delivery)
- `order_status_history.changed_by`: nullable (system-triggered vs staff-triggered transitions)
- `orders` snapshot totals (`subtotal`, `delivery_fee`, `tax_amount`, `total_amount`) stored, not computed at read time
- `orders.delivery_distance_meters`, `delivery_fee_band`, `delivery_fee`: all nullable (null for collection orders)
- `menu_categories` deletion → `menu_items.category_id` set to null (items become uncategorized, not deleted)

---

# 13. Testing Requirements

**Unit Tests**
- Not applicable (schema definition, not logic)

**Validation Tests**
- `prisma validate` — schema compiles
- `prisma generate` — client generates
- `prisma migrate dev` — migration creates without error
- Manual review: ER diagram matches schema

**E2E Tests**
- Not applicable

---

# 14. Observability / Logging

- Log migration execution result
- No runtime logging (schema-only task)

---

# 15. Security / Permissions

- `password_hash` on `users` — never store plaintext passwords
- No API keys or secrets in the schema file
- `DATABASE_URL` must come from environment variable
- `collected_by_user_id` on `payments` enables staff accountability audit trails

---

# 16. Performance Requirements

- Index all foreign keys: `restaurant_id`, `user_id`, `order_id`, `driver_id`, `category_id`
- Unique constraint on `users.email`
- Unique constraint on `drivers.user_id`
- Composite index: `driver_locations(driver_id, recorded_at)`
- Composite index: `order_status_history(order_id, created_at)`
- Partial index: `deliveries(driver_id) WHERE status IN ('assigned', 'picked_up', 'on_the_way')`

---

# 17. Deliverable Format

**Summary**
Brief explanation of the schema, table count, and migration.

**ER Diagram**
Mermaid ER diagram showing all tables, relationships, and cardinality.

**Files Created or Updated**
List all files.

**Implementation Notes**
Key decisions: field types, deletion policies, 1:1 vs 1:N relationships, snapshot vs reference, Prisma workspace setup.

**Risks / Follow-ups**
Any deferred tables, naming decisions, or schema evolution concerns.

---

# 18. Completion Checklist

Before marking the task complete, verify:

- [ ] required context files were read
- [ ] dependencies were satisfied
- [ ] schema follows architecture rules (§3, §4, §5)
- [ ] schema follows implementation decisions (§1, §2)
- [ ] all 14 tables are defined
- [ ] all 8 enums are defined with canonical values
- [ ] snapshot fields present on `order_items` and `order_item_options`
- [ ] `restaurant_id` placement follows the rules (with stated exceptions)
- [ ] `drivers.user_id` is unique FK (1:1 with `users`)
- [ ] `payments` is one-to-many ledger
- [ ] deletion policies explicitly defined for all FKs
- [ ] delivery distance snapshot on `orders`
- [ ] ER diagram is produced
- [ ] `prisma validate` passes
- [ ] `prisma generate` succeeds
- [ ] `prisma migrate dev` creates migration
- [ ] Prisma lives in `database/` as `@restaurant-direct/database`
- [ ] `backend/` depends on `@restaurant-direct/database`
- [ ] no out-of-scope tables were added
- [ ] schema is production-ready

---

# 19. Agent Instruction

**Assigned Agent Instruction:**

Execute this task strictly according to:

- `/ai/context.md`
- `/ai/architecture.md`
- `/ai/agent_rules.md`
- `/ai/implementation_decisions.md`
- `/docs/PRD_Core.md`

Do not invent tables, columns, or relationships outside approved documents.

If blocked, report:
- blocker
- impact
- exact missing dependency

---
End of File
