"use client"

import React, { useState } from "react"
import { AppShell, PageHeader, OfflineBanner, OrderCard, OrderCardData } from "@restaurant-direct/ui"
import { Wifi, Search, Filter } from "lucide-react"

// Mock Data
const MOCK_ORDERS: OrderCardData[] = [
    {
        id: "order_1",
        orderNumber: "8492",
        customerName: "Alice Smith",
        status: "pending",
        fulfillmentType: "delivery",
        paymentState: "paid",
        placedAtISO: new Date(Date.now() - 1000 * 60 * 5).toISOString(),
        totalAmount: 245.50,
        currency: "ZAR",
        itemCount: 2,
        items: [
            { id: "item_1", quantity: 1, name: "Double Smash Burger", modifiers: ["No tomato", "Extra sauce"] },
            { id: "item_2", quantity: 1, name: "Large Fries" }
        ],
        deliveryAddress: "14 Long Street, Cape Town"
    },
    {
        id: "order_2",
        orderNumber: "8493",
        customerName: "Bob Johnson",
        status: "preparing",
        fulfillmentType: "pickup",
        paymentState: "pay_in_store",
        placedAtISO: new Date(Date.now() - 1000 * 60 * 15).toISOString(),
        totalAmount: 120.00,
        currency: "ZAR",
        itemCount: 1,
        items: [
            { id: "item_3", quantity: 1, name: "Spicy Wrap", notes: "Extra spicy please" }
        ],
        customerNote: "Will arrive in 10 mins"
    },
    {
        id: "order_3",
        orderNumber: "8494",
        customerName: "Charlie Davis",
        status: "ready_for_pickup",
        fulfillmentType: "delivery",
        paymentState: "paid",
        placedAtISO: new Date(Date.now() - 1000 * 60 * 35).toISOString(),
        totalAmount: 430.25,
        currency: "ZAR",
        itemCount: 4,
        items: [
            { id: "item_4", quantity: 2, name: "Pad Thai", modifiers: ["Chicken", "Mild"] },
            { id: "item_5", quantity: 2, name: "Spring Rolls" }
        ],
        deliveryAddress: "45 Kloof Street, Gardens",
        assignedDriverName: "Sipho M.",
        isLate: true
    }
]

