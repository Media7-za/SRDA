# 1. Task Metadata

## Task Name
Create Password Reset Flow

## File Path
`/ai/tasks/create_password_reset_flow.md`

## Assigned Agent
- Backend Agent

## Priority
- Low (Post-MVP Priority, execute when requested)

## Status
- Not Started

---

# 2. Objective

Implement the "Forgot Password" workflow allowing users to request a password reset, generate a secure token, and submit a new password.

---

# 3. Business Context

Customers inevitably forget passwords. Without a self-serve reset flow, customer support load increases and sales are lost due to login friction.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/agents/backend_agent.md`

---

# 5. Dependencies

- Email sending infrastructure (or a mock logging implementation for MVP).
- `users` table.

---

# 6. Scope

## In Scope
- Create POST `/auth/forgot-password` (accepts email).
- Generate a secure, short-lived reset token.
- Save token (hash or raw based on schema) to DB or rely on a signed JWT sent to email. (Recommendation: Signed JWT containing user ID, sent to email, expiring in 15 mins prevents needing DB schema changes).
- Mock sending the email (log the link to the console for dev).
- Create POST `/auth/reset-password` (accepts token + new password).
- Update and hash the new password.

## Out of Scope
- Real email delivery service integration (e.g., SendGrid/AWS SES) unless explicitly configured.
- Frontend UI.

---

# 7. Inputs
Payload 1 (Forgot): `{ "email": "user@example.com" }`
Payload 2 (Reset): `{ "token": "...", "newPassword": "..." }`

---

# 8. Required Outputs
- Endpoints in `AuthController`.
- Logic in `AuthService`.

---

# 9. Acceptance Criteria
- Requesting a reset for a non-existent email returns success (to prevent email enumeration).
- Reset payload validates the token signature/expiry.
- Password is successfully updated in the DB and hashed.

---

# 10. Implementation Rules
- Never confirm whether an email exists in the system during the `forgot-password` step.
- Tokens must expire quickly (e.g., 15 minutes).

---

# 11. API / Data Contracts
- Standard envelope applies to all responses.

---

# 12. Edge Cases
- Expired tokens.
- Re-using a token (JWTs are stateless, so if using them, consider how to invalidate after use, e.g., using a `password_changed_at` timestamp in DB to invalidate older tokens).

---

# 13. Testing Requirements
- E2E flow test from token generation to successful password change.

---

# 14. Observability / Logging
- Log password reset events.

---

# 15. Security / Permissions
- Both routes are public.

---

# 16. Performance Requirements
- Standard.

---

# 17. Deliverable Format

**Summary**
Explanation of the chosen token strategy (DB persisted vs JWT).

**Files Created/Updated**
Controllers and services.

---

# 18. Completion Checklist
- [ ] Enumeration prevented
- [ ] Token expiration configured
- [ ] Hashing applied to new password

---

# 19. Agent Instruction

Execute this task strictly according to `backend_agent.md`. Security is critical. If using JWTs for reset tokens, ensure they cannot be used as standard login tokens.

---
End of File
