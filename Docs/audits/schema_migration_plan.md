# Schema Migration Plan

## 1. Purpose

This document defines the safe execution order for reconciling PRD/domain intent with the Prisma/Postgres implementation in this repository.

It is the operational runbook for rolling schema changes without accidental data loss.

---

## 2. Current Authority Model

Current authority chain for schema decisions:

- physical schema truth = `database/prisma/schema.prisma`
- applied history = `database/prisma/migrations/*`
- product/domain intent = `Docs/PRD_Core.md`
- drift analysis reference = `Docs/audits/schema_drift_report.md`

`Docs/audits/schema_drift_report.md` is a point-in-time audit reference. It is not canonical schema truth.

---

## 3. Current State Summary

Repo-specific status:

- `database/prisma/migrations/20260308162610_patch1_mvp_schema_alignment/migration.sql` addresses many drift items previously listed in `Docs/audits/schema_drift_report.md`.
- `database/prisma/migrations/20260308190532_board_events_outbox/migration.sql` adds realtime board outbox structures (table, function, triggers), but also contains destructive reset SQL.
- `database/prisma/schema.prisma` now includes `FulfillmentType`, canonical `UserRole` values, modifier group/option tables, `driver_devices`, `driver_earnings_config`, and `board_events`.
- Some PRD-described entities are still absent from Prisma (for example promotions/loyalty and audit sessions).
- `Docs/PRD_Core.md` represents intended domain model, but does not exactly match implemented schema details.

---

## 4. Production Safety Rule

Destructive SQL is not production-safe without explicit review and approval.

Any migration containing operations such as:

- `TRUNCATE ... CASCADE`
- lossy rewrites or drop/recreate transforms
- table recreation
- unsafe enum replacement

must be treated as unsafe for direct production apply.

Preferred production sequence:

`expand -> backfill -> validate -> contract`

---

## 5. Migration Inventory

| Migration Path | Purpose | Risk Level | Production-safe as written? | Notes |
|---|---|---|---|---|
| `database/prisma/migrations/20260307160529_init/migration.sql` | Initial baseline schema | Medium | Conditional | Intended baseline for new environments; production safety depends on environment state and data migration requirements. |
| `database/prisma/migrations/20260308162610_patch1_mvp_schema_alignment/migration.sql` | Align schema with PRD/domain naming and operational fields | High | Conditional | No table-wide truncate, but includes destructive operations (`DROP TABLE`, `DROP TYPE`, multiple `DROP COLUMN`s, NOT NULL additions) that require phased rollout on non-empty DBs. |
| `database/prisma/migrations/20260308190532_board_events_outbox/migration.sql` | Adds board events outbox table/function/triggers | Critical | No | Includes `TRUNCATE ... CASCADE` across core tables plus broad schema rewrite statements; not safe for production as written. |

---

## 6. Prechecks

Before applying migrations to non-empty databases:

1. Verify a fresh backup/snapshot exists and restore is tested.
2. Verify migration status/head is known in target DB.
3. Inspect live enum values before enum changes:

```sql
SELECT DISTINCT role FROM users ORDER BY role;
SELECT DISTINCT order_type FROM orders ORDER BY order_type;
```

4. Inspect row counts for impacted tables:

```sql
SELECT 'users' AS table_name, count(*) FROM users
UNION ALL SELECT 'orders', count(*) FROM orders
UNION ALL SELECT 'order_items', count(*) FROM order_items
UNION ALL SELECT 'order_item_options', count(*) FROM order_item_options
UNION ALL SELECT 'deliveries', count(*) FROM deliveries
UNION ALL SELECT 'drivers', count(*) FROM drivers
UNION ALL SELECT 'restaurants', count(*) FROM restaurants;
```

5. Confirm no destructive SQL runs unintentionally (`TRUNCATE`, `DROP TABLE`, `DROP COLUMN`, `DROP TYPE`, `CASCADE`).
6. Confirm application code is compatible with expanded schema before rollout.
7. Confirm outbox dependencies/permissions for function + triggers where applicable.

---

## 7. Safe Execution Sequence

1. Review target schema (`database/prisma/schema.prisma`) vs current live schema.
2. Classify each migration as safe/unsafe/conditional before apply.
3. Apply additive changes first (new nullable columns, new tables, new indexes).
4. Backfill data for new fields and new enum mappings.
5. Deploy code that reads/writes new fields.
6. Validate data integrity, nullability, and query/index behavior.
7. Only then remove/contract obsolete columns, tables, or enums.

For this repo:

- treat patch alignment work as multi-phase in production;
- keep outbox rollout separated from destructive schema resets.

---

## 8. Verification Queries

### 8.1 Enum/value validation

```sql
SELECT enumlabel
FROM pg_enum e
JOIN pg_type t ON t.oid = e.enumtypid
WHERE t.typname = 'UserRole'
ORDER BY enumsortorder;

SELECT enumlabel
FROM pg_enum e
JOIN pg_type t ON t.oid = e.enumtypid
WHERE t.typname = 'FulfillmentType'
ORDER BY enumsortorder;
```

### 8.2 Non-null/backfill validation

```sql
SELECT count(*) AS missing_fulfillment_type
FROM orders
WHERE fulfillment_type IS NULL;

SELECT count(*) AS missing_opening_hours
FROM restaurants
WHERE opening_hours IS NULL;
```

### 8.3 Index presence

```sql
SELECT indexname
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname IN (
    'orders_id_version_idx',
    'drivers_restaurant_id_is_available_idx',
    'restaurants_status_idx',
    'users_restaurant_id_role_idx',
    'board_events_restaurant_id_occurred_at_idx'
  )
ORDER BY indexname;
```

### 8.4 Trigger/function presence for outbox

```sql
SELECT proname
FROM pg_proc
WHERE proname = 'emit_order_board_event';

SELECT tgname, tgrelid::regclass AS table_name
FROM pg_trigger
WHERE tgname IN (
  'emit_order_board_event_orders_trigger',
  'emit_order_board_event_deliveries_trigger'
)
ORDER BY tgname;
```

### 8.5 Board events insert behavior

```sql
SELECT id, event, order_id, occurred_at
FROM board_events
ORDER BY occurred_at DESC
LIMIT 10;
```

Expected: rows are emitted after order/delivery inserts or updates.

---

## 9. Rollback Guidance

Schema rollback is not always symmetrical.

- For destructive failures, preferred rollback path is restore-from-backup.
- For additive migrations, disable new code paths first, then roll forward with corrective SQL/migration.
- Outbox function/triggers can be rolled back independently if needed, but application behavior must tolerate missing outbox emission.

---

## 10. Open Gaps / Follow-ups

Based on current repo evidence:

1. PRD-described entities absent from Prisma:
   - `promotions`, `order_promotions`, `loyalty_accounts`, `loyalty_transactions` (from `Docs/PRD_Core.md`)
   - `audit_sessions` (from `Docs/audits/schema_drift_report.md`)
2. Drift report is partially stale and should be refreshed to distinguish resolved vs unresolved items.
3. `20260308190532_board_events_outbox/migration.sql` needs decomposition for production-safe rollout (separate additive outbox work from destructive reset SQL).
4. Patch1 operations should be staged for non-empty production databases using expand/backfill/validate/contract phases.
