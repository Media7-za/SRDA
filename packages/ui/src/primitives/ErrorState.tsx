import React from "react"
import { AlertCircle } from "lucide-react"

import { Card } from "./Card"

export function ErrorState({
    title = "Something went wrong",
    description = "We couldn't load this section. Try again.",
    action
}: {
    title?: string
    description?: string
    action?: React.ReactNode
}) {
    return (
        <Card className="flex min-h-[240px] flex-col items-center justify-center text-center">
            <div className="mb-4 rounded-full bg-rose-50 p-3 text-rose-600">
                <AlertCircle className="h-6 w-6" />
            </div>
            <h2 className="text-lg font-semibold text-slate-900">{title}</h2>
            <p className="mt-2 max-w-md text-sm text-slate-600">{description}</p>
            {action ? <div className="mt-5">{action}</div> : null}
        </Card>
    )
}
