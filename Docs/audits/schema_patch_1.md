# Schema Patch 1 Audit

## 1. Scope

This audit covers:

- `database/prisma/migrations/20260308162610_patch1_mvp_schema_alignment/migration.sql`
- resulting implemented structure in `database/prisma/schema.prisma`
- drift context from `Docs/audits/schema_drift_report.md`

Patch 1 performs broad schema alignment, including:

- enum/value alignment (`UserRole`, `FulfillmentType`)
- naming alignment (`order_type` to `fulfillment_type`)
- column additions across users/restaurants/orders/deliveries/drivers
- modifier model restructuring (flat options to grouped modifiers)
- supporting operational tables (`driver_devices`, `driver_earnings_config`)
- supporting indexes for dashboard/admin query patterns

---

## 2. Why Patch 1 Exists

Patch 1 exists because the repository had PRD-vs-implementation drift:

- role and fulfillment enum mismatches
- missing fields needed by dashboard/owner/driver flows
- missing grouped modifier model
- missing indexes for expected query paths

Patch 1 addresses a large subset of those gaps. As a result, `Docs/audits/schema_drift_report.md` should not be treated as fully current after patch1.

---

## 3. Changes Included

### Users / Roles

- Replaces legacy role enum values with:
  - `platform_admin`, `restaurant_owner`, `restaurant_staff`, `driver`, `customer`
- Adds:
  - `users.is_active`
  - `users.manager_pin`
  - `users.must_reset_password`
  - `users.restaurant_id`
- Adds index:
  - `users_restaurant_id_role_idx`

### Restaurants

- Adds:
  - `default_ready_time_minutes`
  - `features` (JSONB)
  - `logo_url`
  - `status`
  - `suspension_reason`
  - `suspended_at`
  - `suspended_by`
- Replaces:
  - `opening_hours` with `JSONB NOT NULL`
- Adds index:
  - `restaurants_status_idx`

### Orders

- Replaces:
  - `order_type` with enum `fulfillment_type` (`delivery`, `pickup`)
- Adds:
  - `version`
  - `special_instructions`
  - `cancellation_reason`
  - `cancelled_by_user_id`
  - `cancelled_at`
- Adds index:
  - `orders_id_version_idx`

### Deliveries

- Adds:
  - `failure_reason`

### Drivers / Driver Locations

- Drivers:
  - drops `current_latitude`, `current_longitude`, `location_recorded_at`
  - adds `last_location_at`, `latitude`, `longitude`, `restaurant_id` (NOT NULL)
- Driver locations:
  - drops `recorded_at`
  - adds `accuracy`
  - adds `timestamp` (default current timestamp)
- Adds/replaces indexes:
  - `drivers_restaurant_id_is_available_idx`
  - `driver_locations_driver_id_timestamp_idx`

### Modifiers

- Drops legacy `menu_item_options`
- Creates:
  - `menu_modifier_groups`
  - `menu_modifier_options`
- Rewires `order_item_options.source_menu_item_option_id` to `source_modifier_option_id`
- Adds supporting indexes and foreign keys

### Supporting tables

- Creates:
  - `driver_devices`
  - `driver_earnings_config`

### Enums

- Creates `FulfillmentType`
- Replaces `UserRole` enum through swap (`UserRole_new` -> `UserRole`)
- Drops legacy `OrderType`

---

## 4. Safety Assessment

**This migration can cause data loss if applied directly to non-empty databases.**

**Classification: conditionally safe.**

It is not production-safe as a one-shot apply on non-empty databases.

Why:

1. Destructive operations are present:
   - `DROP TABLE "menu_item_options"`
   - `DROP TYPE "OrderType"`
   - multiple `DROP COLUMN` operations
2. Potentially lossy column replacement:
   - `restaurants.opening_hours` is dropped and recreated as `JSONB NOT NULL` without conversion/backfill SQL in the same migration
3. Risky NOT NULL addition:
   - `drivers.restaurant_id TEXT NOT NULL` is added without explicit backfill in the migration
4. Type conversion assumptions:
   - `users.role` cast to new enum values assumes all existing values convert cleanly
5. Rename vs recreate risk:
   - Prisma migrations may not always detect renames and can emit drop/recreate operations instead, which can cause unintended data loss
6. Backfill-before-constraint rule:
   - No NOT NULL constraint should be applied before data backfill is complete and validated

Result:

- suitable for new/empty or tightly controlled development environments
- requires phased strategy for production data

---

## 5. Required Production Strategy

Patch1 should be executed as phased migrations:

### Expand

- add new nullable columns, new tables, new indexes, and new enum structures
- avoid immediate drops of old structures in this phase

### Backfill

- map legacy values into new fields/types
- convert `opening_hours` legacy shape into JSONB
- populate `drivers.restaurant_id` for existing rows
- migrate modifier references to new group/option tables

### Validate

- verify row counts, foreign key integrity, enum values, and nullability assumptions
- verify app reads/writes both old/new paths during transition if dual-write is used

### Contract

- drop old columns/tables/enums only after backfill + validation pass

---

## 6. Preconditions

Before applying patch1 to production-like environments:

- backup/snapshot exists and restore is tested
- live values have been audited (`users.role`, `orders.order_type`, etc.)
- app compatibility with new schema is confirmed
- migration SQL manually reviewed for destructive operations
- rollout window and rollback plan approved

---

## 7. Validation Checklist

After application (or per phase):

- [ ] schema matches expected patch1 models/fields in `database/prisma/schema.prisma`
- [ ] data is preserved for impacted tables
- [ ] enum values are valid (`UserRole`, `FulfillmentType`)
- [ ] `orders.fulfillment_type` is populated for live rows
- [ ] `drivers.restaurant_id` is populated and valid
- [ ] no orphaned references from modifier migration
- [ ] expected indexes exist:
  - `orders_id_version_idx`
  - `drivers_restaurant_id_is_available_idx`
  - `restaurants_status_idx`
  - `users_restaurant_id_role_idx`
  - `driver_locations_driver_id_timestamp_idx`
- [ ] order, delivery, and dashboard-related write paths still succeed
- [ ] if outbox migration is also applied, function/trigger behavior is validated separately

---

## 8. Recommendation

- approved for local/dev usage
- approved for new/empty environments
- **not approved for production as written on non-empty datasets**
- approved for production only if split into phased migrations (`expand -> backfill -> validate -> contract`) with explicit conversion SQL and tested rollback readiness
