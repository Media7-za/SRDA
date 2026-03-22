import React from "react"

import { cn } from "../utils/cn"

export type StatusTone = "neutral" | "info" | "success" | "warning" | "danger"
export type StatusVariant = "pending" | "preparing" | "ready" | "delivered" | "failed"

const statusToneMap: Record<StatusTone, string> = {
    neutral: "bg-slate-100 text-slate-700 border-slate-200",
    info: "bg-sky-50 text-sky-700 border-sky-200",
    success: "bg-emerald-50 text-emerald-700 border-emerald-200",
    warning: "bg-amber-50 text-amber-700 border-amber-200",
    danger: "bg-rose-50 text-rose-700 border-rose-200"
}

const legacyVariantToneMap: Record<StatusVariant, StatusTone> = {
    pending: "warning",
    preparing: "info",
    ready: "success",
    delivered: "neutral",
    failed: "danger"
}

export function StatusBadge({
    children,
    label,
    tone,
    variant,
    className
}: {
    children?: React.ReactNode
    label?: React.ReactNode
    tone?: StatusTone
    variant?: StatusVariant
    className?: string
}) {
    const resolvedTone = tone ?? (variant ? legacyVariantToneMap[variant] : "neutral")

    return (
        <span
            className={cn(
                "inline-flex items-center rounded-full border px-2.5 py-1 text-xs font-medium",
                statusToneMap[resolvedTone],
                className
            )}
        >
            {children ?? label}
        </span>
    )
}
