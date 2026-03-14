"use client"

import React, { useState } from "react"
import { AppShell, PageHeader } from "@restaurant-direct/ui"
import { ChevronLeft, Info } from "lucide-react"
import Link from "next/link"
import { KanbanOrder, MOCK_KANBAN_ORDERS, OrderStatus } from "../_mocks/kanban-orders"
import { KanbanColumn } from "./components/KanbanColumn"

export default function KanbanPrototype() {
    const [orders, setOrders] = useState<KanbanOrder[]>(MOCK_KANBAN_ORDERS)

    const handleAction = (id: string) => {
        setOrders(prev => prev.map(order => {
            if (order.id !== id) return order;

            let nextStatus: OrderStatus = order.status;
            switch (order.status) {
                case 'pending':
                    nextStatus = 'confirmed';
                    break;
                case 'confirmed':
                case 'preparing':
                    nextStatus = 'ready_for_pickup';
                    break;
                case 'ready_for_pickup':
                    nextStatus = order.fulfillmentType === 'delivery' ? 'out_for_delivery' : 'delivered';
                    break;
            }

            return { ...order, status: nextStatus, version: order.version + 1 };
        }));
    }

    const sideNav = (
        <div className="flex w-64 border-r border-border-subtle bg-surface-card flex-col p-4 shadow-sm text-text-secondary">
            <Link href="/dashboard/sandbox" className="flex items-center gap-2 hover:text-text-primary transition-colors mb-8 pl-2 font-medium">
                <ChevronLeft className="h-4 w-4" />
                <span>Back to Sandbox</span>
            </Link>
            <div className="font-black text-text-primary text-xl mb-8 pl-4 uppercase tracking-widest border-l-4 border-brand-primary">KANBAN LAB</div>
            <div className="space-y-2">
                <div className="bg-brand-primary/10 text-brand-primary font-bold px-4 py-2 rounded-lg">Operational Feed</div>
                <div className="hover:bg-surface-muted font-medium px-4 py-2 rounded-lg transition-colors cursor-pointer">History</div>
                <div className="hover:bg-surface-muted font-medium px-4 py-2 rounded-lg transition-colors cursor-pointer">Station Settings</div>
            </div>
        </div>
    )

    return (
        <AppShell navigation={sideNav}>
            <div className="h-screen flex flex-col bg-zinc-50/50">
                <div className="p-6 border-b border-border-subtle bg-white">
                    <PageHeader
                        title="Live Order Feed"
                        description="Operational Kanban view for high-volume kitchen management."
                    />

                    <div className="mt-4 flex items-center gap-2 text-xs font-medium text-text-tertiary bg-surface-muted px-4 py-2 rounded-lg w-fit">
                        <Info className="h-3.5 w-3.5" />
                        <span>Interactive Prototype: Click action buttons to advance order states.</span>
                    </div>
                </div>

                {/* Kanban Board */}
                <div className="flex-1 overflow-x-auto overflow-y-hidden p-6 gap-6 flex items-start">
                    <KanbanColumn
                        title="New Orders"
                        orders={orders.filter(o => o.status === 'pending')}
                        onAction={handleAction}
                        accentColor="bg-yellow-500"
                    />
                    <KanbanColumn
                        title="Preparing"
                        orders={orders.filter(o => o.status === 'confirmed' || o.status === 'preparing')}
                        onAction={handleAction}
                        accentColor="bg-orange-600"
                    />
                    <KanbanColumn
                        title="Ready"
                        orders={orders.filter(o => o.status === 'ready_for_pickup')}
                        onAction={handleAction}
                        accentColor="bg-blue-600"
                    />
                    <KanbanColumn
                        title="Completed"
                        orders={orders.filter(o => o.status === 'out_for_delivery' || o.status === 'delivered')}
                        onAction={handleAction}
                        accentColor="bg-green-600"
                    />
                </div>
            </div>
        </AppShell>
    )
}
