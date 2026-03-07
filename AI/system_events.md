# System Events Specification
## Project: Restaurant Ordering & Delivery Platform

This document defines the **canonical event model** for the platform.

Events describe **important state changes** in the system and act as the communication layer between modules.

Events are used for:

- realtime updates
- notifications
- logging
- analytics
- background jobs
- integrations

All AI agents must use these event names and payload structures when publishing or reacting to system events.

If a new event is required, it must be added to this file.

---

# 1. Event Design Principles

## 1.1 Events Represent Facts

Events describe something that **already happened**.

Correct:

```
OrderCreated
PaymentSucceeded
DriverAssigned
```

Incorrect:

```
CreateOrder
ProcessPayment
```

Commands tell the system what to do.
Events record what happened.

## 1.2 Events Must Be Immutable

Events must never be modified after publication.

They represent a historical record.

## 1.3 Events Must Be Past Tense

Events must follow this naming convention:

Noun + PastTenseVerb

Examples:

```
OrderCreated
PaymentSucceeded
OrderCancelled
DriverLocationUpdated
```

## 1.4 Events Must Contain Minimal Necessary Data

Events must include:

* entity identifiers
* timestamps
* relevant metadata

They must not include large payloads or redundant data.

---

# 2. Event Structure

All events must follow this structure.

Example event envelope:

```json
{
  "event_id": "uuid",
  "event_type": "OrderCreated",
  "occurred_at": "2026-03-06T12:00:00Z",
  "source": "order-service",
  "data": {}
}
```

Required fields:

| Field | Description |
| :--- | :--- |
| `event_id` | unique event identifier |
| `event_type` | canonical event name |
| `occurred_at` | ISO timestamp |
| `source` | module that emitted event |
| `data` | event payload |

---

# 3. Event Categories

Events are grouped by domain.

* Authentication Events
* User Events
* Restaurant Events
* Menu Events
* Cart Events
* Order Events
* Payment Events
* Delivery Events
* Driver Events
* Notification Events
* System Events

---

# 4. Authentication Events

## `UserRegistered`
Emitted when a new account is created.
Payload:
```json
{
  "user_id": "uuid",
  "email": "user@example.com"
}
```

## `UserLoggedIn`
Emitted after successful login.
Payload:
```json
{
  "user_id": "uuid"
}
```

---

# 5. Restaurant Events

## `RestaurantUpdated`
Emitted when restaurant configuration changes.
Payload:
```json
{
  "restaurant_id": "uuid"
}
```

---

# 6. Menu Events

## `MenuItemCreated`
Payload:
```json
{
  "menu_item_id": "uuid",
  "restaurant_id": "uuid"
}
```

## `MenuItemUpdated`
Payload:
```json
{
  "menu_item_id": "uuid",
  "restaurant_id": "uuid"
}
```

## `MenuItemAvailabilityChanged`
Payload:
```json
{
  "menu_item_id": "uuid",
  "available": true
}
```

---

# 7. Cart Events

Cart events are primarily useful for analytics and experimentation.

## `CartItemAdded`
Payload:
```json
{
  "cart_id": "uuid",
  "menu_item_id": "uuid",
  "quantity": 1
}
```

## `CartItemRemoved`
Payload:
```json
{
  "cart_id": "uuid",
  "menu_item_id": "uuid"
}
```

---

# 8. Order Events

Order events represent the core commerce lifecycle.

## `OrderCreated`
Triggered when a pending order is created.
Payload:
```json
{
  "order_id": "uuid",
  "restaurant_id": "uuid",
  "user_id": "uuid",
  "status": "pending"
}
```

## `OrderConfirmed`
Triggered after payment verification.
Payload:
```json
{
  "order_id": "uuid"
}
```

## `OrderPreparing`
Triggered when restaurant begins preparation.
Payload:
```json
{
  "order_id": "uuid"
}
```

## `OrderReadyForPickup`
Payload:
```json
{
  "order_id": "uuid"
}
```

## `OrderOutForDelivery`
Payload:
```json
{
  "order_id": "uuid",
  "driver_id": "uuid"
}
```

