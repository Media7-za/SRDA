export type OrderStatus = 'pending' | 'confirmed' | 'preparing' | 'ready_for_pickup' | 'out_for_delivery' | 'delivered' | 'cancelled';
export type FulfillmentType = 'pickup' | 'delivery';
export type PaymentStatus = 'paid' | 'pay_in_store';

export interface KanbanItem {
    id: string;
    name: string;
    quantity: number;
    modifiers?: string[];
}

export interface KanbanOrder {
    id: string;
    shortId: string;
    customerName: string;
    items: KanbanItem[];
    total: number;
    status: OrderStatus;
    fulfillmentType: FulfillmentType;
    paymentStatus: PaymentStatus;
    minutesAgo: number;
    estimatedReadyMinutes?: number;
    version: number;
}

export const MOCK_KANBAN_ORDERS: KanbanOrder[] = [
    {
        id: "o1",
        shortId: "A3F9C1",
        customerName: "John Doe",
        total: 245.00,
        status: 'pending',
        fulfillmentType: 'delivery',
        paymentStatus: 'paid',
        minutesAgo: 4,
        version: 1,
        items: [
            { id: "i1", name: "Double Cheese Burger", quantity: 2, modifiers: ["No Onions", "Extra Pickles"] },
            { id: "i2", name: "Large Fries", quantity: 1 }
        ]
    },
    {
        id: "o2",
        shortId: "B7E2D4",
        customerName: "Sarah Smith",
        total: 180.50,
        status: 'confirmed',
        fulfillmentType: 'pickup',
        paymentStatus: 'pay_in_store',
        minutesAgo: 12,
        estimatedReadyMinutes: 20,
        version: 2,
        items: [
            { id: "i3", name: "Margherita Pizza", quantity: 1, modifiers: ["Thin Crust"] }
        ]
    },
    {
        id: "o3",
        shortId: "C9A5B8",
        customerName: "Mike Johnson",
        total: 420.00,
        status: 'ready_for_pickup',
        fulfillmentType: 'delivery',
        paymentStatus: 'paid',
        minutesAgo: 25,
        version: 3,
        items: [
            { id: "i4", name: "Family Pack: Wings", quantity: 1, modifiers: ["Spicy"] },
            { id: "i5", name: "Coke 2L", quantity: 1 }
        ]
    },
    {
        id: "o4",
        shortId: "D1C4E7",
        customerName: "Emma Wilson",
        total: 95.00,
        status: 'out_for_delivery',
        fulfillmentType: 'delivery',
        paymentStatus: 'paid',
        minutesAgo: 45,
        version: 4,
        items: [
            { id: "i6", name: "Chicken Caesar Salad", quantity: 1 }
        ]
    }
];
