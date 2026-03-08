// import { useQuery } from '@tanstack/react-query'
// import { fetchOrders } from '@/api/orders'

/**
 * React Query hook for the initial dashboard fetch.
 * Acts as the source of truth for the board, before realtime patches.
 */
export function useOrdersBoardQuery() {
    // Skeleton implementation
    /*
    return useQuery({
      queryKey: ['orders', 'board'],
      queryFn: fetchOrders,
      staleTime: 1000 * 60 * 5, // 5 minutes
    })
    */

    return {
        data: [],
        isLoading: false,
        isError: false,
    }
}
