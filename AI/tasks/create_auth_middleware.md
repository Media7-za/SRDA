# 1. Task Metadata

## Task Name
Create Auth Middleware & Role Guard

## File Path
`/ai/tasks/create_auth_middleware.md`

## Assigned Agent
- Backend Agent

## Priority
- High

## Status
- Not Started

---

# 2. Objective

Create Express/Fastify middleware to extract and verify JWTs from incoming requests, and create a Role-Based Access Control (RBAC) guard to protect routes.

---

# 3. Business Context

Many APIs (like viewing order history or updating store status) must be strictly protected. Middleware ensures auth logic is centralized and applied safely across the application without duplicating code in every controller.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/agents/backend_agent.md`
- `/ai/tasks/design_authentication_system.md` (RBAC rules)

---

# 5. Dependencies

- JWT utilities created in `create_login_api.md`.

---

# 6. Scope

## In Scope
- Create `requireAuth` middleware to verify Bearer tokens from the `Authorization` header.
- Extend the `Request` object type in TypeScript to include the decoded `user` payload.
- Create a `requireRole(allowedRoles[])` middleware factory to enforce RBAC.
- Handle expired or invalid tokens cleanly.

## Out of Scope
- Applying middleware to every route (this task only *creates* the tools; applying them happens when specific feature APIs are built).

---

# 7. Inputs
- HTTP Headers (`Authorization: Bearer <token>`).

---

# 8. Required Outputs
- `src/middleware/auth.ts` containing the middleware functions.
- Custom type definitions for Express Request.

---

# 9. Acceptance Criteria
- `requireAuth` blocks requests without tokens or with invalid/expired tokens (Returns 401).
- valid tokens inject the decoded user payload into `req.user`.
- `requireRole(['admin'])` blocks a request from a user with a `customer` role (Returns 403 Forbidden).
- Responses adhere to the standard envelope.

---

# 10. Implementation Rules
- Keep the middleware thin. If DB lookup is required (e.g., to ensure user wasn't deleted since token issuance), do it efficiently or rely purely on stateless JWT claims if MVP allows. For MVP, stateless is preferred unless PRD dictates otherwise.

---

# 11. API / Data Contracts
- 401 format: `{ success: false, data: null, error: { message: "Unauthorized", code: "UNAUTHORIZED" } }`
- 403 format: `{ success: false, data: null, error: { message: "Forbidden", code: "FORBIDDEN" } }`

---

# 12. Edge Cases
- Malformed Authorization headers (e.g., missing "Bearer " prefix).

---

# 13. Testing Requirements
- Unit test the middleware functions using mock Request/Response objects.

---

# 14. Observability / Logging
- Log 403 Forbidden attempts (potential security probing).

---

# 15. Security / Permissions
- This task *is* the security implementation.

---

# 16. Performance Requirements
- Middleware must execute quickly on every protected request.

---

# 17. Deliverable Format

**Summary**
Explanation of how to use the middleware in route definitions.

**Files Created/Updated**
Middleware files.

---

# 18. Completion Checklist
- [ ] Request object typing updated
- [ ] Bearer token extraction implemented
- [ ] Role guarding implemented
- [ ] Tests added

---

# 19. Agent Instruction

Execute this task strictly according to `backend_agent.md`. Provide a clear example in the summary of how a developer should attach this middleware to a route.

---
End of File
