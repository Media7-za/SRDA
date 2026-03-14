# PRD — Driver App
**Platform:** Restaurant Direct  
**App:** Flutter (separate repository: `food-delivery-mobile/`)  
**Stage:** MVP  
**Audience:** AI Coding Agents — treat every rule here as a strict contract

> **Related PRDs:**
> - Restaurant Dashboard → `/docs/PRD_Dashboard.md` (delivery state ownership rules)
> - Restaurant Owner Portal → `/docs/PRD_Owner_Portal.md` (driver account creation)
> - Platform Super-Admin → `/docs/PRD_Platform_Admin.md`
> - Core product → `/docs/PRD_Core.md`

---

## Table of Contents

1. [Purpose & Scope](#1-purpose--scope)
2. [Canonical Role & JWT](#2-canonical-role--jwt)
3. [App Architecture](#3-app-architecture)
4. [Delivery State Ownership](#4-delivery-state-ownership)
5. [Screen: Online/Offline Toggle (Home)](#5-screen-onlineoffline-toggle-home)
6. [Screen: Incoming Delivery Notification](#6-screen-incoming-delivery-notification)
7. [Screen: Active Delivery Map](#7-screen-active-delivery-map)
8. [Screen: Delivery History](#8-screen-delivery-history)
9. [Screen: Earnings Summary](#9-screen-earnings-summary)
10. [GPS Location System](#10-gps-location-system)
11. [Push Notifications (FCM)](#11-push-notifications-fcm)
12. [Offline Handling](#12-offline-handling)
13. [API Contract](#13-api-contract)
14. [State Machines](#14-state-machines)
15. [Domain Invariants](#15-domain-invariants)
16. [Out of Scope (MVP)](#16-out-of-scope-mvp)

---

## 1. Purpose & Scope

The Driver App is a **Flutter mobile application** used by restaurant delivery drivers to receive, manage, and complete delivery jobs.

It is the **only** app that drives delivery state transitions beyond `assigned`. The Restaurant Dashboard assigns a delivery and can mark it failed, but all intermediate state transitions (`assigned` → `picked_up` → `on_the_way` → `delivered`) are driven exclusively by this app.

### Repository
The Driver App lives in a **separate repository** — it is not part of the pnpm monorepo:
```
food-delivery-mobile/
  /lib
  /android
  /ios
```

It communicates with the backend exclusively via REST APIs. It does not access Supabase directly.

### MVP Screens
- Home (Online/Offline toggle + active delivery summary)
- Active Delivery Map (route, status actions, navigation)
- Delivery History (past jobs)
- Earnings Summary (tenant-dependent — see Section 9)
- Push notification entry points (from background/killed state)

---

## 2. Canonical Role & JWT

The driver authenticates with `role = driver`. This is the canonical value from the platform `UserRole` enum — do not use alternate strings.

**JWT payload:**
```json
{
  "sub": "user-uuid",
  "role": "driver",
  "restaurant_id": "restaurant-uuid",
  "driver_id": "driver-uuid",
  "iat": 1700000000,
  "exp": 1700086400
}
```

- JWT expiry: 24 hours (drivers run long shifts — shorter expiry creates friction).
- On expiry: show a re-login screen. Do not silently fail API calls.
- JWT stored in Flutter `flutter_secure_storage` — never in SharedPreferences or plain local storage.

**Login endpoint:** `POST /api/auth/driver/login` with `{ email, password }`.

---

## 3. App Architecture

### Tech Stack
- **Framework:** Flutter (Dart)
- **State management:** Riverpod
- **Navigation:** GoRouter
- **Maps:** Google Maps Flutter plugin
- **HTTP:** Dio (with interceptors for JWT injection and 401 handling)
- **Secure storage:** flutter_secure_storage
- **Push notifications:** firebase_messaging (FCM)
- **Background location:** background_locator_2 or geolocator with background mode enabled

**Rule for AI agents:** Do not introduce alternate state management libraries (Provider, Bloc, GetX) unless this document is explicitly updated. Riverpod is the canonical choice.

### Folder Structure
```
food-delivery-mobile/lib/
  main.dart
  app.dart                        ← GoRouter setup, app theme
  core/
    api/
      api_client.dart             ← Dio instance + interceptors
      endpoints.dart              ← all API endpoint constants
    auth/
      auth_repository.dart
      auth_notifier.dart          ← Riverpod notifier
    storage/
      secure_storage.dart
  features/
    home/
      home_screen.dart
      home_notifier.dart
    delivery/
      active_delivery_screen.dart
      delivery_notifier.dart
      delivery_map_widget.dart
      delivery_action_button.dart
    history/
      history_screen.dart
      history_notifier.dart
    earnings/
      earnings_screen.dart
      earnings_notifier.dart
  shared/
    widgets/
      status_badge.dart
      loading_overlay.dart
      error_banner.dart
    models/
      delivery.dart
      order_summary.dart
      driver.dart
      earnings.dart
```

### Layer Rules
- Screens contain only UI and call Riverpod notifiers. No business logic in screens.
- Notifiers contain state management and call repositories.
- Repositories handle all API calls via `api_client.dart`. No direct `http` or `Dio` calls outside repositories.
- Models are plain Dart classes with `fromJson` / `toJson`. No business logic in models.

---

## 4. Delivery State Ownership

This is the most important rule in this PRD. Read it carefully.

**The Driver App owns the following delivery state transitions exclusively:**

| Driver Action | Delivery Transition | Coupled Order Transition |
|---|---|---|
| Tap "I've arrived / Picked Up" | `assigned` → `picked_up` | order → `out_for_delivery` |
| Tap "On the Way" | `picked_up` → `on_the_way` | no change |
| Tap "Delivered" | `on_the_way` → `delivered` | order → `delivered` |

**The Restaurant Dashboard owns:**

| Dashboard Action | Delivery Transition |
|---|---|
| Assign Driver modal | `unassigned` → `assigned` |
| Mark Failed | any active state → `failed` |

**Rule for AI agents:** The Driver App must never attempt to set delivery status to `assigned` or `failed` — those transitions belong to the Dashboard. The Driver App must never skip states — transitions must follow the sequence exactly. The backend enforces valid transitions server-side and rejects invalid ones.

---

## 5. Screen: Online/Offline Toggle (Home)

**Route:** `/home`  
**This is the first screen after login.**

### Layout

```
┌─────────────────────────────────┐
│  Restaurant Name                │
│  [ONLINE ●] / [OFFLINE ○]       │  ← prominent toggle
│                                 │
│  ┌───────────────────────────┐  │
│  │  Active Delivery          │  │
│  │  Order #A3F9C1            │  │
│  │  123 Main St, Cape Town   │  │
│  │  Status: On the Way       │  │
│  │  [View Delivery →]        │  │
│  └───────────────────────────┘  │
│                                 │
│  No active delivery             │  ← shown when idle
└─────────────────────────────────┘
```

### Online/Offline Toggle

- Calls `PATCH /api/drivers/:id/status` with `{ status: 'online' | 'offline' }`.
- When `offline`: driver will not receive new delivery assignments. GPS posting stops.
- When `online`: driver is eligible for assignment. GPS posting resumes.
- Toggle state is persisted server-side on `drivers.status`. On app restart, the app fetches current status from `GET /api/drivers/:id` and reflects it accurately — do not persist toggle state locally.

### Active Delivery Card

If the driver has an active delivery (`assigned`, `picked_up`, or `on_the_way`):
- Show order short ID, delivery address, current status badge
- Tap → navigates to Active Delivery screen

If no active delivery:
- Show "No active delivery. You're ready for the next job."

---

## 6. Screen: Incoming Delivery Notification

Drivers receive a **push notification** (FCM) when a new delivery is assigned to them.

### Notification Payload
```json
{
  "type": "delivery_assigned",
  "delivery_id": "uuid",
  "order_id": "uuid",
  "short_order_id": "A3F9C1",
  "pickup_address": "Restaurant Name, 45 Long St",
  "dropoff_address": "123 Main St, Cape Town",
  "item_count": 3
}
```

### Notification Behaviour

**App in foreground:** Show an in-app modal overlay:
```
New Delivery Assigned
Order #A3F9C1 — 3 items
Pickup: Restaurant Name, 45 Long St
Drop-off: 123 Main St, Cape Town
[ View Delivery ]
```

**App backgrounded or killed:** FCM delivers a system notification. Tapping it opens the app directly to the Active Delivery screen for that `delivery_id`.

### No Accept/Reject in MVP

The Driver App does **not** have an Accept/Reject flow. Assignments are made by the restaurant dashboard and are binding. The driver taps "View Delivery" to proceed.

**Rule for AI agents:** Do not build an accept/reject flow. This is explicitly out of scope. If a driver cannot complete a delivery, the restaurant dashboard marks it failed.

---

## 7. Screen: Active Delivery Map

**Route:** `/delivery/:delivery_id`

The core operational screen. The driver uses this screen for the entire duration of a delivery.

### Layout

```
┌─────────────────────────────────┐
│  Order #A3F9C1    [ON THE WAY]  │  ← status badge
│                                 │
│  ┌───────────────────────────┐  │
│  │                           │  │
│  │     Google Maps           │  │
│  │     (route displayed)     │  │
│  │                           │  │
│  └───────────────────────────┘  │
│                                 │
│  Drop-off: 123 Main St          │
│  Cape Town, 8001                │
│  [ Open in Google Maps ]        │  ← deep link to Google Maps nav
│                                 │
│  ┌───────────────────────────┐  │
│  │   [ Picked Up ✓ ]        │  │  ← primary action button
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

### Map Display

- Embedded Google Maps showing the route from current driver location to next destination.
- **While `assigned`:** Route shown to pickup address (restaurant).
- **While `picked_up` / `on_the_way`:** Route shown to dropoff address (customer).
- Driver's current location dot updates in real time as GPS posts.

### Primary Action Button

One button drives the delivery forward. It changes based on current status:

| Current Delivery Status | Button Label | API Call |
|---|---|---|
| `assigned` | Picked Up | `PATCH /api/deliveries/:id/status` → `picked_up` |
| `picked_up` | On the Way | `PATCH /api/deliveries/:id/status` → `on_the_way` |
| `on_the_way` | Mark Delivered | `PATCH /api/deliveries/:id/status` → `delivered` |
| `delivered` | [no button — completion screen shown] | — |

### Delivered Confirmation

On tapping "Mark Delivered":
1. Show a confirmation modal: *"Confirm delivery to 123 Main St?"*
2. On confirm: call API, transition to `delivered`.
3. Show a brief completion screen: *"Delivery complete! Great work."*
4. After 3 seconds → navigate back to Home screen.

### External Navigation

"Open in Google Maps" button deep-links to Google Maps with the destination pre-filled:
```
https://maps.google.com/?daddr={latitude},{longitude}
```
This opens the native Google Maps app for turn-by-turn navigation. The Driver App itself does not provide turn-by-turn — it shows a static route overview only.

### Order Summary (collapsible)

A collapsible panel at the bottom of the map screen showing:
- Item names and quantities (from the order snapshot)
- Customer name
- Special instructions (if any — `orders.special_instructions` field, nullable)

---

## 8. Screen: Delivery History

**Route:** `/history`

A scrollable list of the driver's past completed and failed deliveries.

### List Item

Each row shows:
- Order short ID
- Delivery address (truncated)
- Status badge: `delivered` (green) or `failed` (red)
- Date and time completed
- Earnings for that delivery (if earnings enabled for this restaurant — see Section 9)

### Pagination

Load 20 items per page. Infinite scroll — load next page on scroll to bottom.

**API:** `GET /api/drivers/:id/deliveries?status=completed&page=1&limit=20`

---

## 9. Screen: Earnings Summary

**Route:** `/earnings`

**This screen is tenant-dependent.** It is only visible if `restaurants.features.earnings_enabled = true` for the driver's restaurant.

**Rule for AI agents:** Check `restaurants.features` on app load. If `earnings_enabled` is `false` or absent, remove the Earnings tab from the bottom navigation entirely. Do not show a disabled state — simply omit the tab.

### Earnings Model (MVP)

**Per-delivery flat fee** set by the restaurant owner in the Owner Portal.

```
driver_earnings_config
  id
  restaurant_id          UUID     NOT NULL  UNIQUE
  fee_per_delivery       DECIMAL  NOT NULL  DEFAULT 0.00
  currency               TEXT     DEFAULT 'ZAR'
```

> **Note for Owner Portal PRD:** A "Driver Earnings" settings section must be added to the Owner Portal (Phase 2) allowing the owner to set `fee_per_delivery`. This is referenced here for schema completeness — it is not built in the Owner Portal MVP.

### Earnings Screen Layout

```
┌─────────────────────────────────┐
│  Earnings                       │
│                                 │
│  This Week                      │
│  R [total]   [N] deliveries     │
│                                 │
│  This Month                     │
│  R [total]   [N] deliveries     │
│                                 │
│  ─────────────────────────────  │
│  Recent                         │
│  Order #A3F9C1  R[fee]  Today   │
│  Order #B2E8D0  R[fee]  Today   │
│  ...                            │
└─────────────────────────────────┘
```

Earnings figures are computed server-side — the app never calculates earnings locally.

**APIs:**
```
GET /api/drivers/:id/earnings/summary
GET /api/drivers/:id/earnings/history?page=1&limit=20
```

---

## 10. GPS Location System

### Posting Frequency

Every **15 seconds** while the driver is `online` and has an active delivery.

GPS posting **stops** when:
- Driver toggles to `offline`
- Driver has no active delivery (status `unassigned` or idle)
- App is killed (background posting resumes on next foreground if delivery still active)

GPS posting **does not start** when:
- Driver is `offline`
- Driver has no active delivery

**Rationale:** Posting only during active deliveries preserves battery and reduces unnecessary server load. There is no business value in tracking a driver's location when they are idle.

### Location Payload

```json
POST /api/drivers/:id/location
{
  "latitude": -33.9249,
  "longitude": 18.4241,
  "recorded_at": "2026-03-08T14:22:00Z",
  "delivery_id": "uuid-or-null"
}
```

### Backend Behaviour on Location Receipt

The backend must:
1. Insert a record into `driver_locations` (append-only history).
2. Update `drivers.current_location` with the latest coordinates.
3. Update `drivers.last_location_at` with the timestamp.

Both updates happen atomically in a single transaction.

### GPS Staleness Rule

The Restaurant Dashboard considers a driver's location stale if `drivers.last_location_at` is older than 120 seconds. The Driver App does not need to handle this — it is a dashboard display concern. The Driver App simply posts on schedule.

### Background Location

The app must request `always` location permission on iOS and background location permission on Android. If the user denies background location, show a persistent warning: *"Background location is required for delivery tracking. Please enable it in Settings."* Do not silently fail.

### Permission Request Flow

1. On first login, explain why location is needed: *"We need your location to show customers where their order is and to help navigate your deliveries."*
2. Request permission.
3. If denied: show warning, allow app use but disable GPS posting and show a banner: *"Location disabled — your position won't be shared."*
4. Never request permission again without user interaction (follow platform guidelines).

---

## 11. Push Notifications (FCM)

### Technology

**Firebase Cloud Messaging (FCM)** — server-sent push. This is the production standard and works when the app is backgrounded or killed.

**Why not Flutter local push only:** Local push requires the app to be running. Drivers may have the app backgrounded or closed when an assignment is made. FCM delivers to the device OS, which displays the notification regardless of app state.

### FCM Token Management

On app launch (and on FCM token refresh), the app must register the device token:

```
POST /api/drivers/:id/fcm-token
{ "token": "fcm-device-token-string", "platform": "android" | "ios" }
```

**Data model:**
```
driver_devices
  id              UUID
  driver_id       UUID       NOT NULL
  fcm_token       TEXT       NOT NULL
  platform        ENUM ('android', 'ios')
  created_at      TIMESTAMP
  updated_at      TIMESTAMP
```

A driver may have multiple devices (phone + tablet). All registered tokens receive notifications.

### Notification Types (MVP)

| Type | Trigger | Content |
|---|---|---|
| `delivery_assigned` | Backend assigns a delivery to this driver | "New delivery — Order #[id], [N] items" |
| `delivery_cancelled` | Restaurant cancels an in-progress delivery | "Delivery cancelled — Order #[id]" |

### Notification Handling

**Foreground:** Intercept via `FirebaseMessaging.onMessage` and show an in-app modal (see Section 6).

**Background / killed:** FCM handles display. On tap, `FirebaseMessaging.onMessageOpenedApp` navigates to the relevant screen.

**On app launch from killed state:** Check `FirebaseMessaging.instance.getInitialMessage()` for a pending notification and navigate accordingly.

---

## 12. Offline Handling

Drivers may lose connectivity mid-delivery. The app must handle this gracefully.

### Offline Behaviour

| Scenario | App Behaviour |
|---|---|
| Network lost while viewing map | Show offline banner. Map tiles remain visible (cached). GPS continues posting — queue posts locally if no connection. |
| Network lost while tapping status button | Show error: *"Could not update status — you appear to be offline. Tap to retry."* Do not advance state locally. |
| GPS post fails due to no connection | Queue the location post locally (max 10 queued points). Flush queue in order when connectivity returns. |
| Network restored | Dismiss offline banner. Flush location queue. Retry any failed status update if still in the same state. |

### Location Queue

Store up to 10 location points locally using `flutter_secure_storage` or `sqflite`. On reconnect, flush the queue oldest-first via sequential API calls. After flushing, clear the queue.

**Rule:** Do not send queued location points out of order. The backend expects monotonically increasing `recorded_at` timestamps per driver.

### Status Update Rule

**Never advance delivery status optimistically.** Status transitions must be confirmed by a successful API response before the UI advances. If the API call fails, the button remains pressable for retry. This is different from the Dashboard's optimistic UI — delivery state changes have physical real-world consequences (a driver may stop driving if they think a status updated when it didn't).

---

## 13. API Contract

All requests include `Authorization: Bearer <jwt>`.  
All responses use the global envelope:
```json
{ "success": true, "data": { ... } }
{ "success": false, "data": null, "error": { "code": "...", "message": "..." } }
```

| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/auth/driver/login` | Driver login — returns JWT |
| POST | `/api/auth/driver/logout` | Invalidate session |
| GET | `/api/drivers/:id` | Get driver profile + current status |
| PATCH | `/api/drivers/:id/status` | Toggle online/offline |
| POST | `/api/drivers/:id/location` | Post GPS location |
| POST | `/api/drivers/:id/fcm-token` | Register FCM device token |
| GET | `/api/drivers/:id/deliveries/active` | Get current active delivery (if any) |
| PATCH | `/api/deliveries/:id/status` | Advance delivery status (driver-owned transitions only) |
| GET | `/api/deliveries/:id` | Get full delivery detail (order snapshot, addresses) |
| GET | `/api/drivers/:id/deliveries?status=completed&page=&limit=` | Delivery history |
| GET | `/api/drivers/:id/earnings/summary` | Earnings totals (tenant-gated) |
| GET | `/api/drivers/:id/earnings/history?page=&limit=` | Earnings history (tenant-gated) |

### Driver-Permitted Delivery Status Values

The `PATCH /api/deliveries/:id/status` endpoint must enforce that drivers can only submit these values:

```
picked_up
on_the_way
delivered
```

Any other value submitted by a driver JWT must be rejected with `403 Forbidden`. The backend enforces this regardless of what the app sends.

---

## 14. State Machines

### Delivery Status — Driver-Owned Transitions

```
assigned
  → picked_up       (Driver taps "Picked Up")

picked_up
  → on_the_way      (Driver taps "On the Way")

on_the_way
  → delivered       (Driver taps "Mark Delivered" + confirms modal)

delivered           [terminal — no further driver actions]
failed              [terminal — set by Dashboard only, driver sees read-only]
```

### Driver Online Status

```
offline
  → online          (Driver toggles ON)

online
  → offline         (Driver toggles OFF)
```

**Rule:** A driver cannot go offline while they have an active delivery (`assigned`, `picked_up`, `on_the_way`). The backend must reject the status change and return: `"Cannot go offline while a delivery is in progress."` The app must surface this message to the driver.

---

## 15. Domain Invariants

These laws must never be violated. AI agents must not generate code that breaks them.

```
1.  The Driver App may only submit delivery status values: picked_up, on_the_way,
    delivered. All other transitions belong to other apps. Backend enforces this.

2.  Delivery status transitions must follow the defined sequence exactly.
    No skipping states. Backend rejects out-of-sequence transitions.

3.  Delivery status must never be advanced optimistically.
    The UI must only advance after a confirmed successful API response.

4.  A driver cannot go offline while they have an active delivery.
    Backend must reject the request with a clear error message.

5.  GPS location posts must always include a recorded_at timestamp from the device.
    The backend must store received_at server-side as well, for drift detection.

6.  Queued offline location posts must be flushed in chronological order.
    Out-of-order posts are rejected by the backend.

7.  JWT must be stored in flutter_secure_storage only.
    Never SharedPreferences, never plain local storage.

8.  The Earnings screen and tab must be completely hidden (not just disabled)
    when restaurants.features.earnings_enabled is false or absent.

9.  The Driver App must never access the Supabase database directly.
    All data access goes through the Backend REST API.

10. FCM device tokens must be re-registered on every app launch and on
    token refresh. Stale tokens cause missed delivery notifications.
```

---

## 16. Out of Scope (MVP)

AI agents must not implement the following:

- Accept / Reject delivery flow (assignments are binding in MVP)
- Batched deliveries (one active delivery per driver)
- Turn-by-turn navigation within the app (deep-link to Google Maps only)
- In-app chat between driver and customer
- Driver ratings / feedback
- Scheduled delivery support
- Driver earnings configuration UI (lives in Owner Portal Phase 2)
- Cash on delivery (explicitly unsupported platform-wide)
- Multiple device session management (all registered tokens receive notifications)
- Driver referral or incentive programs
- Proof of delivery (photo capture)
- Contactless delivery instructions UI

---

*End of Driver App PRD*