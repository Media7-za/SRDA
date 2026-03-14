import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'earnings_notifier.dart';

/// Earnings summary screen — only visible when earnings_enabled = true.
///
/// PRD_Driver.md §9: Shows week/month totals and recent earnings list.
/// PRD_Driver.md §15 Invariant #8: Screen is HIDDEN (not disabled) when
/// earnings are disabled for the tenant.
class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(earningsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, EarningsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.recentHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(earningsNotifierProvider.notifier).loadAll(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
          ref.read(earningsNotifierProvider.notifier).loadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () =>
            ref.read(earningsNotifierProvider.notifier).loadAll(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary cards
            _SummaryCard(
              label: 'This Week',
              total: state.weekTotal,
              deliveryCount: state.deliveryCount,
            ),
            const SizedBox(height: 12),
            _SummaryCard(
              label: 'This Month',
              total: state.monthTotal,
            ),
            const SizedBox(height: 24),

            // Recent history header
            const Text(
              'Recent',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Earnings list
            if (state.recentHistory.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Center(
                  child: Text(
                    'No earnings recorded yet',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              )
            else
              ...state.recentHistory.map(
                (record) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(
                      'Order #${record.orderShortId}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      _formatDate(record.completedAt),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    trailing: Text(
                      'R${record.fee.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ),

            // Loading more indicator
            if (state.isLoadingMore)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
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

/// Summary card showing totals.
class _SummaryCard extends StatelessWidget {
  final String label;
  final double total;
  final int? deliveryCount;

  const _SummaryCard({
    required this.label,
    required this.total,
    this.deliveryCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.orange.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'R${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (deliveryCount != null)
              Column(
                children: [
                  Text(
                    '$deliveryCount',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    'deliveries',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
