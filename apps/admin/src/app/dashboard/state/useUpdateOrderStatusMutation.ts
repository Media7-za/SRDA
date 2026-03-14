import { useMutation, useQueryClient } from '@tanstack/react-query';
import { OrderCardData } from '@restaurant-direct/ui';
import { useDashboardUiStore } from './useDashboardUiStore';

async function updateOrderStatusApi(id: string, status: string): Promise<OrderCardData> {
  const res = await fetch(`http://localhost:3001/api/orders/${id}/status`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ status })
  });
  const json = await res.json();
  if (!res.ok || !json.success) throw new Error(json.error || `HTTP ${res.status}`);
  return json.data;
}

async function assignDriverApi(id: string, driverId: string): Promise<OrderCardData> {
  const res = await fetch(`http://localhost:3001/api/orders/${id}/assign-driver`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ driverId })
  });
  const json = await res.json();
  if (!res.ok || !json.success) throw new Error(json.error || `HTTP ${res.status}`);
  return json.data;
}

export function useUpdateOrderStatusMutation(restaurantId: string) {
  const queryClient = useQueryClient();
  const { setToast } = useDashboardUiStore();

  return useMutation({
    mutationFn: ({ id, status, driverId }: { id: string, status?: string, driverId?: string }) => {
      if (driverId) return assignDriverApi(id, driverId);
      if (status) return updateOrderStatusApi(id, status);
      throw new Error('No mutation payload provided');
    },
    onMutate: async (newStatusUpdate) => {
      const queryKey = ['orders', 'board', restaurantId];
      await queryClient.cancelQueries({ queryKey });

      const previousOrders = queryClient.getQueryData<OrderCardData[]>(queryKey);

      queryClient.setQueryData<OrderCardData[]>(queryKey, (old) => {
        if (!old) return old;
        return old.map(order => {
          if (order.id !== newStatusUpdate.id) return order;

          // Apply optimistic updates
          const updated = { ...order };
          if (newStatusUpdate.status) updated.status = newStatusUpdate.status as any;
          // Mock driver assignment
          if (newStatusUpdate.driverId) {
            updated.assignedDriverName = 'Assigning driver...';
            if (updated.status === 'ready_for_pickup') {
              updated.status = 'out_for_delivery';
            }
          }
          return updated;
        });
      });

      return { previousOrders, queryKey };
    },
    onError: (err: any, _, context) => {
      console.error("Optimistic mutation failed! Reverting back:", err);
      if (context?.previousOrders) {
        queryClient.setQueryData(context.queryKey, context.previousOrders);
      }

      // Map standard errors to user-friendly toasts
      const msg = err.message.toLowerCase();
      if (msg.includes('already complete') || msg.includes('409')) {
        setToast("This order was already updated by another associate.");
      } else if (msg.includes('422') || msg.includes('driver')) {
        setToast("Please assign a driver first.");
      } else if (msg.includes('404') || msg.includes('410')) {
        setToast("Order was cancelled by the customer.");
      } else {
        setToast(`Failed to update order: ${err.message}`);
      }
    },
    onSettled: (data) => {
      // Once the server returns the authoritative response, push that into the cache to sync.
      // (If the realtime bridge gets it first, dedupe handles it.)
      if (data) {
        queryClient.setQueryData(['orders', 'board', restaurantId], (old: OrderCardData[] | undefined) => {
          if (!old) return old;
          return old.map(order => order.id === data.id ? data : order);
        });
      }
    }
  });
}
