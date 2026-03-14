# 1. Task Metadata

## Task Name
Setup Prisma Models and Migrations

## File Path
`/ai/tasks/03_setup_prisma_models_and_migrations.md`

## Assigned Agent
- Database Agent (schema validation, migration review)
- Backend Agent (repository base, Prisma Client wiring)

## Priority
- Critical (blocking — repository and service layers depend on this)

## Status
- ✅ Complete

---

# 2. Objective

Verify the Prisma Client generation is correct and fully typed, wire up the repository base pattern so the Backend Agent can build on it, and confirm that the database workspace package (`@restaurant-direct/database`) is properly consumable from `backend/`.

This task is the handoff point between the Database Agent's schema work and the Backend Agent's implementation work.

---

# 3. Business Context

The schema exists (Task 01) and the database is running (Task 02). This task verifies that the ORM layer is production-ready and establishes the repository pattern that all backend services will use. Without this, every subsequent backend task will re-invent how to access the database.

---

# 4. Required Context Files

The assigned agent must read these before doing any work:

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/architecture.md`
- `/ai/implementation_decisions.md`
- `/ai/agents/database_agent.md`
- `/ai/agents/backend_agent.md`
- `/docs/PRD_Core.md`

If any required file is missing, stop and report the blocker.

---

# 5. Dependencies

- Task 00 (Project Scaffolding) — ✅ Complete
- Task 01 (Finalize Database Schema) — must be ✅ Complete
- Task 02 (Setup Local Database) — must be ✅ Complete
- Local PostgreSQL running with all 14 tables migrated
- `database/prisma/schema.prisma` finalized
- Prisma Client generated

---

# 6. Scope

## In Scope

### 6.1 Verify Prisma Client Generation

Confirm that the generated Prisma Client:

- Exposes typed models for all 14 tables
- Exposes typed enums for all 8 enums
- Includes relation accessors (e.g., `order.orderItems`, `user.addresses`)
- Can be imported from `backend/` via `@restaurant-direct/database`

Run:

```bash
cd database
npx prisma generate
```

Then verify import works from `backend/`:

```typescript
import { PrismaClient } from "@restaurant-direct/database/client";
```

### 6.2 Create Prisma Client Singleton

Create a shared Prisma Client instance in the `database/` package:

```
database/src/client.ts
```

This file must:

- Export a singleton `PrismaClient` instance
- Handle connection lifecycle (connect on first use, disconnect on shutdown)
- Enable query logging in development mode only
- Be the **only** place where `new PrismaClient()` is called

```typescript
// database/src/client.ts
import { PrismaClient } from "@prisma/client";

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === "development" ? ["query", "warn", "error"] : ["error"],
  });

if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma;
```

Export from `database/src/index.ts`:

```typescript
export { prisma } from "./client";
export * from "@prisma/client";
```

### 6.3 Wire Up Repository Base

Create a base repository pattern in `backend/`:

```
backend/src/repositories/base.repository.ts
```

This file must:

- Import `prisma` from `@restaurant-direct/database`
- Export the `prisma` instance for use by specific repositories
- Provide the foundation pattern for all domain repositories

```typescript
// backend/src/repositories/base.repository.ts
import { prisma } from "@restaurant-direct/database";

export { prisma };
```

### 6.4 Create First Domain Repository (Stub)

Create a minimal stub repository to prove the pattern works:

```
backend/src/repositories/restaurant.repository.ts
```

This stub must:

- Import from `base.repository.ts`
- Export a single query function (e.g., `findAllRestaurants`)
- Use the Prisma Client with full typing
- Not implement full business logic (that comes in Phase C)

```typescript
// backend/src/repositories/restaurant.repository.ts
import { prisma } from "./base.repository";

