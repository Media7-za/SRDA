# API Contracts
**Platform:** Restaurant Direct  
**Authority:** These shapes are locked. Agents must not invent, extend, or abbreviate these contracts without updating this document first.  
**Source of truth hierarchy:** `PRD_Core.md` → `domain_glossary.md` → `api_contracts.md` → surface PRDs  
**Audience:** All AI coding agents — backend, frontend, and database agents.

---

## Rules

```
1. Every API response uses the global envelope (see Section 1).
2. Field names use camelCase in JSON payloads and TypeScript types.
3. Field names use snake_case in the database (Prisma handles mapping).
4. No endpoint may return a field not listed in its contract below.
5. No endpoint may accept a request body field not listed in its contract.
6. Enum values in payloads must match domain_glossary.md canonical values exactly.
7. All money fields are decimal strings in JSON — never floats. (e.g. "125.00")
8. All timestamps are ISO 8601 UTC strings. (e.g. "2026-03-08T14:22:00Z")
9. Nullable fields must be explicitly included as null — never omitted.
10. version field must be included on every order mutation request and response.
```

---

## Table of Contents

1. [Global Response Envelope](#1-global-response-envelope)
2. [Auth Contracts](#2-auth-contracts)
3. [Order Contracts](#3-order-contracts)
4. [Dashboard Board Contracts](#4-dashboard-board-contracts)
5. [Realtime Event Contracts](#5-realtime-event-contracts)
6. [Menu Contracts](#6-menu-contracts)
7. [Driver Contracts](#7-driver-contracts)
8. [Delivery Contracts](#8-delivery-contracts)
9. [Customer Checkout Contracts](#9-customer-checkout-contracts)
10. [Restaurant Contracts](#10-restaurant-contracts)
11. [Platform Admin Contracts](#11-platform-admin-contracts)

---

## 1. Global Response Envelope

Every API response — success or failure — uses this envelope. No exceptions.

### Success
```json
{
  "success": true,
  "data": { }
}
```

### Error
```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "ORDER_NOT_FOUND",
    "message": "Order with id abc123 was not found."
  }
}
```

### Paginated Success
```json
{
  "success": true,
  "data": {
    "items": [ ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 84,
      "hasMore": true
    }
  }
}
```

### Canonical Error Codes

| Code | HTTP Status | Meaning |
|---|---|---|
| `UNAUTHORISED` | 401 | Missing or invalid JWT |
| `FORBIDDEN` | 403 | Valid JWT but insufficient role/scope |
| `NOT_FOUND` | 404 | Resource does not exist |
| `CONFLICT` | 409 | Optimistic lock version mismatch |
| `VALIDATION_ERROR` | 422 | Request body failed validation |
| `RESTAURANT_CLOSED` | 423 | Order rejected — restaurant is closed |
| `INVALID_TRANSITION` | 422 | Order/delivery state transition not permitted |
| `DUPLICATE_REQUEST` | 409 | Idempotency key already used |
| `DRIVER_ACTIVE_DELIVERY` | 409 | Driver has active delivery — action blocked |

---

## 2. Auth Contracts

### POST /api/auth/{role}/login

**Request:**
```typescript
{
  email:    string   // required
  password: string   // required
}
```

**Response `data`:**
```typescript
{
  user: {
    id:           string
    role:         UserRole
    restaurantId: string | null
    name:         string
    email:        string
  }
  // JWT set as httpOnly cookie — not in response body
}
```

---

## 3. Order Contracts

### OrderStatus (canonical — see domain_glossary.md)
```
pending | confirmed | preparing | ready_for_pickup | out_for_delivery | delivered | cancelled
```

### OrderSummary
Used in list views, board cards, and Realtime payloads. Lightweight — no nested items.

```typescript
type OrderSummary = {
  id:                  string
  shortId:             string           // last 6 chars of id, uppercase
  restaurantId:        string
  customerId:          string
  customerName:        string
  status:              OrderStatus
  fulfillmentType:     FulfillmentType  // "delivery" | "pickup"
  totalPrice:          string           // decimal string e.g. "125.00"
  paymentStatus:       OrderPaymentStatus
  itemSummary:         string           // e.g. "2x Burger (+Cheese), 1x Coke"
  itemCount:           number
  estimatedReadyMinutes: number | null
  specialInstructions: string | null
  version:             number
  createdAt:           string           // ISO 8601
  cancelledAt:         string | null
}
```

### OrderDetail
Full order — used on detail screens and order tracking.

```typescript
type OrderDetail = {
  id:                  string
  shortId:             string
  restaurantId:        string
  customerId:          string
  customerName:        string
  customerPhone:       string
  status:              OrderStatus
  fulfillmentType:     FulfillmentType
  subtotal:            string
  deliveryFee:         string
  tax:                 string
  totalPrice:          string
  paymentStatus:       OrderPaymentStatus
  specialInstructions: string | null
  estimatedReadyMinutes: number | null
  version:             number
  createdAt:           string
  cancelledAt:         string | null
  cancellationReason:  string | null
  cancelledById:       string | null
  items:               OrderItemDetail[]
  delivery:            DeliverySummary | null  // null for pickup orders
  payment:             PaymentSummary | null
}

type OrderItemDetail = {
  id:        string
  itemName:  string           // snapshot
  itemPrice: string           // snapshot decimal
  quantity:  number
  lineTotal:  string
  modifiers: OrderItemModifier[]
}

type OrderItemModifier = {
  id:              string
  optionName:      string    // snapshot
  priceAdjustment: string    // snapshot decimal
}

type PaymentSummary = {
  id:        string
  provider:  string          // "stripe" | "in_store"
  method:    string          // "card_online" | "cash" | "card_in_store"
  amount:    string
  currency:  string
  status:    PaymentStatus
  collectedAt: string | null
}
```

### PATCH /api/orders/:id/status

**Request:**
```typescript
{
  status:  OrderStatus   // new target status
  version: number        // current version — required for optimistic locking
  cancellationReason?: string  // required when status = "cancelled"
  managerPin?:          string  // required when cancelling a "confirmed" order
  estimatedReadyMinutes?: number  // optional when status = "confirmed"
}
```

**Response `data`:**
```typescript
{
  order: OrderSummary
}
```

**409 Conflict response** (version mismatch):
```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "CONFLICT",
    "message": "Order was modified by another session. Please refresh.",
    "currentVersion": 4
  }
}
```

---

## 4. Dashboard Board Contracts

### OrderCardData
The shape rendered on each card in the swimlane board. Computed server-side.

```typescript
type OrderCardData = {
  id:                  string
  shortId:             string
  status:              OrderStatus
  fulfillmentType:     FulfillmentType
  itemSummary:         string     // "2x Double Burger (+Cheese), 1x Coke"
  itemCount:           number
  totalPrice:          string
  paymentStatus:       OrderPaymentStatus
  customerName:        string
  estimatedReadyMinutes: number | null
  specialInstructions: string | null
  version:             number
  createdAt:           string
  minutesElapsed:      number     // minutes since createdAt — computed server-side
  delivery:            OrderCardDelivery | null
}

type OrderCardDelivery = {
  id:           string
  status:       DeliveryStatus
  driverName:   string | null
  driverId:     string | null
}
```

### OrdersBoardResponse
Response shape for `GET /api/orders/board?restaurant_id=`.

```typescript
type OrdersBoardResponse = {
  pending:         OrderCardData[]
  confirmed:       OrderCardData[]
  preparing:       OrderCardData[]
  readyForPickup:  OrderCardData[]
  outForDelivery:  OrderCardData[]
}
```

**Rules:**
- `delivered` and `cancelled` orders are excluded from the board response.
- Each column is sorted by `createdAt` ascending (oldest first).
- `minutesElapsed` is computed server-side at response time — never by the frontend.
- The board never returns more than 50 orders per column. If a column exceeds 50, the backend returns the 50 oldest and logs a warning.

---

## 5. Realtime Event Contracts

Supabase Realtime events are **invalidation signals only**. They carry minimal data to trigger a React Query cache invalidation. The frontend fetches fresh data via REST after receiving an event.

**Rule:** The frontend must never use Realtime payload data to update UI state directly. It must always refetch via the REST API.

### RealtimeBoardEvent
Sent when an order status changes — triggers Dashboard board refetch.

```typescript
type RealtimeBoardEvent = {
  type:        "ORDER_STATUS_CHANGED"
  orderId:     string
  restaurantId: string
  newStatus:   OrderStatus
  version:     number
}
```

### RealtimeOrderEvent
Sent to the customer-facing order tracking screen.

```typescript
type RealtimeOrderEvent = {
  type:     "ORDER_UPDATED"
  orderId:  string
  newStatus: OrderStatus
}
```

### RealtimeDriverLocationEvent
Sent when a driver posts a GPS update — triggers Dashboard map marker refresh.

```typescript
type RealtimeDriverLocationEvent = {
  type:       "DRIVER_LOCATION_UPDATED"
  driverId:   string
  deliveryId: string | null
  restaurantId: string
}
```

**Rule:** The location event carries no coordinates. The Dashboard fetches fresh coordinates via `GET /api/deliveries/:id/location` after receiving the event.

---

## 6. Menu Contracts

### MenuItemResponse
Full menu item including modifier groups. Used on the customer-facing item detail modal and Owner Portal item edit form.

```typescript
type MenuItemResponse = {
  id:            string
  restaurantId:  string
  categoryId:    string
  name:          string
  description:   string | null
  price:         string           // decimal string
  imageUrl:      string | null
  isAvailable:   boolean
  modifierGroups: ModifierGroupResponse[]
}

type ModifierGroupResponse = {
  id:            string
  name:          string           // e.g. "Extras"
  selectionType: ModifierSelectionType  // "single" | "multiple"
  isRequired:    boolean
  minSelections: number | null
  maxSelections: number | null
  displayOrder:  number
  options:       ModifierOptionResponse[]
}

type ModifierOptionResponse = {
  id:              string
  name:            string          // e.g. "Extra Cheese"
  priceAdjustment: string         // decimal string — "0.00" for free options
  isAvailable:     boolean
  displayOrder:    number
}
```

### MenuCategoryWithItemsResponse
Used on the Owner Portal menu management screen.

```typescript
type MenuCategoryWithItemsResponse = {
  id:           string
  restaurantId: string
  name:         string
  displayOrder: number
  isActive:     boolean
  items:        MenuItemSummary[]
}

type MenuItemSummary = {
  id:          string
  name:        string
  price:       string
  isAvailable: boolean
  imageUrl:    string | null
  modifierGroupCount: number
}
```

---

## 7. Driver Contracts

### DriverLocationPayload
Posted by the Driver App every 15 seconds during an active delivery.

```typescript
// POST /api/drivers/:id/location
// Request body:
type DriverLocationPayload = {
  latitude:    number    // e.g. -33.9249
  longitude:   number    // e.g. 18.4241
  recordedAt:  string    // ISO 8601 — device timestamp
  deliveryId:  string | null
}
```

**Response `data`:**
```typescript
{
  received: true
}
```

**Rules:**
- `recordedAt` is the device timestamp. The backend also stores `receivedAt` server-side for drift detection.
- Queued offline posts must be sent oldest-first. The backend rejects posts where `recordedAt` is older than the driver's most recent `lastLocationAt`.
- The backend updates `drivers.currentLocation` and `drivers.lastLocationAt` atomically on receipt.

### DriverSummary
Used on the Dashboard driver assignment modal and Owner Portal driver list.

```typescript
type DriverSummary = {
  id:           string
  restaurantId: string
  name:         string
  phone:        string
  isActive:     boolean
  isOnline:     boolean
  hasActiveDelivery: boolean
  currentLocation: LatLng | null
  lastLocationAt:  string | null    // ISO 8601
  locationIsStale: boolean          // true if lastLocationAt > 120 seconds ago
}

type LatLng = {
  latitude:  number
  longitude: number
}
```

### DriverStatusRequest
```typescript
// PATCH /api/drivers/:id/status
{
  status: "online" | "offline"
}
```

**Rules:**
- Backend rejects `offline` if driver has an active delivery (`assigned`, `picked_up`, `on_the_way`).
- Error response uses code `DRIVER_ACTIVE_DELIVERY`.

### FCMTokenRegistration
```typescript
// POST /api/drivers/:id/fcm-token
{
  token:    string
  platform: DevicePlatform   // "android" | "ios"
}
```

---

## 8. Delivery Contracts

### DeliverySummary
Embedded in order responses and used in Dashboard delivery tracking.

```typescript
type DeliverySummary = {
  id:            string
  orderId:       string
  driverId:      string | null
  driverName:    string | null
  status:        DeliveryStatus
  failureReason: string | null
  assignedAt:    string | null
  pickedUpAt:    string | null
  deliveredAt:   string | null
  failedAt:      string | null
}
```

### DeliveryStatusRequest
Posted by the Driver App to advance delivery state.

```typescript
// PATCH /api/deliveries/:id/status
{
  status: "picked_up" | "on_the_way" | "delivered"
  // Only these three values are accepted from driver JWTs.
  // "assigned" and "failed" are rejected with 403 Forbidden.
}
```

### DeliveryLocationResponse
Returned when Dashboard polls driver position.

```typescript
// GET /api/deliveries/:id/location
type DeliveryLocationResponse = {
  driverId:       string
  deliveryId:     string
  currentLocation: LatLng | null
  lastLocationAt:  string | null
  locationIsStale: boolean     // true if lastLocationAt > 120 seconds ago
}
```

### DriverAssignmentRequest
Posted by the Dashboard to assign a driver.

```typescript
// POST /api/deliveries/:id/assign
{
  driverId: string
}
```

---

## 9. Customer Checkout Contracts

### CheckoutRequest

```typescript
// POST /api/orders/checkout
type CheckoutRequest = {
  idempotencyKey:  string        // unique UUID generated client-side
  restaurantId:    string
  fulfillmentType: FulfillmentType  // "delivery" | "pickup"
  paymentMethod:   "card_online" | "in_store"
  deliveryAddress: DeliveryAddress | null  // required if fulfillmentType = "delivery"
  specialInstructions: string | null
  items: CheckoutItem[]
}

type CheckoutItem = {
  menuItemId:  string
  quantity:    number
  selectedModifierOptionIds: string[]
}

type DeliveryAddress = {
  street:     string
  city:       string
  postalCode: string
  latitude:   number
  longitude:  number
  savedAddressId: string | null  // if using a saved address
}
```

### CheckoutResponse

```typescript
type CheckoutResponse = {
  orderId:          string
  paymentMethod:    "card_online" | "in_store"
  // Online payment only:
  stripeClientSecret: string | null
  // Calculated totals (for display — always recalculated server-side):
  subtotal:         string
  deliveryFee:      string
  tax:              string
  totalPrice:       string
}
```

### PriceMismatchError
Returned when server-calculated total differs from what was submitted.

```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "PRICE_MISMATCH",
    "message": "Some item prices have changed since you added them to your cart.",
    "updatedItems": [
      {
        "menuItemId": "abc123",
        "itemName": "Double Burger",
        "previousPrice": "85.00",
        "currentPrice": "90.00"
      }
    ],
    "newTotal": "130.00"
  }
}
```

---

## 10. Restaurant Contracts

### RestaurantPublicResponse
Returned to the customer app — excludes sensitive operational fields.

```typescript
type RestaurantPublicResponse = {
  id:           string
  name:         string
  description:  string | null
  phone:        string
  logoUrl:      string | null
  isOpen:       boolean          // computed: is_active AND current time within opening_hours
  openingHours: OpeningHours
  features: {
    loyaltyEnabled:     boolean
    promotionsEnabled:  boolean
    deliveryEnabled:    boolean
    pickupEnabled:      boolean
  }
}

type OpeningHours = {
  monday:    DayHours
  tuesday:   DayHours
  wednesday: DayHours
  thursday:  DayHours
  friday:    DayHours
  saturday:  DayHours
  sunday:    DayHours
}

type DayHours = {
  isOpen: boolean
  open:   string | null    // "11:00" — null if isOpen = false
  close:  string | null    // "20:00" — null if isOpen = false
}
```

### RestaurantOperationalResponse
Returned to Owner Portal and Dashboard — includes operational fields.

```typescript
type RestaurantOperationalResponse = RestaurantPublicResponse & {
  email:                    string
  address:                  string
  city:                     string
  postalCode:               string
  isActive:                 boolean   // raw field — not computed
  status:                   RestaurantStatus
  defaultReadyTimeMinutes:  number
  suspensionReason:         string | null
}
```

---

## 11. Platform Admin Contracts

### RestaurantAdminSummary
Used in the Platform Admin restaurant list table.

```typescript
type RestaurantAdminSummary = {
  id:              string
  name:            string
  ownerName:       string
  ownerEmail:      string
  city:            string
  status:          RestaurantStatus
  isActive:        boolean
  ordersToday:     number
  createdAt:       string
  suspendedAt:     string | null
  suspensionReason: string | null
}
```

### SuspendRestaurantRequest
```typescript
// POST /api/platform/restaurants/:id/suspend
{
  reason: string   // required — min 10 chars
}
```

### FeatureFlagUpdateRequest
```typescript
// PATCH /api/platform/restaurants/:id/features
{
  features: {
    loyaltyEnabled?:    boolean
    promotionsEnabled?: boolean
    deliveryEnabled?:   boolean
    pickupEnabled?:     boolean
    analyticsEnabled?:  boolean
    earningsEnabled?:   boolean
  }
}
```

**Rule:** Only the keys listed above are accepted. Any unrecognised key in the request body must be rejected with `VALIDATION_ERROR`. The backend performs a merge — unspecified keys retain their current values.

### AuditSessionResponse
```typescript
// POST /api/platform/restaurants/:id/audit-session
type AuditSessionResponse = {
  auditToken:  string    // raw token — shown once, not stored in plain text
  expiresAt:   string    // ISO 8601 — 30 minutes from creation
  restaurantId: string
}
```

---

*End of API Contracts*
