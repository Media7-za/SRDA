"use client"

import React from "react"
import { cn } from "@restaurant-direct/ui"
import { Clock, CheckCircle2, Play, Package, Truck, Receipt } from "lucide-react"
import { KanbanOrder } from "../../_mocks/kanban-orders"

interface KanbanCardProps {
    order: KanbanOrder;
    onAction: (id: string) => void;
}

export function KanbanCard({ order, onAction }: KanbanCardProps) {
    const getActionLabel = () => {
        switch (order.status) {
            case 'pending': return "Accept Order";
            case 'confirmed':
            case 'preparing': return "Mark Ready";
            case 'ready_for_pickup':
                return order.fulfillmentType === 'delivery' ? "Assign Driver" : "Mark Collected";
            default: return null;
        }
    }

    const ActionIcon = () => {
        switch (order.status) {
            case 'pending': return <Play className="h-4 w-4" />;
            case 'confirmed':
            case 'preparing': return <CheckCircle2 className="h-4 w-4" />;
            case 'ready_for_pickup':
                return order.fulfillmentType === 'delivery' ? <Truck className="h-4 w-4" /> : <Package className="h-4 w-4" />;
            default: return null;
        }
    }

    const actionLabel = getActionLabel();

    return (
        <div className="bg-surface-card border border-border-subtle rounded-xl overflow-hidden shadow-sm hover:shadow-md transition-shadow group">
            {/* Header / Badges */}
            <div className="p-4 border-b border-border-subtle">
                <div className="flex items-center justify-between mb-2">
                    <span className="font-bold text-text-primary">#{order.shortId}</span>
                    <span className={cn(
                        "text-[10px] font-black uppercase tracking-wider px-2 py-0.5 rounded",
                        order.fulfillmentType === 'delivery' ? "bg-orange-500/10 text-orange-600" : "bg-blue-500/10 text-blue-600"
                    )}>
                        {order.fulfillmentType}
                    </span>
                </div>
                <div className="flex items-center justify-between">
                    <span className="text-sm font-medium text-text-secondary">{order.customerName}</span>
                    <div className="flex items-center gap-1 text-text-tertiary">
                        <Clock className="h-3 w-3" />
                        <span className="text-xs font-medium">{order.minutesAgo}m ago</span>
                    </div>
                </div>
            </div>

            {/* Items */}
            <div className="p-4 space-y-3 min-h-[100px]">
                <div className="text-[10px] font-bold text-text-tertiary uppercase tracking-widest">Items</div>
                <ul className="space-y-2">
                    {order.items.map(item => (
                        <li key={item.id} className="text-sm">
                            <div className="flex items-start gap-2">
                                <span className="font-bold text-brand-primary">{item.quantity}x</span>
                                <span className="text-text-primary leading-tight font-medium">{item.name}</span>
                            </div>
                            {item.modifiers && item.modifiers.length > 0 && (
                                <div className="ml-6 mt-1 flex flex-wrap gap-1">
                                    {item.modifiers.map((mod, idx) => (
                                        <span key={idx} className="text-[10px] bg-surface-muted text-text-secondary px-1.5 py-0.5 rounded">
                                            {mod}
                                        </span>
                                    ))}
                                </div>
                            )}
                        </li>
                    ))}
                </ul>
            </div>

            {/* Footer / Meta */}
            <div className="px-4 py-3 bg-surface-muted/30 border-t border-border-subtle">
                <div className="flex items-center justify-between mb-3">
                    <div className="flex items-center gap-1.5">
                        <Receipt className="h-3.5 w-3.5 text-text-tertiary" />
                        <span className="text-sm font-bold text-text-primary">R{order.total.toFixed(2)}</span>
                        <span className={cn(
                            "ml-2 text-[10px] font-bold uppercase px-1.5 py-0.5 rounded",
                            order.paymentStatus === 'paid' ? "bg-green-500/10 text-green-600" : "bg-yellow-500/10 text-yellow-700"
                        )}>
                            {order.paymentStatus === 'paid' ? 'Paid' : 'Pay In-Store'}
                        </span>
                    </div>
                    {(order.status === 'confirmed' || order.status === 'preparing') && order.estimatedReadyMinutes && (
                        <div className="text-[10px] font-bold text-brand-primary bg-brand-primary/5 px-2 py-0.5 rounded">
                            Est. {order.estimatedReadyMinutes}m
                        </div>
                    )}
                </div>

                {actionLabel && (
                    <button
                        onClick={() => onAction(order.id)}
                        className="w-full bg-brand-primary hover:bg-brand-primary_hover text-white text-sm font-bold py-2.5 rounded-lg flex items-center justify-center gap-2 shadow-sm transition-all active:scale-[0.98]"
                    >
                        <ActionIcon />
                        {actionLabel}
                    </button>
                )}
            </div>
        </div>
    )
}
