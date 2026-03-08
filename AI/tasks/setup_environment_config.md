# 1. Task Metadata

## Task Name
Setup Environment Config

## File Path
`/ai/tasks/setup_environment_config.md`

## Assigned Agent
- Backend Agent

## Priority
- High

## Status
- Not Started

---

# 2. Objective

Implement robust environment variable validation and configuration management for the backend service.

---

# 3. Business Context

Fail-fast configuration ensures that the server will not boot if critical secrets (like Database URLs, Stripe Secret Keys, or JWT Secrets) are missing, preventing runtime disasters in production.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/agents/backend_agent.md`

---

# 5. Dependencies

- Project scaffolding.

---

# 6. Scope

## In Scope
- Create a configuration validator (e.g., using `zod` or `joi`).
- Define required environment variables (`DATABASE_URL`, `PORT`, `JWT_SECRET`, `STRIPE_SECRET_KEY`, `NODE_ENV`).
- Export a strongly-typed `config` object to be used throughout the backend.
- Create a `.env.example` file.

## Out of Scope
- Setting actual production values.

---

# 7. Inputs
- Project requirements.

---

# 8. Required Outputs
- `src/config/env.ts` (or similar utility).
- Updated `.env.example`.

---

# 9. Acceptance Criteria
- Server booting fails immediately (throws error) if required env variables are missing.
- Configuration is strongly typed (no `process.env.ANYTHING` directly in business logic).
- `.env.example` accurately reflects required keys.

---

# 10. Implementation Rules
- Centralize all `process.env` access into one file.
- Provide sensible defaults where safe (e.g., `PORT=3000`).

---

# 11. API / Data Contracts
- Not applicable.

---

# 12. Edge Cases
- Invalid formats (e.g., PORT is a string but needs to be parsed as a number).

---

# 13. Testing Requirements
- Unit test the config loader (mocking `process.env`).

---

# 14. Observability / Logging
- Log a success message when configuration successfully loads (do NOT log the values themselves).

---

# 15. Security / Permissions
- Never log secrets.
- Ensure `.env` is in `.gitignore`.

---

# 16. Performance Requirements
- Negligible boot-time cost.

---

# 17. Deliverable Format

**Summary**
Explanation of the validation library chosen.

**Implementation Notes**
List of defined configuration keys.

---

# 18. Completion Checklist
- [ ] Centralized config implemented
- [ ] Validation library used
- [ ] App fails fast on missing keys

---

# 19. Agent Instruction

Execute this task strictly according to `backend_agent.md`. This is a critical security and stability foundation.

---
End of File
