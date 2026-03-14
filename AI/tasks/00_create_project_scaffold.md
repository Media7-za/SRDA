# 1. Task Metadata

## Task Name
Project Scaffolding

## File Path
`/ai/tasks/00_create_project_scaffold.md`

## Assigned Agent
- Architect Agent
- Backend Agent
- Frontend Agent

## Priority
- Critical

## Status
- ✅ Complete

---

# 2. Objective

Initialize the foundational monorepo and toolchain for the Restaurant Ordering & Delivery Platform.  
This task must set up the directory structure, base configurations (TypeScript, ESLint, Prettier), and necessary framework scaffolding for the frontend (Next.js) and backend (Node.js + Fastify) according to the architecture guidelines.

---

# 3. Business Context

A standardized, well-configured codebase is essential for a coordinated engineering team.  
This task establishes the foundation upon which all future feature development (database, auth, API, frontend) will be built, ensuring consistency and preventing technical debt early on.

---

# 4. Required Context Files

The assigned agent must read these before doing any work:

- `/ai/context.md`
- `/ai/architecture.md`
- `/ai/agent_rules.md`
- `/ai/implementation_decisions.md`
- `/docs/PRD_Core.md`

If any required file is missing, stop and report the blocker.

---

# 5. Dependencies

- none

---

# 6. Scope

## In Scope

- Initialize the main project monorepo using `pnpm workspaces` (and optionally `turborepo`)
- Setup strict TypeScript configurations (`tsconfig.json`)
- Setup linting and formatting (`eslint.config.js` / `.eslintrc`, `.prettierrc`)
- Initialize the backend (Node + Fastify + TypeScript)
- Initialize the frontend (Next.js + TypeScript)
- Create the locked folder architecture (excluding mobile)
- Add basic `.env.example` with required minimum variables
- Create a simple `GET /health` endpoint for the backend to prove routing works
- Add core developer scripts (`dev`, `build`, `lint`, `format`, `test`)

## Out of Scope

- Database connection setup
- Authentication setup
- API endpoint creation (other than `/health`)
- UI component creation
- Containerization/Docker setup

---

# 7. Inputs

- Technical stack requirements (Next.js, Node + Fastify, pnpm)
- Architecture guidelines

# 8. Required Outputs

- Workspace defined `package.json` at root
- `.gitignore`
- `.env.example` containing at minimum: `DATABASE_URL`, `JWT_SECRET`, `STRIPE_SECRET_KEY`, `NEXT_PUBLIC_API_URL`
- Shared Linter & Formatter configs
- Locked Folder Architecture:
  ```text
  /apps
    /web         (Next.js web application)
  /backend
    /src
      /controllers
      /services
      /repositories
      /routes
  /database
    /schema
    /migrations
  /packages
    /config    (Shared tsconfig, eslint)
  ```
- Functional `GET /health` endpoint in the backend
- Standardized `README.md` for developers

## Mobile Application Note
The Flutter mobile application is **not scaffolded in this task**.
Mobile development will occur in a **separate Flutter repository** that consumes the backend APIs.

# 9. Acceptance Criteria

- repository initializes without errors
- `pnpm install` succeeds
- TypeScript strict mode enabled
- ESLint passes with no errors
- Prettier formats successfully
- `pnpm run dev` starts both frontend and backend dev servers
- `GET /health` endpoint responds correctly with a 200 OK
- folder structure exactly matches the architecture spec

---

# 10. Implementation Rules

- strictly use `pnpm` for package management
- strict TypeScript checks must be enabled (`"strict": true`)
- do not invent new architecture patterns outside approved documents
- keep base dependencies minimal to avoid bloat

---

# 11. API / Data Contracts

`GET /health`
```json
{
  "status": "ok",
  "timestamp": "2026-03-06T12:00:00.000Z"
}
```

---

# 12. Edge Cases

- port conflicts for development servers (ensure configurable ports via `.env` but default backend to 3001 and frontend to 3000)
- node version mismatches (add `.nvmrc` or `engines` in `package.json`)

---

# 13. Testing Requirements

**Unit Tests**
- Verify `/health` endpoint returns 200 via simple test

**Integration Tests**
- Not applicable.

**E2E Tests**
- Not applicable.

---

# 14. Observability / Logging

- log server startup success for frontend and backend

---

# 15. Security / Permissions

- Ensure no secrets or API keys are hardcoded in the generated config files

---

# 16. Performance Requirements

**DX Requirements:**
- Hot reload must work reliably for both backend server and frontend dev server
- Developers must be able to run `pnpm dev` from the root to start the entire stack

---

# 17. Deliverable Format

The assigned agent must return results in this structure:

**Summary**
Brief explanation of what was implemented.

**Files Created or Updated**
List all files.

**Implementation Notes**
Short explanation of key logic decisions.

**Tests**
List tests added and what they cover.

**Risks / Follow-ups**
List any remaining concerns or next steps.

---

# 18. Completion Checklist

Before marking the task complete, verify:

- [ ] required context files were read
- [ ] dependencies were satisfied
- [ ] implementation follows architecture rules
- [ ] implementation follows implementation decisions
- [ ] outputs were produced
- [ ] acceptance criteria passed
- [ ] tests were added (if applicable)
- [ ] no out-of-scope work was added
- [ ] code is production-ready (configuration level)

---

# 19. Example Agent Instruction

**Assigned Agent Instruction:**

Execute this task strictly according to:

- `/ai/context.md`
- `/ai/architecture.md`
- `/ai/agent_rules.md`
- `/ai/implementation_decisions.md`
- `/docs/PRD_Core.md`

Do not invent architecture, APIs, or schema outside approved documents.

If blocked, report:
- blocker
- impact
- exact missing dependency

---
End of File
