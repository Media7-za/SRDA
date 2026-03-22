import React from "react"

export function PageHeader({
    title,
    subtitle,
    description,
    actions
}: {
    title: React.ReactNode
    subtitle?: React.ReactNode
    description?: React.ReactNode
    actions?: React.ReactNode
}) {
    const supportingText = subtitle ?? description

    return (
        <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
            <div className="min-w-0">
                <h1 className="text-2xl font-semibold tracking-tight text-slate-950 sm:text-3xl">{title}</h1>
                {supportingText ? <p className="mt-1 text-sm text-slate-600 sm:text-base">{supportingText}</p> : null}
            </div>
            {actions ? <div className="flex shrink-0 items-center gap-2">{actions}</div> : null}
        </div>
    )
}
