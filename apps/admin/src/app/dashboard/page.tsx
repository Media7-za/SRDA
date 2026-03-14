"use client"

import React, { useState } from "react"
import { AppShell, PageHeader, OfflineBanner, OrderCard, OrderCardData } from "@restaurant-direct/ui"
import { Wifi, Search, Filter } from "lucide-react"
import Link from "next/link"

import { useOrdersBoardQuery } from "./state/useOrdersBoardQuery"
import { useUpdateOrderStatusMutation } from "./state/useUpdateOrderStatusMutation"
import { useOrdersRealtimeBridge } from "./state/useOrdersRealtimeBridge"
import { useDashboardUiStore } from "./state/useDashboardUiStore"

// Mock tenant configuration for the frontend MVP
const RESTAURANT_ID = "mock_request_restaurant_id"

export default function Dashboard() {
    const { data: orders = [], isLoading, isError } = useOrdersBoardQuery(RESTAURANT_ID)
    const { mutate: updateOrder, isPending } = useUpdateOrderStatusMutation(RESTAURANT_ID)
    useOrdersRealtimeBridge(RESTAURANT_ID)

    const { toastMessage, connectionStatus, setConnectionStatus } = useDashboardUiStore()

    const isOffline = connectionStatus === 'offline'

    // Realtime action handling maps directly to the backend contracts
    const handleAcceptOrder = (id: string) => updateOrder({ id, status: "preparing" })
    const handleMarkReady = (id: string) => updateOrder({ id, status: "ready_for_pickup" })
    const handleAssignDriver = (id: string) => updateOrder({ id, driverId: "mock_driver_uuid" }) // Realistically opens a modal
    const handleCompletePickup = (id: string) => updateOrder({ id, status: "delivered" })

    // Top Nav placeholder
    const topNav = (
        <div className="flex h-16 items-center justify-between border-b border-border-subtle bg-surface-card px-4 md:px-8 shadow-sm">
            <div className="font-bold text-brand-primary text-xl">Platform</div>
            <div className="flex gap-4">
                <button
                    onClick={() => setConnectionStatus(isOffline ? 'connected' : 'offline')}
                    className="flex items-center gap-2 text-sm text-text-secondary"
                >
                    <Wifi className={`h-4 w-4 ${isOffline ? "text-status-failed" : "text-status-ready"}`} />
                    {isOffline ? "Offline Mode (Simulated)" : "Online"}
                </button>
            </div>
        </div>
    )

    // Empty placeholder for sidebar
    const sideNav = (
        <div className="hidden w-64 border-r border-border-subtle bg-surface-card md:flex flex-col p-4 shadow-sm">
            <div className="font-bold text-text-primary text-xl mb-8 pl-4">Restaurant</div>
            <div className="space-y-2">
                <div className="bg-brand-primary/10 text-brand-primary font-medium px-4 py-2 rounded-md transition-colors cursor-pointer">Live Dashboard</div>
                <div className="text-text-secondary hover:bg-state-hover_overlay font-medium px-4 py-2 rounded-md transition-colors cursor-pointer">Menu Management</div>
                <div className="text-text-secondary hover:bg-state-hover_overlay font-medium px-4 py-2 rounded-md transition-colors cursor-pointer">Analytics</div>
                <div className="pt-4 mt-4 border-t border-border-subtle">
                    <Link href="/dashboard/sandbox" className="text-text-tertiary hover:text-brand-primary flex items-center gap-2 font-medium px-4 py-2 rounded-md transition-colors cursor-pointer group">
                        <span className="flex h-2 w-2 rounded-full bg-orange-500 animate-pulse" />
                        Lab / Sandbox
                    </Link>
                </div>
            </div>
        </div>
    )

    if (isLoading) {
        return (
            <AppShell navigation={sideNav} topBar={topNav}>
                <div className="flex flex-col h-full items-center justify-center text-text-secondary">
                    Loading live operations board...
                </div>
            </AppShell>
        )
    }

    if (isError) {
        return (
            <AppShell navigation={sideNav} topBar={topNav}>
                <div className="flex flex-col h-full items-center justify-center text-status-failed">
                    Failed to connect to order feed. Please refresh.
                </div>
            </AppShell>
        )
    }

    const pendingOrders = orders.filter(o => o.status === "pending" || o.status === "confirmed")
    const preparingOrders = orders.filter(o => o.status === "preparing")
    const readyOrders = orders.filter(o => o.status === "ready_for_pickup" || o.status === "out_for_delivery")
    const completedOrders = orders.filter(o => o.status === "delivered" || o.status === "cancelled")

    return (
        <AppShell navigation={sideNav} topBar={topNav}>
            <div className="flex flex-col h-full gap-4 max-h-[calc(100vh-2rem)] relative">

                {/* Global Toast Layer */}
                {toastMessage && (
                    <div className="absolute bottom-4 right-4 z-50 bg-surface-card border-l-4 border-status-failed shadow-lg p-4 rounded-md">
                        <p className="font-medium text-text-primary">{toastMessage}</p>
                    </div>
                )}

                {isOffline && (
                    <OfflineBanner onRetry={() => setConnectionStatus('connected')} />
                )}

                <PageHeader
                    title="Live Operations Dashboard"
                    actions={
                        <div className="flex gap-2">
                            <button className="flex items-center p-2 rounded-md border border-border-subtle hover:bg-state-hover_overlay transition-colors">
                                <Filter className="h-4 w-4" />
                            </button>
                        </div>
                    }
                />

                {/* Dashboard Grid */}
                <div className="grid flex-1 grid-cols-1 gap-6 md:grid-cols-2 xl:grid-cols-4 overflow-hidden">

                    {/* Pending Lane */}
                    <div className="flex flex-col rounded-lg bg-surface-background/50 border border-border-subtle">
                        <div className="flex items-center justify-between border-b border-border-subtle bg-surface-card p-4 rounded-t-lg">
                            <h2 className="font-bold text-text-primary flex items-center gap-2">
                                Pending
                                {pendingOrders.length > 0 && <span className="flex h-5 w-5 items-center justify-center rounded-full bg-status-pending text-xs text-text-inverse">{pendingOrders.length}</span>}
                            </h2>
                        </div>
                        <div className="flex-1 overflow-y-auto p-4 space-y-4">
                            {pendingOrders.map(order => (
                                <OrderCard
                                    key={order.id}
                                    data={order}
                                    primaryActionLabel="Accept Order"
                                    onPrimaryAction={handleAcceptOrder}
                                    state={isOffline ? "offline" : undefined}
                                />
                            ))}
                        </div>
                    </div>

                    {/* Preparing Lane */}
                    <div className="flex flex-col rounded-lg bg-surface-background/50 border border-border-subtle">
                        <div className="flex items-center justify-between border-b border-border-subtle bg-surface-card p-4 rounded-t-lg">
                            <h2 className="font-bold text-text-primary flex items-center gap-2">
                                Preparing
                                {preparingOrders.length > 0 && <span className="flex h-5 w-5 items-center justify-center rounded-full bg-status-preparing text-xs text-text-inverse">{preparingOrders.length}</span>}
                            </h2>
                        </div>
                        <div className="flex-1 overflow-y-auto p-4 space-y-4">
                            {preparingOrders.map(order => (
                                <OrderCard
                                    key={order.id}
                                    data={order}
                                    primaryActionLabel="Mark Ready"
                                    onPrimaryAction={handleMarkReady}
                                    state={isOffline ? "offline" : undefined}
                                />
                            ))}
                        </div>
                    </div>

                    {/* Ready Lane */}
                    <div className="flex flex-col rounded-lg bg-surface-background/50 border border-border-subtle overflow-hidden">
                        <div className="flex items-center justify-between border-b border-border-subtle bg-surface-card p-4 rounded-t-lg">
                            <h2 className="font-bold text-text-primary flex items-center gap-2">
                                Ready / Dispatched
                                {readyOrders.length > 0 && <span className="flex h-5 w-5 items-center justify-center rounded-full bg-status-ready text-xs text-text-inverse">{readyOrders.length}</span>}
                            </h2>
                        </div>
                        <div className="flex-1 overflow-y-auto p-4 space-y-4">
                            {readyOrders.map(order => {
                                const isDelivery = order.fulfillmentType === 'delivery';
                                const needsDriver = isDelivery && order.status === 'ready_for_pickup';

                                return (
                                    <OrderCard
                                        key={order.id}
                                        data={order}
                                        primaryActionLabel={needsDriver ? "Assign Driver" : (!isDelivery ? "Complete Pickup" : "Track Driver")}
                                        onPrimaryAction={needsDriver ? handleAssignDriver : (!isDelivery ? handleCompletePickup : undefined)}
                                        state={isOffline ? "offline" : undefined}
                                    />
                                )
                            })}
                        </div>
                    </div>

                    {/* Completed Lane */}
                    <div className="flex flex-col rounded-lg bg-surface-background/50 border border-border-subtle">
                        <div className="flex items-center justify-between border-b border-border-subtle bg-surface-card p-4 rounded-t-lg opacity-75">
                            <h2 className="font-bold text-text-primary flex items-center gap-2">
                                Completed
                            </h2>
                        </div>
                        <div className="flex-1 overflow-y-auto p-4 space-y-4">
                            {completedOrders.length === 0 ? (
                                <div className="flex flex-col items-center justify-center h-full text-text-secondary p-4 text-center">
                                    <div className="p-3 rounded-full bg-surface-card shadow-sm border border-border-subtle mb-3">
                                        <Search className="h-5 w-5 opacity-50" />
                                    </div>
                                    <p className="font-medium text-sm">No recent completions</p>
                                    <p className="text-xs opacity-75 mt-1">Orders completed in the last hour will appear here</p>
                                </div>
                            ) : (
                                completedOrders.map(order => (
                                    <OrderCard
                                        key={order.id}
                                        data={order}
                                        state="default"
                                    />
                                ))
                            )}
                        </div>
                    </div>

                </div>
            </div>
        </AppShell>
    )
}
