"use client"

import React from "react"
import { cn } from "@restaurant-direct/ui"
import { KanbanOrder } from "../../_mocks/kanban-orders"
import { KanbanCard } from "./KanbanCard"

interface KanbanColumnProps {
    title: string;
    orders: KanbanOrder[];
    onAction: (id: string) => void;
    accentColor?: string;
}

export function KanbanColumn({ title, orders, onAction, accentColor = "bg-brand-primary" }: KanbanColumnProps) {
    return (
        <div className="flex flex-col h-full min-w-[320px] w-full max-w-[450px] bg-surface-muted/20 border border-border-subtle rounded-2xl overflow-hidden shadow-sm">
            {/* Column Header */}
            <div className="p-4 bg-white border-b border-border-subtle flex items-center justify-between shadow-sm relative overflow-hidden">
                <div className={cn("absolute top-0 left-0 w-1 h-full", accentColor)} />
                <div className="flex items-center gap-3">
                    <h3 className="font-black text-text-primary uppercase tracking-tight text-lg pl-1">{title}</h3>
                    <span className="flex items-center justify-center w-6 h-6 bg-surface-muted text-text-secondary text-xs font-black rounded-full border border-border-subtle">
                        {orders.length}
                    </span>
                </div>
            </div>

            {/* Scrollable Area */}
            <div className="flex-1 overflow-y-auto p-4 space-y-4 bg-zinc-50/30">
                {orders.length > 0 ? (
                    orders.map(order => (
                        <KanbanCard
                            key={order.id}
                            order={order}
                            onAction={onAction}
                        />
                    ))
                ) : (
                    <div className="h-full flex flex-col items-center justify-center py-12 px-6 border-2 border-dashed border-border-subtle rounded-xl opacity-60">
                        <p className="text-sm font-bold text-text-tertiary uppercase tracking-widest text-center">
                            No orders in {title}
                        </p>
                    </div>
                )}
            </div>
        </div>
    )
}
