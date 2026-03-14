import React from "react"
export type PaymentVariant = "paid" | "unpaid" | "refunded" | "pay_in_store"
export function PaymentBadge({ variant }: { variant: PaymentVariant }) {
    return <span>{variant}</span>
}
