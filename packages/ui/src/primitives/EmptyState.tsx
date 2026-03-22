import React from "react"
import { Inbox } from "lucide-react"

import { Card } from "./Card"

export function EmptyState({
    title,
    description,
    action,
    icon
}: {
    title: string
    description?: string
    action?: React.ReactNode
    icon?: React.ReactNode
}) {
    return (
        <Card className="flex min-h-[240px] flex-col items-center justify-center text-center">
            <div className="mb-4 rounded-full bg-slate-100 p-3 text-slate-500">
                {icon ?? <Inbox className="h-6 w-6" />}
            </div>
            <h2 className="text-lg font-semibold text-slate-900">{title}</h2>
            {description ? <p className="mt-2 max-w-md text-sm text-slate-600">{description}</p> : null}
            {action ? <div className="mt-5">{action}</div> : null}
        </Card>
    )
}
