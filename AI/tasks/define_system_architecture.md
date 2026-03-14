# 1. Task Metadata

## Task Name
Define System Architecture

## File Path
`/ai/tasks/define_system_architecture.md`

## Assigned Agent
- Architect Agent

## Priority
- Critical

## Status
- Not Started

---

# 2. Objective

Formally define the system architecture, service isolation, and technical stack boundaries for the platform. This task provides the high-level blueprint for all other designs.

---

# 3. Business Context

A stable, modular architecture ensures that as the platform grows (e.g., adding multi-restaurant support), the core logic remains maintainable and scalable.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/docs/PRD_Core.md`
- `/ai/agents/architect_agent.md`
- `/ai/architecture.md` (existing baseline)

---

# 5. Dependencies

- Project Scaffolding (✅ Complete)

---

# 6. Scope

## In Scope
- Define high-level service architecture (UserService, MenuService, OrderService, etc.).
- Define inter-service communication patterns.
- Confirm final technology stack choices.
- Define scalability strategies for multi-tenancy.

## Out of Scope
- Code implementation.
- Detailed database schema (covered in a separate task).
- Specific UI component design.

---

# 7. Inputs
- Project PRD
- Existing `/ai/architecture.md`

---

# 8. Required Outputs
- System Architecture Overview document updated/finalized.
- Service layer responsibility definitions.
- Technology stack confirmation.

---

# 9. Acceptance Criteria
- Architecture supports a single-restaurant MVP but is extensible to multi-tenant SaaS.
- Modular service design ensures isolation.
- Architecture adheres to all Commerce Architecture Audit priorities in `architect_agent.md`.

---

# 10. Implementation Rules
- Simplicity first.
- Modular services.
- API-first development.

---

# 11. API / Data Contracts
- Not applicable.

---

# 12. Edge Cases
- Multi-restaurant data isolation strategy.
- Offline-first considerations (if any, though focused on Web/Cloud).

---

# 13. Testing Requirements
- Architecture review for invariant violations.

---

# 14. Observability / Logging
- None for design.

---

# 15. Security / Permissions
- Define high-level auth boundaries.

---

# 16. Performance Requirements
- Standard MVP performance expectations apply.

---

# 17. Deliverable Format

**Summary**
Brief explanation of the architecture.

**Architecture Document**
Updated specifications.

---

# 18. Completion Checklist
- [ ] required context files were read
- [ ] implementation follows architecture rules
- [ ] acceptance criteria passed
- [ ] no out-of-scope work was added

---

# 19. Agent Instruction

Execute this task strictly according to `architect_agent.md`. Focus on building a scalable foundation.

---
End of File
