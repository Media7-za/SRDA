# AI Agent Context Router

This document is the canonical routing guide for AI coding agents.

Before writing any code, agents **must** load every file listed under their active task.
Loading partial context is not permitted. If any listed file is missing or inaccessible, the agent must stop and report the missing file rather than proceeding.

---

## Core Files (Always Load — Every Task)

These files are mandatory regardless of which sub-project is being worked on:

```
/ai/context.md
/ai/architecture.md
/ai/agent_rules.md
/ai/implementation_decisions.md
/ai/agents/database_agent.md
```

---

## Working on the Restaurant Dashboard?

```
/docs/PRD_Dashboard.md
/docs/platform/design_tokens.md
/docs/tenants/phuket_thai/design_tokens.md
/docs/component_architecture.md
/docs/ui_conformance_rules.md
/docs/screens/dashboard.md
```

> Covers: live order feed, driver management, realtime architecture, order + delivery state machines, concurrency protection, role-based access, domain invariants.  
> App: `apps/web` — operational tool used by restaurant staff during live service.

---

## Working on the Restaurant Owner Portal?

```
/docs/PRD_Owner_Portal.md
/docs/platform/design_tokens.md
/docs/tenants/phuket_thai/design_tokens.md
/docs/component_architecture.md
/docs/ui_conformance_rules.md
/docs/screens/owner_portal.md
```

> Covers: restaurant settings, opening hours, menu management (categories, items, modifiers), staff account management, driver management. Phase 2: promotions, loyalty, analytics.  
> App: `apps/owner-portal` — configuration tool used by restaurant owners.

---

## Working on the Platform Super-Admin Panel?

```
/docs/PRD_Platform_Admin.md
/docs/platform/design_tokens.md
/docs/component_architecture.md
/docs/ui_conformance_rules.md
/docs/screens/platform_admin.md
```

> Covers: restaurant onboarding, restaurant management (suspend/activate), feature flags, platform revenue overview, impersonation & audit.  
> App: `apps/platform-admin` — platform operator control centre. Note: Does not load tenant tokens as it sits above tenants.

---

## Working on the Driver App?

```
/docs/PRD_Driver.md
/docs/platform/design_tokens.md
/docs/tenants/phuket_thai/design_tokens.md
/docs/component_architecture.md
/docs/ui_conformance_rules.md
/docs/screens/driver_app.md
```

> Covers: Flutter driver app, delivery state transitions, GPS location posting, delivery task UI.  
> App: separate Flutter repository (`food-delivery-mobile/`).

---

## Working on the Customer App?

```
/docs/PRD.md
/docs/platform/design_tokens.md
/docs/tenants/phuket_thai/design_tokens.md
/docs/component_architecture.md
/docs/ui_conformance_rules.md
/docs/screens/customer_app.md
```

> Covers: menu browsing, cart, checkout, order tracking, loyalty, payments.  
> App: `apps/web` (customer-facing routes).

---

## Cross-Cutting Work (schema, payments, shared services)?

```
/docs/PRD.md
/docs/PRD_Platform_Admin.md
/docs/PRD_Owner_Portal.md
```

> Plus the sub-PRD most relevant to the feature being built.

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

- All file paths are case-sensitive. Use lowercase for all paths under `/ai/` and `/docs/`.
- If a PRD file does not yet exist, the agent must ask for it rather than inferring requirements.
- `architecture.md` is the source of truth for canonical enums, state machines, and module boundaries. If a PRD conflicts with `architecture.md`, flag the conflict — do not silently pick one.
- The `UserRole` enum in `/packages/types/src/roles.ts` is the canonical source of truth for all role values. Never invent a new role string.
- `PRD_Admin.md` is superseded by `PRD_Owner_Portal.md` and `PRD_Platform_Admin.md`. Do not load `PRD_Admin.md`.