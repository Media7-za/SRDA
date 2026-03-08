# UI Conformance Testing Rules

This document defines the strict, automated QA rules that guarantee AI-generated UI adheres to the Platform design architecture. The **QA Agent** must execute these conformance checks against all frontend components and screens before they are considered "done."

Failure to pass any of these checks constitutes a bug, and the Frontend Agent must rewrite the code.

---

## 1. Token Usage Conformance

**Rule:** Every color, dimension, and typography class MUST map back to a defined design token.
* **Pass:** `<button className="bg-brand-primary text-text-inverse rounded-pill h-button-primary">`
* **Fail:** `<button className="bg-[#D4A017] text-white rounded-full h-12">`
* **Check:** Scan the code for raw hex codes, arbitrary `px` values for paddings/margins, and raw `rounded-*` (e.g. `rounded-[20px]`) that circumvent the Tailwind token mapping.
* **Exceptions:** 1px borders or inline layout coordinates (e.g., `translate-x-1`) where tokens are strictly unnecessary. These exceptions must be **minimal and non-semantic**; do not stretch this allowance into ad hoc layout styling.

## 2. Canonical Component Usage Conformance

**Rule:** Screens MUST be composed exclusively of canonical components defined in `/docs/component_architecture.md`.
* **Pass:** `<OrderCard order={order} />`
* **Fail:** `<div className="order-summary-box shadow-md rounded-lg p-4">...</div>`
* **Check:** Ensure the Frontend Agent imported and used the canonical primitives. If a screen uses a raw `div` cluster to reinvent a `MenuItemCard`, reject the pull request / code block. Note: **Layout-only wrappers** (like grid containers or stack divs) are permitted, provided they do NOT recreate a domain component.
* **Slot Verification:** Ensure required slots (Header, Meta, Body, Footer) are present and correctly populated for components like `OrderCard` or `DeliveryTaskCard`.

## 3. Screen Contract Conformance

**Rule:** A screen must perfectly match the layout, authorized components, and required sections dictated by its contract in `/docs/screens/*.md`.
* **Check:** Verify the screen route matches the intended contract.
* **Check:** Identify forbidden components (e.g., a `MenuItemCard` surfacing improperly in the Admin Analytics screen).
* **Check:** Verify the flow and sequence of the "Required Sections" matches exactly (e.g., a Customer Home screen MUST render the `PageHeader` before the `RewardStatusCard`).

## 4. State Coverage Conformance

**Rule:** A component or route is incomplete if it does not handle all semantic states defined in its contract.
* **Check:** Does the page correctly mount an `OfflineBanner` if the network hook fails?
* **Check:** Are buttons capable of rendering `loading` and `disabled` states?
* **Check:** Does the screen include an `EmptyState` when the data payload returns `0` items?
* **Check:** Do forms map errors to `border.error` tokens and display semantic helper text?

## 5. Accessibility Conformance

**Rule:** The generated UI must pass foundational automated accessibility standards.
* **Check:** Are tap targets at minimum `44px` high (`tap_target_min`) on mobile surfaces?
* **Check:** Do interactive elements (buttons, inputs) possess the `focus-ring` utility bindings?
* **Check:** Are images covered by `alt` attributes?
* **Check:** Are reduced motion tokens utilized for complex entrance or exit animations?

---

## Workflow Enforcement
When the QA Agent audits frontend work, it will reply with a **Conformance Report**:
1. Token Pass/Fail
2. Component Usage Pass/Fail
3. Screen Contract Pass/Fail
4. State Pass/Fail
5. Accessibility Pass/Fail

If any category FAILS, the QA Agent MUST provide the exact file and line number violation, and instruct the Frontend Agent to correct it.
