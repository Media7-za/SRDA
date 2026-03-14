---
title: "Build Dashboard Orders API"
description: "Implementation of backend routes necessary for the Live Operations Dashboard"
---

# Objective
Implement the backend routes and logic to handle fetching the Order Board and transitioning Order status across lanes for the `apps/admin` (Restaurant Owner Live Dashboard).

# Context
We just scaffolded the Admin dashboard frontend which requires:
1. Fetching all live, active orders for a given `restaurant_id`
2. Transitioning an order's status securely 
3. Returning properly typed entities mapping to the local UI `OrderCardData`.

# Required Endpoints

### 1. `GET /api/orders/board?restaurant_id={id}`
- **Purpose:** Hydrate the `useOrdersBoardQuery` cache list on initial load.
- **Rules:**
  - Must return all orders that are NOT completely fulfilled and cleared.
  - Returns `pending`, `preparing`, `ready_for_pickup`, `out_for_delivery` by default.
  - Returns today's `delivered` / `cancelled` for the Completed lane logic.
  - Strict JWT validation: Must verify `role = restaurant_owner` (or `restaurant_staff`) and that their `restaurant_id` matches the path/query parameters.

### 2. `PATCH /api/orders/:id/status`
- **Purpose:** Transition orders forward (or backward for rollback) in the dashboard lifecycle state machine.
- **Body Payload:** `{"status": "preparing"}`
- **Rules:**
  - Verify role and tenant ID as above.
  - Validate state machine transitions natively. E.g. A `delivered` order should not transition back to `pending`.
  - For `delivery` fulfillment types, if transitioned to `out_for_delivery`, require driver assignment.
  
# Output Mappings
The payload returned MUST align with the `OrderCardData` type definition in `packages/ui/src/domain/OrderCard.tsx`:
```json
{
  "id": "uuid",
  "orderNumber": "string",
  "customerName": "string",
  "status": "string",
  "fulfillmentType": "[delivery|pickup]",
  "paymentState": "[paid|unpaid|refunded|pay_in_store]",
  "placedAtISO": "iso-date",
  "totalAmount": 120.00,
  "currency": "ZAR",
  ...
}
```

# Realtime Trigger Considerations
The backend must ensure its database operations trigger `pg_notify` / Supabase Realtime channel updates. Supabase covers standard `UPDATE` webhooks, but ensure no soft-deletes or silent data changes bypass these hooks.
