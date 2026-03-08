# Food Delivery App — UX Design & User Flow Super Blueprint

**Tenant:** Phuket Thai
**Project:** Food Delivery App Mobile Ordering App
**Platforms:** Next.js (Web PWA) + Flutter (Mobile)
**Purpose:**

This document defines the **complete UX architecture, navigation logic, UI states, component hierarchy, and frontend invariants** for the Phuket Thai application.

It acts as the **single source of truth** for:

* Product Design
* Frontend Engineering
* Backend Integration
* QA Testing
* Future AI-assisted development

The system prioritizes:

* **Frictionless food ordering**
* **Fast perceived performance**
* **Resilient offline-friendly UX**
* **Minimal taps to checkout**

---

# 1. Core UX Principles (2026 Standard)

### Frictionless Commerce

The path from **"Hungry" → "Order Placed"** must require the **fewest possible interactions**.

Users must be able to:

1. Open the app
2. Browse the menu immediately
3. Add food to cart
4. Checkout

Account creation **must never block menu browsing**.

---

### Optimistic UI

The application assumes success.

Example behavior:

User taps **Add to Cart**

UI response immediately:

* Cart icon increments
* Floating cart bar appears
* Toast confirmation appears

The network request executes **silently in the background**.

If failure occurs, rollback the UI state with a clear message.

---

### Idempotent Actions

High-intent buttons must disable instantly after being tapped.

Examples:

* Add to Cart
* Place Order
* Schedule Order
* Apply Reward

Implementation rule:

```text
Button tap → disable → show loading state → resolve → re-enable
```

Prevent duplicate requests and double charging.

---

### State Transparency

Users must always understand system state.

Every API interaction must visually represent:

* Loading
* Success
* Error

Never display blank screens or infinite spinners.

Use:

* Skeleton loaders
* Inline status messages
* Retry buttons

---

# 2. Global UI States & Persistence

### Local-First Architecture

Critical user state must persist locally.

Persist using:

* IndexedDB (Web)
* Local Storage
* Device storage (Flutter)

Persisted states include:

* Cart contents
* Pickup vs Delivery mode
* Selected location
* Selected store
* Last viewed category

If the app crashes or reloads, the user must return to the **exact same cart state**.

---

### Skeleton / Shimmer Loading

During initial data fetches display:

* Skeleton menu items
* Shimmer category headers
* Placeholder item cards

Full-screen loading spinners are prohibited.

---

### Empty States

All empty collections must display:

* Illustration
* Friendly explanation
* Action button

Examples:

Cart Empty:

```
Your cart is empty.
Let's find something delicious.
[ Browse Menu ]
```

Orders Empty:

```
No orders yet.
Your next meal is waiting.
```

---

### Error Boundaries

If a component crashes:

* Replace only that component with fallback UI
* Prevent the entire screen from white-screening

Example fallback:

```
Something went wrong.
[ Retry ]
```

---

# 3. Navigation Architecture

### Bottom Navigation Bar

Persistent across main screens.

Tabs:

* Home
* Menu
* Rewards
* Search

Active tab highlighted using **brand gold color**.

Cart is **not a tab**.

Cart access methods:

* Header cart icon
* Floating cart bar

---

### Floating Cart Bar

Appears when cart contains items.

Example:

```
View Cart • 3 items • $24.50
```

Position:

* Fixed above bottom navigation
* Full width
* Tap opens Cart Review

Purpose:

* Encourage checkout
* Reduce friction
* Maintain cart awareness

---

# 4. Customer Navigation Flow

---

# Flow A — First-Time Launch

### Screen: Splash

Purpose:

* Initialize app
* Validate session token
* Load persisted state

If JWT exists → restore session.

---

### Screen: Onboarding Carousel

Three slides:

1. Welcome to Phuket Thai
2. Earn rewards on every order
3. Easy reordering

Primary action:

```
Next
```

Final slide button:

```
Get Started
```

---

### Screen: Location Gate

Prompt user to set order context.

Primary action:

```
Continue
```

Triggers native location permission.

Secondary option:

```
Enter delivery address
```

---

# Flow B — Home Dashboard

The Home screen acts as the **discovery and quick-order hub**.

Sections:

### Header

Contains:

* profile icon
* location pin
* store address
* open/closed indicator

---

### Order Mode Toggle

Segmented control:

```
Pickup | Delivery
```

Includes action:

```
Schedule Order
```

---

### Rewards Snapshot

Displays:

* reward points
* progress to next reward

Example:

```
120 points • 30 away from free spring rolls
```

---

### Reorder Section

High-conversion feature.

Displays previous purchases:

```
Order Again
Pad Thai
Green Curry
Thai Fried Rice
```

