# Customer App Screen Contract (V2)

This document defines the strict screen compositions for the Customer App. AI agents must abide by these rules to prevent layout drift and component hallucination. Do not use vague nouns; compose ONLY with canonical components from `component_architecture.md`.

---

## 1. Global Shell
All screens in the Customer App must wrap within the `AppShell`.
* **Allowed Components:** `TopNav`, `BottomNav`, `Toast`, `OfflineBanner`
* **Forbidden:** `Sidebar`

---

## 2. Screen: Home Dashboard
* **Route:** `/`
* **Auth Rule:** Optional (Guest browsing allowed)
* **Goal:** Drive repeat order, highlight loyalty, and facilitate item discovery.
* **Layout Mode:** Full Page
* **Primary Action:** Prompt first order or reorder.
* **Required Sections (Order):**
  1. `PageHeader` (Location & Store Status)
  2. `RewardStatusCard` (if logged in)
  3. `SectionHeader` ("Favorites")
  4. Carousel of `MenuItemCard`
  5. `SectionHeader` ("Chef Specials")
  6. Carousel of `MenuItemCard`
* **Forbidden Components:** `OrderCard`, `PaymentBadge`, `DeliveryTaskCard`
* **States:**
  * **Empty:** Show "Featured Items" if no order history.
  * **Offline:** Display `OfflineBanner`.

---

## 3. Screen: Menu & Category Browsing
* **Route:** `/menu`
* **Auth Rule:** Optional
* **Goal:** Browse the full catalog via scrollspy.
* **Layout Mode:** Full Page
* **Primary Action:** Add item to cart.
* **Required Sections (Order):**
  1. `PageHeader` (Categories)
  2. Grid of `MenuItemCard`
  3. `AddToCartBar` (Sticky bottom, visible if cart > 0)
* **States:**
  * **Loading:** Skeleton versions of `MenuItemCard`.
  * **Empty:** `EmptyState` ("No items available in this category").

---

## 4. Screen: Item Customization 
* **Route:** `/menu/[id]` 
* **Auth Rule:** Optional
* **Goal:** Select modifiers, adjust quantity, add to cart.
* **Layout Mode:** `BottomSheet` or `Drawer`
* **Primary Action:** `PrimaryButton` ("Add to Cart")
* **Required Sections (Order):**
  1. `ModalHeader` (Item Name & Price)
  2. Form list of modifiers (`ToggleSwitch`, `SelectInput`)
  3. `QuantityStepper`
  4. `PrimaryButton`
* **Forbidden Components:** `BottomNav`

---

## 5. Screen: Cart & Checkout
* **Route:** `/cart` and `/checkout`
* **Auth Rule:** Required (for final checkout)
* **Goal:** Review order details, select fulfillment, pay.
* **Layout Mode:** Full Page
* **Primary Action:** `PrimaryButton` ("Proceed to Pay" / "Place Order")
* **Required Sections (Order):**
  1. `PageHeader` ("Your Cart")
  2. Cart Items list (`QuantityStepper` per item)
  3. `CheckoutAddressForm`
  4. `PaymentMethodForm`
  5. `PrimaryButton`
* **States:**
  * **Empty:** `EmptyState` ("Your cart is empty.")

---

## 6. Screen: Order Tracking
* **Route:** `/orders/[id]/tracking`
* **Auth Rule:** Required
* **Goal:** Live status updates of a specific active order.
* **Layout Mode:** Full Page
* **Primary Action:** None (Read-only tracking)
* **Required Sections (Order):**
  1. `PageHeader`
  2. `StatusBadge` (Prominent)
  3. `MapView` (if out for delivery)
* **Forbidden Components:** `AddToCartBar`, `QuantityStepper`
* **Data Dependencies:** WebSocket/SSE connection for `order_updated` events.

---

## 7. Screen: Order History
* **Route:** `/orders`
* **Auth Rule:** Required
* **Goal:** View past orders and trigger reorders.
* **Layout Mode:** Full Page
* **Primary Action:** `PrimaryButton` ("Reorder")
* **Required Sections (Order):**
  1. `PageHeader` ("Order History")
  2. List of `OrderHistoryListItem`
* **Forbidden Components:** `MenuItemCard` (Do not use catalog cards for historical logs).
