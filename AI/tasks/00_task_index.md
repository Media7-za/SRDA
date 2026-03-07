# Project Task Index — Execution Roadmap
## Project: Restaurant Ordering & Delivery Platform

This file defines the **sequenced execution plan** for building the MVP. It is a stateful roadmap, not a brainstorming catalog. Agents must follow this sequence to ensure dependencies are met.

**Legend:**
- `✅` Complete
- `🔜` Next up
- `[ ]` Not started
- `📄` Task file exists
- `📝` Task file not yet created

---

## ✅ Completed

| # | Task | File | Status |
|---|------|------|--------|
| 00 | Project Scaffolding | `00_create_project_scaffold.md` 📄 | ✅ |
| — | System Architecture | `/ai/architecture.md` | ✅ locked |
| — | Implementation Decisions | `/ai/implementation_decisions.md` | ✅ locked |
| — | Agent System & Rules | `/ai/agent_rules.md` + `/ai/agents/*` | ✅ locked |
| — | Domain Invariants | `/ai/domain_invariants.md` | ✅ locked |
| — | Shared Types Package | `packages/types/src/index.ts` | ✅ |

---

## 🗄 Near-Term MVP Execution Sequence

### Phase A — Data Foundation
> Schema, migrations, and environment configuration. Nothing else can start until this is solid.

- [x] **01.** `01_finalize_database_schema.md` 📄 ✅ — Prisma schema + initial migration (all MVP tables, enums, indexes)
- [x] **02.** `02_setup_local_database.md` 📄 ✅ — Choose local Postgres strategy, configure `.env`, run first migration, verify DB connection
- [x] **03.** `03_setup_prisma_models_and_migrations.md` 📄 ✅ — Verify Prisma Client generation, create client singleton, wire up repository base

---

### Phase B — Authentication
> Users, roles, JWT, and middleware. Required before any protected API.

- [ ] **04.** `04_create_authentication_system.md` 📝 — Register, login, JWT issuance, bcrypt, role guard middleware

---

### Phase C — Restaurant & Menu APIs
> Core data APIs that the entire frontend depends on.

- [ ] **05.** `05_create_restaurant_api.md` 📝 — CRUD for restaurants (admin-only), opening hours
- [ ] **06.** `06_create_menu_api.md` 📝 — Categories, items, modifiers CRUD + public menu fetch endpoint

---

### Phase D — Cart, Checkout & Orders
> The critical commerce path: cart → validate → order → payment.

- [ ] **07.** `07_build_cart_state_and_persistence.md` 📝 — Cart model, guest cart, authenticated cart, guest-to-user merge rules
- [ ] **08.** `08_implement_checkout_validation.md` 📝 — Server-side price recalculation, availability check, snapshot creation, delivery serviceability
- [ ] **09.** `09_create_order_api.md` 📝 — Pending order creation, order snapshot model, order status state machine
- [ ] **10.** `10_create_stripe_payment_intent.md` 📝 — Stripe SDK setup, PaymentIntent creation, client secret return, idempotency keys
- [ ] **11.** `11_handle_payment_confirmation_and_webhook.md` 📝 — Stripe webhook handler (signature verification), in-store payment recording, order+payment state coupling

---

### Phase E — Restaurant Operations
> Operationally critical — the restaurant cannot function without this. Parallel with or immediately after Phase D.

- [ ] **12.** `12_build_restaurant_order_management_ui.md` 📝 — Live order feed, Accept/Prepare/Ready buttons, "Mark Paid & Complete" for collection orders
- [ ] **13.** `13_implement_restaurant_order_workflow.md` 📝 — Restaurant-side status transitions (confirmed → preparing → ready), notification to customer

---

### Phase F — Customer Frontend
> Customer-facing screens consuming the APIs built above.

- [ ] **14.** `14_build_customer_menu_and_cart_ui.md` 📝 — Menu browsing, item detail, modifier selection, cart screen, quantity editing
- [ ] **15.** `15_build_checkout_ui.md` 📝 — Address input, delivery/collection toggle, Stripe Elements, order submission
- [ ] **16.** `16_build_login_and_signup_screens.md` 📝 — Auth forms, JWT token storage, redirect after login during checkout

---

### Phase G — Delivery & Tracking
> Driver assignment, location updates, and realtime order tracking.

- [ ] **17.** `17_implement_delivery_and_driver_assignment.md` 📝 — Driver assignment, delivery serviceability check, delivery fee band calculation, one-active-delivery rule
- [ ] **18.** `18_implement_order_tracking_realtime.md` 📝 — WebSocket/SSE for live order status, driver location updates, polling fallback
- [ ] **19.** `19_build_order_tracking_screen.md` 📝 — Customer-facing live tracking screen

---

### Phase H — QA (Risk-Mapped)
> Tests mapped to actual MVP risk areas, not generic categories.

- [ ] **20.** `20_test_guest_checkout_flow.md` 📝 — Guest cart → login during checkout → cart merge → order placed
- [ ] **21.** `21_test_payment_and_order_state_integrity.md` 📝 — Payment failed but order not confirmed, webhook replay, in-store payment, idempotency
- [ ] **22.** `22_test_price_change_revalidation.md` 📝 — Price changed mid-cart, item unavailable at checkout, stale cart handling
- [ ] **23.** `23_test_delivery_and_tracking_flow.md` 📝 — Driver assignment, status transitions, realtime updates, over-distance rejection
- [ ] **24.** `24_test_restaurant_operations_flow.md` 📝 — Order accept → prepare → ready → complete cycle, concurrent order handling

---

### Phase I — Deployment
> Production hosting, secrets, and CI/CD.

- [ ] **25.** `25_setup_deployment_and_env_secrets.md` 📝 — Database hosting, backend + frontend deploy, env injection, CI/CD pipeline

---

## ⭐ Post-MVP Backlog

These are tracked but not part of the MVP execution sequence:

| Task | Category |
|------|----------|
| `add_multi_restaurant_support.md` | SaaS expansion |
| `add_restaurant_onboarding.md` | SaaS expansion |
| `add_restaurant_subscription_system.md` | SaaS billing |
| `add_restaurant_analytics.md` | SaaS dashboards |
| `implement_distance_band_pricing.md` | Delivery v2 |
| `build_admin_dashboard_overview.md` | Admin v2 (revenue, analytics) |
| `build_restaurant_settings_ui.md` | Admin v2 (hours, contact, config) |
| `build_menu_management_ui.md` | Admin v2 (CRUD interface) |
| `create_notification_system.md` | Notifications (email, push, SSE) |
| `create_password_reset_flow.md` | Auth v2 |
| `add_loyalty_system.md` | Growth |
| `add_promotions_engine.md` | Growth |

---

## 📊 Execution Summary

| Phase | Focus | Tasks | Status |
|-------|-------|-------|--------|
| ✅ | Completed foundations | 6 items | Done |
| A | Data Foundation | 3 | Done |
| B | Authentication | 1 | Next |
| C | Restaurant & Menu | 2 | Queued |
| D | Cart, Checkout & Orders | 5 | Queued |
| E | Restaurant Operations | 2 | Queued |
| F | Customer Frontend | 3 | Queued |
| G | Delivery & Tracking | 3 | Queued |
| H | QA (Risk-Mapped) | 5 | Queued |
| I | Deployment | 1 | Queued |
| — | Post-MVP Backlog | 12 | Deferred |
| | **MVP Total** | **25** | |

---

*Before starting any task, the assigned agent must read the task file, check dependencies in this index, and review: `/ai/context.md`, `/ai/architecture.md`, `/ai/agent_rules.md`, `/ai/implementation_decisions.md`.*
