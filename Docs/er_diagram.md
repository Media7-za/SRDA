# ER Diagram — Restaurant Direct MVP Schema

> **Generated:** 2026-03-06  
> **Source:** `database/prisma/schema.prisma`  
> **Tables:** 14 | **Enums:** 8

---

```mermaid
erDiagram
    %% ═══════════════════════════════════════
    %% AUTH MODULE
    %% ═══════════════════════════════════════

    users {
        uuid id PK
        string name
        string email UK
        string phone
        string password_hash
        UserRole role
        timestamp deleted_at
        timestamp created_at
        timestamp updated_at
    }

    addresses {
        uuid id PK
        uuid user_id FK
        string label
        string street
        string city
        string postal_code
        decimal latitude
        decimal longitude
        timestamp created_at
        timestamp updated_at
    }

    %% ═══════════════════════════════════════
    %% MENU MODULE
    %% ═══════════════════════════════════════

    restaurants {
        uuid id PK
        string name
        string description
        string phone
        string email
        string address
        string opening_hours
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }

    menu_categories {
        uuid id PK
        uuid restaurant_id FK
        string name
        int display_order
        timestamp created_at
        timestamp updated_at
    }

    menu_items {
        uuid id PK
        uuid restaurant_id FK
        uuid category_id FK
        string name
        string description
        decimal price
        string image_url
        boolean is_available
        timestamp created_at
        timestamp updated_at
    }

    menu_item_options {
        uuid id PK
        uuid menu_item_id FK
        uuid restaurant_id FK
        string name
        decimal price
        boolean is_available
        timestamp created_at
        timestamp updated_at
    }

    %% ═══════════════════════════════════════
    %% ORDER MODULE
    %% ═══════════════════════════════════════

    orders {
        uuid id PK
        uuid customer_id FK
        uuid restaurant_id FK
        uuid address_id FK
        OrderStatus status
        OrderType order_type
        OrderPaymentStatus payment_status
        decimal subtotal
        decimal delivery_fee
        decimal tax_amount
        decimal total_amount
        int delivery_distance_meters
        string delivery_fee_band
        string idempotency_key UK
        timestamp created_at
        timestamp updated_at
    }

    order_items {
        uuid id PK
        uuid order_id FK
        uuid menu_item_id FK
        string item_name "SNAPSHOT"
        decimal item_price "SNAPSHOT"
        int quantity
        decimal line_total "SNAPSHOT"
    }

    order_item_options {
        uuid id PK
        uuid order_item_id FK
        uuid source_menu_item_option_id FK "nullable analytics"
        string option_name "SNAPSHOT"
        decimal option_price "SNAPSHOT"
    }

    order_status_history {
        uuid id PK
        uuid order_id FK
        OrderStatus status
        string changed_by "nullable"
        string note
        timestamp created_at
    }

    %% ═══════════════════════════════════════
    %% PAYMENT MODULE
    %% ═══════════════════════════════════════

    payments {
        uuid id PK
        uuid order_id FK
        PaymentProvider provider
        PaymentMethod method
        string provider_payment_id "nullable"
        decimal amount
        string currency
        PaymentStatus status
        uuid collected_by_user_id FK "nullable"
        timestamp collected_at "nullable"
        timestamp created_at
        timestamp updated_at
    }

    %% ═══════════════════════════════════════
    %% DELIVERY MODULE
    %% ═══════════════════════════════════════

    drivers {
        uuid id PK
        uuid user_id FK UK "1:1 with users"
        string vehicle_type
        boolean is_available
        decimal current_latitude "nullable"
        decimal current_longitude "nullable"
        timestamp location_recorded_at "nullable"
        timestamp created_at
        timestamp updated_at
    }

    deliveries {
        uuid id PK
        uuid order_id FK UK "1:1 with orders"
        uuid driver_id FK "nullable"
        uuid restaurant_id FK
        DeliveryStatus status
        timestamp picked_up_at
        timestamp delivered_at
        timestamp created_at
        timestamp updated_at
    }

    driver_locations {
        uuid id PK
        uuid driver_id FK
        uuid delivery_id FK "nullable"
        decimal latitude
        decimal longitude
        timestamp recorded_at
    }

    %% ═══════════════════════════════════════
    %% RELATIONSHIPS
    %% ═══════════════════════════════════════

    users ||--o{ addresses : "has (CASCADE)"
    users ||--o{ orders : "places (RESTRICT)"
    users ||--o| drivers : "extends as (RESTRICT)"
    users ||--o{ payments : "collects (SET NULL)"

    restaurants ||--o{ menu_categories : "has (CASCADE)"
    restaurants ||--o{ menu_items : "has (CASCADE)"
    restaurants ||--o{ menu_item_options : "has (CASCADE)"
    restaurants ||--o{ orders : "receives (RESTRICT)"
    restaurants ||--o{ deliveries : "fulfills (RESTRICT)"

    menu_categories ||--o{ menu_items : "contains (SET NULL)"
    menu_items ||--o{ menu_item_options : "has (CASCADE)"
    menu_items ||--o{ order_items : "referenced by (RESTRICT)"

    orders ||--o{ order_items : "includes (CASCADE)"
    orders ||--o{ payments : "paid via (RESTRICT)"
    orders ||--o| deliveries : "delivered by (RESTRICT)"
    orders ||--o{ order_status_history : "tracked by (CASCADE)"

    order_items ||--o{ order_item_options : "has (CASCADE)"

    menu_item_options ||--o{ order_item_options : "source of (SET NULL)"

    drivers ||--o{ deliveries : "assigned to (RESTRICT)"
    drivers ||--o{ driver_locations : "tracked at (CASCADE)"

    addresses ||--o{ orders : "deliver to (SET NULL)"
```

---

## Deletion Policy Summary

| Entity | Strategy | Detail |
|--------|----------|--------|
| `users` | Soft delete | `deleted_at` timestamp |
| `menu_items` | Soft disable | `is_available` flag |
| `restaurants` | Soft disable | `is_active` flag |
| `orders` | **Never deleted** | — |
| `payments` | **Never deleted** | — |
| `addresses` | Hard delete via CASCADE from user | FK to orders SET NULL |
| `menu_categories` | Hard delete CASCADE from restaurant | FK to items SET NULL |

## Index Summary

| Index | Type | Purpose |
|-------|------|---------|
| `users.email` | UNIQUE | Login lookup |
| `drivers.user_id` | UNIQUE | 1:1 enforcement |
| `orders.idempotency_key` | UNIQUE | Duplicate prevention |
| `deliveries.order_id` | UNIQUE | 1:1 enforcement |
| `driver_locations(driver_id, recorded_at)` | COMPOSITE | Time-range queries |
| `order_status_history(order_id, created_at)` | COMPOSITE | Audit queries |
| `deliveries(driver_id) WHERE status IN (...)` | PARTIAL | Active delivery lookups |
| All FK columns | BTREE | Standard FK performance |
