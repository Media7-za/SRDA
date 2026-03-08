# 1. Task Metadata

## Task Name
Setup Database Migrations

## File Path
`/ai/tasks/setup_database_migrations.md`

## Assigned Agent
- Backend Agent

## Priority
- Low (Verification Phase)

## Status
- Not Started

---

# 2. Objective

Verify and document the process for running database migrations against the local development database and staging environments.

> **Note:** Initial migration scripts and database setup have largely been covered in `02_setup_local_database.md` and `03_setup_prisma_models_and_migrations.md`. This task serves as a final verification checklist for the migration workflow.

---

# 3. Business Context

A reliable migration strategy ensures database changes can be safely applied across development, staging, and production environments without data loss.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/tasks/02_setup_local_database.md`
- `/ai/tasks/03_setup_prisma_models_and_migrations.md`

---

# 5. Dependencies

- Local database is running.
- Prisma schema is complete.

---

# 6. Scope

## In Scope
- Add migration convenience scripts to the root `package.json` and `backend/package.json` (e.g., `db:migrate:dev`, `db:migrate:deploy`).
- Ensure `.env.example` includes the `DATABASE_URL` format.
- Document the migration command workflow in the project README.

## Out of Scope
- Writing new migrations.
- Altering existing schema.

---

# 7. Inputs
- Existing Prisma schema.

---

# 8. Required Outputs
- Updated `package.json` scripts.
- Documentation on migration execution.

---

# 9. Acceptance Criteria
- Running `pnpm run db:migrate:dev` successfully applies pending migrations to the local database.
- Process is clearly documented.

---

# 10. Implementation Rules
- Use Prisma migration tools exclusively (`migrate dev` for dev, `migrate deploy` for prod).

---

# 11. API / Data Contracts
- Not applicable.

---

# 12. Edge Cases
- Handling failed migrations (document rollback process).

---

# 13. Testing Requirements
- Test running the script locally.

---

# 14. Observability / Logging
- Prisma migration output logs.

---

# 15. Security / Permissions
- Ensure production migration scripts do not accidentally run `migrate dev` (which can reset the DB).

---

# 16. Performance Requirements
- Not applicable.

---

# 17. Deliverable Format

**Summary**
Overview of the migration scripts added.

---

# 18. Completion Checklist
- [ ] Safe `deploy` commands configured
- [ ] `.env.example` updated

---

# 19. Agent Instruction

Execute this task strictly according to `backend_agent.md`. Ensure that the workflow is safe and repeatable.

---
End of File
