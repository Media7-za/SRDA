DROP TYPE IF EXISTS "FulfillmentType" CASCADE;
CREATE TYPE "FulfillmentType" AS ENUM ('delivery', 'pickup');

TRUNCATE TABLE "deliveries" CASCADE;
TRUNCATE TABLE "driver_locations" CASCADE;
TRUNCATE TABLE "drivers" CASCADE;
TRUNCATE TABLE "payments" CASCADE;
TRUNCATE TABLE "order_status_history" CASCADE;
TRUNCATE TABLE "order_item_options" CASCADE;
TRUNCATE TABLE "order_items" CASCADE;
TRUNCATE TABLE "orders" CASCADE;
TRUNCATE TABLE "users" CASCADE;
TRUNCATE TABLE "restaurants" CASCADE;

-- DropForeignKey
ALTER TABLE "menu_item_options" DROP CONSTRAINT "menu_item_options_menu_item_id_fkey";

-- DropForeignKey
ALTER TABLE "menu_item_options" DROP CONSTRAINT "menu_item_options_restaurant_id_fkey";

-- DropForeignKey
ALTER TABLE "order_item_options" DROP CONSTRAINT "order_item_options_source_menu_item_option_id_fkey";

-- DropIndex
DROP INDEX "driver_locations_driver_id_recorded_at_idx";

-- AlterTable
ALTER TABLE "deliveries" ADD COLUMN     "failure_reason" TEXT;

-- AlterTable
ALTER TABLE "driver_locations" DROP COLUMN "recorded_at",
ADD COLUMN     "accuracy" DOUBLE PRECISION,
ADD COLUMN     "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- AlterTable
ALTER TABLE "drivers" DROP COLUMN "current_latitude",
DROP COLUMN "current_longitude",
DROP COLUMN "location_recorded_at",
ADD COLUMN     "last_location_at" TIMESTAMP(3),
ADD COLUMN     "latitude" DECIMAL(10,7),
ADD COLUMN     "longitude" DECIMAL(10,7),
ADD COLUMN     "restaurant_id" TEXT NOT NULL;

-- AlterTable
ALTER TABLE "order_item_options" DROP COLUMN "source_menu_item_option_id",
ADD COLUMN     "source_modifier_option_id" TEXT;

-- AlterTable
ALTER TABLE "orders" DROP COLUMN "order_type",
ADD COLUMN     "cancellation_reason" TEXT,
ADD COLUMN     "cancelled_at" TIMESTAMP(3),
ADD COLUMN     "cancelled_by_user_id" TEXT,
ADD COLUMN     "fulfillment_type" "FulfillmentType" NOT NULL,
ADD COLUMN     "special_instructions" TEXT,
ADD COLUMN     "version" INTEGER NOT NULL DEFAULT 1;

-- AlterTable
ALTER TABLE "restaurants" ADD COLUMN     "default_ready_time_minutes" INTEGER NOT NULL DEFAULT 20,
ADD COLUMN     "features" JSONB,
ADD COLUMN     "logo_url" TEXT,
ADD COLUMN     "status" TEXT NOT NULL DEFAULT 'inactive',
ADD COLUMN     "suspended_at" TIMESTAMP(3),
ADD COLUMN     "suspended_by" TEXT,
ADD COLUMN     "suspension_reason" TEXT,
DROP COLUMN "opening_hours",
ADD COLUMN     "opening_hours" JSONB NOT NULL;

-- AlterTable
ALTER TABLE "users" ADD COLUMN     "is_active" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "manager_pin" TEXT,
ADD COLUMN     "must_reset_password" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "restaurant_id" TEXT;

-- DropTable
DROP TABLE "menu_item_options";

-- DropEnum
DROP TYPE "OrderType";

