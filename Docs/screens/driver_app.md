# Driver App Screen Contract (V2)

This document defines the strict screen compositions for the Driver App (built in Flutter/Mobile context). AI agents must abide by these rules. Use ONLY canonical components from `component_architecture.md`.

---

## 1. Global Shell
All screens in the Driver App must wrap within the `AppShell` or native equivalent wrapper.
* **Allowed Components:** `TopNav`, `BottomNav` (if used for primary switching), `Toast`, `OfflineBanner`
* **Forbidden:** `Sidebar`, `OrderCard` (Use `DeliveryTaskCard` exclusively)

---

## 2. Screen: Available Deliveries (The Pool)
* **Route:** `/driver/available`
* **Auth Rule:** Required (`driver` role)
* **Goal:** View and claim orders that are ready for delivery.
* **Layout Mode:** Full Page
* **Primary Action:** `PrimaryButton` ("Accept Delivery")
* **Required Sections (Order):**
  1. `PageHeader` ("Available Tasks")
  2. List of `DeliveryTaskCard`
* **Forbidden Components:** `MenuItemCard`, `QuantityStepper`
* **States:**
  * **Loading:** Skeletons for `DeliveryTaskCard`.
  * **Empty:** `EmptyState` ("No pending deliveries.")
  * **Offline:** Must block acceptance of new tasks.

---

## 3. Screen: Active Delivery (Navigation & Task)
* **Route:** `/driver/active/[id]`
* **Auth Rule:** Required (`driver` role)
* **Goal:** Route to customer and mark order as delivered.
* **Layout Mode:** Full Page with Fixed Bottom Panel
* **Primary Action:** `PrimaryButton` ("Mark as Delivered", "Arrived")
* **Required Sections (Order):**
  1. `MapView` (Full bleed)
  2. `BottomSheet` containing `DeliveryTaskCard` (Pinned details), `SecondaryButton` ("Call Customer"), and `PrimaryButton`.
* **States:**
  * **Error:** E.g., GPS permission denied fallback.

---

## 4. Screen: Delivery History & Earnings
* **Route:** `/driver/history`
* **Auth Rule:** Required (`driver` role)
* **Goal:** Review past trips and daily earnings totals.
* **Layout Mode:** Full Page
* **Primary Action:** None
* **Required Sections (Order):**
  1. `PageHeader` ("Earnings History")
  2. `StatCard` (Daily total)
  3. List of `DeliveryTaskCard` (Read-only historical variant)
