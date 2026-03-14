export interface KDSItem {
    id: string;
    name: string;
    quantity: number;
    modifiers?: string[];
}

export interface KDSOrder {
    id: string;
    shortId: string;
    items: KDSItem[];
    minutesElapsed: number;
    isUrgent: boolean;
    fulfillmentType: 'delivery' | 'pickup';
}

export const MOCK_KDS_ORDERS: KDSOrder[] = [
    {
        id: "order_1",
        shortId: "A3F9C1",
        minutesElapsed: 4,
        isUrgent: false,
        fulfillmentType: 'delivery',
        items: [
            { id: "i1", name: "Double Cheese Burger", quantity: 2, modifiers: ["No Onions", "Extra Pickles"] },
            { id: "i2", name: "Large Fries", quantity: 1 },
            { id: "i3", name: "Coke Zero", quantity: 1 }
        ]
    },
    {
        id: "order_2",
        shortId: "B7E2D4",
        minutesElapsed: 12,
        isUrgent: false,
        fulfillmentType: 'pickup',
        items: [
            { id: "i4", name: "Margherita Pizza", quantity: 1, modifiers: ["Thin Crust"] },
            { id: "i5", name: "Garlic Bread", quantity: 2 }
        ]
    },
    {
        id: "order_3",
        shortId: "C9A5B8",
        minutesElapsed: 18,
        isUrgent: true,
        fulfillmentType: 'delivery',
        items: [
            { id: "i6", name: "Family Pack: Wings", quantity: 1, modifiers: ["Spicy", "Blue Cheese Dip"] },
            { id: "i7", name: "Onion Rings", quantity: 3 }
        ]
    },
    {
        id: "order_4",
        shortId: "D1C4E7",
        minutesElapsed: 2,
        isUrgent: false,
        fulfillmentType: 'pickup',
        items: [
            { id: "i8", name: "Chicken Caesar Salad", quantity: 1, modifiers: ["Dressing on side"] },
            { id: "i9", name: "Mineral Water", quantity: 2 }
        ]
    }
];
