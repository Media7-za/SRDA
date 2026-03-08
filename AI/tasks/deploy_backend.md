# 1. Task Metadata

## Task Name
Deploy Backend Worker/API

## File Path
`/ai/tasks/deploy_backend.md`

## Assigned Agent
- DevOps Agent

## Priority
- High

## Status
- Not Started

---

# 2. Objective

Deploy the Node.js/TypeScript backend process (Express/Fastify) to a production environment (like Railway, Render, or an AWS EC2 instance). 

*(Note: If the backend is built entirely as Next.js API Routes within the frontend monorepo, this task merges with the Frontend deployment. Assuming a decoupled architecture based on prior backend agent rules.)*

---

# 3. Business Context

The APIs must remain online, scale cleanly under Friday night demand, and accurately process Webhooks.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agents/devops_agent.md`

---

# 5. Dependencies

- `setup_environment_variables.md`
- `setup_production_database.md`

---

# 6. Scope

## In Scope
- Write a `Dockerfile` (or use cloud provider runtime defaults like `nixpacks` on Railway).
- Configure build command (`pnpm build`) and start command (`pnpm start:prod`).
- Ensure `npx prisma generate` runs during the build step.
- Verify health check route (`/health`) returns 200 OK after deployment.

## Out of Scope
- Domain DNS setup (though it usually follows immediately).

---

# 7. Inputs
- Infrastructure dashboard.

---

# 8. Required Outputs
- `Dockerfile` or `engine` definitions in `package.json`.
- Live API URL.

---

# 9. Acceptance Criteria
- Application builds without TS errors in the cloud.
- Process stays running (doesn't crash loop).
- `/health` endpoint is publicly reachable and returns a 200 payload.

---

# 10. Implementation Rules
- Set the `NODE_ENV=production` explicitly to optimize Node performance (Express caching, logging reduction).

---

# 11. API / Data Contracts
N/A

---

# 12. Edge Cases
- Missing Prisma client due to skipped build step (ensure postinstall or build scripts explicitly generate it).

---

# 13. Testing Requirements
- E2E smoke test verifying a live public route against the production URL.

---

# 14. Observability / Logging
- Ensure standard out/standard error logs are captured by the hosting provider's dashboard metrics.

---

# 15. Security / Permissions
- Standard HTTPS/TLS must be active on the public interface.

---

# 16. Performance Requirements
- Check memory limits. If deploying on 512MB RAM, monitor the JS heap size closely during peak webhook events.

---

# 17. Deliverable Format
Deployed service and URL.

---

# 18. Completion Checklist
- [ ] Build script succeeded
- [ ] Prisma client generated in container
- [ ] NODE_ENV="production"
- [ ] Healthcheck passes

---

# 19. Agent Instruction
You are the DevOps Agent. Ensure the deployment handles graceful shutdowns cleanly, preventing dropped webhooks if the platform cycles the server instances.

---
End of File
