# 1. Task Metadata

## Task Name
Setup Local Database

## File Path
`/ai/tasks/02_setup_local_database.md`

## Assigned Agent
- Database Agent
- Backend Agent (assist)

## Priority
- Critical (blocking — migration and all backend work depends on a running database)

## Status
- ✅ Complete

---

# 2. Objective

Establish a running local PostgreSQL instance, configure the database connection string, run the first Prisma migration against a live database, and verify that the application can connect and query it.

This is the bridge between "schema on paper" (Task 01) and "schema running in a real database."

---

# 3. Business Context

Without a running database, no backend work can begin. This task removes the single biggest blocker between architecture and implementation. It also locks in the local development setup that every contributor will use.

---

# 4. Required Context Files

The assigned agent must read these before doing any work:

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/architecture.md`
- `/ai/implementation_decisions.md`
- `/ai/agents/database_agent.md`
- `/docs/PRD_Core.md`

If any required file is missing, stop and report the blocker.

---

# 5. Dependencies

- Task 00 (Project Scaffolding) — ✅ Complete
- Task 01 (Finalize Database Schema) — must be ✅ Complete
- `database/prisma/schema.prisma` must exist with the finalized MVP schema
- `pnpm` workspace must be functional

---

# 6. Scope

## In Scope

### 6.1 Choose How PostgreSQL Runs Locally

Evaluate and select **one** local Postgres strategy. Document the choice in this task's deliverable.

Options (pick one):

| Option | Pros | Cons |
|--------|------|------|
| **Docker Compose** | Reproducible, version-locked, team-consistent | Requires Docker installed |
| **Postgres.app** (macOS) | Zero config, native, fast | Mac-only, manual version management |
| **Homebrew `postgresql`** | Simple install | Manual service management, OS-specific |
| **Supabase Local (CLI)** | Matches prod if using Supabase | Heavier, extra tooling |

Recommended default: **Docker Compose** (most portable, team-friendly).

If Docker is chosen, provide a `docker-compose.yml` at the project root with:
- PostgreSQL 15+ image
- Named volume for data persistence
- Port mapping (default: `5432:5432`)
- Health check
- Service name: `db`

### 6.2 Configure `.env`

Create or update `.env` (and `.env.example`) with:

```
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/restaurant_direct_dev?schema=public"
```

Ensure:
- `.env` is in `.gitignore` (never committed)
- `.env.example` contains the template with placeholder values
- The URL uses `restaurant_direct_dev` as the database name

### 6.3 Run the First Migration

Execute:

```bash
cd database
npx prisma migrate dev --name init
```

This must:
- Create all 14 MVP tables
- Apply all indexes and constraints
- Generate the Prisma Client

### 6.4 Verify Database Connection

Create a minimal connection verification script:

```
database/scripts/verify-connection.ts
```

This script must:
- Import the Prisma Client
- Attempt to connect to the database
- Run a simple query (e.g., `SELECT 1` or `prisma.$queryRaw`)
- Log success or failure with the connection URL (masked password)
- Exit with code 0 on success, 1 on failure

Add a script to `database/package.json`:

```json
{
  "scripts": {
    "db:verify": "tsx scripts/verify-connection.ts"
  }
}
```

## Out of Scope

- Seed data (deferred to a later task)
- Repository implementation
- API endpoints
- Production database hosting
- CI/CD database provisioning
- Prisma Studio setup (optional developer convenience, not required)

---

# 7. Inputs

- `database/prisma/schema.prisma` — finalized schema from Task 01
- `.env.example` — existing template from Task 00

---

# 8. Required Outputs

| Deliverable | Location |
|-------------|----------|
| Local Postgres setup (Docker Compose or equivalent) | `docker-compose.yml` (if Docker) |
| `.env` file with `DATABASE_URL` | `.env` (gitignored) |
| `.env.example` updated | `.env.example` |
| First migration applied | `database/prisma/migrations/` |
| Prisma Client generated | `database/node_modules/.prisma/client/` |
| Connection verification script | `database/scripts/verify-connection.ts` |
| `db:verify` script in `database/package.json` | `database/package.json` |

---

# 9. Acceptance Criteria

- [ ] Local PostgreSQL is running and accessible on `localhost:5432`
- [ ] `.env` contains a valid `DATABASE_URL`
- [ ] `.env` is in `.gitignore`
- [ ] `.env.example` contains a template `DATABASE_URL` with placeholder values
- [ ] `npx prisma migrate dev` completes successfully
- [ ] All 14 MVP tables exist in the database (can verify via `prisma db pull` or `\dt` in psql)
- [ ] Prisma Client is generated (`npx prisma generate` succeeds)
- [ ] `pnpm run db:verify` connects successfully and exits with code 0
- [ ] Database name is `restaurant_direct_dev`
- [ ] If Docker is used: `docker compose up -d` starts Postgres, `docker compose down` stops it
- [ ] Setup instructions are documented in `README.md` or a `database/README.md`

---

# 10. Implementation Rules

- Use PostgreSQL 15 or higher
- Database name: `restaurant_direct_dev`
- Default credentials for local dev only: `postgres:postgres`
- Never commit `.env` with real credentials
- Connection verification must use the Prisma Client, not a raw driver
- Do not introduce additional ORM dependencies
- Follow naming conventions from `/ai/agent_rules.md`

---

# 11. API / Data Contracts

Not applicable (infrastructure task).

---

# 12. Edge Cases

- Docker not installed on developer machine → document the alternative (Postgres.app / Homebrew)
- Port 5432 already in use → document how to change the port
- Database already exists from a previous attempt → migration must handle idempotently
- `.env` already exists from Task 00 → merge, don't overwrite
- Prisma Client import fails in `backend/` → verify workspace dependency `@restaurant-direct/database` is correctly configured..
- Migration fails due to schema errors → report error and do not proceed

---

# 13. Testing Requirements

**Unit Tests**
- Not applicable (infrastructure task)

**Validation Tests**
- `npx prisma validate` — schema compiles
- `npx prisma migrate dev` — migration applies cleanly
- `npx prisma generate` — client generates
- `pnpm run db:verify` — connection works

**E2E Tests**
- Not applicable

---

# 14. Observability / Logging

- Log database connection success/failure in the verification script
- Log migration execution result

---

# 15. Security / Permissions

- `DATABASE_URL` must come from `.env`, never hardcoded
- Default dev credentials (`postgres:postgres`) are acceptable for local development only
- Document that production must use a secure, unique password
- `.env` must be in `.gitignore`

---

# 16. Performance Requirements

- Standard MVP performance expectations apply
- PostgreSQL must start within 10 seconds (Docker health check)

---

# 17. Deliverable Format

**Summary**
Brief explanation of the local database setup chosen and verification results.

**Files Created or Updated**
List all files.

**Implementation Notes**
Which Postgres strategy was chosen and why.

**Tests**
List verification steps and their results.

**Risks / Follow-ups**
Any remaining concerns or next steps (e.g., seed data, CI database).

---

# 18. Completion Checklist

Before marking the task complete, verify:

- [ ] required context files were read
- [ ] dependencies were satisfied (Task 01 complete)
- [ ] local PostgreSQL is running
- [ ] `.env` is configured and gitignored
- [ ] `.env.example` is updated
- [ ] first migration applied successfully
- [ ] all 14 tables exist in the database
- [ ] Prisma Client generated
- [ ] connection verification script works
- [ ] setup instructions documented
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
- `/docs/PRD_Core.md`

Do not invent architecture, APIs, or schema outside approved documents.

If blocked, report:
- blocker
- impact
- exact missing dependency

---
End of File
