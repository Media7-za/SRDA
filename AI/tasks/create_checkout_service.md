# 1. Task Metadata

## Task Name
Create Checkout Service

## File Path
`/ai/tasks/create_checkout_service.md`

## Assigned Agent
- Backend Agent

## Priority
- Critical

## Status
- Not Started

---

# 2. Objective

Implement the critical boundary where a Cart is converted into a pending Order. This service solidifies the order snapshot, checking delivery availability and calculating final fees before handing off to the payment gateway.

---

# 3. Business Context

The checkout boundary is where financial intent becomes a logged transaction. The business must ensure that what the customer pays for is perfectly snapshotted so historical records remain accurate regardless of future menu price changes.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/agents/backend_agent.md`
- `/ai/architecture.md` (Commerce Rules & Snapshots)

---

# 5. Dependencies

- `create_cart_service.md`
- Complete Database setup (Orders and OrderItems tables with snapshot columns).

---

# 6. Scope

## In Scope
- Create `CheckoutService.processCheckout(cart, user/guest, fulfillmentType, address)`.
- Re-validate the cart one final time (prices and availability).
- If `delivery`, calculate distance and apply the delivery fee band.
- Generate SNAPSHOT records: copy `name` and `price` from `menu_items` into `order_items`.
- Create a `pending` record in the `orders` table.
- Clear the cart state.

## Out of Scope
- Actually processing the Stripe payment or taking in-store payment (this task just preps the order and calculates the final total). 

---

# 7. Inputs
- A validated Cart object.
- Fulfillment type (`delivery` or `collection`).
- User ID (if authenticated) or Guest contact details.
- Delivery Address (if `delivery`).

---

# 8. Required Outputs
- `CheckoutService` with snapshotting logic.
- API Endpoint (e.g., `POST /checkout/initiate`).

---

# 9. Acceptance Criteria
- Order creation fails if any item is unavailable.
- Order is saved in the database with status `pending`.
- `order_items` contains exact copies of the `store_price` and `item_name` at the time of checkout.
- Order includes `delivery_fee` and `delivery_distance_meters` if fulfillment is delivery.
- Success returns the `orderId` and final total to the frontend (ready for payment intent).

---

# 10. Implementation Rules
- **CRITICAL INVARIANT:** You MUST map `menuItem.price` -> `orderItem.item_price`. You MUST NOT rely on foreign keys to `menu_items` to calculate the order's historical total.

---

# 11. API / Data Contracts
Response returns the initialized Order:
```json
{
  "success": true,
  "data": {
    "orderId": "uuid",
    "totalAmount": 200.00
  },
  "error": null
}
```

---

# 12. Edge Cases
- Item goes out of stock exactly during the checkout transaction.
- Delivery requested, but distance exceeds max delivery radius (reject it).

---

# 13. Testing Requirements
- **Crucial:** Unit test the snapshotting process. Change the `menu_items` price in the DB *after* the order is created, and assert the order total does *not* change.
- Integration test for delivery fee calculation.

---

# 14. Observability / Logging
- Log checkout initiated.
- Log distance limitation rejections.

---

# 15. Security / Permissions
- Available to guests and authenticated users.

---

# 16. Performance Requirements
- Wrap order creation in a database transaction to prevent orphaned order items if something fails.

---

# 17. Deliverable Format
Standard backend implementation.

---

# 18. Completion Checklist
- [ ] Snapshot architecture invariant respected
- [ ] Delivery validation enforced
- [ ] DB Transaction used for creation

---

# 19. Agent Instruction
Execute this task strictly according to `backend_agent.md`. The Architect Agent has mandated that checkout is the most critical logic in the app. Snapshotting must be flawless.

---
End of File
