// import { useMutation, useQueryClient } from '@tanstack/react-query'
// import { updateOrderStatus } from '@/api/orders'

/**
 * Handles optimistic UI updates when moving orders across lanes.
 * Performs rollback automatically if the API call fails.
 */
export function useUpdateOrderStatusMutation() {
    // Skeleton implementation
    /*
    const queryClient = useQueryClient()
    return useMutation({
      mutationFn: updateOrderStatus,
      onMutate: async (newStatusUpdate) => {
        // 1. Cancel outgoing refetches
        await queryClient.cancelQueries({ queryKey: ['orders', 'board'] })
        // 2. Snapshot previous value
        const previousOrders = queryClient.getQueryData(['orders', 'board'])
        // 3. Optimistically update the cache
        queryClient.setQueryData(['orders', 'board'], (old: any) => {
          return old.map(order => 
            order.id === newStatusUpdate.id 
              ? { ...order, status: newStatusUpdate.status } 
              : order
          )
        })
        // 4. Return context for rollback
        return { previousOrders }
      },
      onError: (err, newStatusUpdate, context) => {
        // Rollback
        queryClient.setQueryData(['orders', 'board'], context?.previousOrders)
      },
      onSettled: () => {
        // Optionally invalidate or just let realtime sync take over
      }
    })
    */

    return {
        mutate: (args: any) => console.log('mutating', args),
        isPending: false,
    }
}
