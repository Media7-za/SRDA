import { useEffect } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { OrderCardData } from '@restaurant-direct/ui';

export function useOrdersRealtimeBridge(restaurantId: string) {
  const queryClient = useQueryClient();

  useEffect(() => {
    if (!restaurantId) return;

    const channel = supabase
      .channel(`board_events:${restaurantId}`)
      .on(
        'postgres_changes',
        { event: 'INSERT', schema: 'public', table: 'board_events', filter: `restaurant_id=eq.${restaurantId}` },
        (response) => {
          const event = response.new as any;
          if (event.entity !== 'order') return;

          const newCardData: OrderCardData = event.payload;

          queryClient.setQueryData<OrderCardData[]>(['orders', 'board', restaurantId], (oldOrders) => {
            if (!oldOrders) return oldOrders;

            const existingIndex = oldOrders.findIndex(o => o.id === newCardData.id);

            if (existingIndex > -1) {
              const existing = oldOrders[existingIndex];

              // Skip if UI state already progressed optimistically ahead of or equal to this event
              if (existing.status === newCardData.status) {
                return oldOrders;
              }

              const newOrdersCount = [...oldOrders];
              newOrdersCount[existingIndex] = newCardData;
              return newOrdersCount;
            } else {
              // Prepend newly emitted order
              return [newCardData, ...oldOrders];
            }
          });
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [restaurantId, queryClient]);
}
