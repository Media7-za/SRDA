/**
 * Shared TypeScript types for Restaurant Direct platform.
 *
 * This package is the single source of truth for types shared
 * between the frontend and backend. It follows the dependency rule:
 * apps & backend may import from here, but this package must not
 * import from apps or backend.
 */

// ── API Response Envelope ──────────────────────────────────────────

export interface ApiSuccessResponse<T> {
    success: true;
    data: T;
}

export interface ApiErrorResponse {
    success: false;
    data: null;
    error: {
        code: string;
        message: string;
    };
}

export type ApiResponse<T> = ApiSuccessResponse<T> | ApiErrorResponse;

// ── Order States ───────────────────────────────────────────────────

export const ORDER_STATES = [
    'pending',
    'confirmed',
    'preparing',
    'ready_for_pickup',
    'out_for_delivery',
    'delivered',
    'cancelled',
] as const;

export type OrderState = (typeof ORDER_STATES)[number];

// ── Payment States ─────────────────────────────────────────────────

export const PAYMENT_STATES = ['pending', 'processing', 'succeeded', 'failed', 'refunded'] as const;

export type PaymentState = (typeof PAYMENT_STATES)[number];

// ── Payment Status on Order ────────────────────────────────────────

export const PAYMENT_STATUSES = ['unpaid', 'paid'] as const;

export type PaymentStatus = (typeof PAYMENT_STATUSES)[number];

// ── Delivery States ────────────────────────────────────────────────

export const DELIVERY_STATES = [
    'unassigned',
    'assigned',
    'picked_up',
    'on_the_way',
    'delivered',
    'failed',
] as const;

export type DeliveryState = (typeof DELIVERY_STATES)[number];

// ── Fulfillment Modes ──────────────────────────────────────────────

export const FULFILLMENT_MODES = ['delivery', 'collection'] as const;

export type FulfillmentMode = (typeof FULFILLMENT_MODES)[number];

// ── Payment Providers ──────────────────────────────────────────────

export const PAYMENT_PROVIDERS = ['stripe', 'in_store'] as const;

export type PaymentProvider = (typeof PAYMENT_PROVIDERS)[number];

export const PAYMENT_METHODS = ['card_online', 'cash', 'card_in_store'] as const;

export type PaymentMethod = (typeof PAYMENT_METHODS)[number];

// ── Health Check ───────────────────────────────────────────────────

export interface HealthCheckResponse {
    status: 'ok';
    timestamp: string;
}
