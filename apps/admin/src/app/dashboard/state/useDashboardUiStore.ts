// import { create } from 'zustand'

export interface DashboardUiState {
    // UI toggles
    audioMuted: boolean
    audioUnlocked: boolean

    // Highlighting & focus
    selectedOrderId: string | null
    highlightedOrderIds: string[]

    // Display filtering
    activeFilters: {
        fulfillmentType?: 'delivery' | 'pickup'
        paymentState?: 'paid' | 'unpaid'
    }

    // Connection UI banner
    connectionStatus: 'connected' | 'reconnecting' | 'offline'

    // Actions
    toggleAudio: () => void
    setSelectedOrderId: (id: string | null) => void
    setConnectionStatus: (status: 'connected' | 'reconnecting' | 'offline') => void
}

/**
 * Small local Zustand store to handle transient UI state
 * unrelated to the source-of-truth order cache.
 */
export const useDashboardUiStore = () => {
    // Skeleton replacing zustand create until implementation
    return {
        audioMuted: false,
        audioUnlocked: false,
        selectedOrderId: null,
        highlightedOrderIds: [],
        activeFilters: {},
        connectionStatus: 'connected',
        toggleAudio: () => { },
        setSelectedOrderId: () => { },
        setConnectionStatus: () => { }
    }
}
