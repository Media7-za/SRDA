# 1. Task Metadata

## Task Name
Create Database Models (Implementation)

## File Path
`/ai/tasks/create_database_models.md`

## Assigned Agent
- Backend Agent

## Priority
- Low (Verification/Implementation Phase)

## Status
- Not Started

---

# 2. Objective

Verify the existing Prisma schema and ensure the generated Prisma Client is correctly imported and exported from the `@restaurant-direct/database` workspace package for use by the backend.

> **Note:** The actual architecture and Prisma schema file have already been designed in `01_finalize_database_schema.md`. This task ensures the *backend implementation layer* correctly consumes it.

---

# 3. Business Context

The backend must interact with the database using strongly typed models. Ensuring the client is generated correctly in the monorepo setup prevents runtime errors.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/agents/backend_agent.md`
- `/ai/tasks/01_finalize_database_schema.md` (Source of truth)

---

# 5. Dependencies

- `01_finalize_database_schema.md` (✅ Complete)

---

# 6. Scope

## In Scope
- Run `pnpm prisma generate` in the database workspace.
- Create a Prisma Client singleton in the `backend/src/utils/db.ts` to prevent connection exhaustion in dev.
- Create a base Repository class or interface that uses this singleton.

## Out of Scope
- Modifying `schema.prisma` (Do not change the schema).
- Running migrations (handled in another task).

---

# 7. Inputs
- Existing `/database/prisma/schema.prisma`.

---

# 8. Required Outputs
- `db.ts` utility file.
- Types exported for use in services.

---

# 9. Acceptance Criteria
- Backend can import `prisma` from `@restaurant-direct/database/client` (or similar configured path).
- TypeScript compiles without schema errors.
- Client singleton prevents multiple instances during hot-reloads.

---

# 10. Implementation Rules
- Follow singleton pattern for Prisma Client (especially important if using Next.js or similar dev servers in the future).

---

# 11. API / Data Contracts
- Not applicable.

---

# 12. Edge Cases
- Connection pooling limits.

---

# 13. Testing Requirements
- Basic DB connection test.

---

# 14. Observability / Logging
- Prisma query logging (enabled in development mode).

---

# 15. Security / Permissions
- Do not commit `.env` containing connection strings.

---

# 16. Performance Requirements
- Singleton client to avoid connection leak.

---

# 17. Deliverable Format

**Summary**
Confirmation of Prisma client generation.

**Files Created Updated**
Path to the DB singleton utility.

---

# 18. Completion Checklist
- [ ] schema not altered during this task
- [ ] singleton implemented

---

# 19. Agent Instruction

Execute this task strictly according to `backend_agent.md`. Rely *only* on the schema defined by the Architect Agent. Do not invent new fields.

---
End of File