-- CreateTable
CREATE TABLE "menu_modifier_groups" (
    "id" TEXT NOT NULL,
    "menu_item_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "required" BOOLEAN NOT NULL DEFAULT false,
    "max_select" INTEGER,

    CONSTRAINT "menu_modifier_groups_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "menu_modifier_options" (
    "id" TEXT NOT NULL,
    "group_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "price_delta" INTEGER,

    CONSTRAINT "menu_modifier_options_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "driver_devices" (
    "id" TEXT NOT NULL,
    "driver_id" TEXT NOT NULL,
    "fcm_token" TEXT NOT NULL,
    "device_type" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "driver_devices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "driver_earnings_config" (
    "id" TEXT NOT NULL,
    "tenant_id" TEXT NOT NULL,
    "flat_fee_per_delivery" INTEGER NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'ZAR',
    "active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "driver_earnings_config_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "board_events" (
    "id" TEXT NOT NULL,
    "restaurant_id" TEXT NOT NULL,
    "entity" TEXT NOT NULL DEFAULT 'order',
    "event" TEXT NOT NULL,
    "order_id" TEXT NOT NULL,
    "occurred_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "version_updated_at_iso" TEXT NOT NULL,
    "payload" JSONB NOT NULL,

    CONSTRAINT "board_events_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "menu_modifier_groups_menu_item_id_idx" ON "menu_modifier_groups"("menu_item_id");

-- CreateIndex
CREATE INDEX "menu_modifier_options_group_id_idx" ON "menu_modifier_options"("group_id");

-- CreateIndex
CREATE INDEX "driver_devices_driver_id_idx" ON "driver_devices"("driver_id");

-- CreateIndex
CREATE INDEX "board_events_restaurant_id_occurred_at_idx" ON "board_events"("restaurant_id", "occurred_at");

-- CreateIndex
CREATE INDEX "driver_locations_driver_id_timestamp_idx" ON "driver_locations"("driver_id", "timestamp");

-- CreateIndex
CREATE INDEX "drivers_restaurant_id_is_available_idx" ON "drivers"("restaurant_id", "is_available");

-- CreateIndex
CREATE INDEX "orders_id_version_idx" ON "orders"("id", "version");

-- CreateIndex
CREATE INDEX "restaurants_status_idx" ON "restaurants"("status");

-- CreateIndex
CREATE INDEX "users_restaurant_id_role_idx" ON "users"("restaurant_id", "role");

-- AddForeignKey
ALTER TABLE "menu_modifier_groups" ADD CONSTRAINT "menu_modifier_groups_menu_item_id_fkey" FOREIGN KEY ("menu_item_id") REFERENCES "menu_items"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "menu_modifier_options" ADD CONSTRAINT "menu_modifier_options_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "menu_modifier_groups"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_item_options" ADD CONSTRAINT "order_item_options_source_modifier_option_id_fkey" FOREIGN KEY ("source_modifier_option_id") REFERENCES "menu_modifier_options"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "driver_devices" ADD CONSTRAINT "driver_devices_driver_id_fkey" FOREIGN KEY ("driver_id") REFERENCES "drivers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- Emit Function for Board Events
CREATE OR REPLACE FUNCTION emit_order_board_event()
RETURNS TRIGGER AS $$
DECLARE
    target_order_id TEXT;
    order_record RECORD;
    v_customer_name TEXT;
    v_driver_name TEXT;
    v_address_string TEXT;
    v_items JSONB;
    v_is_late BOOLEAN;
    v_payload JSONB;
BEGIN
    -- Determine target order ID based on table
    IF TG_TABLE_NAME = 'orders' THEN
        target_order_id := NEW.id;
    ELSIF TG_TABLE_NAME = 'deliveries' THEN
        target_order_id := NEW.order_id;
    END IF;

    -- Fetch the base order info
    SELECT * INTO order_record FROM orders WHERE id = target_order_id;
    IF NOT FOUND THEN
        RETURN NEW;
    END IF;

    -- Fetch Customer Name
    SELECT name INTO v_customer_name FROM users WHERE id = order_record.customer_id;

    -- Fetch Driver Name if delivery
    v_driver_name := NULL;
    SELECT u.name INTO v_driver_name
    FROM deliveries d
    JOIN drivers dr ON d.driver_id = dr.id
    JOIN users u ON dr.user_id = u.id
    WHERE d.order_id = target_order_id;

    -- Fetch Address
    v_address_string := NULL;
    IF order_record.address_id IS NOT NULL THEN
        SELECT street || ', ' || city INTO v_address_string FROM addresses WHERE id = order_record.address_id;
    END IF;

    -- Fetch Items
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', oi.id,
            'quantity', oi.quantity,
            'name', oi.item_name,
            'modifiers', COALESCE((
                SELECT jsonb_agg(oio.option_name)
                FROM order_item_options oio
                WHERE oio.order_item_id = oi.id
            ), '[]'::jsonb)
        )
    ) INTO v_items
    FROM (
        SELECT * FROM order_items 
        WHERE order_id = target_order_id 
        ORDER BY id ASC 
        LIMIT 3
    ) oi;

    IF v_items IS NULL THEN
        v_items := '[]'::jsonb;
    END IF;

    -- Calculate Late
    v_is_late := false;
    IF order_record.estimated_ready_at IS NOT NULL 
       AND order_record.status IN ('pending', 'confirmed', 'preparing') 
       AND order_record.estimated_ready_at < NOW() THEN
        v_is_late := true;
    END IF;

    -- Build Payload
    v_payload := jsonb_build_object(
        'id', order_record.id,
        'orderNumber', left(order_record.id::text, 8),
        'customerName', v_customer_name,
        'status', order_record.status,
        'fulfillmentType', order_record.fulfillment_type,
        'paymentState', CASE WHEN order_record.payment_status::text = 'paid' THEN 'paid' ELSE 'unpaid' END,
        'placedAtISO', to_char(order_record.created_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"'),
        'quotedReadyAtISO', CASE WHEN order_record.estimated_ready_at IS NOT NULL THEN to_char(order_record.estimated_ready_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"') ELSE NULL END,
        'totalAmount', order_record.total_amount,
        'currency', 'ZAR',
        'itemCount', order_record.item_count,
        'items', v_items,
        'customerNote', order_record.customer_note,
        'specialInstructions', order_record.special_instructions,
        'deliveryAddress', v_address_string,
        'assignedDriverName', v_driver_name,
        'isLate', v_is_late
    );

    -- Insert into outbox
    INSERT INTO board_events (
        id, restaurant_id, entity, event, order_id, occurred_at, version_updated_at_iso, payload
    ) VALUES (
        gen_random_uuid()::text,
        order_record.restaurant_id,
        'order',
        TG_OP,
        target_order_id,
        NOW(),
        to_char(order_record.updated_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"'),
        v_payload
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER emit_order_board_event_orders_trigger
AFTER INSERT OR UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION emit_order_board_event();

CREATE TRIGGER emit_order_board_event_deliveries_trigger
AFTER INSERT OR UPDATE ON deliveries
FOR EACH ROW
EXECUTE FUNCTION emit_order_board_event();
