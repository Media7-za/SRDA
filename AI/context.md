# AI Context File

## Project: Restaurant Ordering & Delivery Platform

## 1. Project Overview

This project is a **food ordering and delivery platform** designed initially for a **single restaurant** but architected from the start to scale into a **multi-restaurant SaaS platform**.

The main objective is to allow restaurants to **avoid high commission fees charged by third-party delivery platforms** and own their customer relationships.

The system will provide:

• Online ordering
• Menu browsing
• Cart and checkout
• Payment processing
• Delivery tracking
• Customer accounts
• Restaurant admin tools

The architecture must support evolving from:

Single Restaurant App
→ Multi-Restaurant Marketplace
→ White-Label SaaS for restaurants.

---

# 2. Product Goals

Primary goals:

1. Allow customers to order food directly from a restaurant.
2. Enable restaurants to manage menus and orders.
3. Provide delivery tracking and driver management.
4. Eliminate marketplace commission fees.
5. Build a scalable system that can later host multiple restaurants.

---

# 3. Target Users

### Customers

People ordering food via web or mobile.

Capabilities:
• browse menu
• add items to cart
• checkout
• track order
• view order history

---

### Restaurant Staff

Restaurant employees managing orders.

Capabilities:
• manage menu
• view incoming orders
• update order status
• assign delivery

---

### Delivery Drivers

Capabilities:
• accept delivery jobs
• view pickup and delivery address
• update delivery status

---

### Admin / Owner

Capabilities:
• manage restaurant settings
• manage menu
• manage drivers
• view analytics and revenue

---

# 4. MVP Feature Set

The MVP should include the core ordering workflow.

## Phase 1 — Core Ordering

Customer features:

• user registration and login
• menu browsing
• item customization
• add to cart
• checkout
• order creation
• order tracking

Restaurant features:

• order dashboard
• order status updates
• menu management

---

## Phase 2 — Payments

• payment gateway integration
• order confirmation
• payment status handling

---

## Phase 3 — Delivery

• driver assignment
• delivery status updates
• driver location tracking

---

## Phase 4 — Growth

• promotions and discount codes
• ratings and reviews
• loyalty system

---

# 5. Core System Entities

The core data model includes the following entities.

users
restaurants
addresses
menu_categories
menu_items
orders
order_items
payments
drivers
deliveries
promotions
reviews

These entities form the foundation of the platform.

The system must be designed so that:

A restaurant can have many menu items.
A user can place many orders.
An order contains multiple order items.
A driver may handle multiple deliveries.

---

# 6. Key Business Logic

### Ordering Flow

Customer workflow:

Browse Menu
→ Add Items to Cart
→ Checkout
→ Payment
→ Order Created
→ Restaurant Prepares Order
→ Driver Picks Up
→ Delivery Completed

---

### Order Status Lifecycle

Order statuses must follow this lifecycle:

pending
confirmed
preparing
ready_for_pickup
out_for_delivery
delivered
cancelled

---

# 7. UI Screen List (MVP)

The MVP should include approximately 12 screens.

Customer screens:

Home
Menu
Item Detail
Cart
Checkout
Order Confirmation
Order Tracking
Order History
Profile

Restaurant screens:

Admin Dashboard
Order Management
Menu Management

Driver screens:

Driver Dashboard
Delivery Task Screen

---

# 8. System Architecture

The platform follows a **modular service architecture**.

Core modules:

Auth Service
Menu Service
Order Service
Payment Service
Delivery Service
Notification Service

Each module must be isolated and follow service-layer architecture.

Controllers should remain thin.

Business logic must live inside services.

---

# 9. Technology Direction

Expected modern stack:

Frontend Web
Next.js
React
Tailwind CSS

Mobile App
Flutter (optional for MVP)

Backend
Node.js
TypeScript
REST API

Database
PostgreSQL

Authentication
JWT

Password Security
bcrypt

---

# 10. Repository Structure

The repository should follow this structure.

apps/
web
mobile

backend/
api
services
repositories
models

database/
migrations
schema

docs/
PRD.md
architecture.md
ui_screens.md

ai/
context.md
agent_rules.md
agents/

---

# 11. AI Agent Development Workflow

The system is developed using **four specialized AI agents**.

Architect Agent
Backend Engineer Agent
Frontend Engineer Agent
QA Engineer Agent

---

## Architect Agent Responsibilities

• define system architecture
• design database schema
• define API specification
• define folder structure

The architect must not generate application code.

---

## Backend Engineer Agent Responsibilities

• implement database models
• implement services
• implement repositories
• build REST APIs
• integrate payment gateways

---

## Frontend Engineer Agent Responsibilities

• build UI screens
• implement reusable components
• integrate with backend APIs
• implement mobile-first design

---

## QA Agent Responsibilities

• write unit tests
• write API tests
• verify edge cases
• verify payment flows
• validate order lifecycle

---

# 12. Engineering Rules

All AI agents must follow these rules:

1. Database-first development
2. Modular architecture
3. Service layer pattern
4. Strict typing
5. Clean folder structure
6. Production-ready code only

Controllers must never contain business logic.

Database access must occur via repositories.

---

# 13. Future Scalability

Although the MVP supports one restaurant, the architecture must allow:

Multiple restaurants
Multiple locations
Restaurant onboarding
Marketplace ordering

Future features:

• multi-restaurant search
• restaurant discovery
• delivery zones
• SaaS subscription for restaurants

---

# 14. Regional Considerations

The system must support payment providers commonly used in South Africa.

Potential integrations:

Paystack
Ozow
Stripe

Currency support:

South African Rand (ZAR)

---

# 15. AI Instruction

Before generating code, AI agents must always read:

/ai/context.md
/docs/PRD.md
/ai/agent_rules.md

These documents define the system architecture and development protocols.

AI agents must not invent architecture or database schema outside these documents.

All code must align with this context.

---

# End of Context
