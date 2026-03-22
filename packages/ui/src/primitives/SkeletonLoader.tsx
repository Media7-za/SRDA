import React from "react"

import { cn } from "../utils/cn"

export function SkeletonLoader({
    lines = 3,
    showAvatar = false,
    className
}: {
    lines?: number
    showAvatar?: boolean
    className?: string
}) {
    return (
        <div className={cn("animate-pulse rounded-2xl border border-slate-200 bg-white p-4 shadow-sm", className)}>
            <div className="flex items-start gap-3">
                {showAvatar ? <div className="h-10 w-10 rounded-full bg-slate-200" /> : null}
                <div className="flex-1 space-y-3">
                    <div className="h-4 w-1/3 rounded bg-slate-200" />
                    {Array.from({ length: lines }).map((_, index) => (
                        <div
                            key={index}
                            className={cn("h-3 rounded bg-slate-200", index === lines - 1 ? "w-2/3" : "w-full")}
                        />
                    ))}
                </div>
            </div>
        </div>
    )
}
