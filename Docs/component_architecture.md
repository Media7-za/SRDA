# Component Architecture Contract (V2)

This document acts as the definitive source of truth for all reusable UI components across the platform. AI agents must **only** build and compose these approved components. Do not invent new structural components without explicit permission.

If a needed UI primitive is absent from this contract, stop and request a contract update. DO NOT invent it.

## 1. Canonical Component Inventory

### Core Structural (Shared)
* `AppShell`
* `TopNav`
* `BottomNav`
* `Sidebar`
* `SectionHeader`
* `PageHeader`
* `ModalHeader`
* `EmptyState`
* `ErrorState`
* `OfflineBanner`
* `Toast`
* `ConfirmationModal`
* `Drawer`
* `BottomSheet`

### Data Display (Shared)
* `DataTable`
* `ChartPanel`
* `StatCard`
* `MapView`

### Interaction & Feedback (Shared)
* `PrimaryButton`
* `SecondaryButton`
* `GhostButton`
* `DestructiveButton`

### Forms & Inputs (Shared)
* `FormField`
* `TextInput`
* `SelectInput`
* `ToggleSwitch`

### Domain-Specific Components
* `MenuItemCard` (Customer, Admin)
* `OrderCard` (Admin live-ops exclusively)
* `DeliveryTaskCard` (Driver routing exclusively)
* `OrderHistoryListItem` (Customer history)
* `RewardStatusCard` (Customer)
* `StatusBadge` (Shared)
* `PaymentBadge` (Admin)
* `FulfillmentBadge` (Admin, Driver)
* `AddToCartBar` (Customer)
* `QuantityStepper` (Customer)
* `CheckoutAddressForm` (Customer)
* `PaymentMethodForm` (Customer)

---

## 2. Component Specifications (Standardized)

All components MUST conform to the state definitions:
* **Supported States:** `loading`, `empty`, `error`, `disabled`, `offline`, `success`, `selected`, `readonly`

### OrderCard
* **Purpose:** Operational summary and next-action control for a live order.
* **Used in:** Admin Panel (Live Operations)
* **Not used in:** Customer App, Driver App
* **Required Slots:**
  * Header: Order number, `FulfillmentBadge`, `PaymentBadge`
  * Meta: Customer name, Time placed / Elapsed time
  * Body: Item summary, special notes
  * Footer: Total price, Primary action, Secondary action
* **Allowed States:** `loading`, `default`, `success`, `error`, `offline`
* **Token Bindings:** Background: `surface.card`, Shadow: `shadow.card`, Radius: `radius.lg`

### DeliveryTaskCard
* **Purpose:** High-level package routing and delivery tracking.
* **Used in:** Driver App
* **Not used in:** Customer App, Admin Panel
* **Required Slots:**
  * Header: Task ID, `FulfillmentBadge`
  * Meta: Distance, Estimated Time
  * Body: Customer address, special delivery notes
  * Footer: Primary action (e.g., "Accept Delivery", "Mark Arrived")
* **Allowed States:** `loading`, `default`, `success`, `error`, `offline`
* **Token Bindings:** Background: `surface.card`, Shadow: `shadow.card`, Radius: `radius.lg`

### MenuItemCard
* **Purpose:** Browsing a menu item or editing it in the admin dashboard.
* **Used in:** Customer App, Admin Panel
* **Not used in:** Driver App
* **Required Slots:**
  * Image: Item photo
  * Meta: Item name, Description, Price, Dietary Badges
  * Action: `PrimaryButton` / `GhostButton`
* **Allowed States:** `default`, `disabled` (sold out), `selected`, `loading`
* **Token Bindings:** Radius: `radius.lg`, Padding: `component.card.padding`

### OrderHistoryListItem
* **Purpose:** Compact, structured log of a previously placed order.
* **Used in:** Customer App
* **Not used in:** Admin Panel, Driver App
* **Required Slots:**
  * Meta: Date, `StatusBadge`, Total Price
  * Body: Summary of items (e.g., "Pad Thai, Spring Rolls")
  * Action: `PrimaryButton` ("Reorder")
