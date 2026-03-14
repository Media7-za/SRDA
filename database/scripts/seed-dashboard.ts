import { PrismaClient, OrderStatus, FulfillmentType, OrderPaymentStatus, DeliveryStatus, PaymentProvider, PaymentMethod } from '@prisma/client';

const prisma = new PrismaClient();

// Deterministic mock IDs
const RESTAURANT_ID = 'mock_request_restaurant_id';
const DRIVER_IDS = ['driver_1', 'driver_2', 'driver_3'];
const CUSTOMER_IDS = ['customer_1', 'customer_2', 'customer_3', 'customer_4', 'customer_5'];
const MENU_ITEM_IDS = ['menu_1', 'menu_2', 'menu_3', 'menu_4', 'menu_5', 'menu_6', 'menu_7', 'menu_8'];

async function main() {
    console.log('🌱 Starting deterministic dashboard seed...');

    // 1. Clean existing mock data securely in reverse order of references
    await prisma.delivery.deleteMany({ where: { restaurantId: RESTAURANT_ID } });
    await prisma.payment.deleteMany({ where: { order: { restaurantId: RESTAURANT_ID } } });
    await prisma.orderStatusHistory.deleteMany({ where: { order: { restaurantId: RESTAURANT_ID } } });
    await prisma.orderItemOption.deleteMany({ where: { orderItem: { order: { restaurantId: RESTAURANT_ID } } } });
    await prisma.orderItem.deleteMany({ where: { order: { restaurantId: RESTAURANT_ID } } });
    await prisma.order.deleteMany({ where: { restaurantId: RESTAURANT_ID } });

    await prisma.menuModifierOption.deleteMany({ where: { group: { menuItem: { restaurantId: RESTAURANT_ID } } } });
    await prisma.menuModifierGroup.deleteMany({ where: { menuItem: { restaurantId: RESTAURANT_ID } } });
    await prisma.menuItem.deleteMany({ where: { restaurantId: RESTAURANT_ID } });
    await prisma.menuCategory.deleteMany({ where: { restaurantId: RESTAURANT_ID } });
    await prisma.restaurant.deleteMany({ where: { id: RESTAURANT_ID } });

    await prisma.driverLocation.deleteMany({ where: { driver: { userId: { in: DRIVER_IDS } } } });
    await prisma.driver.deleteMany({ where: { userId: { in: DRIVER_IDS } } });
    await prisma.user.deleteMany({ where: { id: { in: [...DRIVER_IDS, ...CUSTOMER_IDS] } } });

    // 2. Create Restaurant
    await prisma.restaurant.create({
        data: {
            id: RESTAURANT_ID,
            name: "The Rustic Burger",
            description: "Premium handcrafted burgers and sides.",
            openingHours: { "monday": "09:00-22:00" },
        }
    });

    // 3. Create Users (Customers)
    const customers = [];
    for (let i = 0; i < CUSTOMER_IDS.length; i++) {
        customers.push(await prisma.user.create({
            data: {
                id: CUSTOMER_IDS[i],
                name: `Customer ${i + 1}`,
                email: `customer${i + 1}@example.com`,
                passwordHash: 'hashed_pw', // Placeholder
                role: 'customer'
            }
        }));
    }

    // 4. Create Users (Drivers) & Driver profiles
    for (let i = 0; i < DRIVER_IDS.length; i++) {
        await prisma.user.create({
            data: {
                id: DRIVER_IDS[i],
                name: `Driver ${i + 1}`,
                email: `driver${i + 1}@example.com`,
                passwordHash: 'hashed_pw',
                role: 'driver',
                driver: {
                    create: {
                        id: `driver_profile_${i}`,
                        restaurantId: RESTAURANT_ID,
                        isAvailable: true,
                        vehicleType: i % 2 === 0 ? 'Bike' : 'Car'
                    }
                }
            }
        });
    }

    // 5. Create Menu Items
    const menuItemsData = [
        { id: MENU_ITEM_IDS[0], name: "Classic Cheeseburger", price: 85.00 },
        { id: MENU_ITEM_IDS[1], name: "Double Smash Burger", price: 120.00 },
        { id: MENU_ITEM_IDS[2], name: "Spicy Chicken Burger", price: 95.00 },
        { id: MENU_ITEM_IDS[3], name: "Vegan Burger", price: 110.00 },
        { id: MENU_ITEM_IDS[4], name: "Large Fries", price: 35.00 },
        { id: MENU_ITEM_IDS[5], name: "Sweet Potato Fries", price: 45.00 },
        { id: MENU_ITEM_IDS[6], name: "Onion Rings", price: 40.00 },
        { id: MENU_ITEM_IDS[7], name: "Vanilla Milkshake", price: 55.00 },
    ];

    for (const item of menuItemsData) {
        await prisma.menuItem.create({
            data: {
                id: item.id,
                restaurantId: RESTAURANT_ID,
                name: item.name,
                price: item.price,
                isAvailable: true
            }
        });
    }

    // Helper to generate deterministic dates
    const now = new Date();
    const minutesAgo = (mins: number) => new Date(now.getTime() - mins * 60000);

    // 6. Generate Orders based on requested mix
    // Mix: 6 pending, 7 preparing, 5 ready_for_pickup, 3 out_for_delivery, 6 completed/cancelled

    let orderCounter = 1;
    const createOrder = async ({
        status,
        fulfillmentType,
        minsAgo,
        isLate,
        driverId,
        itemCount,
        paymentStatus = OrderPaymentStatus.paid
    }: any) => {
        const id = `order_mock_${orderCounter++}`;
        const placedAt = minutesAgo(minsAgo);
        const estimatedReadyAt = minutesAgo(minsAgo - (isLate ? -10 : 20)); // If late, ready time was 10 mins ago

        const selectedItems = menuItemsData.slice(0, Math.min(itemCount, menuItemsData.length));
        const subtotal = selectedItems.reduce((acc, item) => acc + item.price, 0);
        const taxAmount = subtotal * 0.15;
        const totalAmount = subtotal + taxAmount;

        return prisma.order.create({
            data: {
                id,
                customerId: CUSTOMER_IDS[orderCounter % CUSTOMER_IDS.length],
                restaurantId: RESTAURANT_ID,
                status,
                fulfillmentType,
                paymentStatus,
                subtotal,
                taxAmount,
                totalAmount,
                createdAt: placedAt,
                updatedAt: placedAt, // Will optionally be updated below for completed
                estimatedReadyAt,
                itemCount: selectedItems.length,
                orderItems: {
                    create: selectedItems.map(item => ({
                        menuItemId: item.id,
                        itemName: item.name,
                        itemPrice: item.price,
                        quantity: 1,
                        lineTotal: item.price,
                        // Adding a deterministic modifier to every 2nd order to test flattening
                        ...(orderCounter % 2 === 0 ? {
                            options: {
                                create: [
                                    { optionName: "No Onions", optionPrice: 0 },
                                ]
                            }
                        } : {})
                    }))
                },
                ...(status === 'out_for_delivery' || status === 'delivered' || driverId ? {
                    delivery: {
                        create: {
                            restaurantId: RESTAURANT_ID,
                            status: status === 'delivered' ? DeliveryStatus.delivered : status === 'out_for_delivery' ? DeliveryStatus.on_the_way : DeliveryStatus.assigned,
                            driverId: `driver_profile_${DRIVER_IDS.indexOf(driverId || DRIVER_IDS[0])}`
                        }
                    }
                } : {})
            }
        });
    };

    // --- PENDING (6) ---
    for (let i = 0; i < 6; i++) {
        await createOrder({ status: OrderStatus.pending, fulfillmentType: i % 2 === 0 ? FulfillmentType.delivery : FulfillmentType.pickup, minsAgo: i * 2, itemCount: 2 });
    }

    // --- PREPARING (7) ---
    // Make one Late
    for (let i = 0; i < 7; i++) {
        await createOrder({ status: OrderStatus.preparing, fulfillmentType: FulfillmentType.delivery, minsAgo: 15 + i * 2, isLate: i === 0, itemCount: 3 });
    }

    // --- READY FOR PICKUP (5) ---
    // Mix delivery waiting for driver and pay-in-store pickup
    for (let i = 0; i < 5; i++) {
        await createOrder({
            status: OrderStatus.ready_for_pickup,
            fulfillmentType: i < 3 ? FulfillmentType.delivery : FulfillmentType.pickup,
            paymentStatus: i === 4 ? OrderPaymentStatus.unpaid : OrderPaymentStatus.paid,
            minsAgo: 30 + i * 2,
            itemCount: 4
        });
    }

    // --- OUT FOR DELIVERY (3) ---
    for (let i = 0; i < 3; i++) {
        await createOrder({
            status: OrderStatus.out_for_delivery,
            fulfillmentType: FulfillmentType.delivery,
            driverId: DRIVER_IDS[i % DRIVER_IDS.length],
            minsAgo: 45 + i * 2,
            itemCount: 2
        });
    }

    // --- COMPLETED / CANCELLED (6 in last 2 hours) ---
    // Large order with many items (will be truncated to Top 3 in UI)
    await createOrder({ status: OrderStatus.delivered, fulfillmentType: FulfillmentType.delivery, minsAgo: 60, itemCount: 8, driverId: DRIVER_IDS[0] });
    await createOrder({ status: OrderStatus.delivered, fulfillmentType: FulfillmentType.pickup, minsAgo: 65, itemCount: 2 });
    await createOrder({ status: OrderStatus.cancelled, fulfillmentType: FulfillmentType.delivery, minsAgo: 70, itemCount: 1 });
    await createOrder({ status: OrderStatus.delivered, fulfillmentType: FulfillmentType.delivery, minsAgo: 90, itemCount: 3, driverId: DRIVER_IDS[1] });
    await createOrder({ status: OrderStatus.cancelled, fulfillmentType: FulfillmentType.pickup, minsAgo: 100, itemCount: 4 });
    await createOrder({ status: OrderStatus.delivered, fulfillmentType: FulfillmentType.delivery, minsAgo: 110, itemCount: 2, driverId: DRIVER_IDS[2] });

    console.log('✅ Deterministic dashboard seed complete!');
}

main()
    .catch((e) => {
        console.error(e);
        // Soft exit mapping to avoid TS process error if missing types
        if (typeof process !== 'undefined') process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
