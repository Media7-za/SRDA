import React from "react"

import { cn } from "../utils/cn"

export function Card({
    children,
    className
}: {
    children: React.ReactNode
    className?: string
}) {
    return (
        <section className={cn("rounded-2xl border border-slate-200 bg-white p-4 shadow-sm sm:p-5", className)}>
            {children}
        </section>
    )
}
