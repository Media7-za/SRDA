# Architecture Specification
## Project: Restaurant Ordering & Delivery Platform

**Source of Truth:** This document defines the exact architecture, system modules, service boundaries, operational rules, and data flows for the entire platform. **ALL AI agents must strictly adhere to these patterns.** Do not invent new architectural layers, break module ownership, or bypass defined boundaries without explicit updates to this file.

---

## 1. System Overview

The application follows a **Decoupled Monolithic Architecture** within a single **pnpm workspace monorepo**. 

- **Frontend Clients:** 
  - Web Application: Next.js (primary MVP interface)
  - Mobile Application: Flutter (optional for MVP, implemented in a separate mobile repository when required)

**Note:** The mobile application is **not implemented inside the pnpm workspace monorepo** because Flutter uses a different toolchain. When developed, it will consume the same REST APIs exposed by the backend.

### 1.1 Repository Structure (Strict)

```text
/apps               (Client Applications)
  /web              (Next.js web application)
/backend            (Node.js + Fastify API Server)
  /src
    /config         (Environment and app configuration)
    /controllers    (HTTP request/response handling)
    /services       (Core business logic)
    /repositories   (Database access layer)
    /routes         (API endpoint definitions)
    /middlewares    (Auth, validation, error handling)
    /utils          (Shared helper functions)
/database           (Database Schema & Migrations — workspace package)
  /prisma           (Prisma schema file)
  /migrations       (Generated DB migrations)
/packages           (Shared Monorepo Libraries)
  /types            (Shared TypeScript types)
  /config           (Shared ESLint, Prettier, TS configs)
/docs               (Project Documentation)
/ai                 (AI Context and Task Documents)
```

### 1.2 Mobile App Location
The Flutter mobile application is **not part of the monorepo**.
When developed it will exist as a separate repository:
```text
food-delivery-mobile/
  /lib
  /android
  /ios
```
The Flutter app communicates with the backend exclusively through REST APIs.

### 1.3 Mobile Platform Policy
The official mobile technology for this platform is **Flutter**.

Reasons:
- strong performance for delivery tracking interfaces
- single codebase for iOS and Android
- mature ecosystem for maps and realtime tracking
- clear separation from web monorepo tooling

AI agents must **not introduce React Native or Expo** unless the architecture document is explicitly updated.

**Rule:** Dependencies flow inwards. Frontend apps can import from `/packages/types`, but `/packages/types` cannot import from `/apps`. The Backend and Frontend do not share execution code.

---

## 2. Backend Architecture (Layered Service Pattern)

The backend strictly enforces the **Controller-Service-Repository** pattern. 
Never put database queries in a controller. Never put HTTP logic in a repository.

### Layer 1: Routes
- Maps HTTP methods and paths to Controllers.
- Applies route-level middleware (Authentication, Rate Limiting).
- **Tool:** Fastify routing.

### Layer 2: Controllers
- Extracts data from HTTP requests (params, body, query).
- Validates input formats (using Zod or Fastify schemas).
- Calls exactly one or more Services.
- Formats HTTP responses (standardized JSON structure).
- **Rule:** Controllers must remain "thin" (under 50 lines of logic). No business rules.

### Layer 3: Services
- Executes core business logic and rules.
- Calls Repositories to fetch/save data.
- Calls external providers (like Stripe).
- Throws domain-specific errors (not HTTP errors). 
- **Rule:** Services do not know about HTTP ("req" or "res") and they do not write Raw SQL.

### Layer 4: Repositories
- Handles all database interactions.
- Abstracts the ORM (Prisma) from the rest of the application.
- **Rule:** Only repositories may import and use the Prisma Client. 

---

## 3. Core System Modules (Bounded Contexts & Ownership)

The system is organized around specific business domains. **Strict Ownership Rule:** A service can only directly query its owned tables. To access data owned by another module, it must call that module's Service.

### 3.1 Authentication & User Identity (Auth Module)
- **Role:** Identity management and JWT issuance.
- **Table Ownership:** `users`, `roles`, `sessions`.

### 3.2 Restaurant & Catalog (Menu Module)
- **Role:** Managing restaurant profiles and available food items. Highly cached.
- **Table Ownership:** `restaurants`, `menu_items`, `menu_categories`, `menu_modifiers`.

### 3.3 Ordering Engine (Order Module)
- **Role:** Handles the cart lifecycle, order validation, pricing calculation, and status tracking.
- **Table Ownership:** `orders`, `order_items`, `order_item_options`, `carts`.

### 3.4 Payments & Billing (Payment Module)
- **Role:** Reconciling payment status with orders via external gateways (Stripe) and internal manual resolutions (Pay In-Store).
- **Table Ownership:** `payments` (the canonical ledger), `payment_intents`.
- **Rule:** No raw credit card data is stored; only intent IDs and statuses. All money events (online or in-store) must be recorded in the `payments` table.
- **Rule:** In-store payments require staff accountability via `collected_by_user_id` on the `payments` record.