export default function Dashboard() {
    const [isOffline, setIsOffline] = useState(false)

    // Top Nav placeholder
    const topNav = (
        <div className="flex h-16 items-center justify-between border-b border-border-subtle bg-surface-card px-4 md:px-8 shadow-sm">
            <div className="font-bold text-brand-primary text-xl">Platform</div>
            <div className="flex gap-4">
                <button onClick={() => setIsOffline(!isOffline)} className="flex items-center gap-2 text-sm text-text-secondary">
                    <Wifi className={cn("h-4 w-4", isOffline ? "text-status-offline" : "text-status-ready")} />
                    {isOffline ? "Offline Mode" : "Online"}
                </button>
            </div>
        </div>
    )

    // Empty placeholder for sidebar
    const sideNav = (
        <div className="hidden w-64 border-r border-border-subtle bg-surface-card md:flex flex-col p-4 shadow-sm">
            <div className="font-bold text-text-primary text-xl mb-8 pl-4">Restaurant</div>
            <div className="space-y-2">
                <div className="bg-brand-primary/10 text-brand-primary font-medium px-4 py-2 rounded-md">Live Dashboard</div>
                <div className="text-text-secondary hover:bg-state-hover_overlay font-medium px-4 py-2 rounded-md transition-colors cursor-pointer">Menu Management</div>
                <div className="text-text-secondary hover:bg-state-hover_overlay font-medium px-4 py-2 rounded-md transition-colors cursor-pointer">Analytics</div>
            </div>
        </div>
    )

    return (
        <AppShell navigation={sideNav} topBar={topNav}>
            <div className="flex flex-col h-full gap-4 max-h-[calc(100vh-2rem)]">
                {isOffline && (
                    <OfflineBanner onRetry={() => setIsOffline(false)} />
                )}

                <PageHeader
                    title="Live Operations Dashboard"
                    actions={
                        <div className="flex gap-2">
                            <button className="flex items-center p-2 rounded-md border border-border-subtle hover:bg-state-hover_overlay transition-colors">
                                <Filter className="h-4 w-4" />
                            </button>
                        </div>
                    }
                />

                {/* Dashboard Grid */}
                <div className="grid flex-1 grid-cols-1 gap-6 md:grid-cols-2 xl:grid-cols-4 overflow-hidden">

                    {/* Pending Lane */}
                    <div className="flex flex-col rounded-lg bg-surface-background/50 border border-border-subtle">
                        <div className="flex items-center justify-between border-b border-border-subtle bg-surface-card p-4 rounded-t-lg">
                            <h2 className="font-bold text-text-primary flex items-center gap-2">
                                Pending
                                <span className="flex h-5 w-5 items-center justify-center rounded-full bg-status-pending text-xs text-text-inverse">1</span>
                            </h2>
                        </div>
                        <div className="flex-1 overflow-y-auto p-4 space-y-4">
                            {MOCK_ORDERS.filter(o => o.status === "pending").map(order => (
                                <OrderCard
                                    key={order.id}
                                    data={order}
                                    primaryActionLabel="Accept Order"
                                    secondaryActionLabel="Reject"
                                    state={isOffline ? "offline" : "default"}
                                />
                            ))}
                        </div>
                    </div>

                    {/* Preparing Lane */}
                    <div className="flex flex-col rounded-lg bg-surface-background/50 border border-border-subtle">
                        <div className="flex items-center justify-between border-b border-border-subtle bg-surface-card p-4 rounded-t-lg">
                            <h2 className="font-bold text-text-primary flex items-center gap-2">
                                Preparing
                                <span className="flex h-5 w-5 items-center justify-center rounded-full bg-status-preparing text-xs text-text-inverse">1</span>
                            </h2>
                        </div>
                        <div className="flex-1 overflow-y-auto p-4 space-y-4">
                            {MOCK_ORDERS.filter(o => o.status === "preparing").map(order => (
                                <OrderCard
                                    key={order.id}
                                    data={order}
                                    primaryActionLabel="Mark Ready"
                                    state={isOffline ? "offline" : "default"}
                                />
                            ))}
                        </div>
                    </div>

                    {/* Ready Lane */}
                    <div className="flex flex-col rounded-lg bg-surface-background/50 border border-border-subtle overflow-hidden">
                        <div className="flex items-center justify-between border-b border-border-subtle bg-surface-card p-4 rounded-t-lg">
                            <h2 className="font-bold text-text-primary flex items-center gap-2">
                                Ready / Dispatched
                                <span className="flex h-5 w-5 items-center justify-center rounded-full bg-status-ready text-xs text-text-inverse">1</span>
                            </h2>
                        </div>
                        <div className="flex-1 overflow-y-auto p-4 space-y-4">
                            {MOCK_ORDERS.filter(o => ["ready_for_pickup", "out_for_delivery"].includes(o.status)).map(order => (
                                <OrderCard
                                    key={order.id}
                                    data={order}
                                    primaryActionLabel={order.fulfillmentType === 'pickup' ? "Complete Order" : "Track Driver"}
                                    state={isOffline ? "offline" : "default"}
                                />
                            ))}
                        </div>
                    </div>

                    {/* Completed Lane */}
                    <div className="flex flex-col rounded-lg bg-surface-background/50 border border-border-subtle">
                        <div className="flex items-center justify-between border-b border-border-subtle bg-surface-card p-4 rounded-t-lg opacity-75">
                            <h2 className="font-bold text-text-primary flex items-center gap-2">
                                Completed
                            </h2>
                        </div>
                        <div className="flex-1 overflow-y-auto p-4 space-y-4">
                            <div className="flex flex-col items-center justify-center h-full text-text-secondary p-4 text-center">
                                <div className="p-3 rounded-full bg-surface-card shadow-sm border border-border-subtle mb-3">
                                    <Search className="h-5 w-5 opacity-50" />
                                </div>
                                <p className="font-medium text-sm">No recent completions</p>
                                <p className="text-xs opacity-75 mt-1">Orders completed in the last hour will appear here</p>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </AppShell>
    )
}
