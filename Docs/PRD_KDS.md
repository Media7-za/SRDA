# PRD — Kitchen Display System (KDS)
**Platform:** Restaurant Direct  
**App:** KDS Module (Web-based)  
**Stage:** Evolutionary Prototype / MVP  
**Audience:** AI Coding Agents & Kitchen Staff

---

## 1. Purpose & Scope

The Kitchen Display System (KDS) is a specialized, high-visibility interface designed for kitchen staff to manage active food preparation. It replaces traditional paper "chits" with a real-time digital board optimized for speed, clarity, and touch interaction.

### In Scope (MVP)
- Real-time order injection via Supabase Realtime.
- Multi-column or grid layout for active orders.
- "Bumping" logic (advancing order status to `READY`).
- High-visibility timers tracking elapsed preparation time.
- Modification highlighting (e.g., "NO ONIONS" in red).

### Out of Scope (MVP)
- Split-station routing (e.g., separate Grill vs. Salad stations).
- Recipe display or inventory tracking.
- Printer integration (KDS is digital-first).

---

## 2. Order Lifecycle (Kitchen Perspective)

The KDS specifically manages the transition between **PREPARING** and **READY**.

| Action | Current Status | Resulting Status | UI Result |
|---|---|---|---|
| Auto-Inject | `CONFIRMED` | `PREPARING` | Order appears on KDS. |
| **BUMP** | `PREPARING` | `READY` | Order removed from KDS. |
| **UN-BUMP** | `READY` | `PREPARING` | Order restored to KDS (History view only). |

---

## 3. UI / UX Rules (The "Hotline" Standard)

Kitchen environments are harsh (heat, grease, speed). The UI must follow these strict ergonomics:

### 3.1 Visual Hierarchy
- **Typography**: Minimum 18px for item names; 24px+ for quantities.
- **Contrast**: Pure white text on deep charcoal (`#0a0a0a`) or black backgrounds.
- **Colors**:
  - `Orange`: Delivery orders.
  - `Blue`: Pickup/Collection orders.
  - `Red`: Urgent or Modified items.

### 3.2 Timers & Urgency
Every order card must display a "Minutes Elapsed" timer from the moment it hits `PREPARING`.
- **0–10 mins**: Standard (Neutral borders).
- **10–15 mins**: Warning (Yellow accents).
- **15+ mins**: **URGENT** (Red flashing borders or high-contrast red header).

### 3.3 Touch Targets
- Action buttons (BUMP) must be at least 80px in height.
- The entire bottom section of an order card should act as the bump trigger.

---

## 4. Realtime & State

### 4.1 Data Flow
1. **Subscription**: `orders:status=in.(confirmed,preparing)`
2. **Event**: `INSERT` or `UPDATE` triggers a re-fetch of the order details.
3. **Optimistic Bump**: When staff "Bumps" an order, it is hidden from the UI immediately while the API call `PATCH /api/orders/:id/status` with `status: 'ready'` happens in the background.

---

## 5. Hardware Profile

- **Device**: Desktop or Tablet (Landscape orientation preferred).
- **Input**: Touchscreen or "Bump Bar" (keyboard-mapped shortcuts).
- **Connectivity**: Constant Wi-Fi/Ethernet required for realtime sync.

---

## 6. API Interactions (KDS Specific)

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/orders/active` | Initial load of all `PREPARING` orders. |
| PATCH | `/api/orders/:id/status` | Advance status to `READY` or revert to `PREPARING`. |
