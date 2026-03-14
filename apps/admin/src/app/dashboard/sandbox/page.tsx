"use client"

import React from "react"
import { AppShell, PageHeader } from "@restaurant-direct/ui"
import { Beaker, ChefHat, BarChart3, Settings2, Receipt } from "lucide-react"
import Link from "next/link"

const PROTOTYPES = [
    {
        title: "Kitchen Display (KDS)",
        description: "Evolutionary: High-contrast order management for the hotline.",
        href: "/dashboard/sandbox/kds",
        icon: ChefHat,
        status: "Active",
        color: "bg-orange-500"
    },
    {
        title: "Kanban Order Feed",
        description: "Live: Operational board with four-column swimlanes.",
        href: "/dashboard/sandbox/kanban",
        icon: Receipt,
        status: "Active",
        color: "bg-emerald-500"
    },
    {
        title: "Phuket Thai KDS",
        description: "Op-Special: High-fidelity Thai kitchen display with urgency logic.",
        href: "/dashboard/sandbox/phuket-kds",
        icon: ChefHat,
        status: "Active",
        color: "bg-red-600"
    },
    {
        title: "Advanced Analytics",
        description: "Sketch: Future reporting dashboard with interactive charts.",
        href: "#",
        icon: BarChart3,
        status: "Planned",
        color: "bg-blue-500"
    },
    {
        title: "Menu Management V2",
        description: "Sketch: Drag-and-drop hierarchy for menu editing.",
        href: "#",
        icon: Settings2,
        status: "Discovery",
        color: "bg-purple-500"
    }
]

export default function SandboxIndex() {
    const sideNav = (
        <div className="hidden w-64 border-r border-border-subtle bg-surface-card md:flex flex-col p-4 shadow-sm">
            <Link href="/dashboard" className="font-bold text-text-primary text-xl mb-8 pl-4">Restaurant</Link>
            <div className="space-y-2">
                <Link href="/dashboard" className="text-text-secondary hover:bg-state-hover_overlay font-medium px-4 py-2 rounded-md transition-colors block">Live Dashboard</Link>
                <div className="bg-brand-primary/10 text-brand-primary font-medium px-4 py-2 rounded-md">Lab / Sandbox</div>
            </div>
        </div>
    )

    return (
        <AppShell navigation={sideNav}>
            <div className="flex flex-col gap-6 p-6">
                <PageHeader
                    title="Design Lab & Sandbox"
                    description="Explore upcoming features and evolutionary prototypes."
                />

                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {PROTOTYPES.map((p, idx) => {
                        const Icon = p.icon
                        return (
                            <div key={idx} className="bg-surface-card border border-border-subtle rounded-xl overflow-hidden shadow-sm hover:shadow-md transition-all group">
                                <div className={`h-2 ${p.color}`} />
                                <div className="p-6">
                                    <div className="flex items-center justify-between mb-4">
                                        <div className={`p-3 rounded-lg ${p.color}/10 text-brand-primary`}>
                                            <Icon className="h-6 w-6" />
                                        </div>
                                        <span className={`text-[10px] font-bold uppercase tracking-widest px-2 py-1 rounded bg-zinc-100 dark:bg-zinc-800 text-zinc-500`}>
                                            {p.status}
                                        </span>
                                    </div>
                                    <h3 className="text-xl font-bold text-text-primary mb-2">{p.title}</h3>
                                    <p className="text-sm text-text-secondary mb-6 leading-relaxed">
                                        {p.description}
                                    </p>

                                    {p.href !== "#" ? (
                                        <Link
                                            href={p.href}
                                            className="inline-flex items-center gap-2 text-sm font-bold text-brand-primary hover:underline"
                                        >
                                            Launch Prototype →
                                        </Link>
                                    ) : (
                                        <span className="text-sm font-bold text-text-tertiary cursor-not-allowed">
                                            Coming Soon
                                        </span>
                                    )}
                                </div>
                            </div>
                        )
                    })}
                </div>

                <div className="mt-12 bg-zinc-50 dark:bg-zinc-900 rounded-2xl p-8 border border-zinc-200 dark:border-zinc-800">
                    <div className="flex items-start gap-4">
                        <div className="p-3 bg-white dark:bg-black rounded-xl shadow-sm border border-zinc-200 dark:border-zinc-800">
                            <Beaker className="h-6 w-6 text-zinc-400" />
                        </div>
                        <div>
                            <h4 className="text-lg font-bold text-text-primary mb-1">About the Sandbox</h4>
                            <p className="text-sm text-text-secondary max-w-2xl leading-relaxed">
                                Prototypes in the sandbox are evolutionary stages of the SRDA platform.
                                Some use mocked data to test interactions and layout before backend integration.
                                Feel free to "break" things here—it's isolated from production operations.
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </AppShell>
    )
}
