# PRD — Customer App (Experience & UX)
**Platform:** Restaurant Direct
**Stage:** MVP
**Audience:** Frontend Developers & Designers

---

## 1. Purpose & Scope

The Customer App is the primary interface for end-users to discover, order, and track food from the restaurant. It is designed for high conversion, speed, and brand loyalty.

**Authority Note:** Payment rules, order states, and domain invariants are defined in [PRD_Core.md](./PRD_Core.md). This document focuses on the user experience and specific app features.

---

## 2. Target Users: Customers

People ordering food.

**Needs:**
* Fast ordering
* Easy payment
* Order tracking
* Saved addresses
* Loyalty rewards

---

## 3. MVP Feature Set

### 3.1 Menu Browsing
*   **Structure:** Restaurant → Categories → Items → Options.
*   **UX Requirement:** Fluid scrolling, high-quality images, and clear price visibility.
*   **Customization:** Customers can select modifiers (e.g., "+ Cheese", "No Onions").

### 3.2 Cart & Checkout
*   **Cart:** Persistent cart state. Ability to edit quantities or remove items.
*   **Fulfillment Selection:** Clear toggle between **Delivery** and **Pickup**.
*   **Address Selection:** Integrated map/search for delivery addresses. Saved addresses for return users.
*   **Payment:** Seamless Stripe integration for online payments. "Pay In-Store" option for Collection.

### 3.3 Order Tracking
*   **Real-time Updates:** Visual progress bar showing the [Canonical Order Lifecycle](./PRD_Core.md#6-order-lifecycle).
*   **Driver Tracking:** If in `OUT_FOR_DELIVERY` state, show driver's real-time position on the map.

---

## 4. First-Time User Onboarding

When a new user opens the app for the first time:

• Display a welcome loyalty incentive.
• Highlight popular dishes ("Most Loved").
• Frictionless item discovery to encourage the first order.

---

## 5. Success Metrics (Conversion)

*   **Conversion Rate:** Percentage of visitors who complete an order.
*   **Cart Abandonment Rate:** Identifying drop-off points in the flow.
*   **Repeat Order Rate:** Measuring loyalty.

---

## 6. Design System Contract

All UI components must adhere to the [UI Conformance Rules](./ui_conformance_rules.md) and use the design tokens defined in [component_architecture.md](./component_architecture.md).
