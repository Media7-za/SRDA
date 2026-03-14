export type PhuketStatus = 'new' | 'accepted' | 'preparing' | 'ready';

export interface PhuketItem {
    id: string;
    name: string;
    quantity: number;
    modifiers?: string[];
}

export interface PhuketOrder {
    id: string;
    shortId: string;
    customerName: string;
    items: PhuketItem[];
    status: PhuketStatus;
    minutesElapsed: number;
    isLate: boolean;
    progress?: number; // 0-100
    laneAccent: string;
}

export const MOCK_PHUKET_ORDERS: PhuketOrder[] = [
    {
        id: "p1",
        shortId: "54A1",
        customerName: "SARAH K.",
        minutesElapsed: 3,
        isLate: false,
        status: 'new',
        laneAccent: 'border-gold',
        items: [
            { id: "pi1", name: "🍜 Pad Thai Chicken", quantity: 1, modifiers: ["No peanuts"] },
            { id: "pi2", name: "🍤 Prawn Tempura", quantity: 2, modifiers: ["Large"] }
        ]
    },
    {
        id: "p2",
        shortId: "54A0",
        customerName: "MIKE P.",
        minutesElapsed: 8,
        isLate: false,
        status: 'accepted',
        laneAccent: 'border-orange',
        items: [
            { id: "pi3", name: "🍛 Green Curry", quantity: 1 },
            { id: "pi4", name: "🧋 Thai Iced Tea", quantity: 1 }
        ]
    },
    {
        id: "p3",
        shortId: "53F9",
        customerName: "LISA R.",
        minutesElapsed: 15,
        isLate: false,
        status: 'preparing',
        laneAccent: 'border-green',
        progress: 60,
        items: [
            { id: "pi5", name: "🍱 Combo #3", quantity: 2, modifiers: ["Well-Done"] }
        ]
    },
    {
        id: "p4",
        shortId: "53F8",
        customerName: "OFFLINE",
        minutesElapsed: 22,
        isLate: true,
        status: 'preparing',
        laneAccent: 'border-red',
        items: [
            { id: "pi6", name: "🍛 Massaman Curry", quantity: 1 }
        ]
    },
    {
        id: "p5",
        shortId: "53F5",
        customerName: "A1",
        minutesElapsed: 9,
        isLate: false,
        status: 'ready',
        laneAccent: 'border-blue',
        items: [
            { id: "pi7", name: "Duck Spring Rolls", quantity: 1 }
        ]
    }
];