### 3.5 Delivery & Fulfillment (Delivery Module)
- **Role:** Assigning orders to drivers and tracking delivery states.
- **Table Ownership:** `deliveries`, `drivers`, `driver_locations`.

### 3.6 Realtime & Notifications (Event Module)
- **Role:** Handles WebSockets/SSE for live order tracking, and push notifications/emails.
- **Rule:** Other modules throw internal events (e.g., `OrderConfirmedEvent`), which this module listens to and broadcasts out.

### 3.7 Canonical Enums & Vocabulary
To prevent architectural drift, AI agents must strictly use the following vocabulary across schema, API, and UI:
- **Schema/API nouns:** `drivers`, `deliveries`, `driver_locations`
- **Forbidden:** Do not use `trip` unless it has a distinct business meaning from `delivery`.
- **Order States:** heavily standardizing to `pending`, `confirmed`, `preparing`, `ready_for_pickup`, `out_for_delivery`, `delivered`, `cancelled`. No aliases (e.g. no `ready` or `PAID`).

### 3.8 Delivery Data Model
The expected minimum relationships for the MVP delivery domain:
- `orders` (1) — (0..1) `deliveries`
- `drivers` (1) — (many) `deliveries`
- `drivers` (1) — (many) `driver_locations`

## Delivery Modeling Rules

- MVP supports only one active delivery per driver at a time.
- Batched deliveries are out of scope for MVP.
- Canonical delivery entities are: drivers, deliveries, driver_locations.
- `driver_locations` stores bounded historical coordinates with retention cleanup.
- drivers may have many deliveries historically, but at most one active delivery at any moment.

### 3.9 Delivery States & Coupling
Valid Delivery States: `unassigned`, `assigned`, `picked_up`, `on_the_way`, `delivered`, `failed`.
Coupling rules to Order states:
- when delivery becomes `assigned`, order usually remains `ready_for_pickup`
- when delivery becomes `picked_up`, order becomes `out_for_delivery`
- when delivery becomes `delivered`, order becomes `delivered`

### 3.10 Location Storage Strategy (Dual Model)
To power real-time UI without infinitely scaling coordinates, location utilizes a dual model:
1. **`drivers.current_location`**:
   - Stores only the latest known location (`latitude`, `longitude`, `recorded_at`).
2. **`driver_locations` (History)**:
   - Append-only history with fields: `id`, `driver_id`, `delivery_id` (nullable), `latitude`, `longitude`, `recorded_at`.
   - Retention policy: Keep detailed points for **7–30 days**, aggregating or deleting older points via a scheduled cleanup job.

---

## 4. Critical Commerce Rules

### 4.1 Cart vs Order Separation
The **Cart** represents temporary, mutable shopping intent. It can change freely and is not authoritative.
The **Order** is the immutable commercial record of what was purchased. It never trusts frontend totals and is created as `pending` before payment.

### 4.2 Mandatory Order Snapshots
When an order is created, the system **must snapshot** the pricing data. The `order_items` snapshot must explicitly include:
- `item_name`
- `item_price`
- `quantity`
- `selected_options` (including `option_name` and `option_price`)
- `line_total`
- `delivery_fee` (on the order level)
- `tax_amount` (on the order level)
- `total_amount` (on the order level)

**Rule:** Never link dynamically to menu data for historical orders.

### 4.3 Server-Side Price Calculation
The frontend calculates a total for display, but the backend must never trust it. The checkout validation step on the server must recalculate all totals, validate items, and validate availability before creating an order.

### 4.4 `restaurant_id` on Core Entities
Even for a single-restaurant MVP, the schema must include `restaurant_id` on core entities to ensure scalability.
- `restaurant_id` on menu items, modifiers, and categories
- `restaurant_id` on orders
- `restaurant_id` on promotions

### 4.5 Idempotent Checkout (Critical)
Checkout operations must be idempotent to prevent duplicate orders or double charges.
- Each checkout attempt must include a unique idempotency key.
- Repeated requests with the same key must return the same order/payment result.

### 4.6 Verified Payment via Webhook (Online)
For online payments (Stripe), payment success must be verified strictly through webhook signatures. Client-side payment confirmations alone cannot finalize orders. Payment verification must never trust the frontend.

### 4.7 Fulfillment & Payment Modes (MVP Locked Decisions)
The platform supports two explicit order/payment branches:
1. **Delivery + Online Payment:** Online checkout using Stripe.
2. **Collection + Pay In-Store:** Bypasses Payment Intents. The customer pays cash or card at the pickup counter. 

*Delivery + Pay In-Store (Cash on Delivery) is explicitly unsupported in MVP.*

---

## 5. State Machines & Coupling Rules

### 5.1 Order State Machine
Valid transitions:
`pending` -> `confirmed` -> `preparing` -> `ready_for_pickup` -> `out_for_delivery` -> `delivered`

Explicitly Invalid Transitions (Examples):
- `pending` -> `delivered`
- `delivered` -> `preparing`
- `cancelled` -> `preparing`

