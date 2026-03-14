"use client"

import React from "react"
import { cn } from "@restaurant-direct/ui"
import { PhuketOrder } from "../../_mocks/phuket-orders"

// --- Components ---

export const KDSHeader = ({ restaurantName, time, isConnected }: { restaurantName: string, time: string, isConnected: boolean }) => (
    <header className="flex justify-between items-center p-4 bg-[#1a202c] border-b border-white/5">
        <div className="flex flex-col">
            <h1 className="text-2xl font-black text-white tracking-tighter uppercase leading-none">Kitchen Queue - Live</h1>
            <span className="text-brand-gold font-bold text-xs uppercase tracking-widest mt-1">'{restaurantName}'</span>
        </div>
        <div className="flex items-center gap-6">
            <span className="text-2xl font-mono font-bold text-white tabular-nums tracking-wider">{time}</span>
            <span className={cn(
                "flex items-center gap-2 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest",
                isConnected ? "bg-green-500/10 text-green-500 border border-green-500/20" : "bg-red-500/10 text-red-500 border border-red-500/20"
            )}>
                <span className={cn("w-2 h-2 rounded-full animate-pulse", isConnected ? "bg-green-500" : "bg-red-500")} />
                {isConnected ? "Server Connected" : "Connection Error"}
            </span>
        </div>
    </header>
)

export const AlertBanner = ({ message, count }: { message: string, count: number }) => (
    <div className="bg-red-600/10 border-y border-red-600/20 p-2 flex items-center justify-center gap-3">
        <span className="flex items-center gap-2 text-red-500 text-xs font-black uppercase tracking-widest">
            <span className="relative flex h-3 w-3">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-3 w-3 bg-red-500"></span>
            </span>
            {message} - {count} Active Orders
        </span>
    </div>
)

export const KitchenCard = ({ order, onAction }: { order: PhuketOrder, onAction: (id: string) => void }) => {
    const isLate = order.isLate;

    return (
        <div className={cn(
            "bg-[#1e2533] rounded-lg p-4 mb-4 border-l-[6px] transition-all hover:translate-x-1 shadow-xl relative overflow-hidden",
            order.laneAccent === 'border-gold' && "border-l-[#FBBC05]",
            order.laneAccent === 'border-orange' && "border-l-[#E36414]",
            order.laneAccent === 'border-green' && "border-l-[#4CAF50]",
            order.laneAccent === 'border-blue' && "border-l-[#2196F3]",
            order.laneAccent === 'border-red' && "border-l-[#D32F2F] bg-[#2d1a1a]"
        )}>
            <div className="flex justify-between items-start mb-3">
                <div className="flex items-center gap-2">
                    <span className="text-xl font-black text-white">#{order.shortId}</span>
                    {isLate && <span className="text-[10px] font-black text-red-500 bg-red-500/10 px-1.5 py-0.5 rounded animate-pulse">(LATE)</span>}
                </div>
                <div className="text-right">
                    <span className="text-xs font-bold text-white/40 uppercase tabular-nums">{order.minutesElapsed}m ago</span>
                    <div className="text-[10px] font-black text-brand-gold uppercase tracking-tight">{order.customerName}</div>
                </div>
            </div>

            {order.progress !== undefined && (
                <div className="h-1.5 bg-black/40 rounded-full mb-4 overflow-hidden">
                    <div
                        className="h-full bg-[#4CAF50] transition-all duration-1000"
                        style={{ width: `${order.progress}%` }}
                    />
                </div>
            )}

            <ul className="space-y-2 mb-4">
                {order.items.map(item => (
                    <li key={item.id} className="group">
                        <div className="flex gap-2">
                            <span className="text-lg font-bold text-white leading-tight">
                                <span className="text-brand-gold mr-2">{item.quantity}x</span>
                                {item.name}
                            </span>
                        </div>
                        {item.modifiers && item.modifiers.map((mod, i) => (
                            <div key={i} className="text-xs font-black text-red-400 uppercase ml-8 mt-1 border-l border-red-900/50 pl-2">
                                + {mod}
                            </div>
                        ))}
                    </li>
                ))}
            </ul>

            <button
                onClick={() => onAction(order.id)}
                className={cn(
                    "w-full py-4 rounded-md font-black uppercase text-sm tracking-widest transition-all active:scale-[0.97] shadow-lg",
                    order.status === 'new' && "bg-[#FBBC05] text-black hover:bg-[#ffcc33]",
                    order.status === 'accepted' && "bg-[#2196F3] text-white hover:bg-[#42a5f5]",
                    order.status === 'preparing' && "bg-[#2196F3] text-white hover:bg-[#42a5f5]",
                    order.status === 'ready' && "bg-[#add8e6] text-black hover:bg-white"
                )}
            >
                {order.status === 'new' ? 'Accept' :
                    order.status === 'accepted' ? 'Start Prep' :
                        order.status === 'preparing' ? 'Mark Ready' : 'Bump'}
            </button>
        </div>
    )
}

export const OperationalLane = ({ title, count, children, colorClass }: { title: string, count: number, children: React.ReactNode, colorClass?: string }) => (
    <section className="flex flex-col h-full bg-white/[0.03] rounded-xl p-3 border border-white/5">
        <div className="flex items-center justify-between mb-4 px-2">
            <h2 className={cn("text-sm font-black uppercase tracking-widest", colorClass || "text-white/60")}>
                {title}
            </h2>
            <span className="text-xs font-black bg-white/10 text-white/50 px-2 py-0.5 rounded-full">{count}</span>
        </div>
        <div className="flex-1 overflow-y-auto custom-scrollbar pr-1">
            {children}
        </div>
    </section>
)
