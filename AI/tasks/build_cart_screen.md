# 1. Task Metadata

## Task Name
Build Cart Screen

## File Path
`/ai/tasks/build_cart_screen.md`

## Assigned Agent
- Frontend Agent

## Priority
- High

## Status
- Not Started

---

# 2. Objective

Implement the Cart review screen where the user can view their selected items, modify quantities, and see the calculated subtotal before proceeding to checkout.

---

# 3. Business Context

The cart is where users decide if they have ordered enough or too much. Clarity here prevents cart abandonment. It must clearly summarize items and their selected customizations.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agents/frontend_agent.md`

---

# 5. Dependencies

- Zustand Cart Store populated via `build_item_detail_screen.md`.

---

# 6. Scope

## In Scope
- Create `/app/cart/page.tsx` (or a slide-out drawer).
- Read items from Zustand store.
- Render `CartLineItem` components displaying: Name, Selected Options, Unit Price, Total Price, and a Quantity adjuster.
- Calculate and display Subtotal.
- Include an "Empty Cart" empty state.
- Include a "Proceed to Checkout" button.

## Out of Scope
- Calculating delivery fees (done in Checkout).
- Processing payment.

---

# 7. Inputs
- Zustand Cart Store state.

---

# 8. Required Outputs
- `CartPage`/`CartDrawer` component.
- `CartLineItem` component.

---

# 9. Acceptance Criteria
- Adjusting quantity updates the line total and subtotal immediately.
- Reducing quantity to 0 removes the item.
- The UI reflects the empty state gracefully when all items are removed.

---

# 10. Implementation Rules
- If syncing cart with backend (as per backend tasks), ensure mutating the cart triggers the API calls via React Query mutations and optimally updates the UI using optimistic updates.

---

# 11. API / Data Contracts
Consumes `PATCH /cart/items/:lineItemId` and `DELETE /cart/items/:lineItemId` (if using server-side cart), or purely local Zustand state.

---

# 12. Edge Cases
- Item was modified heavily; ensure all selected options fit cleanly in the UI.

---

# 13. Testing Requirements
- Component testing for `CartLineItem` increment/decrement logic.

---

# 14. Observability / Logging
- None.

---

# 15. Security / Permissions
- Public/Session based.

---

# 16. Performance Requirements
- Optimistic UI updates are mandatory if backend cart syncing is active, so the user doesn't wait for a spinner when pressing "+".

---

# 17. Deliverable Format
Next.js page and UI components.

---

# 18. Completion Checklist
- [ ] Line totals correct
- [ ] Empty state polished
- [ ] Optimistic updates implemented

---

# 19. Agent Instruction
Execute strictly according to `frontend_agent.md`.

---
End of File
