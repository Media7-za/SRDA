import { useQuery } from '@tanstack/react-query';
import { OrderCardData } from '@restaurant-direct/ui';

async function fetchBoard(restaurantId: string): Promise<OrderCardData[]> {
  const res = await fetch(`http://localhost:3001/api/orders/board?restaurant_id=${restaurantId}`);
  if (!res.ok) {
    throw new Error('Failed to fetch board data');
  }
  const json = await res.json();
  if (!json.success) throw new Error(json.error);
  return json.data.orders;
}

/**
 * React Query hook for the initial dashboard fetch.
 * Acts as the source of truth for the board, before realtime patches.
 */
export function useOrdersBoardQuery(restaurantId: string) {
  return useQuery({
    queryKey: ['orders', 'board', restaurantId],
    queryFn: () => fetchBoard(restaurantId),
    // Poll every 60 seconds as a safety net in case WebSocket drops
    refetchInterval: 1000 * 60,
  });
}
