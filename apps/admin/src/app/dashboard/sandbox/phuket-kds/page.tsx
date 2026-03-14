"use client"

import React, { useState, useEffect } from "react"
import { AppShell } from "@restaurant-direct/ui"
import { PhuketOrder, MOCK_PHUKET_ORDERS, PhuketStatus } from "../_mocks/phuket-orders"
import { KDSHeader, AlertBanner, KitchenCard, OperationalLane } from "./components/PhuketKDS"

export default function PhuketKDSPrototype() {
    const [orders, setOrders] = useState<PhuketOrder[]>(MOCK_PHUKET_ORDERS)
    const [time, setTime] = useState("18:42:15")
    const [isPressureMode, setIsPressureMode] = useState(true)

    // Simulate clock
    useEffect(() => {
        const timer = setInterval(() => {
            const now = new Date()
            setTime(now.toLocaleTimeString('en-GB', { hour12: false }))
        }, 1000)
        return () => clearInterval(timer)
    }, [])

    const handleAction = (id: string) => {
        const order = orders.find(o => o.id === id);
        if (!order) return;

        if (order.status === 'ready') {
            // Bump logic (remove)
            setOrders(prev => prev.filter(o => o.id !== id))
        } else {
            // Transition logic
            setOrders(prev => prev.map(o => {
                if (o.id !== id) return o;

                let nextStatus: PhuketStatus = o.status;
                let nextAccent = o.laneAccent;

                if (o.status === 'new') {
                    nextStatus = 'accepted';
                    nextAccent = 'border-orange';
                } else if (o.status === 'accepted') {
                    nextStatus = 'preparing';
                    nextAccent = 'border-green';
                } else if (o.status === 'preparing') {
                    nextStatus = 'ready';
                    nextAccent = 'border-blue';
                }

                return { ...o, status: nextStatus, laneAccent: nextAccent, progress: nextStatus === 'preparing' ? 0 : undefined }
            }))
        }
    }

    // Simulate progress for preparing orders
    useEffect(() => {
        const interval = setInterval(() => {
            setOrders(prev => prev.map(o => {
                if (o.status === 'preparing' && o.progress !== undefined && o.progress < 100) {
                    return { ...o, progress: Math.min(100, o.progress + 5) }
                }
                return o;
            }))
        }, 3000)
        return () => clearInterval(interval)
    }, [])

    return (
        <div className="min-h-screen bg-[#121826] flex flex-col font-sans selection:bg-brand-gold selection:text-black">
            <KDSHeader
                restaurantName="Phuket Thai"
                time={time}
                isConnected={true}
            />

            {isPressureMode && (
                <AlertBanner
                    message="Kitchen Under Pressure"
                    count={orders.length + 15}
                />
            )}

            <main className="flex-1 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 p-4 overflow-hidden h-[calc(100vh-120px)]">
                <OperationalLane
                    title="New"
                    count={orders.filter(o => o.status === 'new').length}
                    colorClass="text-[#FBBC05]"
                >
                    {orders.filter(o => o.status === 'new').map(order => (
                        <KitchenCard key={order.id} order={order} onAction={handleAction} />
                    ))}
                </OperationalLane>

                <OperationalLane
                    title="Accepted"
                    count={orders.filter(o => o.status === 'accepted').length}
                    colorClass="text-[#E36414]"
                >
                    {orders.filter(o => o.status === 'accepted').map(order => (
                        <KitchenCard key={order.id} order={order} onAction={handleAction} />
                    ))}
                </OperationalLane>

                <OperationalLane
                    title="Preparing"
                    count={orders.filter(o => o.status === 'preparing').length}
                    colorClass="text-[#4CAF50]"
                >
                    {orders.filter(o => o.status === 'preparing').map(order => (
                        <KitchenCard key={order.id} order={order} onAction={handleAction} />
                    ))}
                </OperationalLane>

                <OperationalLane
                    title="Ready"
                    count={orders.filter(o => o.status === 'ready').length}
                    colorClass="text-[#2196F3]"
                >
                    {orders.filter(o => o.status === 'ready').map(order => (
                        <KitchenCard key={order.id} order={order} onAction={handleAction} />
                    ))}
                </OperationalLane>
            </main>

            {/* Hidden toggle for simulation purposes */}
            <div className="fixed bottom-4 right-4 opacity-0 hover:opacity-100 transition-opacity">
                <button
                    onClick={() => setIsPressureMode(!isPressureMode)}
                    className="bg-white/10 text-white p-2 rounded text-[10px] font-black uppercase"
                >
                    Toggle Pressure
                </button>
            </div>

            <style jsx global>{`
                .custom-scrollbar::-webkit-scrollbar {
                    width: 4px;
                }
                .custom-scrollbar::-webkit-scrollbar-track {
                    background: transparent;
                }
                .custom-scrollbar::-webkit-scrollbar-thumb {
                    background: rgba(255, 255, 255, 0.1);
                    border-radius: 10px;
                }
                .custom-scrollbar::-webkit-scrollbar-thumb:hover {
                    background: rgba(255, 255, 255, 0.2);
                }
            `}</style>
        </div>
    )
}
