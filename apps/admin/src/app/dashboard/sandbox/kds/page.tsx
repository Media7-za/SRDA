"use client"

import React, { useState, useEffect } from "react"
import { AppShell, cn } from "@restaurant-direct/ui"
import { Clock, CheckCircle2, AlertCircle, ChevronLeft } from "lucide-react"
import Link from "next/link"
import { MOCK_KDS_ORDERS, KDSOrder } from "../_mocks/kds-orders"

export default function KDSPrototype() {
    const [orders, setOrders] = useState<KDSOrder[]>(MOCK_KDS_ORDERS)

    // Simulate timers ticking up
    useEffect(() => {
        const interval = setInterval(() => {
            setOrders(prev => prev.map(order => ({
                ...order,
                minutesElapsed: order.minutesElapsed + 1,
                isUrgent: order.minutesElapsed + 1 > 15
            })))
        }, 60000) // Update every minute for prototype
        return () => clearInterval(interval)
    }, [])

    const handleBump = (id: string) => {
        setOrders(prev => prev.filter(o => o.id !== id))
    }

    const sideNav = (
        <div className="flex w-64 border-r border-zinc-800 bg-zinc-950 flex-col p-4 shadow-sm text-zinc-400">
            <Link href="/dashboard" className="flex items-center gap-2 hover:text-white transition-colors mb-8 pl-2">
                <ChevronLeft className="h-4 w-4" />
                <span>Back to Dashboard</span>
            </Link>
            <div className="font-bold text-white text-xl mb-8 pl-4 uppercase tracking-widest">KDS LAB</div>
            <div className="space-y-2">
                <div className="bg-orange-600/20 text-orange-500 font-medium px-4 py-2 rounded-md">Live Station</div>
                <div className="hover:bg-zinc-900 font-medium px-4 py-2 rounded-md transition-colors cursor-pointer">History</div>
                <div className="hover:bg-zinc-900 font-medium px-4 py-2 rounded-md transition-colors cursor-pointer">Settings</div>
            </div>
        </div>
    )

    return (
        <AppShell navigation={sideNav}>
            <div className="min-h-screen bg-zinc-950 p-6">
                <div className="flex items-center justify-between mb-8">
                    <div>
                        <h1 className="text-3xl font-black text-white uppercase tracking-tighter">Kitchen Display System</h1>
                        <p className="text-zinc-500 font-medium">Station: Main Hotline</p>
                    </div>
                    <div className="flex gap-4">
                        <div className="bg-zinc-900 border border-zinc-800 rounded-lg px-6 py-3 text-center">
                            <p className="text-xs text-zinc-500 uppercase font-bold">In Queue</p>
                            <p className="text-2xl font-black text-white">{orders.length}</p>
                        </div>
                        <div className="bg-zinc-900 border border-zinc-800 rounded-lg px-6 py-3 text-center">
                            <p className="text-xs text-zinc-500 uppercase font-bold">Avg. Prep</p>
                            <p className="text-2xl font-black text-orange-500">14m</p>
                        </div>
                    </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                    {orders.map(order => (
                        <div
                            key={order.id}
                            className={cn(
                                "flex flex-col bg-zinc-900 border-2 rounded-xl overflow-hidden shadow-2xl transition-all",
                                order.isUrgent ? "border-red-600 ring-4 ring-red-600/20" : "border-zinc-800"
                            )}
                        >
                            {/* Header */}
                            <div className={cn(
                                "p-4 flex justify-between items-center",
                                order.isUrgent ? "bg-red-600" : (order.fulfillmentType === 'delivery' ? "bg-orange-600" : "bg-blue-600")
                            )}>
                                <span className="font-black text-xl text-white">#{order.shortId}</span>
                                <div className="flex items-center gap-2 bg-black/20 px-3 py-1 rounded-full">
                                    <Clock className="h-4 w-4 text-white" />
                                    <span className="font-bold text-white leading-none">{order.minutesElapsed}m</span>
                                </div>
                            </div>

                            {/* Items */}
                            <div className="flex-1 p-5 space-y-4">
                                {order.items.map(item => (
                                    <div key={item.id} className="border-b border-zinc-800 pb-3 last:border-0">
                                        <div className="flex justify-between items-start">
                                            <span className="text-2xl font-black text-white leading-tight">
                                                <span className="text-orange-500 mr-2">{item.quantity}x</span>
                                                {item.name}
                                            </span>
                                        </div>
                                        {item.modifiers && item.modifiers.length > 0 && (
                                            <div className="mt-2 flex flex-wrap gap-2">
                                                {item.modifiers.map((mod, idx) => (
                                                    <span key={idx} className="bg-zinc-800 text-red-400 text-sm font-black px-2 py-0.5 rounded border border-red-900/50 uppercase">
                                                        {mod}
                                                    </span>
                                                ))}
                                            </div>
                                        )}
                                    </div>
                                ))}
                            </div>

                            {/* Action Area */}
                            <button
                                onClick={() => handleBump(order.id)}
                                className="w-full bg-zinc-800 hover:bg-green-600 text-zinc-400 hover:text-white py-6 flex items-center justify-center gap-3 transition-all active:scale-95 group"
                            >
                                <CheckCircle2 className="h-8 w-8 group-hover:scale-110 transition-transform" />
                                <span className="text-2xl font-black uppercase tracking-tight">Bump Order</span>
                            </button>
                        </div>
                    ))}

                    {orders.length === 0 && (
                        <div className="col-span-full py-32 flex flex-col items-center justify-center border-4 border-dashed border-zinc-800 rounded-3xl">
                            <AlertCircle className="h-16 w-16 text-zinc-700 mb-4" />
                            <p className="text-3xl font-black text-zinc-700 uppercase">Board is Clear</p>
                            <p className="text-zinc-600 font-bold mt-2">Standing by for new orders...</p>
                        </div>
                    )}
                </div>
            </div>
        </AppShell>
    )
}
