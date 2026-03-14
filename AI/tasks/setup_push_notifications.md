# 1. Task Metadata

## Task Name
Setup Push Notifications

## File Path
`/ai/tasks/setup_push_notifications.md`

## Assigned Agent
- Backend Agent

## Priority
- Medium (Post-MVP or V1 feature)

## Status
- Not Started

---

# 2. Objective

Integrate a push notification provider (e.g., Firebase Cloud Messaging - FCM, or OneSignal) to send alerts to the mobile app (Flutter) or web app.

---

# 3. Business Context

Real-time tracking is active, but push notifications passively alert users that their food is outside without requiring them to stare at the screen. It also allows staff to be alerted when a new order arrives.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/docs/PRD_Core.md`

---

# 5. Dependencies

- User database schema finalized.
- Backend framework running.

---

# 6. Scope

## In Scope
- Add a `fcm_tokens` array or related table/column to the `users` table to store device tokens.
- Create an API endpoint (`POST /users/devices`) for the frontend to register its push token.
- Initialize the FCM (or chosen provider) Admin SDK in the backend project.
- Create a reusable utility `NotificationSender.send(userId, title, body, dataPayload)`.

## Out of Scope
- Actually hooking the utility into the order flow (done in the next task).
- Frontend implementation of asking for notification permissions.

---

# 7. Inputs
Payload for registering a device:
```json
{
  "token": "dck9_abc123..."
}
```

---

# 8. Required Outputs
- `NotificationService` wrapper initialized with credentials.
- Device registration endpoint.
- Database changes if tracking multiple devices per user.

---

# 9. Acceptance Criteria
- Device tokens can be saved and associated with a signed-in user.
- The `NotificationSender` utility successfully pushes a test message to the provider's API.
- If a token is discovered to be invalid/expired by the provider's response, it is removed from the database.

---

# 10. Implementation Rules
- Store push credentials securely via environment variables (e.g., passing a service account JSON payload as a base64 string in `.env`).

---

# 11. API / Data Contracts
```json
POST /users/devices
{ "token": "string" }
```

---

# 12. Edge Cases
- A user logging in on multiple devices (appends token).
- A user logging out (endpoint needed to deregister token: `DELETE /users/devices/:token`).

---

# 13. Testing Requirements
- Unit test the cleanup logic for expired tokens.
- Mock the specific Provider SDK to ensure it is called correctly.

---

# 14. Observability / Logging
- Log provider errors (e.g., "FCM Error: NotRegistered").

---

# 15. Security / Permissions
- Device registration requires JWT authentication.

---

# 16. Performance Requirements
- Push notification HTTP calls must be deeply decoupled (async, non-blocking) from the main request thread.

---

# 17. Deliverable Format
Standard backend implementation.

---

# 18. Completion Checklist
- [ ] Token registration API created
- [ ] Token deregistration handled
- [ ] Provider SDK wired up
- [ ] Non-blocking utility prepared

---

# 19. Agent Instruction
Execute this task strictly according to `backend_agent.md`. Never block an HTTP response while waiting for Firebase/Apple to confirm a push delivery.

---
End of File