One-tap reorder supported.

---

### Featured Items

Horizontal scroll cards.

Each card contains:

* dish image
* price
* quick-add button

---

# First-Time User Experience (Empty State Home)

When a user has no previous orders, the Home screen must display a discovery-focused layout instead of the "Order Again" module.

This layout is designed to optimize the first conversion and reduce choice paralysis.

Modules displayed:

1. Welcome Hero Card
   - Shows "Start Your Thai Journey"
   - Offers 100 bonus loyalty points
   - CTA: "Claim Your 100 Points"

2. First Reward Progress
   - Displays progress toward first reward
   - Example: 0 / 150 points
   - Message: "Get 150 points for free Spring Rolls"

3. Most Loved Section
   - Grid layout (2 columns)
   - Displays popular dishes
   - Items include "🔥 Popular" badge

4. Quick Add Interaction
   - Each item card includes a + button
   - Adds item directly to cart

5. Explore Full Menu CTA
   - Prominent bottom CTA
   - Navigates to full menu screen

State Logic:

If user.order_count == 0
→ Render First-Time Home Layout

Else
→ Render Returning User Layout (includes "Order Again")

---

# Flow C — Menu Browsing

### Category Navigation (Scrollspy)

Sticky horizontal tabs.

Example categories:

```
Soup
Salads
Entrees
Curries
Noodles
Drinks
Desserts
```

Behavior:

Vertical scrolling updates active tab automatically.

Tapping tab scrolls to that category.

---

### Menu Item Cards

Layout:

Left side:

* Title
* Price
* Description

Right side:

* Thumbnail image
* Floating "+" button

---

### Quick Add Logic

When tapping "+":

If item has **no modifiers**:

→ Add directly to cart

If item **has modifiers**:

→ Open Item Customization modal.

---

### Menu Loading Strategy

To prevent heavy loads:

Initial fetch:

* categories
* first 10 items per category

Remaining items:

Lazy load when section scrolls into view.

---

# Flow D — Item Customization (PDP)

Item customization uses a **high-coverage bottom sheet modal**.

Triggered when:

* item tapped
* modifiers required

---

### Customization Controls

Radio Buttons

Used for required choices:

* size
* spice level
* protein selection

---

Checkboxes

Used for optional modifiers:

* remove ingredients
* add extras

---

### Special Requests

Hidden behind toggle:

```
Add Special Instructions
```

Expands to text field.

Placeholder text:

```
No price altering requests.
```

---

### Sticky Action Bar

Always visible.

Example:

```
Add to Cart — $14.50
```

Price updates dynamically.

---

# Flow E — Cart Interaction

### Optimistic Add

When user taps Add to Cart:

Immediate UI changes:

* modal closes
* cart icon updates
* floating cart appears
* toast notification appears

Example toast:

```
Pad Thai added • +10 reward points
```

---

### Cart Review Bottom Sheet

Displays:

* order items
* modifiers
* subtotal
* tax
* delivery fee
* total

---

### Item Editing

Tapping item reopens PDP modal.

Pre-populated with prior selections.

Updates sent via PUT request.

---

### Destructive Actions

Example:

Empty Cart

Must require confirmation dialog.

---

# Flow F — Checkout

Checkout contains:

* delivery / pickup toggle
* address selection (localized for SA)
* order summary
* payment method selection
* place order button

**Payment Methods (ZA Localization):**

1. **SnapScan**
   - Interactive selection card with logo.
   - Action: Opens QR Overlay on "Place Order".
2. **Ozow (Instant EFT)**
   - Interactive selection card with logo.
   - Action: Redirects to bank selection flow.
3. **Credit/Debit Card**
   - Standard card entry/stored card selection.
4. **Pay In-Store** (Pickup only)

**Button State Logic:**

```text
disabled until address + payment method selected
```

---

# Flow J — Payment Modals (SnapScan Overlay)

Targeted specifically for the South African mobile context.

### Screen: SnapScan QR Overlay

Appears when SnapScan is selected and user taps "Place Order".

**Visual Elements:**

*   **Header:** "Pay with SnapScan" + Close (X) button.
*   **QR Code:** Large, high-contrast dynamic QR.
*   **Amount:** Boldly displayed (e.g., R 480.00).
*   **Instruction:** "Scan to pay or tap to open SnapScan app".
*   **Deep Link:** On mobile, tapping the QR code (or a "Open App" button) triggers the `snapscan://` deep link.

**State Logic:**

*   **Polling:** Frontend polls `/api/orders/{id}/payment-status` every 3 seconds.
*   **Success:** Automatically closes modal and redirects to Flow H (Order Tracking) upon confirmation.

