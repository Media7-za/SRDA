# Domain Glossary
**Platform:** Restaurant Direct  
**Purpose:** Quick-reference canonical values for all enums, statuses, and key terms.  
**Authority:** `PRD_Core.md` is the authoritative source. This glossary is a convenience reference — if any value here conflicts with `PRD_Core.md`, `PRD_Core.md` wins.  
**Audience:** AI agents and developers needing fast lookup of canonical string values.

---

## OrderStatus

Values permitted in `orders.status`. No other values are valid anywhere in the codebase.

| Value | Description | Terminal? |
|---|---|---|
| `pending` | Order placed, awaiting staff acceptance | No |
| `confirmed` | Staff accepted the order | No |
| `preparing` | Kitchen is preparing the order | No |
| `ready_for_pickup` | Order ready — awaiting driver (delivery) or customer (pickup) | No |
| `out_for_delivery` | Driver has picked up and is en route | No |
| `delivered` | Order completed successfully | **Yes** |
| `cancelled` | Order cancelled | **Yes** |

**Retired / invalid values:** `READY`, `completed`, `DELIVERED`, `ready`, `out-for-delivery` — must not appear anywhere.

---

## DeliveryStatus

Values permitted in `deliveries.status`.

| Value | Owner | Description |
|---|---|---|
| `unassigned` | System | No driver assigned yet |
| `assigned` | Dashboard | Driver assigned, not yet picked up |
| `picked_up` | Driver App | Driver has collected the order |
| `on_the_way` | Driver App | Driver is en route to customer |
| `delivered` | Driver App | Delivery completed |
| `failed` | Dashboard | Delivery could not be completed |

---

## FulfillmentType

Values permitted in `orders.fulfillment_type`.

| Value | Description |
|---|---|
| `delivery` | Restaurant driver delivers to customer |
| `pickup` | Customer collects from restaurant |

**Retired value:** `collection` — permanently retired, must not appear anywhere.

---

## PaymentStatus

Values permitted in `payments.status`.

| Value | Description |
|---|---|
| `intent_created` | Stripe Payment Intent created, payment not yet attempted |
| `processing` | Payment in progress |
| `succeeded` | Payment confirmed via Stripe webhook |
| `failed` | Payment failed |

---

## OrderPaymentStatus

Values permitted in `orders.payment_status`.

| Value | Description |
|---|---|
| `unpaid` | Payment not yet collected (pay in-store orders) |
| `paid` | Payment confirmed |
| `refunded` | Payment refunded |

---

## UserRole

Values permitted in `users.role` and all JWT `role` claims.

| Value | App Access |
|---|---|
| `platform_admin` | Platform Admin Panel only |
| `restaurant_owner` | Owner Portal + Dashboard |
| `restaurant_staff` | Dashboard only |
| `driver` | Driver App only |
| `customer` | Customer App only |

**Retired / invalid values:** `admin`, `staff`, `user`, `manager` — must not appear anywhere.

---

## RestaurantStatus

Values permitted in `restaurants.status`.

| Value | Description |
|---|---|
| `active` | Restaurant live and operational |
| `inactive` | Newly created, not yet activated |
| `suspended` | Platform-suspended — cannot accept orders or log in |

**Note:** `restaurants.is_active` (boolean, daily open/close) is separate from `restaurants.status`. Do not conflate.

---

## FulfillmentType / Modifier / Discount Enums

| Enum | Values |
|---|---|
| `ModifierSelectionType` | `single`, `multiple` |
| `DiscountType` | `percent`, `fixed` |
| `LoyaltyModel` | `points`, `stamp_card` |
| `LoyaltyTransactionType` | `earn`, `redeem` |
| `DevicePlatform` | `android`, `ios` |

---

## Feature Flag Keys

Keys permitted in `restaurants.features` JSONB. No other keys are valid.

| Key | Type | Default | Controls |
|---|---|---|---|
| `loyalty_enabled` | boolean | `false` | Loyalty programme |
| `promotions_enabled` | boolean | `false` | Discount codes |
| `delivery_enabled` | boolean | `true` | Delivery orders |
| `pickup_enabled` | boolean | `true` | Pickup orders |
| `analytics_enabled` | boolean | `false` | Analytics in Owner Portal |
| `earnings_enabled` | boolean | `false` | Driver earnings |

---

## Key Terms

| Term | Definition |
|---|---|
| **Tenant** | A single restaurant on the platform. All data is scoped to `restaurant_id`. |
| **Fulfillment type** | How the order reaches the customer: `delivery` or `pickup`. Never `collection`. |
| **Soft delete** | Setting `deleted_at` timestamp instead of removing a record. Used for `menu_items`. |
| **Optimistic locking** | `orders.version` field. Prevents concurrent overwrites on the same order. |
| **Idempotency key** | Unique key on each checkout request. Prevents duplicate orders on network retry. |
| **Audit token** | Short-lived read-only token allowing Platform Admin to view Owner Portal. Never grants write access or payment endpoint access. |
| **Canonical status** | The exact string value stored in the database and used in API payloads — not the UI display label. |
| **Display label** | The human-readable string shown in the UI. Mapped from canonical status at the presentation layer. |
| **Phase 2** | Features deferred from MVP. Schema tables exist; application logic is not wired. |

---

## Machine Canonical Values

Agents may copy these directly when generating enums, validation arrays, switch statements, or type definitions. Do not reconstruct from the tables above — use these blocks as the source.

```
OrderStatus = [
  "pending",
  "confirmed",
  "preparing",
  "ready_for_pickup",
  "out_for_delivery",
  "delivered",
  "cancelled"
]

DeliveryStatus = [
  "unassigned",
  "assigned",
  "picked_up",
  "on_the_way",
  "delivered",
  "failed"
]

FulfillmentType = [
  "delivery",
  "pickup"
]

OrderPaymentStatus = [
  "unpaid",
  "paid",
  "refunded"
]

PaymentStatus = [
  "intent_created",
  "processing",
  "succeeded",
  "failed"
]

UserRole = [
  "platform_admin",
  "restaurant_owner",
  "restaurant_staff",
  "driver",
  "customer"
]

RestaurantStatus = [
  "active",
  "inactive",
  "suspended"
]

ModifierSelectionType = [
  "single",
  "multiple"
]

DiscountType = [
  "percent",
  "fixed"
]

LoyaltyModel = [
  "points",
  "stamp_card"
]

LoyaltyTransactionType = [
  "earn",
  "redeem"
]

DevicePlatform = [
  "android",
  "ios"
]

FeatureFlagKeys = [
  "loyalty_enabled",
  "promotions_enabled",
  "delivery_enabled",
  "pickup_enabled",
  "analytics_enabled",
  "earnings_enabled"
]

RetiredValues = [
  "collection",      // use "pickup"
  "admin",           // use "restaurant_owner"
  "staff",           // use "restaurant_staff"
  "completed",       // use "delivered"
  "READY",           // use "ready_for_pickup"
  "out-for-delivery" // use "out_for_delivery"
]
```

---

*End of Domain Glossary*
