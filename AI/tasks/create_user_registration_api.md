# 1. Task Metadata

## Task Name
Create User Registration API

## File Path
`/ai/tasks/create_user_registration_api.md`

## Assigned Agent
- Backend Agent

## Priority
- High

## Status
- Not Started

---

# 2. Objective

Implement the `/auth/register` API endpoint to allow new customers to create accounts. Passwords must be hashed using bcrypt before insertion into the database.

---

# 3. Business Context

Customer accounts are required for order tracking, saving addresses, and eventually loyalty programs. Secure registration is the first step in the customer journey.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/agents/backend_agent.md`
- `/ai/architecture.md`
- `/ai/tasks/design_authentication_system.md` (Design specifications)

---

# 5. Dependencies

- Database schema finalized (`users` table exists).
- Backend framework initialized (`server.ts` exists).

---

# 6. Scope

## In Scope
- Create POST `/auth/register` route.
- Validate request payload (email format, password strength).
- Check if email is already registered (return 409 Conflict if so).
- Hash password using `bcrypt` (salt rounds: 10 or 12).
- Insert user into database with default role `customer`.
- Return standard success envelope with user data (EXCLUDING password hash).

## Out of Scope
- Email verification flow (deferred for MVP).
- Login generation (user must log in explicitly after registration for now, or you can optionally issue a JWT immediately if standard practice dictates).

---

# 7. Inputs
Request Payload:
```json
{
  "email": "user@example.com",
  "password": "securepassword123",
  "firstName": "John",
  "lastName": "Doe",
  "phone": "+27821234567"
}
```

---

# 8. Required Outputs
- `AuthController` or similar route handler.
- `AuthService` containing the hashing and DB logic.
- Input validation schema (e.g., Zod).

---

# 9. Acceptance Criteria
- Valid payload creates a user in the DB with hashed password.
- Duplicate email returns a clear error without crashing.
- `password_hash` is NEVER returned in the API response.
- Response uses standard envelope.

---

# 10. Implementation Rules
- Keep controllers thin; put hashing and DB saving in `AuthService`.
- Extract salt rounds configuration to environment variables if possible, fallback to 10.

---

# 11. API / Data Contracts
Response (Success):
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "role": "customer",
      "firstName": "John"
    }
  },
  "error": null
}
```

---

# 12. Edge Cases
- Missing payload fields.
- Extremely long passwords (prevent DoS on bcrypt).

---

# 13. Testing Requirements
- Unit test AuthService hashing and DB call.
- Integration test POST `/auth/register` with valid, invalid, and duplicate payloads.

---

# 14. Observability / Logging
- Log successful registrations.
- Log duplicate email attempts as warnings.

---

# 15. Security / Permissions
- Endpoint must be public (no auth required to register).

---

# 16. Performance Requirements
- Bcrypt hashing should be performed asynchronously so as not to block the event loop.

---

# 17. Deliverable Format

**Summary**
Brief explanation of the registration flow.

**Files Created/Updated**
Routes, controllers, and services touched.

---

# 18. Completion Checklist
- [ ] request payload validated
- [ ] password hashed
- [ ] hash excluded from response
- [ ] tests added

---

# 19. Agent Instruction

Execute this task strictly according to `backend_agent.md`. Security is paramount here; double-check that no plain-text passwords or hashes leak anywhere.

---
End of File
