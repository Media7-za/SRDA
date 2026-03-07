# AI Task Template
## Project: Restaurant Ordering & Delivery Platform

Use this template for every task inside `/ai/tasks/`.

This file standardizes how tasks are written so all AI agents execute work consistently.

---

# 1. Task Metadata

## Task Name
[Short clear task name]

## File Path
`/ai/tasks/[task_file_name].md`

## Assigned Agent
- Architect Agent
- Backend Agent
- Frontend Agent
- QA Agent

## Priority
- Critical
- High
- Medium
- Low

## Status
- Not Started
- In Progress
- Blocked
- Complete

---

# 2. Objective

Describe the exact goal of the task in 1–3 sentences.

Example:

Build the checkout API for the MVP ordering flow.  
This task must validate cart contents, create a pending order, create a Stripe payment intent, and return a checkout response for the frontend.

---

# 3. Business Context

Explain why this task exists and how it supports the product.

Example:

This task enables customers to complete payment for an order.  
It is a core MVP capability and directly supports revenue generation.

---

# 4. Required Context Files

The assigned agent must read these before doing any work:

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/implementation_decisions.md`
- `/docs/PRD.md`

Add any extra required files for the task:

- `/ai/agents/architect_agent.md`
- `/ai/agents/backend_agent.md`
- `/ai/agents/frontend_agent.md`
- `/ai/agents/qa_agent.md`

If any required file is missing, stop and report the blocker.

---

# 5. Dependencies

List files, tasks, APIs, or schemas that must already exist.

Example:

- user authentication must already exist
- order schema must already exist
- Stripe configuration must already exist

If no dependencies exist, state:

- none

---

# 6. Scope

## In Scope
List exactly what must be included.

Example:

- create checkout endpoint
- validate authenticated or guest checkout payload
- create pending order
- create Stripe payment intent
- return payment client secret
- handle validation errors

## Out of Scope
List exactly what is not included.

Example:

- saved payment methods
- subscription billing
- loyalty redemption
- marketplace split payments

---

# 7. Inputs

Describe the expected inputs for this task.

Examples:

- request payload
- database schema
- API contracts
- UI wireframe
- existing service methods

Example format:

```json
{
  "cartItems": [],
  "deliveryAddress": {},
  "contactDetails": {},
  "paymentMethod": "card"
}
```

# 8. Required Outputs

Describe exactly what the agent must produce.

Examples:

- controller
- service
- repository
- API route
- UI screen
- reusable components
- test file
- QA report
- migration
- documentation

Be explicit.

# 9. Acceptance Criteria

Define the task completion rules as testable statements.

Example:

- checkout endpoint exists
- invalid cart returns validation error
- pending order is created before payment
- Stripe payment intent is returned
- order is not marked confirmed before payment success
- all code compiles with strict typing

Use clear pass/fail criteria.

---

# 10. Implementation Rules

Repeat any special rules that apply to this task.

Examples:

- must follow service layer architecture
- controllers must stay thin
- repositories handle database access
- use TypeScript strict mode
- do not invent new schema without approval
- use implementation decisions as source of truth

---

# 11. API / Data Contracts

If the task involves data exchange, define the contract.

Example request:
```json
{
  "items": [
    {
      "menuItemId": "uuid",
      "quantity": 2,
      "selectedOptions": []
    }
  ],
  "addressId": "uuid"
}
```

Example response:
```json
{
  "success": true,
  "data": {
    "orderId": "uuid",
    "paymentIntentClientSecret": "string"
  },
  "error": null
}
```

If not applicable, write:
- not applicable

---

# 12. Edge Cases

List required edge cases the implementation must handle.

Examples:

- empty cart
- invalid menu item
- unavailable item
- price changed before checkout
- missing address
- payment failure
- unauthorized user

This section is mandatory.

---

# 13. Testing Requirements

Define the tests required.

**Unit Tests**

Examples:

- service logic
- utility functions
- reducers/stores

**Integration Tests**

Examples:

- API + DB interaction
- service + repository interaction

**E2E Tests**

Examples:

- full checkout flow
- guest cart flow
- realtime tracking flow

If a test type is not required, say so explicitly.

---

# 14. Observability / Logging

List required logs, analytics events, or audit records.

Examples:

- log order creation
- log payment intent creation
- log payment failure
- log order status change

If none required, say:
- none

---

# 15. Security / Permissions

Define auth and permission rules.

Examples:

- customer may access own order only
- restaurant admin may update restaurant-owned orders only
- public endpoint allowed for guest cart validation
- JWT required for admin routes

This section is mandatory.

---

# 16. Performance Requirements

Define any performance expectations.

Examples:

- paginate list endpoints
- minimize unnecessary rerenders
- cache menu data where appropriate
- avoid N+1 queries
- support 1000+ concurrent sessions

If none specific, write:
- standard MVP performance expectations apply

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
- [ ] tests were added
- [ ] no out-of-scope work was added
- [ ] code is production-ready

---

# 19. Example Agent Instruction

Use this format at the bottom of a real task file:

**Assigned Agent Instruction:**

Execute this task strictly according to:

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/implementation_decisions.md`
- `/docs/PRD.md`

Do not invent architecture, APIs, or schema outside approved documents.

If blocked, report:
- blocker
- impact
- exact missing dependency

---

# 20. Template Usage Rule

Every file in `/ai/tasks/` should:

- use this structure
- be explicit
- avoid ambiguity
- define acceptance criteria
- define edge cases
- define outputs clearly

This ensures all AI agents behave like a coordinated engineering team.

---
End of File