# 1. Task Metadata

## Task Name
Create Project Structure (Backend)

## File Path
`/ai/tasks/create_project_structure.md`

## Assigned Agent
- Backend Agent

## Priority
- High

## Status
- Not Started

---

# 2. Objective

Define the internal directory structure for the `backend/` workspace, ensuring it follows the layered architecture defined by the Architect Agent (Controllers, Services, Repositories).

---

# 3. Business Context

A clean, modular structure ensures the codebase remains maintainable as the project scales. It enforces clear boundaries between routing, business logic, and database access.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/agents/backend_agent.md`
- `/docs/PRD_Core.md`

---

# 5. Dependencies

- Project Scaffolding workspace setup (`00_create_project_scaffold.md` - ✅ Complete)

---

# 6. Scope

## In Scope
- Create `/src` directory inside the `backend/` package.
- Create subdirectories: `controllers`, `services`, `repositories`, `routes`, `middleware`, `types`, `utils`.
- Create placeholder `index.ts` files or READMEs in each folder explaining their purpose.
- Initialize `server.ts` entry point placeholder.

## Out of Scope
- Actually implementing the framework (done in next task).
- Modifying monorepo package configurations (already done).

---

# 7. Inputs
- `backend_agent.md` Layer Responsibilities.

---

# 8. Required Outputs
- Directory structure created in `/backend/src/`.
- File structure documented.

---

# 9. Acceptance Criteria
- `backend/src` exists with all required layered subdirectories.
- Controllers, Services, and Repositories are clearly separated.

---

# 10. Implementation Rules
- Follow the exact structure defined in `backend_agent.md`.

---

# 11. API / Data Contracts
- Not applicable.

---

# 12. Edge Cases
- None.

---

# 13. Testing Requirements
- Basic test to ensure structure exists.

---

# 14. Observability / Logging
- None.

---

# 15. Security / Permissions
- None.

---

# 16. Performance Requirements
- None.

---

# 17. Deliverable Format

**Summary**
Brief explanation of the folder structure created.

**Files Created updated**
List of directories and placeholder files.

---

# 18. Completion Checklist
- [ ] required context files were read
- [ ] directories match architecture rules

---

# 19. Agent Instruction

Execute this task strictly according to `backend_agent.md`. You are establishing the scaffolding for all future backend work.

---
End of File
