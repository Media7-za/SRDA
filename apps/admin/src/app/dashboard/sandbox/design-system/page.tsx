import Link from "next/link"

import {
    AppShell,
    Card,
    EmptyState,
    ErrorState,
    PageHeader,
    PrimaryButton,
    SecondaryButton,
    SkeletonLoader,
    StatusBadge
} from "@restaurant-direct/ui"

export default function DesignSystemPrimitivesPage() {
    const sideNav = (
        <div className="hidden w-64 border-r border-border-subtle bg-surface-card md:flex flex-col p-4 shadow-sm">
            <Link href="/dashboard" className="font-bold text-text-primary text-xl mb-8 pl-4">Restaurant</Link>
            <div className="space-y-2">
                <Link href="/dashboard" className="text-text-secondary hover:bg-state-hover_overlay font-medium px-4 py-2 rounded-md transition-colors block">Live Dashboard</Link>
                <Link href="/dashboard/sandbox" className="text-text-secondary hover:bg-state-hover_overlay font-medium px-4 py-2 rounded-md transition-colors block">Lab / Sandbox</Link>
                <div className="bg-brand-primary/10 text-brand-primary font-medium px-4 py-2 rounded-md">Design System</div>
            </div>
        </div>
    )

    return (
        <AppShell navigation={sideNav}>
            <main className="min-h-screen bg-slate-50 p-6 sm:p-8">
                <div className="mx-auto max-w-5xl space-y-8">
                    <PageHeader
                        title="Design System Primitives"
                        subtitle="Foundational components that are safe to build before domain logic is finalized."
                        actions={
                            <>
                                <SecondaryButton>Secondary</SecondaryButton>
                                <PrimaryButton>Primary</PrimaryButton>
                            </>
                        }
                    />

                    <div className="grid gap-6 lg:grid-cols-2">
                        <Card>
                            <h2 className="mb-4 text-lg font-semibold text-slate-900">Buttons and badges</h2>
                            <div className="flex flex-wrap gap-3">
                                <PrimaryButton size="sm">Save</PrimaryButton>
                                <PrimaryButton loading>Saving</PrimaryButton>
                                <SecondaryButton>Cancel</SecondaryButton>
                                <StatusBadge tone="neutral">Draft</StatusBadge>
                                <StatusBadge tone="info">Queued</StatusBadge>
                                <StatusBadge tone="success">Ready</StatusBadge>
                                <StatusBadge tone="warning">Pending</StatusBadge>
                                <StatusBadge tone="danger">Failed</StatusBadge>
                            </div>
                        </Card>

                        <SkeletonLoader lines={4} showAvatar />

                        <EmptyState
                            title="No orders yet"
                            description="When new orders arrive, they will appear here."
                            action={<PrimaryButton>Create order</PrimaryButton>}
                        />

                        <ErrorState action={<SecondaryButton>Retry</SecondaryButton>} />
                    </div>
                </div>
            </main>
        </AppShell>
    )
}