export async function findAllRestaurants() {
  return prisma.restaurant.findMany({
    where: { isActive: true },
  });
}
```

### 6.5 Verify End-to-End Wiring

Create a verification script or test that:

1. Imports the Prisma Client from `@restaurant-direct/database`
2. Runs a typed query through the repository
3. Confirms the response matches the expected Prisma types
4. Proves that the workspace dependency chain works: `backend → database → Prisma → PostgreSQL`

## Out of Scope

- Full repository implementations for all modules
- Service layer implementation
- API endpoints
- Seed data
- Authentication
- Complex query patterns (joins, transactions)
- Production connection pooling (PgBouncer, etc.)

---

# 7. Inputs

- `database/prisma/schema.prisma` — finalized schema
- `database/package.json` — workspace package configuration
- `backend/package.json` — workspace dependency on `@restaurant-direct/database`
- `.env` — configured `DATABASE_URL`

---

# 8. Required Outputs

| Deliverable | Location |
|-------------|----------|
| Prisma Client singleton | `database/src/client.ts` |
| Database package exports | `database/src/index.ts` |
| Base repository | `backend/src/repositories/base.repository.ts` |
| Restaurant repository stub | `backend/src/repositories/restaurant.repository.ts` |
| End-to-end wiring verification (script or test) | `backend/src/repositories/__tests__/wiring.test.ts` or `database/scripts/verify-wiring.ts` |

---

# 9. Acceptance Criteria

- [ ] `npx prisma generate` succeeds without errors
- [ ] Generated Prisma Client exposes typed models for all 14 tables
- [ ] Generated Prisma Client exposes typed enums for all 8 enums
- [ ] `database/src/client.ts` exports a singleton `PrismaClient`
- [ ] `database/src/index.ts` re-exports the client and Prisma types
- [ ] `backend/` can import from `@restaurant-direct/database` without errors
- [ ] `base.repository.ts` exports the `prisma` instance
- [ ] `restaurant.repository.ts` compiles and runs a basic query
- [ ] End-to-end verification passes: backend → database package → Prisma → PostgreSQL
- [ ] No `PrismaClient` is instantiated outside `database/src/client.ts`
- [ ] TypeScript strict mode compiles without errors
- [ ] Query logging is enabled in development, disabled in production

---

# 10. Implementation Rules

- Only `database/src/client.ts` may call `new PrismaClient()`
- Only repositories may import the Prisma Client (per `/ai/agent_rules.md` § 5)
- Services must never import `prisma` directly
- Controllers must never import `prisma` directly
- Use the workspace import path: `@restaurant-direct/database`
- Follow naming conventions: `*.repository.ts` for repository files
- TypeScript strict mode must be enabled

---

# 11. API / Data Contracts

Not applicable (infrastructure + wiring task).

---

# 12. Edge Cases

- Prisma Client not generated → run `npx prisma generate` before importing
- Database not running → verification script must fail gracefully with a clear error
- Workspace dependency not resolved → verify `pnpm install` and `package.json` dependency entry
- `globalThis` Prisma instance stale after schema change → document that `prisma generate` must be re-run
- Multiple `PrismaClient` instances created → singleton pattern prevents this
- Import path mismatch between `@restaurant-direct/database` and actual package name → verify `database/package.json` `name` field

---

# 13. Testing Requirements

**Unit Tests**
- Not applicable (wiring, not logic)

**Integration Tests**
- Verify Prisma Client connects to PostgreSQL
- Verify `restaurant.repository.ts` runs a query and returns typed results
- Verify TypeScript compilation with strict mode

**E2E Tests**
- Not applicable

---

# 14. Observability / Logging

- Prisma query logging in development mode (configured in client singleton)
- Connection error logging

---

# 15. Security / Permissions

- `DATABASE_URL` must come from `.env`, never hardcoded
- Prisma Client must not be exposed to frontend code
- Repository layer is the only access point to the database

---

# 16. Performance Requirements

- Prisma Client must be a singleton (no connection pool exhaustion)
- Development query logging must not affect production performance

---

# 17. Deliverable Format

**Summary**
Brief explanation of the Prisma Client wiring and repository pattern.

**Files Created or Updated**
List all files.

**Implementation Notes**
Why the singleton pattern was chosen, how workspace imports work.

**Tests**
List verification steps and results.

**Risks / Follow-ups**
Connection pooling for production, full repository implementations needed.

---

# 18. Completion Checklist

Before marking the task complete, verify:

- [ ] required context files were read
- [ ] dependencies were satisfied (Tasks 01 + 02 complete)
- [ ] Prisma Client generates with full types
- [ ] singleton pattern is implemented
- [ ] `database/` package exports are correct
- [ ] `backend/` can import from `@restaurant-direct/database`
- [ ] base repository is created
- [ ] restaurant repository stub compiles and runs
- [ ] end-to-end wiring verified
- [ ] no `PrismaClient` instantiation outside the singleton
- [ ] TypeScript compiles with strict mode
- [ ] no out-of-scope work was added

---

# 19. Agent Instruction

**Assigned Agent Instruction:**

Execute this task strictly according to:

- `/ai/context.md`
- `/ai/architecture.md`
- `/ai/agent_rules.md`
- `/ai/implementation_decisions.md`
- `/ai/agents/database_agent.md`
- `/ai/agents/backend_agent.md`
- `/docs/PRD_Core.md`

Do not invent architecture, APIs, or schema outside approved documents.

If blocked, report:
- blocker
- impact
- exact missing dependency

---
End of File
