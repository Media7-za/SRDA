# 1. Task Metadata

## Task Name
Build Checkout Screen

## File Path
`/ai/tasks/build_checkout_screen.md`

## Assigned Agent
- Frontend Agent

## Priority
- Critical

## Status
- Not Started

---

# 2. Objective

Implement the critical `/app/checkout/page.tsx` workflow, covering fulfillment selection (Collection vs Delivery), address input, fetching the finalized order from the backend (Checkout Service), and executing secure payment via Stripe Elements.

---

# 3. Business Context

The checkout is the funnel's bottleneck. Any confusion here equals a lost sale. The UI must be incredibly clear about delivery fees, address validation, and the security of the payment step.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/agents/frontend_agent.md`
- `/ai/architecture.md` (Commerce Invariants, specifically the Payment Webhook logic which dictates that Stripe handles the success).

---

# 5. Dependencies

- Zustand Cart populated via `build_cart_screen.md`.
- Stripe SDK/React Stripe Elements installed (`@stripe/stripe-js`, `@stripe/react-stripe-js`).
- `create_checkout_service.md` API ready to initialize the order.
- `integrate_stripe_payments.md` API ready to return `clientSecret`.

---

# 6. Scope

## In Scope
- Create a multi-step Checkout Form using `react-hook-form` + `zod` for validation.
- Step 1: Authentication / Guest Info (Name, Email, Phone).
- Step 2: Fulfillment (Radio buttons: Delivery vs Collection).
- Step 3: Address Input (conditional, only if Delivery).
- Step 4: Summary + Finalization. Click "Pay" calls `POST /checkout/initiate`.
- Render the Stripe Elements `<PaymentElement />` using the returned `clientSecret`.
- Handle the Stripe `confirmPayment` callback.

## Out of Scope
- Actually processing the charge on our backend.
- Order tracking rendering (next task).

---

# 7. Inputs
- Form input from user.
- Zustand cart.

---

# 8. Required Outputs
- `CheckoutPage` component.
- `CheckoutForm` component powered by RHF/Zod.
- `PaymentIntegration` component wrapping Stripe.

---

# 9. Acceptance Criteria
- Form strictly validates required fields before allowing the "Pay" button to become active.
- Selecting 'Delivery' dynamically reveals the address form.
- The `POST /checkout/initiate` correctly returns the `clientSecret` and the UI swaps to the Stripe Payment Element.
- Successful Stripe confirmation redirects the user to the `Order Tracking` screen using the newly generated `orderId`.

---

# 10. Implementation Rules
- **CRITICAL INVARIANT:** You must never run calculations (like adding a delivery fee to the subtotal) purely on the frontend and send that total to Stripe. The `POST /checkout/initiate` endpoint determines the total safely from the DB snapshot and returns the `clientSecret` based on that immutable calculation.

---

# 11. API / Data Contracts
Consumes `POST /checkout/initiate` returning `{ success: true, data: { orderId, clientSecret, totalAmount... }}`.

---

# 12. Edge Cases
- Payment fails (e.g., declined card) in Stripe: show explicit error message and keep user on the payment screen.
- Cart changes in another tab while this tab is checking out.

---

# 13. Testing Requirements
- E2E testing of the form validation logic.
- Mock the Stripe Elements initialization for unit tests.

---

# 14. Observability / Logging
- None strictly required on frontend, but good to catch and alert on checkout initialization failures.

---

# 15. Security / Permissions
- Never log card details to the console; rely entirely on Stripe Elements.

---

# 16. Performance Requirements
- Prevent double-clicking the "Pay" button (disable it while processing).

---

# 17. Deliverable Format
Next.js pages, RHF hooks, and Stripe wrappers.

---

# 18. Completion Checklist
- [ ] Zod validation strict on address
- [ ] Stripe embedded correctly
- [ ] Form disabled during submit
- [ ] Redirection on success handles `orderId`

---

# 19. Agent Instruction
Execute strictly according to `frontend_agent.md`. Form validation UX is the highest priority here. Field errors must be inline and human-readable.

---
End of File
