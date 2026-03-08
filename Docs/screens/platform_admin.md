# Platform Super-Admin Screen Contract (V1)

This document defines the strict screen compositions for the Platform Operator control panel. Agents must abide by these rules, relying strictly on data-dense UI primitives from `component_architecture.md`.

---

## 1. Global Shell
All screens in the Platform Admin panel must wrap within the `AppShell`.
* **Allowed Components:** `Sidebar`, `TopNav` (Header), `Toast`, `OfflineBanner`, `ConfirmationModal`
* **Forbidden:** `BottomNav`, `MenuItemCard`, `OrderCard`, `DeliveryTaskCard`

---

## 2. Screen: Platform Dashboard / Revenue Analytics
* **Route:** `/platform/dashboard` or `/platform/analytics`
* **Auth Rule:** Required (`platform_admin` role only)
* **Goal:** High-level summary of GMV, order volume, and active tenants.
* **Layout Mode:** Full Page Grid
* **Required Sections (Order):**
  1. `PageHeader` (Platform Metrics)
  2. Grid of `StatCard` (Total Revenue, Active Restaurants)
  3. `DataTable` (Per-Restaurant summary ranking)

---

## 3. Screen: Restaurant List & Management
* **Route:** `/platform/restaurants`
* **Auth Rule:** Required (`platform_admin` role only)
* **Goal:** Overview of all tenants, drill down into status, suspension, & impersonation.
* **Layout Mode:** Full Page List
* **Primary Action:** `PrimaryButton` ("Onboard New Restaurant" -> Navigates to `/new`)
* **Required Sections (Order):**
  1. `PageHeader`
  2. Full-bleed `DataTable` (Restaurants, Status badges, Revenue, Actions)
* **States:**
  * **Empty:** `EmptyState` ("No restaurants boarded yet.")
  * **Loading:** Skeletons for table rows.

---

## 4. Screen: Restaurant Detail & Feature Flags
* **Routes:** `/platform/restaurants/:id`, `/platform/feature-flags`
* **Auth Rule:** Required (`platform_admin` role only)
* **Goal:** Deep dive on a single tenant, toggling modules on/off.
* **Layout Mode:** Full Page Detail
* **Primary Action:** `PrimaryButton` ("Impersonate Support Session")
* **Required Sections (Order):**
  1. `PageHeader` (Tenant Name, Return Link)
  2. Sub-metric Grid (`StatCard` for tenant specifics)
  3. Feature Toggles (`ToggleSwitch` list mapped strictly to backend JSONB structure)
  4. Danger Zone (`DestructiveButton` for suspensions opening a `ConfirmationModal`)

---

## 5. Screen: Impersonation Audit Banner (Cross-cutting)
* **Route:** (Injected onto Owner Portal when loaded in Audit Mode)
* **Rule:** If the platform admin attempts to use an impersonation token on the Owner Portal, a sticky, high-visibility `AppShell` header (Audit Banner) MUST be rendered overriding the normal `TopNav` background (e.g., using `brand.primary`). All forms and POST actions must be visually locked into `readonly` states.
