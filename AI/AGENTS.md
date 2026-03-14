# AI Agent Context Router
**Platform:** Restaurant Direct  
**Rule:** Load every file listed for your task before writing any code. Loading partial context is not permitted. If a listed file is missing, stop and report it — do not proceed.

---

## Core Files (Always Load — Every Task, No Exceptions)

```
/ai/context.md
/ai/architecture.md
/ai/agent_rules.md
/ai/implementation_decisions.md
/ai/agents/database_agent.md
/docs/PRD_Core.md
/docs/domain_glossary.md
```

`PRD_Core.md` is the canonical operating model for the entire platform. It defines the schema, all enums, order lifecycle, payment rules, security rules, and cross-app invariants. Every agent on every surface loads it first.

`domain_glossary.md` provides machine-readable canonical value arrays for every enum and a `RetiredValues` block. Agents use these blocks directly when generating enums, validation arrays, switch statements, or type definitions — never reconstruct values from memory.

---

## Working on the Customer App?

```
/docs/PRD_Core.md          ← already loaded above
/docs/PRD_Customer_App.md
/docs/platform/design_tokens.md
/docs/tenants/phuket_thai/design_tokens.md
/docs/component_architecture.md
/docs/ui_conformance_rules.md
/docs/screens/customer_app.md
```

> Covers: menu browsing UX, cart behaviour, checkout flow, order tracking display, first-time onboarding, saved addresses, customer metrics.  
> App: `apps/web` (customer-facing routes).  
> `PRD_Customer_App.md` references Core rules — it does not redefine them.

---

## Working on the Restaurant Dashboard?

```
/docs/PRD_Core.md          ← already loaded above
/docs/PRD_Dashboard.md
/docs/platform/design_tokens.md
/docs/tenants/phuket_thai/design_tokens.md
/docs/component_architecture.md
/docs/ui_conformance_rules.md
/docs/screens/dashboard.md
```

> Covers: live order feed, swimlane layout, order + delivery state machines, driver assignment, concurrency protection, realtime architecture, cancellation policy.  
> App: `apps/web` (dashboard routes).

---

## Working on the Restaurant Owner Portal?

```
/docs/PRD_Core.md          ← already loaded above
/docs/PRD_Owner_Portal.md
/docs/platform/design_tokens.md
/docs/tenants/phuket_thai/design_tokens.md
/docs/component_architecture.md
/docs/ui_conformance_rules.md
/docs/screens/owner_portal.md
```

> Covers: restaurant settings, opening hours, menu management (categories, items, modifiers), staff accounts, driver management. Phase 2: promotions, loyalty, analytics.  
> App: `apps/owner-portal`.

---

## Working on the Platform Super-Admin Panel?

```
/docs/PRD_Core.md          ← already loaded above
/docs/PRD_Platform_Admin.md
/docs/platform/design_tokens.md
/docs/component_architecture.md
/docs/ui_conformance_rules.md
/docs/screens/platform_admin.md
```

> Covers: restaurant onboarding, suspend/activate, feature flags, platform revenue overview, impersonation and audit sessions.  
> App: `apps/platform-admin`.

---

## Working on the Driver App?

```
/docs/PRD_Core.md          ← already loaded above
/docs/PRD_Driver.md
/docs/platform/design_tokens.md
/docs/tenants/phuket_thai/design_tokens.md
/docs/component_architecture.md
/docs/ui_conformance_rules.md
/docs/screens/driver_app.md
```

> Covers: Flutter driver app, delivery state transitions (driver-owned only), GPS location posting, FCM push notifications, offline handling, earnings (tenant-gated).  
> App: `food-delivery-mobile/` (separate Flutter repository).

---

## Working on the Database / Schema?

```
/docs/PRD_Core.md          ← already loaded above
/docs/audits/schema_drift_report.md
/docs/audits/schema_migration_plan.md
/docs/audits/schema_patch_1.md
```

> PRD_Core.md contains the canonical 15-table schema. Migration files contain the patch sequence and execution order.

---

## Need a Quick Enum or Status Lookup?

```
/docs/domain_glossary.md
```

> Canonical values for all enums, statuses, feature flag keys, and key terms. Quick reference — `PRD_Core.md` is authoritative if any conflict exists.

---

## Working on UI, styling, Tailwind theme, components, or frontend UX?

```
/docs/platform/design_tokens.md
/docs/tenants/phuket_thai/design_tokens.md
/docs/component_architecture.md
/docs/ui_conformance_rules.md
/docs/screens/customer_app.md
/docs/screens/dashboard.md
/docs/screens/owner_portal.md
/docs/screens/platform_admin.md
/docs/screens/driver_app.md
```

> Ensures all agents use canonical spacing, typography, colors, and motion exactly as defined in the design token mapping, completely bounding their work in the UI Conformance constraints so they pass AI QA.

---

## Rules

1. `PRD_Core.md` is loaded by every agent. No exceptions.
2. Surface PRDs reference Core rules — they do not redefine them. If a surface PRD appears to contradict `PRD_Core.md`, `PRD_Core.md` wins. Flag the conflict rather than silently picking one.
3. `PRD.md` and `Restaurant_Direct_PRD.md` are superseded and retired. Do not load them.
4. All file paths are case-sensitive. Use lowercase for all paths under `/ai/` and `/docs/`.
5. If a required PRD file does not exist, stop and report the missing file. Do not infer requirements.
6. The `UserRole` enum in `/packages/types/src/roles.ts` is the canonical source of truth for all role values. Never use `admin`, `staff`, or any unlisted value.
7. `domain_glossary.md` is a convenience reference only — always verify against `PRD_Core.md` for authoritative definitions.
8. `architecture.md` is the source of truth for canonical enums, state machines, and module boundaries. If a PRD conflicts with `architecture.md`, flag the conflict — do not silently pick one.
9. `PRD_Admin.md` is superseded by `PRD_Owner_Portal.md` and `PRD_Platform_Admin.md`. Do not load `PRD_Admin.md`.