### 5.2 Payment State Machine

The canonical domain-level PaymentStatus enum is:
- `pending`
- `processing`
- `succeeded`
- `failed`
- `refunded`

Provider-specific events such as Stripe PaymentIntent creation (`intent_created`) are implementation details and must not replace the domain payment status model. If provider-level tracking is needed, use a separate field (e.g., `payments.provider_status`) or an event log.

> **Revision note (2026-03-06):** Replaced `intent_created` with `pending` and added `refunded`. Rationale: `pending` is a cleaner business-level state; `refunded` is architecturally significant even if refund flows are not MVP priority.

### 5.3 Order-Payment Coupling Rules
The general rule is that `payments` is the canonical ledger of money events, and `orders.payment_status` is a synchronized operational summary.

**For Delivery + Online Payment (Stripe):**
- `order = pending` before payment success.
- Verified payment success (via webhook) allows `order = confirmed`.
- Payment failure cannot produce a confirmed order.

**For Collection + Pay In-Store:**
- Order can be created directly as `confirmed` or `pending` (depending on restaurant auto-accept config).
- `payment_status` remains `unpaid` throughout preparation.
- Staff collection of payment updates `payments` table (with `staff_id`), changes `orders.payment_status` to `paid`, and optionally transitions order state if completed.

**Drift Rule:**
- The order status and payment status must never be allowed to drift apart. All manual adjustments must map directly to an entry in the `payments` table.

---

## 6. Strict Operational Rules
### 6.1 Rate Limiting & Abuse Protection
Protecting endpoints is mandatory for stability and security.
- **Auth Endpoints (`/auth/login`, `/auth/register`):** Strict limits (e.g., 5 reqs / minute / IP).
- **Checkout Endpoints (`/checkout/pay`):** Moderate limits (e.g., 10 reqs / minute / user) to prevent card testing.
- **Public Menu Endpoints (`/restaurants/:id/menu`):** Must be placed behind a caching layer (CDN / Redis) to survive traffic spikes.

### 6.2 Observability and Logging
Production readiness requires tracking critical flows.
The system must log explicitly structured JSON logs for the following events:
- Order Creation Request
- Payment Attempt / Success / Failure
- Order Status Transitions
- Driver Assignment Events
- Any `5xx` error with context

---

## 7. Standardized Data Flows

### Checkout Data Flow (The Critical Path)
1. **Client:** POST `cartItems` and `addressId`.
2. **OrderController:** Validates payload format.
3. **MenuRepository (via OrderService):** Fetches current prices/availability.
4. **OrderService:** Computes final total purely based on DB truth (never trusting client totals) and enforces the **Snapshot Principle**.
5. **PaymentService:** Requests a Stripe `PaymentIntent`.
6. **OrderRepository:** Saves a `PENDING` Order linked to the `PaymentIntent`.
7. **Client:** Processes payment via Stripe Elements.
8. **Stripe Webhook:** Verifies signature, updates `payments.status = succeeded` and `orders.status = confirmed`, triggers a Realtime Notification event.

---

## 8. Frontend Architecture

### UI Component Layers (Next.js)
1. **Pages / Screens:** Handle routing and React Query hooks. Minimal JSX structure.
2. **Feature Components:** Domain-specific blocks (`CheckoutForm`, `MenuGrid`). Accept props, manage form state.
3. **UI Kit:** Stateless, dumb design system components (`Button`, `Card`). No domain logic.

### State Management
- **Server State:** Handled purely by React Query / SWR. 
- **Global UI State:** Minimal usage (Zustand/Context) strictly for global toggles (e.g., Theme, Sidebar).

---

## 9. Error Handling & Build Strategy

### Global Error Envelope
```json
{
  "success": false,
  "data": null,
  "error": { "code": "VALIDATION_ERROR", "message": "Invalid email" }
}
```
*Never leak stack traces.*

### Build & Deploy
- **Database Migrations:** Prisma migrate executes as part of the CD pipeline automatically.
- **Environment:** Managed via `.env` locally, injected via Vercel/Hosting remotely.

## 10. Architectural Enforcement Rules for AI Agents

To ensure strict compliance, any AI agent working on this codebase MUST follow these immutable rules:

1. **Services CANNOT import Prisma**: All database access goes through Repositories.
2. **Controllers CANNOT contain business logic**: Controllers only handle HTTP parsing, validation, and delegating to Services.
3. **Repositories CANNOT call external APIs**: API calls (like Stripe) belong in Services.
4. **Repositories CANNOT handle HTTP**: No `req` or `res` objects inside Repositories.
5. **Frontend CANNOT call database directly**: No direct Supabase client DB queries from the frontend; all data fetching must go through the dedicated Backend Node API.
6. **Modules CANNOT perform direct cross-schema queries**: A module's Service must call another module's Service to access data it doesn't own.
7. **Frontend UI Components CANNOT contain business logic**: Core processing must happen in custom hooks or utility functions, keeping presentation components dumb.

---
End of Architecture Specification
