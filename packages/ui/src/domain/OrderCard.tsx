import React, { ReactNode } from "react"
import { cn } from "../utils/cn"
import { StatusBadge, StatusVariant } from "./StatusBadge"
import { PaymentBadge, PaymentVariant } from "./PaymentBadge"
import { FulfillmentBadge, FulfillmentVariant } from "./FulfillmentBadge"
import { PrimaryButton, SecondaryButton } from "../primitives/Button"
import { Clock, User } from "lucide-react"

export type OrderStatus =
    | "pending"
    | "confirmed"
    | "preparing"
    | "ready_for_pickup"
    | "out_for_delivery"
    | "delivered"
    | "cancelled"

export type OrderItem = {
    id: string
    quantity: number
    name: string
    modifiers?: string[]
    notes?: string
}

export type OrderCardData = {
    id: string
    orderNumber: string
    customerName: string
    status: OrderStatus
    fulfillmentType: FulfillmentVariant
    paymentState: PaymentVariant
    placedAtISO: string
    quotedReadyAtISO?: string
    totalAmount: number
    currency: string
    items: OrderItem[]
    itemCount: number
    customerNote?: string
    deliveryAddress?: string
    assignedDriverName?: string
    isLate?: boolean
}

export interface OrderCardProps {
    data?: OrderCardData
    state?: "default" | "loading" | "error" | "offline" | "success"
    onPrimaryAction?: (id: string) => void
    onSecondaryAction?: (id: string) => void
    primaryActionLabel?: string
    secondaryActionLabel?: string
    className?: string
}

const mapStatusToVariant = (status: OrderStatus): StatusVariant => {
    switch (status) {
        case "pending":
        case "confirmed":
            return "pending"
        case "preparing":
            return "preparing"
        case "ready_for_pickup":
        case "out_for_delivery":
            return "ready"
        case "delivered":
            return "delivered"
        case "cancelled":
            return "failed"
        default:
            return "pending"
    }
}

const formatStatusLabel = (status: OrderStatus): string => {
    return status.split("_").map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(" ")
}

