-- CreateEnum
CREATE TYPE "FulfillmentType" AS ENUM ('delivery', 'pickup');

-- AlterEnum
BEGIN;
CREATE TYPE "UserRole_new" AS ENUM ('platform_admin', 'restaurant_owner', 'restaurant_staff', 'driver', 'customer');
ALTER TABLE "public"."users" ALTER COLUMN "role" DROP DEFAULT;
ALTER TABLE "users" ALTER COLUMN "role" TYPE "UserRole_new" USING ("role"::text::"UserRole_new");
ALTER TYPE "UserRole" RENAME TO "UserRole_old";
ALTER TYPE "UserRole_new" RENAME TO "UserRole";
DROP TYPE "public"."UserRole_old";
ALTER TABLE "users" ALTER COLUMN "role" SET DEFAULT 'customer';
COMMIT;

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

-- CreateIndex
CREATE INDEX "menu_modifier_groups_menu_item_id_idx" ON "menu_modifier_groups"("menu_item_id");

-- CreateIndex
CREATE INDEX "menu_modifier_options_group_id_idx" ON "menu_modifier_options"("group_id");

-- CreateIndex
CREATE INDEX "driver_devices_driver_id_idx" ON "driver_devices"("driver_id");

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

