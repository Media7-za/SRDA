import React from "react"
export type StatusVariant = "pending" | "preparing" | "ready" | "delivered" | "failed"
export function StatusBadge({ variant, label }: { variant: StatusVariant, label: string }) {
    return <span className={`badge-${variant}`}>{label}</span>
}
