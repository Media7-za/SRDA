# System Architecture Overview

## Purpose

This document defines the architectural model of the system and how its core layers interact. It exists to eliminate ambiguity for engineers, designers, and AI agents.

The system is built on three independent but connected layers:

1. **Business Rules (Truth Layer)**
2. **UX Blueprint (Experience Layer)**
3. **UI Constraint System (Enforcement Layer)**

---

# 1. Business Rules (Truth Layer)

## Definition

The Business Rules layer defines what the system **is allowed to do**.

It is the source of truth for:
- domain behavior
- entity relationships
- state transitions
- permissions and roles

## Source Files

- `Docs/PRD_Core.md`
- `Docs/api_contracts.md`
- `Docs/domain_glossary.md`
- `Docs/er_diagram.md`

## Responsibilities

- Define all domain entities
- Define valid state transitions
- Enforce invariants (rules that cannot be broken)
- Define role-based permissions
- Define API contracts

## Example

```
Order State Machine:
created → confirmed → preparing → ready → delivered

Invariant:
Order cannot skip states
```

## Rule

> No UI or API implementation may violate Business Rules.

---

# 2. UX Blueprint (Experience Layer)

## Definition

The UX Blueprint defines how users interact with the system.

It translates business rules into user-facing flows and layouts.

## Source Files

- `Docs/screens/customer_app.md`
- `Docs/screens/dashboard.md`
- `Docs/screens/driver_app.md`
- `Docs/screens/owner_portal.md`
- `Docs/tenants/phuket-thai/UX_Blueprint.md`

## Responsibilities

- Define screens and routes
- Define layout structure per screen
- Define allowed and forbidden components
- Define user flows
- Define UI states (loading, empty, error, offline)

## Example

```
Home Screen

Goal:
Entry point for user

Allowed Components:
- PageHeader
- RewardCard
- MenuItemCard

States:
- Loading → SkeletonLoader
- Empty → EmptyState
- Error → ErrorState
```

## Rule

> All UI must conform to the UX Blueprint for the active tenant.

---

# 3. UI Constraint System (Enforcement Layer)

## Definition

The UI Constraint System defines how UI is allowed to be built.

It prevents inconsistency, drift, and invalid implementations.

## Source Files

- `Docs/platform/design_tokens.md`
- `Docs/component_architecture.md`
- `Docs/ui_conformance_rules.md`
- `Docs/platform/authority_model.md`

## Responsibilities

- Define design tokens
- Define primitive components
- Define composition rules
- Enforce accessibility
- Prevent invalid UI patterns

## Core Rules

### Forbidden
- Raw hex colors
- px-based spacing
- Arbitrary div-based layouts
- Unapproved components

### Required
- Use platform primitives (Button, Card, Badge, etc.)
- Use semantic tokens
- Handle all states:
  - loading
  - empty
  - error
  - offline

## Example

❌ Invalid:
```
<div className="p-4 bg-white rounded-xl">
```

✅ Valid:
```
<Card>
```

## Rule

> UI that violates constraint rules is considered invalid and must be rejected.

---

# 4. Layer Relationship

The three layers interact in a strict hierarchy:

```
Business Rules → UX Blueprint → UI Constraints
```

## Meaning

- Business Rules define **truth**
- UX Blueprint defines **expression of truth**
- UI Constraints define **how expression is allowed to be built**

---

# 5. Implementation Flow

When building any feature, the following order must be followed:

## Step 1 — Business Rules
- What is allowed?
- What are the constraints?

## Step 2 — UX Blueprint
- What should the user see?
- What is the flow?

## Step 3 — UI Constraints
- How must it be implemented?
- Which components are allowed?

---

# 6. Platform vs Tenant Responsibilities

## Platform Layer

Owns:
- design system primitives
- core tokens
- semantic tokens
- enforcement rules

Rule:
> Platform defines possibility and cannot be overridden arbitrarily.

---

## Tenant Layer

Owns:
- theme overrides
- screen definitions
- feature components

Rule:
> Tenant defines experience within platform constraints.

---

# 7. Authority Resolution

When multiple documents appear to define the same UI decision, resolve the conflict in this order:

1. `Docs/platform/design_tokens.md`
2. `Docs/component_architecture.md`
3. `Docs/ui_conformance_rules.md`
4. `Docs/tenants/*` tenant theme and UX blueprint documents
5. implementation code

Platform tokens are canonical for shared structure, motion, accessibility, and operational semantic states. Tenant themes may define brand expression and screen composition, but may not bypass platform safety or structural constraints.

---

# 8. Frontend Implementation Rules

All frontend code MUST:

- Use platform primitives
- Respect tenant UX blueprint
- Not access raw backend models directly
- Use adapter layer for data transformation

---

# 9. Anti-Patterns (Disallowed)

## Direct Styling
```
<div className="bg-white p-4">
```

## Backend Binding
```
fetch('/orders') → render directly
```

## Component Bypass
- Creating new UI patterns outside system

---

# 10. Summary

This system enforces a strict separation of concerns:

- Business Rules define system truth
- UX Blueprint defines user experience
- UI Constraint System enforces consistency

Together, they create a:

> **Deterministic, scalable, and AI-safe architecture**

---

# 11. Final Principle

> UI is not free-form.
> It is a constrained expression of domain truth.

