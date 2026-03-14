import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_notifier.dart';
import '../../core/state/driver_status_notifier.dart';
import '../../shared/models/delivery.dart';
import '../delivery/delivery_repository.dart';

/// Home screen — first screen after login.
///
/// Shows online/offline toggle + active delivery card.
/// PRD_Driver.md §5
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Delivery? _activeDelivery;
  bool _isFetchingDelivery = false;

  @override
  void initState() {
    super.initState();
    // Fetch active delivery on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchActiveDelivery();
    });
  }

  Future<void> _fetchActiveDelivery() async {
    final authState = ref.read(authNotifierProvider);
    if (authState is! Authenticated) return;

    setState(() => _isFetchingDelivery = true);
    try {
      final repo = ref.read(deliveryRepositoryProvider);
      final delivery = await repo.getActiveDelivery(authState.driverId);
      if (mounted) {
        setState(() {
          _activeDelivery = delivery;
          _isFetchingDelivery = false;
        });
        // Update global state
        ref.read(driverStatusProvider.notifier).setHasActiveDelivery(delivery != null);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingDelivery = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final driverStatus = ref.watch(driverStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchActiveDelivery,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchActiveDelivery,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Online/Offline Toggle — uses DriverStatusNotifier, NOT setState
            _OnlineStatusToggle(status: driverStatus),
            const SizedBox(height: 24),

            // Error banner (e.g., "Cannot go offline with active delivery")
            if (driverStatus.error != null) ...[
              _ErrorBanner(
                message: driverStatus.error!,
                onDismiss: () => ref.read(driverStatusProvider.notifier).clearError(),
              ),
              const SizedBox(height: 16),
            ],

            const Text(
              'Active Delivery',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Active Delivery Card — data from API
            if (_isFetchingDelivery)
              const Center(child: CircularProgressIndicator())
            else if (_activeDelivery != null)
              _ActiveDeliveryCard(delivery: _activeDelivery!)
            else
              _NoActiveDeliveryCard(),
          ],
        ),
      ),
    );
  }
}

/// Online/Offline toggle — backed by [DriverStatusNotifier].
///
/// PRD §5: Calls PATCH /api/drivers/:id/status.
/// State comes from server, NOT local toggle.
class _OnlineStatusToggle extends ConsumerWidget {
  final DriverStatusState status;
  const _OnlineStatusToggle({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      color: status.isOnline
          ? Colors.green.withOpacity(0.1)
          : Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  status.isOnline ? Icons.circle : Icons.circle_outlined,
                  color: status.isOnline ? Colors.green : Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 12),
                Text(
                  status.isOnline ? 'ONLINE' : 'OFFLINE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: status.isOnline ? Colors.green : Colors.grey[700],
                  ),
                ),
              ],
            ),
            status.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Switch(
                    value: status.isOnline,
                    onChanged: (_) =>
                        ref.read(driverStatusProvider.notifier).toggleStatus(),
                    activeColor: Colors.green,
                  ),
          ],
        ),
      ),
    );
  }
}

/// Active delivery card — shows real data from GET /api/drivers/:id/deliveries/active.
class _ActiveDeliveryCard extends StatelessWidget {
  final Delivery delivery;
  const _ActiveDeliveryCard({required this.delivery});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${delivery.orderShortId}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    delivery.status.displayLabel,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    delivery.dropoffAddress,
                    style: const TextStyle(color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/delivery/${delivery.id}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('View Delivery →'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when no active delivery exists.
/// PRD §5: "No active delivery. You're ready for the next job."
class _NoActiveDeliveryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No active delivery',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "You're ready for the next job.",
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dismissible error banner for status toggle failures.
class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.red)),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.red),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
