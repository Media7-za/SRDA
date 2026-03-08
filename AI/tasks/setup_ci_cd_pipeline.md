# 1. Task Metadata

## Task Name
Setup CI/CD Pipeline

## File Path
`/ai/tasks/setup_ci_cd_pipeline.md`

## Assigned Agent
- DevOps Agent

## Priority
- Medium (Fast-follower to core deployment)

## Status
- Not Started

---

# 2. Objective

Automate the testing, type-checking, and migration processes to ensure broken code cannot be deployed to the `main` or production branch.

---

# 3. Business Context

Automation prevents manual errors. A red CI build protects the business from deploying a bug that breaks the checkout flow.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agents/devops_agent.md`

---

# 5. Dependencies

- Hosting platforms attached to Git repository (e.g. GitHub Actions, Vercel standard pipeline).

---

# 6. Scope

## In Scope
- Create `.github/workflows/main.yml` (or equivalent).
- Define jobs for: `pnpm install`, `pnpm build`, `pnpm test`.
- Add a specific step to run `npx prisma generate` to ensure types compile.
- Ensure the pipeline fails if Jest tests or Playwright E2E tests fail.

## Out of Scope
- Actually hosting the final web traffic (done by Vercel/Railway).

---

# 7. Inputs
- GitHub branch pushes and Pull Requests.

---

# 8. Required Outputs
- Valid YAML workflow file.

---

# 9. Acceptance Criteria
- Pushing a broken test to an active PR blocks the merge button in GitHub.
- Type errors in TS prevent successful builds.

---

# 10. Implementation Rules
- Utilize actions cache (`actions/setup-node` with pnpm caching) to keep pipeline execution times under 5 minutes.

---

# 11. API / Data Contracts
N/A

---

# 12. Edge Cases
- CI running E2E tests might need a temporary Postgres database. Use a `docker-compose` service directly inside the GitHub Action.

---

# 13. Testing Requirements
- N/A (this *is* the testing requirement).

---

# 14. Observability / Logging
- GitHub Actions logs.

---

# 15. Security / Permissions
- Pass in non-production 'Test' keys for the CI environment variables securely via GitHub Secrets.

---

# 16. Performance Requirements
- Keep it fast so developer feedback loop isn't frustrating.

---

# 17. Deliverable Format
YML Workflow files.

---

# 18. Completion Checklist
- [ ] TS Compilation check
- [ ] Test runner executed
- [ ] Caching implemented

---

# 19. Agent Instruction
You are the DevOps Agent. Make the pipeline strict regarding logic, but forgiving regarding speed. Time is money.

---
End of File
