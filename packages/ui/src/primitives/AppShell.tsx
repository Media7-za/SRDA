import React from "react"

export function AppShell({ children, navigation, topBar }: { children: React.ReactNode, navigation?: React.ReactNode, topBar?: React.ReactNode }) {
    return (
        <div className="flex h-screen w-full flex-col bg-surface-background">
            {topBar && <div className="z-10">{topBar}</div>}
            <div className="flex flex-1 overflow-hidden">
                {navigation && <div className="z-10 h-full">{navigation}</div>}
                <main className="flex-1 overflow-y-auto p-4 md:p-8">
                    {children}
                </main>
            </div>
        </div>
    )
}
