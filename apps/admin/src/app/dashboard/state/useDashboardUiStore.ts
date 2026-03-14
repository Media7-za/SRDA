import { create } from 'zustand';

export interface DashboardUiState {
    // UI toggles
    audioMuted: boolean;
    audioUnlocked: boolean;

    // Highlighting & focus
    selectedOrderId: string | null;
    highlightedOrderIds: string[];

    // Display filtering
    activeFilters: {
        fulfillmentType?: 'delivery' | 'pickup';
        paymentState?: 'paid' | 'unpaid';
    };

    // Connection UI banner
    connectionStatus: 'connected' | 'reconnecting' | 'offline';

    // Simple toast store state
    toastMessage: string | null;

    // Actions
    toggleAudio: () => void;
    setSelectedOrderId: (id: string | null) => void;
    setConnectionStatus: (status: 'connected' | 'reconnecting' | 'offline') => void;
    setToast: (msg: string | null) => void;
}

export const useDashboardUiStore = create<DashboardUiState>((set) => ({
    audioMuted: false,
    audioUnlocked: false,
    selectedOrderId: null,
    highlightedOrderIds: [],
    activeFilters: {},
    connectionStatus: 'connected',
    toastMessage: null,

    toggleAudio: () => set((state) => ({ audioMuted: !state.audioMuted, audioUnlocked: true })),
    setSelectedOrderId: (id) => set({ selectedOrderId: id }),
    setConnectionStatus: (status) => set({ connectionStatus: status }),
    setToast: (msg) => {
        set({ toastMessage: msg });
        if (msg) {
            setTimeout(() => set({ toastMessage: null }), 4000);
        }
    }
}));
