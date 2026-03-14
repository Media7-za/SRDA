import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.7"

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
    // Handle CORS
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
        const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';

        // We use service role to bypass RLS for the state machine logic, 
        // but we manually verify the driver's identity and role first.
        const serviceClient = createClient(supabaseUrl, supabaseServiceKey);

        // 1. Authorization Check
        const authHeader = req.headers.get('Authorization');
        if (!authHeader) {
            throw { code: 'UNAUTHORIZED', message: 'Missing authorization header', status: 401 };
        }

        const { data: { user }, error: authError } = await serviceClient.auth.getUser(authHeader.replace('Bearer ', ''));
        if (authError || !user) {
            throw { code: 'UNAUTHORIZED', message: 'Invalid or expired token', status: 401 };
        }

        // Extract metadata from JWT (PRD Driver §2)
        const role = user.app_metadata?.role;
        const driverId = user.app_metadata?.driver_id;
        const driverRestaurantId = user.app_metadata?.restaurant_id;

        if (role !== 'driver' || !driverId) {
            throw { code: 'FORBIDDEN', message: 'Only drivers can update delivery status', status: 403 };
        }

        // 2. Parse Request & Input Validation
        const { status: newStatus } = await req.json();
        const url = new URL(req.url);
        const deliveryId = url.pathname.split('/').pop();

        // UUID Validation (P2)
        const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
        if (!deliveryId || !uuidRegex.test(deliveryId)) {
            throw { code: 'INVALID_INPUT', message: 'Invalid delivery ID format', status: 400 };
        }

        if (!['picked_up', 'on_the_way', 'delivered'].includes(newStatus)) {
            throw { code: 'INVALID_TRANSITION', message: 'Invalid delivery status provided', status: 400 };
        }

        // 3. Fetch current state and verify ownership + scope
        const { data: delivery, error: fetchError } = await serviceClient
            .from('deliveries')
            .select('*, order:orders(*)')
            .eq('id', deliveryId)
            .single();

        if (fetchError || !delivery) {
            throw { code: 'NOT_FOUND', message: 'Delivery not found', status: 404 };
        }

        // Security Scoping Check (P1 / PRD Core §9)
        if (delivery.driver_id !== driverId) {
            throw { code: 'FORBIDDEN', message: 'You are not assigned to this delivery', status: 403 };
        }

        if (delivery.restaurant_id !== driverRestaurantId) {
            throw { code: 'FORBIDDEN', message: 'Cross-restaurant access prohibited', status: 403 };
        }

        // 4. Conflict Detection (PRD Driver §14)
        if (delivery.order.status === 'cancelled') {
            throw { code: 'STATE_CONFLICT', message: 'Order has been cancelled by the restaurant', status: 409 };
        }

        // 5. State Machine Validation (PRD Driver §14)
        const currentStatus = delivery.status;
        const allowedTransitions: Record<string, string[]> = {
            'assigned': ['picked_up'],
            'picked_up': ['on_the_way'],
            'on_the_way': ['delivered'],
        };

        if (!allowedTransitions[currentStatus]?.includes(newStatus)) {
            throw {
                code: 'INVALID_TRANSITION',
                message: `Cannot transition from '${currentStatus}' to '${newStatus}'`,
                status: 400
            };
        }

        // 6. Execute Updates (Sequential - Atomicity Gap acknowledged)
        // NOTE: For Phase 2, these operations should be moved to a single Postgres RPC function 
        // to ensure transaction atomicity. In this MVP, we use structured try-catch to log partial failures.
        try {
            // A. Update Delivery Status
            const deliveryUpdate: any = { status: newStatus, updated_at: new Date().toISOString() };
            if (newStatus === 'picked_up') deliveryUpdate.picked_up_at = new Date().toISOString();
            if (newStatus === 'delivered') deliveryUpdate.delivered_at = new Date().toISOString();

            const { error: dUpdateError } = await serviceClient
                .from('deliveries')
                .update(deliveryUpdate)
                .eq('id', deliveryId);

            if (dUpdateError) throw dUpdateError;

            // B. Coupled Order Update
            let newOrderStatus = delivery.order.status;
            if (newStatus === 'picked_up') newOrderStatus = 'out_for_delivery';
            if (newStatus === 'delivered') newOrderStatus = 'delivered';

            if (newOrderStatus !== delivery.order.status) {
                const { error: oUpdateError } = await serviceClient
                    .from('orders')
                    .update({ status: newOrderStatus, updated_at: new Date().toISOString() })
                    .eq('id', delivery.order_id);

                if (oUpdateError) throw oUpdateError;

                // C. Insert Order Status History
                const { error: historyError } = await serviceClient.from('order_status_history').insert({
                    order_id: delivery.order_id,
                    status: newOrderStatus,
                    changed_by: user.id,
                    note: `Status updated by driver via mobile app (${newStatus})`
                });
                if (historyError) console.error("History log failed (non-blocking):", historyError);

                // D. Emit Board Event for Realtime UI
                const { error: eventError } = await serviceClient.from('board_events').insert({
                    restaurant_id: delivery.restaurant_id,
                    entity: 'order',
                    event: 'order_updated',
                    order_id: delivery.order_id,
                    version_updated_at_iso: new Date().toISOString(),
                    payload: {
                        id: delivery.order_id,
                        status: newOrderStatus,
                        delivery_status: newStatus
                    }
                });
                if (eventError) console.error("Realtime event emission failed:", eventError);
            }
        } catch (dbErr) {
            console.error("Partial failure in state sequence. Manual reconciliation may be needed.", dbErr);
            throw { code: 'DB_UPDATE_ERROR', message: 'Failed to complete state transition update', status: 500 };
        }

        return new Response(
            JSON.stringify({ success: true, data: { status: newStatus } }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
        );

    } catch (err: any) {
        // 7. Enhanced Error Handling (P3)
        const status = err.status || (err.error?.status) || 500;
        const code = err.code || (err.error?.code) || 'INTERNAL_ERROR';
        const message = err.message || (err.error?.message) || 'An unexpected error occurred';

        console.error(`[Edge Function Error] ${code} (${status}): ${message}`);

        return new Response(
            JSON.stringify({
                success: false,
                data: null,
                error: { code, message }
            }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status }
        );
    }
})
