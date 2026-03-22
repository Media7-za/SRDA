# System Architecture

## Purpose

This document defines the architectural model for SRDA and how its layers interact. It exists to eliminate ambiguity for engineers, designers, and AI agents by clarifying where truth lives, how experiences are expressed, and how UI is enforced.

The system is built on three independent but connected layers:

1. Business Rules (Truth Layer)
2. UX Blueprint (Experience Layer)
3. UI Constraint System (Enforcement Layer)

## 1. Business Rules (Truth Layer)

### Definition

The Business Rules layer defines what the system is allowed to do.

It is the source of truth for:

- domain behavior
- entity relationships
- state transitions
- roles and permissions
- platform contracts

### Current Source Files

- `Docs/PRD_Core.md`
- `Docs/domain_glossary.md`
- `Docs/api_contracts.md`
- `Docs/er_diagram.md`
- app-specific PRDs such as `Docs/PRD_Customer_App.md`, `Docs/PRD_Driver.md`, and `Docs/PRD_Platform_Admin.md`

### Responsibilities

- Define all domain entities
- Define valid lifecycle transitions
- Enforce invariants that cannot be broken
- Define role-based permissions
- Define cross-service contracts

### Rule

No UI, API, or automation may violate Business Rules.

## 2. UX Blueprint (Experience Layer)

### Definition

The UX Blueprint defines how users interact with the system.

It translates business rules into user-facing flows, screens, layout patterns, and state handling.

### Current Source Files

- `Docs/screens/customer_app.md`
- `Docs/screens/dashboard.md`
- `Docs/screens/driver_app.md`
- `Docs/screens/owner_portal.md`
- tenant-specific blueprints under `Docs/tenants/`

### Responsibilities

- Define screens and routes
- Define layout structure per screen
- Define user flows and screen goals
- Define allowed and forbidden component usage at the experience level
- Define UI states such as loading, empty, error, and offline

### Rule

All user-facing UI must conform to the UX Blueprint for the active app and tenant.

## 3. UI Constraint System (Enforcement Layer)

### Definition

The UI Constraint System defines how UI is allowed to be built.

It prevents inconsistency, drift, and invalid implementations by establishing shared tokens, primitives, and conformance rules.

### Current Source Files

- `Docs/platform/design_tokens.md`
- `Docs/platform/authority_model.md`
- `Docs/component_architecture.md`
- `Docs/ui_conformance_rules.md`
- tenant brand overrides such as `Docs/tenants/phuket_thai/design_tokens.md`

### Code Counterparts

- shared primitives and token scaffold in `packages/ui/src`
- app-level theme application in `apps/admin/src/app/providers.tsx`

### Responsibilities

- Define platform tokens
- Define semantic slots and theme variables
- Define primitive components
- Define composition rules
- Enforce accessibility and operational consistency
- Prevent invalid UI patterns

### Core Rules

Forbidden:

- raw hex colors in component implementation
- arbitrary structural values outside tokens
- ad hoc layout shells where a primitive already exists
- bypassing shared primitives for reusable UI surfaces

Required:

- use platform primitives such as `Card`, `PrimaryButton`, `SecondaryButton`, and `StatusBadge`
- use platform tokens and tenant theme variables
- handle loading, empty, error, and offline states where applicable

### Rule

UI that violates constraint rules is invalid and must be corrected before merge.

## 4. Layer Relationship

The layers interact in a strict hierarchy:

```text
Business Rules -> UX Blueprint -> UI Constraint System -> Implementation
```

Meaning:

- Business Rules define truth
- UX Blueprint defines the intended experience
- UI Constraint System defines how that experience may be implemented
- Code is the final expression, not the authority

## 5. Implementation Flow

When building any feature, follow this order:

1. Business Rules
   Clarify what is allowed and what must remain invariant.
2. UX Blueprint
   Clarify what the user should see and how the flow should behave.
3. UI Constraint System
   Clarify which tokens, primitives, and state patterns are allowed.
4. Implementation
   Compose the final UI from approved building blocks.

## 6. Platform vs Tenant Responsibilities

### Platform Layer

Platform owns:

- shared design tokens
- semantic slots
- primitives
- accessibility and motion rules
- enforcement rules

Current implementation home:

- `packages/ui/src/platformTokens.ts`
- `packages/ui/src/semanticTokens.ts`
- `packages/ui/src/platformCssVars.ts`

Rule:

Platform defines possibility and cannot be overridden arbitrarily.

### Tenant Layer

Tenant owns:

- brand expression
- theme overrides
- tenant-specific screen blueprints
- feature composition

Current implementation home:

- `packages/ui/src/phuketThaiThemeVars.ts`
- tenant documentation under `Docs/tenants/`

Rule:

Tenant defines experience within platform constraints.

## 7. Frontend Implementation Rules

All frontend code must:

- use shared primitives for reusable UI
- respect the UX blueprint for the current app or tenant
- use platform tokens and theme variables instead of inventing raw values
- avoid binding view components directly to raw backend models when adapters or view models are more appropriate

## 8. Disallowed Anti-Patterns

Direct styling bypass:

```tsx
<div className="bg-white p-4 rounded-xl" />
```

Backend-bound rendering:

```ts
const orders = await fetch("/orders").then((r) => r.json())
return orders.map((order) => <div key={order.id}>{order.status}</div>)
```

Component bypass:

- creating new reusable UI shells outside the shared primitive layer

## 9. Summary

SRDA enforces a strict separation of concerns:

- Business Rules define system truth
- UX Blueprint defines user experience
- UI Constraint System enforces consistency

Together, these layers create a deterministic, scalable, and AI-safe architecture.

## 10. Final Principle

UI is not free-form.

It is a constrained expression of domain truth.

