import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/delivery_status.dart';
import 'history_notifier.dart';

/// Delivery history screen — scrollable list of past deliveries.
///
/// PRD_Driver.md §8: Paginated, 20 items per page, infinite scroll.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Delivery History')),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, HistoryState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.deliveries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(historyNotifierProvider.notifier).loadInitial(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.deliveries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No delivery history yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Infinite scroll: load more when near bottom
        if (notification is ScrollEndNotification &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
          ref.read(historyNotifierProvider.notifier).loadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () =>
            ref.read(historyNotifierProvider.notifier).loadInitial(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.deliveries.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.deliveries.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final delivery = state.deliveries[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(
                  'Order #${delivery.orderShortId}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      delivery.dropoffAddress,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    if (delivery.createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(delivery.createdAt!),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: delivery.status == DeliveryStatus.delivered
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    delivery.status.displayLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: delivery.status == DeliveryStatus.delivered
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }
}
