# PRD — Restaurant Dashboard Web App (v2)
**Platform:** Restaurant Direct  
**App:** Restaurant Staff Dashboard (Next.js)  
**Stage:** MVP  
**Audience:** AI Coding Agents — treat every rule here as a strict contract  
**Changelog:**
- v2: concurrency protection, fulfillment type model, delivery state ownership, closing edge case policy, cancellation reasons, offline handling, multi-location scaffolding.
- v3: driver assignment collision constraint, confirmed-order cancellation policy (manager approval), GPS staleness detection + UI warning.
- v4: Opening Hours module removed from Restaurant Dashboard — moved exclusively to Admin Panel.

---

## Table of Contents
1. [Purpose & Scope](#1-purpose--scope)
2. [User Roles & Access Control](#2-user-roles--access-control)
3. [Module Overview](#3-module-overview)
4. [Module 1 — Live Order Feed](#4-module-1--live-order-feed)
5. [Module 2 — Estimate Ready Time](#5-module-2--estimate-ready-time)
6. [Module 3 — Driver & Delivery Management](#6-module-3--driver--delivery-management)
7. [Realtime Architecture](#7-realtime-architecture)
8. [Audio Alert System](#8-audio-alert-system)
9. [Offline Handling](#9-offline-handling)
10. [Concurrency Protection](#10-concurrency-protection)
11. [Screen & Route Map](#11-screen--route-map)
12. [API Contract (Frontend ↔ Backend)](#12-api-contract-frontend--backend)
13. [State Machines (Dashboard View)](#13-state-machines-dashboard-view)
14. [Frontend Architecture Rules](#14-frontend-architecture-rules)
15. [Role-Based UI Rules](#15-role-based-ui-rules)
16. [Error Handling](#16-error-handling)
17. [Domain Invariants](#17-domain-invariants)
18. [Out of Scope (MVP)](#18-out-of-scope-mvp)

---

## 1. Purpose & Scope

The Restaurant Dashboard is a **web application** (`apps/web`) used by restaurant staff to manage incoming orders and delivery operations in real time.

It is **not** the customer-facing app. It is **not** the platform super-admin panel (separate PRD).

### In Scope (MVP)
- Live order feed with real-time status transitions
- Per-order estimate ready time adjustment
- Driver management (online/offline, assignment)
- Delivery tracking (status view)
- Role-based access: `restaurant_owner`, `restaurant_staff`

### Architectural Anchors
- **Framework:** Next.js (App Router), Tailwind CSS
- **Backend:** Node.js + Fastify (Controller-Service-Repository)
- **Realtime:** Supabase Realtime channel subscriptions (events only — never data fetching)
- **Auth:** JWT — staff sessions only
- **State:** React Query for server state; Zustand for global UI state (sidebar, audio prefs, online status)
- **Strict Rule:** The frontend CANNOT query the database directly. All data must flow through the Backend REST API. Supabase Realtime is the only exception — used exclusively for push event invalidation, never for data fetching.

### Multi-Location Note
The MVP supports a **single location per restaurant**. However, `restaurant_id` must appear on all core entities (orders, menu items, promotions, drivers) to ensure the schema can accommodate multi-location expansion without redesign. No location-switching UI is built in MVP.

---

## 2. User Roles & Access Control

Two roles exist within the restaurant dashboard. Both roles are scoped to a single `restaurant_id` in the JWT payload.

| Role | Description | Capabilities |
|---|---|---|
| `restaurant_owner` | Restaurant owner or manager | All modules — full read/write |
| `restaurant_staff` | Kitchen or front-of-house staff | Orders + Delivery only — no Opening Hours settings |

### Platform Super-Admin
A third role, `platform_admin`, exists at the platform level and is defined in the Admin Panel PRD. `platform_admin` users may access the restaurant dashboard in a read-only audit mode but cannot take operational actions. Enforced server-side via JWT `role` claim validation.

### JWT Payload Shape
```json
{
  "sub": "user-uuid",
  "role": "restaurant_staff",
  "restaurant_id": "restaurant-uuid",
  "iat": 1700000000,
  "exp": 1700003600
}
```

**Note:** `location_id` is intentionally absent in MVP. When multi-location support is introduced, it will be added to this payload without breaking existing single-location JWTs.

### Route Guard Rule
Every dashboard route must verify:
1. Valid JWT is present.
2. JWT `restaurant_id` matches the resource being accessed.
3. JWT `role` is sufficient for the action.

If any check fails → redirect to `/dashboard/login`.

**Rule:** Role enforcement at the UI level is a convenience only. Every backend endpoint must independently validate the JWT role. The frontend is never the sole enforcement layer.

---

## 3. Module Overview

| Module | Route | Roles Allowed |
|---|---|---|
| Live Order Feed | `/dashboard/orders` | `restaurant_owner`, `restaurant_staff` |
| Driver Management | `/dashboard/drivers` | `restaurant_owner`, `restaurant_staff` |

The sidebar renders only the routes the current JWT role permits.

---

## 4. Module 1 — Live Order Feed

**Route:** `/dashboard/orders`  
**This is the primary screen.** It is the first screen staff see after login.

### 4.1 Layout

The screen is divided into **four swimlane columns**, rendered side by side on desktop (≥1024px). On tablet/mobile, columns stack vertically and are accessible via tabs.

| Column | Orders Displayed |
|---|---|
| New Orders | `status = pending` |
| Preparing | `status = confirmed` or `preparing` |
| Ready | `status = ready_for_pickup` |
| Completed | `status = out_for_delivery` or `delivered` (today only) |

> Completed column shows today's completed orders only, sorted most recent first. Does not paginate in MVP.

### 4.2 Order Card

Each order is represented as a card displaying:

```
Order #[short_id]        [fulfillment_type badge: DELIVERY | PICKUP]
[customer name]          [time since order placed, e.g. "4 min ago"]

Items:
  • 2x Double Burger (+Cheese, +Bacon)
  • 1x Coke

Subtotal: R[amount]
[Est. Ready: 20 min]       ← shown only in Preparing column
[payment badge: PAID | PAY IN-STORE]
```

**Short ID:** Last 6 characters of the order UUID in uppercase. Example: `#A3F9C1`.

**Fulfillment Type Badge:**
- `DELIVERY` → orange background
- `PICKUP` → blue background

**Payment Badge:**
- `PAID` (`payment_status = succeeded`) → green
- `PAY IN-STORE` (in-store collection pending) → yellow

### 4.3 Fulfillment Type Model

Orders carry an explicit `fulfillment_type` field. AI agents must use this field — never infer fulfillment from other fields.

```
orders.fulfillment_type  ENUM  ('pickup', 'delivery')
```

**Why this matters:** Future fulfillment modes (`dine_in`, `scheduled_delivery`, `curbside`) will extend this enum without breaking existing logic.

### 4.4 Order Action Buttons

Each card displays one primary action button, driven by the current order status. Staff press it to advance the order to the next state.

| Current Status | Fulfillment Type | Button Label | Next Status |
|---|---|---|---|
| `pending` | any | Accept Order | `confirmed` |
| `confirmed` | any | Start Preparing | `preparing` |
| `preparing` | any | Mark Ready | `ready_for_pickup` |
| `ready_for_pickup` | `delivery` | Assign Driver | opens driver assignment modal |
| `ready_for_pickup` | `pickup` + pay in-store | Mark Paid & Complete | `delivered` + payment `succeeded` |
| `ready_for_pickup` | `pickup` + already paid | Mark Collected | `delivered` |

**Cancel button:** A secondary `Cancel Order` button is present on `pending` and `confirmed` cards only. Pressing it opens a cancellation modal (see 4.6). Cancellation behaviour differs by status — see policy below.

### 4.5 New Order Arrival Behaviour

When a new `pending` order arrives via Supabase Realtime:
1. The order card slides into the New Orders column with a yellow highlight animation (3 seconds).
2. Audio alert fires (see Section 9).
3. The column header badge count increments immediately.

### 4.6 Order Cancellation Policy & Modal

Cancellation rules differ by order status. This is a hard policy — AI agents must not allow cancellation outside these rules.

| Status | Who Can Cancel | Process |
|---|---|---|
| `pending` | Any staff | Instant cancel — reason modal only |
| `confirmed` | `restaurant_owner` only | Manager approval modal — then reason modal |
| `preparing` or later | Nobody | Cancel button hidden. No cancellation permitted. |

**Rationale:** By `preparing`, food is being made and resources are consumed. Cancellation at this stage requires an out-of-band manager decision (phone call to customer, manual refund via payment dashboard). The system does not support post-preparation cancellation in MVP.

#### Cancellation Modal — `pending` orders (any staff)

Modal content:
- Order summary (short ID, item count, total)
- Required reason selector:

```
[ ] Item unavailable
[ ] Restaurant closing early
[ ] Customer requested cancellation
[ ] Duplicate order
[ ] Other
```

- If "Other" selected: free-text field (max 200 chars)
- Confirm Cancel (red) + Go Back buttons

#### Cancellation Modal — `confirmed` orders (manager approval flow)

Step 1 — Manager Approval Gate:
- Modal header: *"Manager approval required"*
- Body: *"This order may already be in preparation. A manager must approve this cancellation."*
- Input: Manager PIN field (4–6 digit numeric PIN set per `restaurant_owner` account)
- Approve + Go Back buttons

Step 2 — on correct PIN: proceed to the reason modal (same as `pending` flow above)  
Step 3 — on incorrect PIN: inline error *"Incorrect PIN. Ask your manager."* Do not lock after failed attempts in MVP.

**Manager PIN model:**
```
users.manager_pin  TEXT  NULLABLE  ← bcrypt hashed, restaurant_owner accounts only
```

The PIN is set by the owner in Settings (out of scope for this PRD — defined in Admin Panel PRD). If no PIN is set, skip the approval gate and show a warning banner: *"No manager PIN set. Cancellation allowed without approval. Set a PIN in Settings."*

**Data model (unchanged from v2):**
```
orders.cancellation_reason    TEXT       NULLABLE
orders.cancelled_by_user_id   UUID       NULLABLE
orders.cancelled_at           TIMESTAMP  NULLABLE
```

On confirmation: `POST /api/orders/:id/cancel` with `{ reason, other_reason?, manager_pin? }`  
Backend validates the PIN server-side — never trust the frontend to gate this.

### 4.7 Optimistic UI Rule

When a staff member taps an action button:
1. The button enters a loading state immediately.
2. The card moves to the next column optimistically.
3. If the API call fails (including version conflict — see Section 11), the card reverts and an error toast is shown.
4. React Query `invalidateQueries` is called on success to sync server truth.

---

## 5. Module 2 — Estimate Ready Time

Sub-feature of the Live Order Feed — not a standalone screen.

### 5.1 Default Estimate

The restaurant sets a default estimate (in minutes) stored on the `restaurants` table:

```
restaurants.default_ready_time_minutes  INTEGER  DEFAULT 20
```

Configurable in Opening Hours settings (Section 7).

### 5.2 Per-Order Estimate Override

On every order card in the **Preparing** column, staff can adjust the ready time for that specific order.

**UI:** Inline stepper (−5 / +5 buttons). Bounds: minimum 5 minutes, maximum 90 minutes, in 5-minute steps.

**Data model:**
```
orders.estimated_ready_minutes  INTEGER  NULLABLE
```

When `NULL`, the UI displays the restaurant's `default_ready_time_minutes`.

**API:** `PATCH /api/orders/:id/estimate` with body `{ estimated_ready_minutes: number }`.  
This is a lightweight call. Do not re-validate the full order on this endpoint.

**Customer-facing impact:** The customer app reads `estimated_ready_minutes` (falling back to restaurant default) to display approximate wait time. Informational only — does not gate any state transition.

---

## 6. Module 3 — Driver & Delivery Management

**Route:** `/dashboard/drivers`

### 6.1 Driver Ownership Model

**Drivers are restaurant-owned.** Each driver record belongs to exactly one `restaurant_id`. There is no shared platform driver pool in MVP.

```
drivers.restaurant_id  UUID  NOT NULL
```

**Implication:** A driver can only be assigned to orders from their own restaurant. The backend must enforce this — never assign a driver whose `restaurant_id` differs from the order's `restaurant_id`.

### 6.2 Driver List

Displays all drivers linked to this `restaurant_id`.

Each driver row shows:
- Driver name
- Online / Offline status toggle → calls `PATCH /api/drivers/:id/status`
- Current active delivery (if any): order short ID + customer address snippet
- "View on Map" button (opens inline map — see 6.4)

### 6.3 Driver Assignment Modal

Triggered when staff tap **Assign Driver** on a `ready_for_pickup` delivery order.

Modal content:
- Order summary (Order #, delivery address, item count)
- List of **available drivers only** (status = `online`, no active delivery)
- Each row: driver name, last seen time
- "Assign" button per row

On assignment:
1. Call `POST /api/deliveries` with `{ order_id, driver_id }`.
2. Backend creates a `deliveries` record with `status = assigned`.
3. Order status transitions to `out_for_delivery` server-side (coupled transition per architecture spec).
4. Modal closes. Order card moves to Completed column.

**Assignment Collision Protection:**  
The `deliveries` table must enforce a `UNIQUE` constraint on `order_id`:

```sql
ALTER TABLE deliveries ADD CONSTRAINT deliveries_order_id_unique UNIQUE (order_id);
```

If two staff members attempt to assign different drivers to the same order simultaneously, the database rejects the second insert. The backend returns a `409 Conflict` response. The frontend shows toast: *"This order was already assigned to a driver. Refreshing."* and invalidates the orders query.

**Rule for AI agents:** Do not implement this collision check as application logic only. The `UNIQUE` constraint on `deliveries.order_id` is mandatory at the database level — application-level checks alone are insufficient under concurrent load.

If no drivers are available: *"No drivers are currently available. The order will remain in Ready until a driver is assigned."*

### 6.4 Delivery State Ownership

**The Delivery Service owns all delivery state transitions.** The dashboard may only trigger two transitions directly:

| Dashboard Action | Allowed Transition |
|---|---|
| Assign Driver modal | `unassigned` → `assigned` |
| Mark Failed button | any active state → `failed` |

All other transitions (`assigned` → `picked_up` → `on_the_way` → `delivered`) are driven exclusively by the **Driver App**. The dashboard displays these states in read-only mode.

**Rule for AI agents:** Do not build buttons or API calls that allow dashboard staff to manually advance delivery beyond `assigned`. That authority belongs to the Driver App.

### 6.5 Delivery Status Display

Each active delivery on the Drivers page shows a live status badge:

| Delivery Status | Badge Colour |
|---|---|
| `assigned` | Blue |
| `picked_up` | Orange |
| `on_the_way` | Orange |
| `delivered` | Green |
| `failed` | Red |

### 6.6 Map View (MVP)

An embedded Google Maps component showing the driver's `current_location` (from `drivers.current_location`). The map refreshes every 15 seconds via React Query polling on `GET /api/deliveries/:id/location`. Full Supabase Realtime location streaming is a V2 feature.

**GPS Staleness Detection:**

The location API response includes a `last_location_at` timestamp:

```json
{
  "latitude": -29.8587,
  "longitude": 31.0218,
  "last_location_at": "2026-03-08T14:22:00Z"
}
```

The frontend calculates staleness on every poll:

```
now - last_location_at > 120 seconds (2 minutes) → stale
```

**Stale location UI behaviour:**
- Hide or grey out the driver marker on the map
- Show an inline warning below the map:

```
⚠️  Driver location unavailable. Last seen [X] minutes ago.
```

- Do not show the stale coordinates as if they are current — this is misleading to staff

**Not stale (< 2 minutes):** render the map marker and location normally, no warning.

**Data model addition:**
```
drivers.last_location_at  TIMESTAMP  NULLABLE
```

Updated by the Driver App every time it posts a location update. The backend must update this field on every `driver_locations` insert alongside `drivers.current_location`.

### 6.7 Mark Delivery Failed

Staff can tap **Mark Failed** on any active delivery. This:
1. Opens a confirmation modal.
2. Requires a reason (free text, max 200 chars) → stored in `deliveries.failure_reason`.
3. On confirm: calls `PATCH /api/deliveries/:id/status` with `{ status: 'failed', failure_reason }`.
4. Server-side: sets `orders.status = cancelled` and creates a `cancellation_reason = 'delivery_failed'` record.

---

## 8. Realtime Architecture

**Technology:** Supabase Realtime (Postgres CDC).

**Strict Rule:** Supabase Realtime is for push event invalidation only. The frontend must never query the Supabase database client directly. All data loads use the Backend REST API.

### 8.1 Subscribed Channels

The dashboard subscribes to two channels on mount:

#### Channel 1: `orders:restaurant_id={restaurant_id}`
- Listens for: `INSERT` (new order), `UPDATE` (status change, estimate change)
- On event: `queryClient.invalidateQueries(['orders', restaurant_id])`

#### Channel 2: `deliveries:restaurant_id={restaurant_id}`
- Listens for: `INSERT`, `UPDATE`
- On event: `queryClient.invalidateQueries(['deliveries', restaurant_id])`

### 8.2 Channel Lifecycle

```
Component mounts
  → Subscribe to both channels
  → Fetch initial data via REST API

Channel receives event
  → Invalidate relevant React Query key
  → React Query refetches from REST API
  → UI re-renders with fresh data

Component unmounts
  → Unsubscribe from both channels (cleanup)
```

### 8.3 Connection Status Indicator

A small indicator in the dashboard header:
- 🟢 **Live** — channel connected
- 🟡 **Reconnecting…** — channel disconnected, attempting reconnect
- 🔴 **Offline** — no network detected (see Section 10)

Supabase Realtime client handles reconnection automatically. The indicator reads from the channel's subscribe callback state.

---

## 9. Audio Alert System

When a new `pending` order arrives via Supabase Realtime INSERT on `orders`:

1. Play a notification sound (~1 second chime).
2. Audio file bundled locally: `apps/web/public/sounds/new-order.mp3`. Do not use an external CDN.
3. Triggered via Web Audio API: `new Audio('/sounds/new-order.mp3').play()`.

### Browser Autoplay Policy Handling

Browsers block audio without a prior user interaction. Handle as follows:

- On first dashboard load, show a dismissible banner: *"Click anywhere to enable order alerts."*
- On first user click anywhere, call `audioContext.resume()` to unlock autoplay.
- Once unlocked, store `audioUnlocked = true` in Zustand. Banner disappears.
- If `audioUnlocked = false` when a new order arrives, flash the New Orders column header as a visual fallback.

### Mute Toggle

A 🔔 / 🔕 icon in the dashboard header. State stored in Zustand (not persisted — resets on reload).

---

## 10. Offline Handling

The dashboard follows a **stale UI + sync on reconnect** strategy. This is the industry standard for operational POS-style dashboards (Toast, Square, Lightspeed). Blocking all actions on disconnect is unacceptable during a busy service.

### Behaviour

| Network State | Dashboard Behaviour |
|---|---|
| Online | Normal operation |
| Offline / reconnecting | Stale data remains visible. Actions are still permitted. Warning banner shown. |
| Reconnected | Automatic sync triggered |

### Offline Banner

When the network is lost or Supabase Realtime disconnects, show a **non-blocking sticky banner** at the top of the page:

```
⚠️  You're offline. Showing last known orders. Changes may not save until reconnected.
```

The banner disappears automatically when connectivity is restored.

### Reconnect Sync

On reconnect:
1. Supabase Realtime re-subscribes automatically.
2. Call `queryClient.invalidateQueries()` (all keys) to force a full data refresh.
3. Replace the offline banner with a brief success toast: *"Reconnected. Orders refreshed."*

### Failed Actions While Offline

If a staff member takes an action (e.g. accepts an order) while offline and the API call fails:
1. Revert the optimistic UI update.
2. Show error toast: *"Action failed. You appear to be offline. Please retry."*
3. Do not queue or retry actions automatically — require explicit staff retry.

---

## 11. Concurrency Protection

Multiple staff members may have the dashboard open simultaneously. Without concurrency protection, two staff members can act on the same order at the same time, producing conflicting state.

### Optimistic Locking via Version Field

Add a `version` integer to the `orders` table:

```
orders.version  INTEGER  NOT NULL  DEFAULT 1
```

Every order status update increments the version server-side.

### Frontend Behaviour

When fetching an order, the frontend receives the current `version` value. All status mutation requests must include it:

```json
PATCH /api/orders/:id/status
{
  "status": "confirmed",
  "version": 3
}
```

### Backend Behaviour

The backend executes the update conditionally:

```sql
UPDATE orders
SET status = 'confirmed', version = version + 1
WHERE id = :id AND version = :expected_version
```

If the row was already updated by another staff member (version mismatch), zero rows are affected. The backend returns:

```json
{
  "success": false,
  "error": {
    "code": "CONFLICT",
    "message": "This order was updated by another staff member. Refreshing."
  }
}
```

### Frontend on Conflict (409 response)

1. Revert optimistic UI update.
2. Show toast: *"Order updated by another staff member. Refreshing."*
3. Immediately call `queryClient.invalidateQueries(['orders', restaurantId])` to fetch latest state.

**Note:** Version is only required on status transitions and cancellations. It is not required on the lightweight estimate patch endpoint.

---

## 12. Screen & Route Map

```
/dashboard
  /dashboard/login              ← Staff login (unprotected)
  /dashboard/orders             ← Live Order Feed (default post-login)
  /dashboard/drivers            ← Driver & Delivery Management
```

### Login Screen
- Email + password fields
- Calls `POST /api/auth/staff/login`
- On success: stores JWT in an `httpOnly` cookie via Next.js Route Handler
- On failure: inline error below form — never a toast for auth errors

### Redirect Logic
- Unauthenticated access to any `/dashboard/*` → redirect to `/dashboard/login`
- Authenticated access to `/dashboard` → redirect to `/dashboard/orders`

---

## 13. API Contract (Frontend ↔ Backend)

All requests include `Authorization: Bearer <jwt>` header.  
All responses use the global error envelope:
```json
{ "success": true, "data": { ... } }
{ "success": false, "data": null, "error": { "code": "...", "message": "..." } }
```

### Auth
| Method | Endpoint | Body | Description |
|---|---|---|---|
| POST | `/api/auth/staff/login` | `{ email, password }` | Returns JWT |
| POST | `/api/auth/staff/logout` | — | Invalidates session |

### Orders
| Method | Endpoint | Body | Description |
|---|---|---|---|
| GET | `/api/orders?restaurant_id=&date=today` | — | Today's orders for live feed |
| PATCH | `/api/orders/:id/status` | `{ status, version }` | Advance order status (with concurrency check) |
| PATCH | `/api/orders/:id/estimate` | `{ estimated_ready_minutes }` | Update estimate (no version check) |
| POST | `/api/orders/:id/cancel` | `{ reason, other_reason?, manager_pin? }` | Cancel order — PIN required for confirmed orders |
| POST | `/api/orders/:id/mark-paid` | — | Mark in-store payment collected (Collection only) |

### Drivers
| Method | Endpoint | Body | Description |
|---|---|---|---|
| GET | `/api/drivers?restaurant_id=` | — | List all drivers for this restaurant |
| PATCH | `/api/drivers/:id/status` | `{ status: 'online'|'offline' }` | Toggle availability |

### Deliveries
| Method | Endpoint | Body | Description |
|---|---|---|---|
| POST | `/api/deliveries` | `{ order_id, driver_id }` | Create delivery + assign driver |
| PATCH | `/api/deliveries/:id/status` | `{ status, failure_reason? }` | Mark failed (dashboard only) |
| GET | `/api/deliveries/:id/location` | — | Driver current location for map (polled) |

### Restaurant — Open/Closed Toggle
| Method | Endpoint | Body | Description |
|---|---|---|---|
| PATCH | `/api/restaurants/:id/active` | `{ is_active: boolean }` | Instant open/close toggle — available to `restaurant_owner` only |

> All other restaurant settings (opening hours, default ready time, menu management) are managed exclusively via the Admin Panel.

---

## 14. State Machines (Dashboard View)

AI agents must implement these exactly. No additional states, no aliases.  
Canonical state vocabulary is defined in `/docs/architecture.md` Section 3.7.

### Order Status — Staff-Actionable Transitions

```
pending
  → confirmed         (Accept Order)
  → cancelled         (Cancel Order — any staff, reason required)

confirmed
  → preparing         (Start Preparing)
  → cancelled         (Cancel Order — restaurant_owner only, manager PIN + reason required)

preparing
  → ready_for_pickup  (Mark Ready)
  → [cancellation NOT permitted at this stage or beyond]

ready_for_pickup
  → out_for_delivery  (Assign Driver — delivery orders only)
  → delivered         (Mark Collected / Mark Paid & Complete — pickup orders only)

out_for_delivery
  → [no dashboard actions — driver app owns this]

delivered
  → [terminal — no actions]

cancelled
  → [terminal — no actions]
```

### Delivery Status — Ownership Model

```
unassigned
  → assigned          (Dashboard — Assign Driver modal)

assigned
  → picked_up         (Driver App only)

picked_up
  → on_the_way        (Driver App only)

on_the_way
  → delivered         (Driver App only)

[any active state]
  → failed            (Dashboard — Mark Failed, with reason)

delivered             [terminal]
failed                [terminal]
```

### Order ↔ Delivery Coupling (server-side only — do not implement in frontend)

| Delivery transition | Order transition |
|---|---|
| `assigned` | order remains `ready_for_pickup` |
| `picked_up` | order → `out_for_delivery` |
| `delivered` | order → `delivered` |
| `failed` | order → `cancelled` |

---

## 15. Frontend Architecture Rules

### Component Structure
```
/apps/web/app/dashboard/
  layout.tsx                  ← Auth guard, sidebar, header, connection status, offline banner
  orders/
    page.tsx                  ← Swimlane layout, React Query hooks only
    components/
      OrderColumn.tsx         ← Single swimlane column
      OrderCard.tsx           ← Order card + action buttons
      CancelOrderModal.tsx    ← Cancellation reason modal
      AssignDriverModal.tsx   ← Driver assignment modal
  drivers/
    page.tsx
    components/
      DriverList.tsx
      DeliveryStatusBadge.tsx
      DeliveryMap.tsx
```

### React Query Keys (Strict — do not deviate)
```
['orders', restaurantId]              ← all today's orders
['order', orderId]                    ← single order detail
['drivers', restaurantId]             ← all drivers
['deliveries', restaurantId]          ← active deliveries
['restaurant', restaurantId]          ← restaurant settings
['delivery-location', deliveryId]     ← driver location (polled every 15s)
```

### Polling Strategy
- `['delivery-location', deliveryId]` → `refetchInterval: 15000`
- All other queries → invalidated via Supabase Realtime events, no polling

### No Direct DB Calls
```typescript
// ❌ FORBIDDEN
import { supabase } from '@/lib/supabase'
const { data } = await supabase.from('orders').select('*')

// ✅ CORRECT
const { data } = await fetch('/api/orders?restaurant_id=...')
```

---

## 16. Role-Based UI Rules

| Element | `restaurant_staff` | `restaurant_owner` |
|---|---|---|
| Orders module | ✅ Full access | ✅ Full access |
| Drivers module | ✅ Full access | ✅ Full access |
| Restaurant Open/Closed toggle | ❌ Hidden | ✅ Visible |
| Cancel Order (pending) | ✅ Visible | ✅ Visible |
| Cancel Order (confirmed) | ❌ Hidden | ✅ Visible (PIN required) |
| Mark Failed (delivery) | ✅ Visible | ✅ Visible |

**Rule:** UI hiding is a convenience. Backend must validate role on every request independently.

---

## 17. Error Handling

### Toast Notifications (all operational errors)
- Order status update failed → *"Failed to update order. Please try again."*
- Concurrency conflict → *"Order updated by another staff member. Refreshing."*
- Driver assignment failed → *"Could not assign driver. Refresh and retry."*
- Opening hours save failed → *"Failed to save hours. Your changes have not been saved."*

### Form Errors (login screen only)
Inline error below the field. Never a toast for auth errors.

### Realtime Disconnection
Show the 🟡 Reconnecting… header indicator + offline banner. Do not show a toast on every disconnect event.

### Global Error Boundary
Wrap the dashboard layout in a React Error Boundary. On unhandled render error, show a full-page message: *"Something went wrong. Please refresh."* with a Refresh button.

---

## 18. Domain Invariants

These are laws of the system that must never be violated. AI agents must not generate code that would break these invariants under any circumstances.

```
1. An order's price cannot change after checkout.
   Enforced by: order_items snapshot at creation time (item_name, item_price, quantity, line_total).

2. An order must belong to exactly one restaurant.
   Enforced by: orders.restaurant_id NOT NULL.

3. A driver cannot have more than one active delivery at a time.
   Enforced by: backend rejects assignment if driver has any delivery in
   (assigned, picked_up, on_the_way) state.

4. A driver can only be assigned to orders belonging to their own restaurant.
   Enforced by: backend validates drivers.restaurant_id = orders.restaurant_id before assignment.

5. An order cannot reach delivered status without payment being succeeded,
   EXCEPT for fulfillment_type = pickup + in-store payment, where payment is
   collected at the Mark Paid & Complete step.

6. Closing the restaurant (is_active = false) only blocks new order creation.
   It never cancels or modifies in-progress orders.

7. Order status transitions must follow the defined state machine exactly.
   No skipping states. No reversing states (except explicit cancellation).

8. Every order cancellation must record a reason and the staff member who cancelled it.

9. Payment success for online orders must be verified via Stripe webhook signature only.
   Client-side payment confirmation alone cannot finalize an order.

10. Every in-store payment collection must record the staff member via collected_by_user_id.

11. Only one delivery record may exist per order.
    Enforced by: UNIQUE constraint on deliveries.order_id at the database level.
    Application-level checks alone are insufficient.

12. Cancellation of a confirmed order requires restaurant_owner role and a valid manager PIN.
    Cancellation of a preparing (or later) order is not permitted via the dashboard under any
    circumstances. Post-preparation cancellations are handled out-of-band by management.

13. Driver location displayed on the map must not be older than 2 minutes.
    If drivers.last_location_at is older than 120 seconds, the UI must show a stale
    location warning and hide the map marker. Stale coordinates must never be
    presented as current.
```

---

## 19. Out of Scope (MVP)

AI agents must not implement the following. They are explicitly deferred.

- Opening hours management (moved to Admin Panel — not part of this dashboard)
- Default ready time configuration (managed via Admin Panel)
- Promotions & discount code management UI
- Loyalty program management UI
- Revenue analytics & reporting
- Multi-location support (schema is ready, but no UI or JWT `location_id`)
- Platform pool / shared drivers (restaurant-owned only in MVP)
- Push notifications to staff mobile devices
- Printer / receipt ticket integration
- Driver live location streaming via Supabase Realtime (polled map only in MVP)
- Cash on delivery (explicitly unsupported per architecture spec Section 4.7)
- Batched deliveries (one active delivery per driver, MVP)
- Staff account creation / management UI (handled by platform admin panel)
- Automatic action queuing while offline (manual retry only)

---

*End of Restaurant Dashboard PRD v2*