* **Allowed States:** `default`, `loading`, `empty`

### StatusBadge
* **Purpose:** Visually indicate the real-time status of an order or delivery.
* **Used in:** All Apps
* **Required Slots:** Only label text.
* **Allowed Variants (STRICT):** `pending`, `preparing`, `ready`, `delivered`, `failed`, `reconnecting`, `offline`
* **Allowed States:** `default`
* **Token Bindings:** Mapped directly to `status.[variant]`

### PrimaryButton
* **Purpose:** The main call to action on any screen.
* **Used in:** All Apps
* **Required Slots:** Icon (optional), Label
* **Allowed States:** `default`, `disabled`, `loading`, `success`, `error`
* **Token Bindings:** Background: `component.button.primary.bg`, Hover: `component.button.primary.hover_bg`, Pressed: `component.button.primary.pressed_bg`, Radius: `component.button.primary.radius`

### PaymentBadge & FulfillmentBadge
* **Purpose:** Distinct operational tags distinguishing financial status vs order pipeline status.
* **Used in:** Admin Panel, Driver App (Fulfillment only)
* **Allowed Variants (STRICT):**
  * Payment: `paid`, `unpaid`, `refunded`, `pay_in_store` (maps to `commerce.payment`)
  * Fulfillment: `delivery`, `pickup` (maps to `commerce.fulfillment`)
* **Required Slots:** Label text
* **Token Bindings:** Background binds to `commerce.payment`/`commerce.fulfillment`; uses `radius.pill`.

### MapView
* **Purpose:** Renders interactive maps (Google Maps) for delivery tracking and driver navigation.
* **Used in:** Customer App (Tracking), Driver App (Active Delivery)
* **Allowed Variants:** `delivery_tracking` (read-only markers), `driver_navigation` (turn-by-turn routing).
* **Required Slots:** Controls (zoom), Markers (restaurant, customer, driver), Route Polyline.
* **Token Bindings:** Markers should map to semantic brand/operational colors. Border Radius: `radius.lg` if framed inside a card, otherwise full-bleed layout.

### DataTable
* **Purpose:** Dense display of historical data or configuration lists.
* **Used in:** Admin Panel
* **Required Slots:** Header Row, Body Rows, Pagination (if rows > 10).
* **Interaction Rules:** Sortable columns, row hover states (`state.hover_overlay`), mobile-responsive collapse.
* **Allowed States:** `loading` (skeleton rows), `empty`, `default`.
* **Token Bindings:** Border: `border.subtle`, Row Hover: `state.hover_overlay`.

### ChartPanel
* **Purpose:** Visual data representations (e.g. Revenue trend using Recharts).
* **Used in:** Admin Panel
* **Required Slots:** `SectionHeader` (Title/Legend), Chart SVG/Canvas Area.
* **Allowed States:** `loading`, `empty`, `default`.
* **Token Bindings:** Graph elements must use `brand.primary` or semantic success/error tokens.

### StatCard
* **Purpose:** Single metric overview dashboard widget.
* **Used in:** Admin Panel, Driver App (Earnings).
* **Required Slots:** Label (e.g., "Total Revenue"), Value, Delta/Trend (optional, e.g. "+5%").
* **Token Bindings:** Background: `surface.card`, Radius: `radius.lg`, Shadow: `shadow.card`.

---

## 3. Strict State Rules

For any major interactive component or data-fetching surface, the following states MUST be explicitly defined without hallucination:
* **Loading:** Use skeleton loaders instead of spinners for complex cards.
* **Empty:** Clear explanation and a call to action if applicable.
* **Error:** Semantic red borders/text, safe fallback action.
* **Disabled:** Must meet WCAG contrast for disabled states (`state.disabled_bg`, `state.disabled_text`).
* **Offline:** Must trigger `OfflineBanner` if network drops.
* **Success:** Green outline/iconography for completed transient actions.
* **Selected:** Visual overlay or primary border treatment.
* **Readonly:** Disabled visual state but without disabled semantics (focusable but not editable).
