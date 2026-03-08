# Restaurant Owner Portal Screen Contract (V1)

This document defines the strict screen compositions for the Restaurant Owner Portal. As an administrative configuration tool, this UI must prioritize clarity and dense data mapping over customer-facing "wow" mechanics. Use ONLY canonical components from `component_architecture.md`.

---

## 1. Global Shell
All screens in the Owner Portal must wrap within the `AppShell`.
* **Allowed Components:** `Sidebar`, `TopNav` (Header), `Toast`, `OfflineBanner`
* **Forbidden:** `BottomNav`

---

## 2. Screen: Menu Management
* **Route:** `/owner/menu`
* **Auth Rule:** Required (`restaurant_owner` role only)
* **Goal:** CRUD operations for categories, items, modifiers, and stock status.
* **Layout Mode:** Split View (Left: Categories, Right: Items)
* **Primary Action:** `PrimaryButton` ("Add New Item" / "Add Category")
* **Required Sections (Order):**
  1. `PageHeader` (with primary actions)
  2. Main layout grid (`DataTable` or custom split-view structure built carefully)
  3. `MenuItemCard` (used as edit previews)
  4. `Drawer` containing form components (`FormField`, `TextInput`, `SelectInput`, `ToggleSwitch`) for detailed edits.
* **States:**
  * **Empty:** `EmptyState` ("Your menu is empty.")

---

## 3. Screen: Staff / Driver Accounts
* **Routes:** `/owner/staff`, `/owner/drivers`
* **Auth Rule:** Required (`restaurant_owner` role only)
* **Goal:** List and manage users within the tenant.
* **Layout Mode:** Full Page
* **Primary Action:** `PrimaryButton` ("Add Staff" / "Add Driver")
* **Required Sections (Order):**
  1. `PageHeader` (with Primary Action)
  2. `DataTable` (Staff list with status badges and actions)
  3. `ConfirmationModal` (For deactivations)
* **Forbidden Components:** `OrderCard`, `DeliveryTaskCard`

---

## 4. Screen: Settings (General & Hours)
* **Routes:** `/owner/settings/profile`, `/owner/settings/hours`
* **Auth Rule:** Required (`restaurant_owner` role only)
* **Goal:** Form-heavy configuration of basic identity and opening times.
* **Layout Mode:** Centered Forms (or two-column config layouts)
* **Primary Action:** `PrimaryButton` ("Save Changes")
* **Required Sections (Order):**
  1. `PageHeader` (Restaurant status toggle included in Hours view)
  2. Stacked Form Elements (`TextInput`, `SelectInput`, `ToggleSwitch`, File uploads)
  3. `PrimaryButton`
* **States:**
  * **Error:** Form fields must bind `border.error` tokens and display semantic text if invalid.

---

## 5. Screen: Analytics (Phase 2)
* **Route:** `/owner/analytics`
* **Auth Rule:** Required (`restaurant_owner` role only)
* **Goal:** High-level dashboard of restaurant sales and performance.
* **Layout Mode:** Full Page Dashboard Grid
* **Primary Action:** (None - Data consumption only)
* **Required Sections (Order):**
  1. `PageHeader` (Date Filters via `SelectInput`)
  2. Grid of `StatCard` summary metrics
  3. `ChartPanel` components (Recharts lines/bars)
  4. `DataTable` (Top selling items)
* **Forbidden Components:** `OrderCard` (No live-ops mixing allowed in the portal)
