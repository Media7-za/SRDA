# Authority Model

## Purpose

This document defines the source-of-truth hierarchy for UI decisions across the platform and tenant layers.

It prevents conflicts between:

- platform tokens
- platform primitives and conformance rules
- tenant themes and UX blueprints
- implementation code

## 1. Hierarchy of Authority

All UI decisions must follow this order:

1. Platform Tokens
2. Platform UI Constraints
3. Tenant Theme and UX Blueprint
4. Implementation

## 2. Platform Tokens

### Authority

Platform tokens are the canonical source of shared structure.

### Sources

- `Docs/platform/design_tokens.md`
- `packages/ui/src/platformTokens.ts`
- `packages/ui/src/platformCssVars.ts`
- `packages/ui/src/semanticTokens.ts`

### Defines

- spacing scale
- radius scale
- shared component dimensions
- motion rules
- accessibility constraints
- semantic operational states

### Rules

- Must not be overridden arbitrarily by tenants
- Must be referenced through platform token files or theme variables
- If a needed value does not exist, it must be proposed at the platform level before implementation

## 3. Platform UI Constraints

### Sources

- `Docs/component_architecture.md`
- `Docs/ui_conformance_rules.md`
- shared primitives in `packages/ui/src/primitives`

### Defines

- allowed primitive components
- forbidden implementation patterns
- required state handling
- accessibility guarantees

### Rules

- Shared UI must use approved primitives
- Raw structural styling should not bypass the primitive layer
- Violations should be treated as architecture defects, not stylistic differences

## 4. Tenant Theme and UX Blueprint

### Sources

- `Docs/tenants/`
- `packages/ui/src/phuketThaiThemeVars.ts`
- future tenant-specific component and screen layers

### Defines

- brand identity
- visual tone
- layout feel
- feature emphasis
- screen-specific composition choices

### Rules

- Tenants may override semantic theme values such as colors and brand accents
- Tenants may define composed components and screen patterns
- Tenants may not override platform accessibility, structural primitives, or enforcement rules

## 5. Implementation

### Sources

- application code under `apps/`
- shared UI code under `packages/ui/src`

### Rules

- Implementation is the lowest authority layer
- Code must use platform primitives and approved token sources
- Code must respect the active tenant blueprint
- Code must not invent new design-system values inline

## 6. Conflict Resolution

If two layers conflict, resolve by this priority:

1. Platform Tokens
2. Platform UI Constraints
3. Tenant Theme and UX Blueprint
4. Implementation

Example:

If a tenant wants a new radius value that does not exist in platform tokens, implementation must stop at the proposal stage. The new value must be approved and added to the platform first.

## 7. Non-Negotiable Principles

- UI is not free-form
- Tokens are the source of structural values
- Primitives are the approved reusable building blocks
- Tenants define experience, not platform structure

## 8. Summary

Platform defines possibility.

Tenant defines experience.

Implementation renders the final expression inside those constraints.
