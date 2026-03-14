# AI Agent Engineering Rules

## Project

Restaurant Ordering & Delivery Platform

This document defines **strict engineering protocols** that AI agents must follow when generating code for this project.

These rules exist to ensure:

• consistent architecture
• predictable code structure
• maintainable services
• safe database access
• production-ready code

AI agents must **never deviate from these rules**.

---

# 1. Mandatory Context Loading

Before generating any code, the AI agent **must read the following files**:

/ai/context.md
/docs/PRD_Core.md
/ai/architecture.md
/ai/implementation_decisions.md
/ai/agent_rules.md
/ai/agents/database_agent.md

These documents define:

• system architecture
• data model
• engineering standards
• business logic
• locked implementation decisions

This ensures agents never implement features without reading architecture and locked decisions.

If the AI agent does not have access to these files, it must **refuse to generate code**.

---

# 2. Architecture Principles

The backend follows **layered architecture** (Controller → Service → Repository → Database).

Full layer specification is in `/ai/architecture.md` §2.

AI agents must **never merge these layers**.

---

# 3. Controller Rules

Controllers must be **thin**.

Controllers may only: receive requests, validate input, call services, and return responses.

Controllers must **never contain business logic**.

---

# 4. Service Layer Rules

Services contain **all business logic**.

Services must remain **framework independent**.

Services must **not access the database directly** — they must use repositories.

Service responsibilities per module are defined in `/ai/architecture.md` §3.

---

# 5. Repository Rules

Repositories are the **only layer allowed to access the database**.

Responsibilities:

• database queries
• inserts
• updates
• deletes

Services must **never write SQL directly**.

Only repositories may import the ORM client (Prisma or equivalent).

Services must **never import database clients directly**.

---

# 6. Database First Development

All features must start with:

1️⃣ Database schema
2️⃣ Repository implementation
3️⃣ Service logic
4️⃣ API controller
5️⃣ UI integration

AI agents must **not implement UI before APIs exist**.

---

# 7. Strict Typing

The codebase must use **strict typing**.

Backend:

TypeScript strict mode enabled.

Frontend:

TypeScript required.

Avoid `any` types.

All API responses must use defined interfaces.

---

# 8. Folder Structure

Folder structure is defined in `/ai/architecture.md` §1.1.

AI agents must **not invent new directories or restructure existing ones**.

---

# 9. Naming Conventions

Naming must remain consistent.

Tables

snake_case

Example

menu_items
order_items

Classes

PascalCase

Example

OrderService
MenuRepository

Variables

camelCase

Example

orderTotal
deliveryAddress

---

# 10. Order Lifecycle Enforcement

Orders must follow the canonical lifecycle: `pending` → `confirmed` → `preparing` → `ready_for_pickup` → `out_for_delivery` → `delivered` (or `cancelled`).

AI agents must enforce these states. Invalid transitions must throw errors.

Full state machine and coupling rules are in `/ai/architecture.md` §5.

---

# 11. API Design Rules

All APIs must follow REST conventions.

Examples:

GET /menu
GET /menu/:id

POST /orders

GET /orders/:id

PATCH /orders/:id/status

All APIs must return the **canonical response envelope**:

```json
{
  "success": true,
  "data": { ... },
  "error": null
}
```

Error responses:

```json
{
  "success": false,
  "data": null,
  "error": { "message": "..." }
}
```

The envelope must always include `success`, `data`, and `error` fields.

---

# 12. Security Rules

AI agents must enforce security standards.

Required:

• password hashing (bcrypt)
• JWT authentication
• input validation
• rate limiting

Passwords must never be stored in plaintext.

---

# 13. Payment Rules

Payment logic must be isolated in **PaymentService**.

Rules:

• All money events must be recorded in the `payments` table.
• Orders may only be auto-confirmed after successful online payment **OR** restaurant confirmation for pay-in-store orders.
• Payment records must include `provider`, `method`, `amount`, and `status`.
• In-store payments must record `collected_by_user_id` for staff accountability.

Payment architecture, fulfillment modes, and state coupling rules are in `/ai/architecture.md` §3.4, §4.7, §5.3.

---

# 14. AI Agent Restrictions

AI agents must **never**:

Invent new database tables without updating schema.

Invent new API patterns.

Duplicate logic across services.

Write business logic inside controllers.

Ignore strict typing.

Introduce new order states, payment states, or delivery states without updating `/ai/architecture.md`.

---

# 15. Code Quality Requirements

All generated code must be:

• readable
• modular
• typed
• documented
• production ready

AI agents must avoid:

• overly clever code
• deep nesting
• large functions

Maximum function size guideline:

50 lines.

---

# 16. Testing Protocol

QA Agent must generate:

• unit tests
• service tests
• API tests

Critical flows that must be tested:

Order creation
Order lifecycle
Payment confirmation
Delivery assignment

---

# 17. Logging Standards

Critical operations must log structured events including `timestamp`, `order_id`, and `user_id`.

Required log events and format are defined in `/ai/architecture.md` §6.2.

---

# 18. Future Scalability Rules

Even though MVP supports one restaurant, all core entities must include `restaurant_id`.

See `/ai/architecture.md` §4.4 for the full list of affected entities.

---

# 19. AI Development Workflow

AI agents must follow this workflow.

Step 1

Architect defines schema and APIs.

Step 2

Database Agent implements and guards schema integrity (Prisma, migrations, indexes, enums).

Step 3

Backend Agent implements backend.

Step 4

Frontend Agent builds UI.

Step 5

QA Agent verifies flows.

Agents must **not skip steps**.

---

# 20. Delivery Domain Vocabulary

Canonical delivery vocabulary is defined in `/ai/architecture.md` §3.7.

AI agents must **not** introduce alternate terms (e.g. `trips`, `driver_statuses`) unless explicitly added to the architecture document.

---

# 21. Global UI & Design Token Rule

UI-producing agents (Frontend, Architect scaffolding) must **not** invent raw styling, hex codes, or arbitrary dimensions outside of the canonical platform/tenant design token files (`/docs/platform/design_tokens.md` and `/docs/tenants/*/design_tokens.md`). All UI layouts, components, sizes, colors, and motion must be built exclusively using the canonical tokens and Tailwind utility configurations defined therein.

---

# 22. Final Instruction

If the AI agent encounters ambiguity:

It must **ask for clarification instead of guessing**.

Architecture decisions must never be invented.

All code must align with:

/ai/context.md
/docs/PRD_Core.md
/ai/architecture.md
/ai/implementation_decisions.md
/ai/agent_rules.md

---

End of File
