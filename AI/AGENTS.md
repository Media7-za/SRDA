# AI Agent Context Router
**Platform:** Restaurant Direct  
**Rule:** Load every file listed for your task before writing any code. Loading partial context is not permitted. If a listed file is missing, stop and report it — do not proceed.

---

## Core Files (Always Load — Every Task, No Exceptions)

```
/AI/context.md
/AI/architecture.md
/AI/agent_rules.md
/AI/implementation_decisions.md
/AI/agents/database_agent.md
/Docs/PRD_Core.md
/Docs/domain_glossary.md
```

`PRD_Core.md` is the canonical source for product and domain intent across the platform. It defines intended entities, enums, lifecycle rules, payment rules, security rules, and cross-app invariants. Every agent on every surface loads it first.

`domain_glossary.md` is a quick-reference helper for canonical values. Before generating implementation code, agents must verify any schema-facing enum or field value against `database/prisma/schema.prisma` and migration history when implementation drift is possible.

---

## Schema Authority

Physical database schema is defined by:

- `/database/prisma/schema.prisma`
- `/database/prisma/migrations/`

`PRD_Core.md` defines intended product/domain model.
`AI/architecture.md` defines architecture boundaries, ownership rules, state-machine vocabulary, and system patterns.

If there is a mismatch:

- Prisma = implementation truth
- PRD = intended behavior
- Architecture = module boundaries, ownership rules, and canonical state-machine vocabulary
- The gap must be explicitly resolved

---

## Working on the Customer App?

```
/Docs/PRD_Core.md          ← already loaded above
/Docs/PRD_Customer_App.md
/Docs/platform/design_tokens.md
/Docs/tenants/phuket_thai/design_tokens.md
/Docs/component_architecture.md
/Docs/ui_conformance_rules.md
/Docs/screens/customer_app.md
```

> Covers: menu browsing UX, cart behaviour, checkout flow, order tracking display, first-time onboarding, saved addresses, customer metrics.  
> App: `apps/web` (customer-facing routes).  
> `PRD_Customer_App.md` references Core rules — it does not redefine them.

---

## Working on the Restaurant Dashboard?

```
/Docs/PRD_Core.md          ← already loaded above
/Docs/PRD_Dashboard.md
/Docs/platform/design_tokens.md
/Docs/tenants/phuket_thai/design_tokens.md
/Docs/component_architecture.md
/Docs/ui_conformance_rules.md
/Docs/screens/dashboard.md
```

> Covers: live order feed, swimlane layout, order + delivery state machines, driver assignment, concurrency protection, realtime architecture, cancellation policy.  
> App: `apps/web` (dashboard routes).

---

## Working on the Restaurant Owner Portal?

```
/Docs/PRD_Core.md          ← already loaded above
/Docs/PRD_Owner_Portal.md
/Docs/platform/design_tokens.md
/Docs/tenants/phuket_thai/design_tokens.md
/Docs/component_architecture.md
/Docs/ui_conformance_rules.md
/Docs/screens/owner_portal.md
```

> Covers: restaurant settings, opening hours, menu management (categories, items, modifiers), staff accounts, driver management. Phase 2: promotions, loyalty, analytics.  
> App: `apps/owner-portal`.

---

## Working on the Platform Super-Admin Panel?

```
/Docs/PRD_Core.md          ← already loaded above
/Docs/PRD_Platform_Admin.md
/Docs/platform/design_tokens.md
/Docs/component_architecture.md
/Docs/ui_conformance_rules.md
/Docs/screens/platform_admin.md
```

> Covers: restaurant onboarding, suspend/activate, feature flags, platform revenue overview, impersonation and audit sessions.  
> App: `apps/platform-admin`.

---

## Working on the Driver App?

```
/Docs/PRD_Core.md          ← already loaded above
/Docs/PRD_Driver.md
/Docs/platform/design_tokens.md
/Docs/tenants/phuket_thai/design_tokens.md
/Docs/component_architecture.md
/Docs/ui_conformance_rules.md
/Docs/screens/driver_app.md
```

> Covers: Flutter driver app, delivery state transitions (driver-owned only), GPS location posting, FCM push notifications, offline handling, earnings (tenant-gated).  
> App: `food-delivery-mobile/` (separate Flutter repository).

---

## Working on the Database / Schema?

```
/Docs/PRD_Core.md          ← already loaded above
/Docs/audits/schema_drift_report.md
/Docs/audits/schema_migration_plan.md
/Docs/audits/schema_patch_1.md
```

> See **Schema Authority** above. `PRD_Core.md` is the intended domain model; Prisma + migrations are implementation truth. Audit docs (e.g. drift reports) describe gaps to reconcile — they are not a second schema source.

---

## Need a Quick Enum or Status Lookup?

```
/Docs/domain_glossary.md
```

> Canonical values for enums, statuses, feature flag keys, and key terms. Quick reference only — use `database/prisma/schema.prisma` for implemented schema values, `PRD_Core.md` for intended domain meaning, and `AI/architecture.md` for architectural vocabulary/state-machine rules.

---

## Working on UI, styling, Tailwind theme, components, or frontend UX?

```
/Docs/platform/design_tokens.md
/Docs/tenants/phuket_thai/design_tokens.md
/Docs/component_architecture.md
/Docs/ui_conformance_rules.md
/Docs/screens/customer_app.md
/Docs/screens/dashboard.md
/Docs/screens/owner_portal.md
/Docs/screens/platform_admin.md
/Docs/screens/driver_app.md
```

> Ensures all agents use canonical spacing, typography, colors, and motion exactly as defined in the design token mapping, completely bounding their work in the UI Conformance constraints so they pass AI QA.

---

## Rules

1. `PRD_Core.md` is loaded by every agent. No exceptions.
2. Surface PRDs reference Core rules — they do not redefine them. If a surface PRD appears to contradict `PRD_Core.md`, `PRD_Core.md` wins. Flag the conflict rather than silently picking one.
3. `Docs/legacy/Restaurant_Direct_PRD_LEGACY.md` and any older consolidated PRD drafts are superseded and retired. Do not load them.
4. All file paths are case-sensitive. Use the exact on-disk paths in this repository (for example `/AI/...` and `/Docs/...`).
5. If a required PRD file does not exist, stop and report the missing file. Do not infer requirements.
6. For `UserRole` and other schema-facing enums, use `database/prisma/schema.prisma` as implementation truth. `Docs/PRD_Core.md` defines intended values; if they diverge, flag the gap instead of inventing a third source.
7. `Docs/domain_glossary.md` is a convenience reference only. Verify schema-facing values against Prisma and intended meanings against `Docs/PRD_Core.md`.
8. `AI/architecture.md` is authoritative for module boundaries, ownership rules, and state-machine vocabulary. It is not a substitute for current physical table/column definitions in Prisma.
9. Owner/admin requirements live in `Docs/PRD_Owner_Portal.md` and `Docs/PRD_Platform_Admin.md`. Do not use older combined admin drafts if they appear elsewhere.