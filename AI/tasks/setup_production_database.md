# 1. Task Metadata

## Task Name
Setup Production Database

## File Path
`/ai/tasks/setup_production_database.md`

## Assigned Agent
- DevOps Agent

## Priority
- High

## Status
- Not Started

---

# 2. Objective

Provision and configure the managed PostgreSQL database (e.g., Supabase, Neon, or AWS RDS) for the production environment, and cleanly apply the finalized Prisma schema migrations.

---

# 3. Business Context

The production database is the lifeblood of the application. It needs to be highly available, regularly backed up, and strictly access-controlled.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agents/devops_agent.md`
- `/docs/PRD.md`

---

# 5. Dependencies

- `01_finalize_database_schema.md` (The Prisma schema must be considered 'V1 Gold').

---

# 6. Scope

## In Scope
- Provision a hosted PostgreSQL 15+ database instance.
- Secure standard connection strings (URL with connection pooling if using Prisma, e.g., Pgbouncer or Supavisor).
- Secure a direct connection string (URL for database migrations).
- Run `npx prisma migrate deploy` directly against the production instance from a secured administrative machine or CI/CD runner.
- Setup Daily Automated Backups within the database provider settings.

## Out of Scope
- Adding mock/seed data intended only for local development.

---

# 7. Inputs
- Cloud Provider Dashboard (Supabase/Neon).

---

# 8. Required Outputs
- Secured `DATABASE_URL` and `DIRECT_URL`.
- Documented backup strategy in `/docs/infrastructure.md`.

---

# 9. Acceptance Criteria
- Database accepts external connections from authorized IPs or via secure connection pooler.
- The `_prisma_migrations` table is created and shows the initial state successfully deployed.
- Backup retention policy enables at least 7 days of point-in-time recovery (PITR) depending on cloud provider tier.

---

# 10. Implementation Rules
- NEVER run `npx prisma db push` against a production database. Always use `migrate deploy` to ensure strict, linear database evolution.

---

# 11. API / Data Contracts
N/A

---

# 12. Edge Cases
- Exceeding connection limits (ensure Prisma is configured to use the provider's connection pooler string).

---

# 13. Testing Requirements
- Connect using a local client (e.g., TablePlus/DataGrip) and execute a simple `SELECT 1;`.

---

# 14. Observability / Logging
- Enable PostgreSQL slow query logging within the provider dashboard.

---

# 15. Security / Permissions
- Do not commit the `DATABASE_URL` string anywhere.

---

# 16. Performance Requirements
- Standard managed instance configuration.

---

# 17. Deliverable Format
Credentials securely handed off via established secrets manager. Status documented.

---

# 18. Completion Checklist
- [ ] DB Provisioned
- [ ] Pooling configured
- [ ] Initial Migration Deployed `npx prisma migrate deploy`
- [ ] Backups active

---

# 19. Agent Instruction
You are the DevOps agent. Data loss is a critical failure. Verify backups and connection pooling settings before declaring this complete.

---
End of File