---

# Flow K — Store Information Page

Targeted for branch-specific discovery and logistical clarity.

### Screen: Store Info

Triggered by tapping the Store Header on the Home Dashboard.

**Visual Sections:**

1.  **Hero Image:** High-quality photo of the Kloof branch interior/exterior.
2.  **Status Badge:** Dynamic "Open Now" (Green) or "Closed" (Red) badge with closing/opening time.
3.  **Action Grid:**
    *   **Call:** One-tap native dialer.
    *   **Directions:** Opens Google Maps/Apple Maps.
    *   **Share:** Native share sheet for the store link.
    *   **Favorite:** Toggle for quick access.
4.  **Operational Details:**
    *   **Address:** Kloof Village Mall, 13 Village Road, Kloof, 3610 (Expandable text with map preview).
    *   **Phone:** 031 764 0882
    *   **WhatsApp:** 071 204 1828
    *   **Opening Hours:**
        *   Mon - Thu: 11:00 AM – 8:00 PM
        *   Fri - Sat: 11:00 AM – 8:30 PM
        *   Sun: 11:00 AM – 8:00 PM
    *   *Note:* The Kloof branch will be closed for maintenance on Monday, 9 March and Tuesday, 10 March 2026.
5.  **Amenities / Highlights:**
    *   Icons for: Outdoor Seating, Halal Friendly, WiFi, Direct Pickup, Secure Parking.
6.  **About:** Short brand story for Phuket Thai Kloof.

**State Logic:**

*   **Real-time sync:** Hours and Open/Closed status are derived from the `restaurants` database table.
*   **Deep linking:** Directions button uses `geo:lat,lng` or Maps URL.

---

# Flow G — Authentication

Authentication uses **progressive profiling**.

Users may browse and add items before signing in.

---

### Phone Entry Screen

User inputs phone number.

Native numeric keyboard triggered.

---

### OTP Verification

6 digit OTP input.

Features:

* auto focus
* resend code link
* resend cooldown timer

Loading state displayed when verifying.

---

# Flow H — Order Tracking

After checkout users see progress states.

Order stages:

```
Order Received
Preparing
Ready for Pickup
Completed
```

Visual representation:

* progress tracker
* time estimate
* animated state updates

---

# Flow I — Edge Cases

### Store Closed

Bottom sheet appears:

```
Store is currently closed
```

Options:

```
Schedule Order
Browse Menu
```

---

### Inventory Reconciliation

If item becomes unavailable:

Cart screen highlights item.

Example:

```
Pad Thai unavailable
[ Remove Item ]
```

Checkout must not break.

---

# 5. UI Component Architecture

Frontend must follow strict hierarchy.

### Atoms

* Button
* InputField
* Badge
* Typography
* TabBarItem
* Icon

---

### Molecules

* MenuItemRow
* SegmentedControl
* RewardsProgressBar
* OTPInputRow

---

### Organisms

* OnboardingCarousel
* CheckoutForm
* MenuSection
* CartSummary
* PDPModal

---

### Templates

Reusable page layouts.

Examples:

* MenuLayout
* CheckoutLayout
* OrderTrackingLayout

---

### Pages

Final assembled screens.

Examples:

* HomePage
* MenuPage
* CheckoutPage

---

# 6. Interaction Invariants

### Tap Targets

Minimum size:

```
44x44 px
```

---

### Modal Close

All modals must include:

```
X Close Button
```

Top corner.

---

### Button Feedback

Buttons must display:

* pressed state
* loading state
* success state

---

# 7. State Management & API Contract

### Payload Security

Frontend sends only:

* menuItemId
* modifierIds
* quantities

Backend calculates:

* pricing
* taxes
* totals

---

### Temporary IDs

For optimistic UI:

Frontend generates:

```
tempId (UUID)
```

Sent as:

```
X-Idempotency-Key
```

Server returns:

```
cartItemId
```

Frontend replaces tempId silently.

---

# 8. Performance Rules

Target performance:

```
Menu first render < 1.5s
Cart interactions < 200ms
Checkout request < 2s
```

Strategies:

* lazy loading
* image optimization
* caching
* CDN usage

---

# 9. Conversion Optimizations

Include UX patterns proven to increase orders.

### Floating Cart Bar

Encourages checkout visibility.

---

### One-Tap Reorder

Major revenue driver for repeat customers.

---

### Rewards Visibility

Display reward progress prominently.

Encourages order completion.

---

# Final Goal

The Phuket Thai app must feel:

* fast
* intuitive
* premium
* effortless

A user should be able to:

```
Open app
Browse menu
Customize dish
Add to cart
Checkout
```

In under **30 seconds**.
