import React from "react"
export function PageHeader({ title, description, actions }: { title: React.ReactNode, description?: React.ReactNode, actions?: React.ReactNode }) {
    return (
        <div className="flex items-center justify-between mb-6">
            <div>
                <h1 className="text-2xl font-bold text-text-primary">{title}</h1>
                {description && <p className="text-text-secondary mt-1">{description}</p>}
            </div>
            {actions && <div>{actions}</div>}
        </div>
    )
}