## `OrderDelivered`
Payload:
```json
{
  "order_id": "uuid"
}
```

## `OrderCancelled`
Payload:
```json
{
  "order_id": "uuid",
  "reason": "string"
}
```

---

# 9. Payment Events

## `PaymentIntentCreated`
Payload:
```json
{
  "payment_id": "uuid",
  "order_id": "uuid",
  "amount": 0
}
```

## `PaymentProcessing`
Payload:
```json
{
  "payment_id": "uuid",
  "order_id": "uuid"
}
```

## `PaymentSucceeded`
Triggered when Stripe webhook verifies payment.
Payload:
```json
{
  "payment_id": "uuid",
  "order_id": "uuid"
}
```

## `PaymentFailed`
Payload:
```json
{
  "payment_id": "uuid",
  "order_id": "uuid",
  "reason": "string"
}
```

---

# 10. Delivery Events

## `DeliveryCreated`
Payload:
```json
{
  "delivery_id": "uuid",
  "order_id": "uuid"
}
```

## `DeliveryAssigned`
Payload:
```json
{
  "delivery_id": "uuid",
  "driver_id": "uuid"
}
```

## `DeliveryPickedUp`
Payload:
```json
{
  "delivery_id": "uuid",
  "driver_id": "uuid"
}
```

## `DeliveryCompleted`
Payload:
```json
{
  "delivery_id": "uuid"
}
```

---

# 11. Driver Events

## `DriverLocationUpdated`
Payload:
```json
{
  "driver_id": "uuid",
  "latitude": 0,
  "longitude": 0
}
```

## `DriverOnline`
Payload:
```json
{
  "driver_id": "uuid"
}
```

## `DriverOffline`
Payload:
```json
{
  "driver_id": "uuid"
}
```

---

# 12. Notification Events

These events trigger outbound communication.

## `OrderConfirmationNotificationRequested`
Payload:
```json
{
  "order_id": "uuid",
  "user_id": "uuid"
}
```

## `OrderStatusNotificationRequested`
Payload:
```json
{
  "order_id": "uuid",
  "status": "string"
}
```

---

# 13. System Events

## `SystemErrorOccurred`
Payload:
```json
{
  "service": "string",
  "message": "string"
}
```

## `HealthCheckExecuted`
Payload:
```json
{
  "service": "string"
}
```

---

# 14. Event Publishing Rules

Events must be published when the following actions occur:

| Action | Event |
| :--- | :--- |
| user registers | `UserRegistered` |
| menu item created | `MenuItemCreated` |
| order created | `OrderCreated` |
| payment confirmed | `PaymentSucceeded` |
| driver assigned | `DeliveryAssigned` |
| driver sends location | `DriverLocationUpdated` |

---

# 15. Event Consumers

Typical consumers include:

* Realtime service
* Notification service
* Analytics pipeline
* Logging system
* Admin dashboards

---

# 16. Realtime Channels

Events may be streamed through realtime channels.

Channel examples:

```
order:{order_id}
driver:{driver_id}
restaurant:{restaurant_id}
```

---

# 17. Event Versioning

Future versions may include:

```json
{
  "event_version": "1.0"
}
```

This allows backward compatibility if payload formats change.

---

# 18. Event Naming Authority

New events must follow naming conventions defined here.

Agents must not invent ad-hoc event names.

All new events must be added to this document.

---

# 19. Relationship to Other Documents

This file complements:

* `/ai/domain_invariants.md`
* `/ai/architecture.md`
* `/ai/implementation_decisions.md`

Roles:

* `architecture.md` → system structure
* `domain_invariants.md` → domain laws
* `system_events.md` → state change communication
* `implementation_decisions.md` → technology choices

---

# Final Rule

System events represent the observable behavior of the platform.

They must remain:

* consistent
* well named
* stable
* versionable

Incorrect event design leads to:

* broken realtime updates
* inconsistent notifications
* analytics inaccuracies
* difficult debugging

Agents must follow this specification strictly.

End of File
