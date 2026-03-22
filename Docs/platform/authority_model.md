# Authority Model: UI System

## Purpose

This document defines the source-of-truth hierarchy for all UI decisions across the platform and tenant layers.

It prevents conflicts between:

- platform design tokens
- platform component contracts
- tenant themes
- UX blueprints
- implementation code

---

## 1. Hierarchy of Authority

All UI decisions must follow this order:

1. Platform tokens
2. Platform UI constraints
3. Tenant theme and UX blueprint
4. Component implementation

---

## 2. Platform Tokens

### Source

- `Docs/platform/design_tokens.md`

### Defines

- spacing scale
- radius scale
- breakpoints
- motion rules
- accessibility rules
- semantic operational status colors
- shared component base dimensions

### Rules

- Must not be overridden arbitrarily by tenants
- Must be used by all shared primitives
- Must be referenced via semantic tokens or CSS variables in implementation

### Example

Allowed:

```ts
borderRadius: "var(--radius-lg)"
```

Forbidden:

```ts
borderRadius: "24px"
```

---

## 3. Platform UI Constraints

### Source

- `Docs/component_architecture.md`
- `Docs/ui_conformance_rules.md`

### Defines

- allowed components
- forbidden patterns
- required states
- accessibility guarantees
- composition rules

### Rules

- All UI must use approved primitives and canonical components
- Raw styling that bypasses the system is not allowed
- Violations should fail review, QA, or CI

---

## 4. Tenant Theme and UX Blueprint

### Source

- `Docs/tenants/phuket_thai/design_tokens.md`
- `Docs/tenants/phuket-thai/UX_Blueprint.md`
- future tenant-specific screen and theme documents

### Defines

- brand identity
- visual tone
- layout style
- screen composition patterns
- feature emphasis

### Rules

- May override semantic brand-facing values
- May define composed tenant components and screen patterns
- Must not override platform accessibility, structural tokens, or primitive APIs

If a tenant needs a new spacing, radius, shadow, or primitive capability, it must be proposed at the platform layer first.

---

## 5. Component Implementation

### Source

- `apps/**`
- `packages/ui/src/**`

### Rules

- Must use platform primitives
- Must use token-backed values
- Must follow the active tenant UX blueprint
- Must not hardcode colors, arbitrary spacing, or bypass approved primitives for domain components

---

## 6. Conflict Resolution

If two layers conflict, resolve them in this order:

1. Platform tokens
2. Platform UI constraints
3. Tenant theme and UX blueprint
4. Implementation code

Example:

If a tenant wants a `24px` radius but the platform only defines `sm`, `md`, `lg`, and `pill`, implementation must not invent `24px`. The value must first be approved and added as a platform token.

---

## 7. Non-Negotiable Rules

- UI is not free-form
- Tokens are the only source of shared values
- Primitives are the approved building blocks
- Tenants define experience, not platform structure

---

## 8. Summary

| Layer | Responsibility |
| --- | --- |
| Platform tokens | Define shared structure |
| UI constraints | Enforce correctness |
| Tenant docs | Define experience |
| Implementation | Render the approved result |

## Final Principle

UI is a constrained expression of domain truth, not an open canvas.
