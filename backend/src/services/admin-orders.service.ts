import { prisma } from '@restaurant-direct/database';
import { OrderStatus } from '@restaurant-direct/database';

export class AdminOrdersService {
    static async getBoard(restaurantId: string) {
        // We fetch active lanes, plus recently updated completed/cancelled
        const twoHoursAgo = new Date(Date.now() - 2 * 60 * 60 * 1000);

        const orders = await prisma.order.findMany({
            where: {
                restaurantId,
                OR: [
                    { status: { in: ['pending', 'confirmed', 'preparing', 'ready_for_pickup', 'out_for_delivery'] } },
                    {
                        status: { in: ['delivered', 'cancelled'] },
                        updatedAt: { gte: twoHoursAgo }
                    }
                ]
            },
            include: {
                customer: true,
                orderItems: {
                    take: 3,
                    include: { options: true }
                },
                delivery: {
                    include: { driver: { include: { user: true } } }
                },
                address: true
            },
            orderBy: { createdAt: 'desc' }
        });

        const serverTimeISO = new Date().toISOString();

        // Map to OrderCardData exactly
        const mappedOrders = orders.map((order: any) => {
            return {
                id: order.id,
                orderNumber: order.id.slice(0, 8), // mock order number 
                customerName: order.customer.name,
                status: order.status,
                fulfillmentType: order.fulfillmentType === 'delivery' ? 'delivery' : 'pickup',
                paymentState: order.paymentStatus === 'paid' ? 'paid' : 'unpaid', // basic fallback for now
                placedAtISO: order.createdAt.toISOString(),
                quotedReadyAtISO: order.estimatedReadyAt?.toISOString(),
                totalAmount: Number(order.totalAmount),
                currency: 'ZAR',
                itemCount: order.itemCount,
                items: order.orderItems.map((item: any) => ({
                    id: item.id,
                    quantity: item.quantity,
                    name: item.itemName,
                    modifiers: item.options.map((opt: any) => opt.optionName)
                })),
                customerNote: order.customerNote,
                deliveryAddress: order.address ? `${order.address.street}, ${order.address.city}` : undefined,
                assignedDriverName: order.delivery?.driver?.user?.name,
                // Server-derived late check
                isLate: order.estimatedReadyAt
                    && ['pending', 'confirmed', 'preparing'].includes(order.status)
                    && new Date(order.estimatedReadyAt).getTime() < Date.now()
            };
        });

        return {
            orders: mappedOrders,
            serverTimeISO
        };
    }

    static async updateStatus(restaurantId: string, orderId: string, status: OrderStatus) {
        // Enforce basic state transitions here...
        // For MVP we just execute it directly.
        const order = await prisma.order.findFirst({
            where: { id: orderId, restaurantId }
        });

        if (!order) {
            throw new Error('Order not found');
        }

        // e.g. Cannot reverse from complete back to pending
        if (order.status === 'delivered') {
            throw new Error('Order is already complete');
        }

        await prisma.order.update({
            where: { id: orderId },
            data: { status }
        });

        // Normally we might recreate the full object or return what updated
        return this.getSingleOrderMapped(orderId);
    }

    static async assignDriver(restaurantId: string, orderId: string, driverId: string) {
        const order = await prisma.order.findFirst({
            where: { id: orderId, restaurantId }
        });

        if (!order || order.fulfillmentType !== 'delivery') {
            throw new Error('Invalid order for delivery assignment');
        }

        await prisma.delivery.upsert({
            where: { orderId },
            create: {
                orderId,
                driverId,
                restaurantId,
                status: 'assigned'
            },
            update: {
                driverId,
                status: 'assigned'
            }
        });

        // Also advance order status to out_for_delivery if it was ready
        if (order.status === 'ready_for_pickup') {
            await prisma.order.update({
                where: { id: orderId },
                data: { status: 'out_for_delivery' }
            });
        }

        return this.getSingleOrderMapped(orderId);
    }

    private static async getSingleOrderMapped(orderId: string) {
        // Internal helper to return a fully hydrated order mapped exactly to UI
        const order = await prisma.order.findUnique({
            where: { id: orderId },
            include: {
                customer: true,
                orderItems: { take: 3, include: { options: true } },
                delivery: { include: { driver: { include: { user: true } } } },
                address: true
            }
        });

        if (!order) return null;

        return {
            id: order.id,
            orderNumber: order.id.slice(0, 8),
            customerName: order.customer.name,
            status: order.status,
            fulfillmentType: order.fulfillmentType === 'delivery' ? 'delivery' : 'pickup',
            paymentState: order.paymentStatus === 'paid' ? 'paid' : 'unpaid',
            placedAtISO: order.createdAt.toISOString(),
            quotedReadyAtISO: order.estimatedReadyAt?.toISOString(),
            totalAmount: Number(order.totalAmount),
            currency: 'ZAR',
            itemCount: order.itemCount,
            items: order.orderItems.map((item: any) => ({
                id: item.id,
                quantity: item.quantity,
                name: item.itemName,
                modifiers: item.options.map((opt: any) => opt.optionName)
            })),
            customerNote: order.customerNote,
            deliveryAddress: order.address ? `${order.address.street}, ${order.address.city}` : undefined,
            assignedDriverName: order.delivery?.driver?.user?.name,
            isLate: order.estimatedReadyAt
                && ['pending', 'confirmed', 'preparing'].includes(order.status)
                && new Date(order.estimatedReadyAt).getTime() < Date.now()
        };
    }
}