function ElapsedTime({ placedAt }: { placedAt: string }) {
    // In a real app this would use a localized relative time hook
    return <span className="text-xs text-text-secondary">Added {new Date(placedAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span>
}

export function OrderCard({
    data,
    state = "default",
    onPrimaryAction,
    onSecondaryAction,
    primaryActionLabel,
    secondaryActionLabel,
    className
}: OrderCardProps) {
    if (state === "loading" || !data) {
        return (
            <div className={cn("flex flex-col gap-4 rounded-lg bg-surface-card p-4 shadow-card animate-pulse border border-transparent", className)}>
                <div className="flex justify-between">
                    <div className="h-5 w-20 rounded bg-state-disabled_bg" />
                    <div className="flex gap-2"><div className="h-5 w-16 rounded bg-state-disabled_bg" /></div>
                </div>
                <div className="space-y-2">
                    <div className="h-4 w-1/2 rounded bg-state-disabled_bg" />
                    <div className="h-4 w-1/3 rounded bg-state-disabled_bg" />
                </div>
                <div className="h-20 w-full rounded bg-state-disabled_bg mt-2" />
                <div className="flex justify-end gap-2 mt-2">
                    <div className="h-10 w-24 rounded bg-state-disabled_bg" />
                    <div className="h-10 w-24 rounded bg-state-disabled_bg" />
                </div>
            </div>
        )
    }

    const { id, orderNumber, customerName, status, fulfillmentType, paymentState, placedAtISO, totalAmount, currency, items, itemCount, customerNote, deliveryAddress, assignedDriverName, isLate } = data

    const isOffline = state === "offline"
    const isError = state === "error"
    const isSuccess = state === "success"

    return (
        <div className={cn(
            "flex flex-col gap-0 rounded-lg bg-surface-card shadow-card overflow-hidden transition-colors border",
            isLate ? "border-status-failed" : "border-transparent",
            isError && "border-border-error ring-1 ring-border-error",
            isSuccess && "ring-1 ring-status-ready",
            isOffline && "opacity-75 grayscale-[0.2]",
            className
        )}>
            {/* Header */}
            <div className={cn(
                "flex items-center justify-between border-b border-border-subtle p-3",
                isLate ? "bg-status-failed/5" : "bg-surface-background/50"
            )}>
                <div className="flex items-center gap-2 font-bold text-text-primary text-sm">
                    #{orderNumber}
                    {isLate && <span className="text-xs text-status-failed px-1">LATE</span>}
                </div>
                <div className="flex items-center gap-2">
                    <PaymentBadge variant={paymentState} />
                    <FulfillmentBadge variant={fulfillmentType} />
                </div>
            </div>

            {/* Meta */}
            <div className="flex flex-col gap-1 p-3 pb-0">
                <div className="flex items-center justify-between">
                    <div className="flex items-center gap-1.5 font-medium text-text-primary">
                        <User className="h-4 w-4 text-text-secondary" />
                        <span className="truncate">{customerName}</span>
                    </div>
                    <div className="flex items-center gap-1.5 text-text-secondary">
                        <Clock className="h-4 w-4" />
                        <ElapsedTime placedAt={placedAtISO} />
                    </div>
                </div>
                <div className="mt-1">
                    <StatusBadge
                        variant={mapStatusToVariant(status)}
                        label={formatStatusLabel(status)}
                    />
                </div>
            </div>

            {/* Body: Items & Notes */}
            <div className="flex flex-col gap-2 p-3 text-sm flex-1">
                <ul className="flex flex-col gap-1.5 text-text-primary">
                    {items.map(item => (
                        <li key={item.id} className="flex gap-2">
                            <span className="font-semibold text-text-secondary">{item.quantity}x</span>
                            <div className="flex flex-col">
                                <span className="font-medium">{item.name}</span>
                                {item.modifiers && item.modifiers.length > 0 && (
                                    <span className="text-xs text-text-secondary">{item.modifiers.join(', ')}</span>
                                )}
                                {item.notes && (
                                    <span className="text-xs italic text-status-pending mt-0.5">Note: {item.notes}</span>
                                )}
                            </div>
                        </li>
                    ))}
                </ul>

                {itemCount > items.length && (
                    <div className="text-xs text-brand-primary font-medium mt-1">
                        + {itemCount - items.length} more items...
                    </div>
                )}

                {customerNote && (
                    <div className="mt-2 rounded bg-status-pending/10 p-2 text-xs text-text-primary border border-status-pending/20">
                        <span className="font-semibold block mb-0.5">Order Note:</span>
                        {customerNote}
                    </div>
                )}

                {fulfillmentType === "delivery" && deliveryAddress && (
                    <div className="mt-2 text-xs text-text-secondary border-t border-border-subtle pt-2">
                        <span className="font-semibold block text-text-primary">Deliver To:</span>
                        <span className="truncate block mt-0.5">{deliveryAddress}</span>
                        {assignedDriverName && <span className="truncate block text-brand-primary mt-1">Driver: {assignedDriverName}</span>}
                    </div>
                )}
            </div>

            {/* Footer */}
            <div className="flex items-center justify-between border-t border-border-subtle bg-surface-background/50 p-3 mt-auto">
                <div className="font-bold text-text-primary">
                    {currency} {totalAmount.toFixed(2)}
                </div>
                <div className="flex items-center gap-2">
                    {secondaryActionLabel && onSecondaryAction && (
                        <SecondaryButton
                            label={secondaryActionLabel}
                            onClick={() => onSecondaryAction(id)}
                            className="h-8 px-3 py-1 text-xs min-h-0"
                            disabled={isOffline}
                        />
                    )}
                    {primaryActionLabel && onPrimaryAction && (
                        <PrimaryButton
                            label={primaryActionLabel}
                            onClick={() => onPrimaryAction(id)}
                            state={isOffline ? "disabled" : "default"}
                            className="h-8 px-3 py-1 text-xs min-h-0 min-w-[80px]"
                        />
                    )}
                </div>
            </div>
        </div>
    )
}
