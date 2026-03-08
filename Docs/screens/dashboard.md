# Restaurant Dashboard Screen Contract (V2)

This document defines the strict screen compositions for the Restaurant Dashboard. This is the operational tool used during live service (not the configuration portal). AI agents must abide by these rules. Use ONLY canonical components from `component_architecture.md`.

---

## 1. Global Shell
All screens in the Restaurant Dashboard must wrap within the `AppShell`.
* **Allowed Components:** `TopNav` (Header), `Toast`, `OfflineBanner`, `Sidebar` (if configured for live apps navigation)
* **Forbidden:** `BottomNav`

---

## 2. Screen: Live Operations & Order Feed
* **Route:** `/dashboard` or `/`
* **Auth Rule:** Required (`restaurant_owner` or `restaurant_staff` role)
* **Goal:** Command center for active kitchen operations and immediate order fulfillment.
* **Layout Mode:** Full Page (Kanban, Grid, or Split View)
* **Primary Action:** `PrimaryButton` (e.g., "Mark Ready", "Confirm Order")
* **Required Sections (Order):**
  1. `PageHeader`
  2. Active Orders Board (Columns / Grid of `OrderCard`)
* **Forbidden Components:**
  * `MenuItemCard`
  * `CheckoutAddressForm`
  * `RewardStatusCard`
  * `DataTable` (Live operations rely on cards, not dense tables)
* **States:**
  * **Loading:** Skeleton grid for `OrderCard`.
  * **Empty:** `EmptyState` ("No active orders right now.")
  * **Offline:** Critical: `OfflineBanner` must explicitly lock actions if WebSocket drops.

---

*(Note: Configuration features like Menu Management, Staff Accounts, and Analytics have been moved to the Owner Portal. They must not be implemented here.)*
