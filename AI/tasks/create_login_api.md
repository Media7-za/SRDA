# 1. Task Metadata

## Task Name
Create Login API

## File Path
`/ai/tasks/create_login_api.md`

## Assigned Agent
- Backend Agent

## Priority
- High

## Status
- Not Started

---

# 2. Objective

Implement the `/auth/login` API endpoint to authenticate users, verify passwords against stored bcrypt hashes, and issue JSON Web Tokens (JWT).

---

# 3. Business Context

Secure login enables customers to access their order history and checkout faster, and restricts restaurant operations to authorized staff.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/agents/backend_agent.md`
- `/ai/tasks/design_authentication_system.md` (Design specifications)

---

# 5. Dependencies

- `create_user_registration_api.md` (User table and hashing strategy established).
- `JWT_SECRET` configured in environment setup.

---

# 6. Scope

## In Scope
- Create POST `/auth/login` route.
- Validate request payload (email, password).
- Lookup user by email.
- Compare provided password with stored hash using `bcrypt.compare`.
- Sign and return a JWT upon success, including `userId` and `role` in the payload.
- Handle invalid credentials securely.

## Out of Scope
- Refresh token rotation (short-lived MVP: tokens can be longer-lived or strictly managed client-side).
- OAuth integrations.

---

# 7. Inputs
Request Payload:
```json
{
  "email": "user@example.com",
  "password": "securepassword123"
}
```

---

# 8. Required Outputs
- Updates to `AuthController` and `AuthService`.
- JWT utility functions (`signToken`, `verifyToken`).

---

# 9. Acceptance Criteria
- Valid credentials return a signed JWT.
- Invalid email or incorrect password both return a generic `401 Unauthorized` (e.g., "Invalid credentials") to prevent user enumeration.
- JWT payload contains necessary identity claims (`sub`: userId, `role`: userRole).
- Response uses standard envelope.

---

# 10. Implementation Rules
- Prevent timing attacks by avoiding early returns explicitly stating "user not found" versus "wrong password".
- Store the `JWT_SECRET` in `.env` and validate it on app startup.

---

# 11. API / Data Contracts
Response (Success):
```json
{
  "success": true,
  "data": {
    "token": "eyJhbG...",
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "role": "customer"
    }
  },
  "error": null
}
```

---

# 12. Edge Cases
- Missing email or password.
- Attempting to login a soft-deleted user (if implemented).

---

# 13. Testing Requirements
- Unit test password comparison logic.
- Integration test valid login and invalid login.

---

# 14. Observability / Logging
- Log failed login attempts (without logging the attempted password).

---

# 15. Security / Permissions
- Public route.

---

# 16. Performance Requirements
- Standard requirements.

---

# 17. Deliverable Format

**Summary**
Brief explanation of the JWT strategy implemented.

**Files Created/Updated**
Routes, controllers, utility functions.

---

# 18. Completion Checklist
- [ ] generic 401 message used for all failures
- [ ] JWT signed correctly
- [ ] secret loaded from config

---

# 19. Agent Instruction

Execute this task strictly according to `backend_agent.md`. Rely on external libraries like `jsonwebtoken` and `bcrypt`.

---
End of File
