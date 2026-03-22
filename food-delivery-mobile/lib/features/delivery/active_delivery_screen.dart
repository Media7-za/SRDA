import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/state/location_providers.dart';
import '../../shared/models/delivery.dart';
import '../../shared/widgets/delivery_map_widget.dart';
import '../../shared/widgets/status_badge.dart';
import 'delivery_notifier.dart';

/// Active Delivery Screen — core operational screen for drivers.
/// 
/// PRD_Driver.md §7: Shows map, route, status actions, order summary.
/// PRD_Driver.md §12: No optimistic UI — waits for API confirmation.
class ActiveDeliveryScreen extends ConsumerWidget {
  final String deliveryId;
  const ActiveDeliveryScreen({super.key, required this.deliveryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch real delivery data from notifier
    final deliveryState = ref.watch(deliveryNotifierProvider(deliveryId));
    
    // Watch current position for map updates
    final positionAsync = ref.watch(currentPositionProvider);

    if (deliveryState.isLoading && deliveryState.delivery == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (deliveryState.error != null && deliveryState.delivery == null) {
      return Scaffold(
        body: Center(child: Text('Error: ${deliveryState.error}')),
      );
    }

    final delivery = deliveryState.delivery;
    if (delivery == null) {
      return const Scaffold(
        body: Center(child: Text('Delivery not found')),
      );
    }
    
    return _DeliveryContent(
      delivery: delivery,
      positionAsync: positionAsync,
      deliveryId: deliveryId,
    );
  }
}

/// Content widget for ActiveDeliveryScreen.
class _DeliveryContent extends ConsumerWidget {
  final Delivery delivery;
  final AsyncValue<Position?> positionAsync;
  final String deliveryId;

  const _DeliveryContent({
    required this.delivery,
    required this.positionAsync,
    required this.deliveryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPosition = positionAsync.value;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${delivery.orderId}'),
        actions: [
          StatusBadge(status: delivery.status),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Map Viewport (2/3 of screen)
          Expanded(
            flex: 2,
            child: positionAsync.isLoading
                ? const Center(child: CircularProgressIndicator())
                : positionAsync.hasError
                    ? const Center(child: Text('Location unavailable'))
                    : DeliveryMapWidget(
                        delivery: delivery,
                        currentPosition: currentPosition,
                      ),
          ),
          
          // Action Panel (1/3 of screen)
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Next Destination Label
                  Text(
                    delivery.status == DeliveryStatus.assigned 
                        ? 'Next: Pickup' 
                        : 'Next: Drop-off',
                    style: const TextStyle(
                      color: Colors.grey, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    delivery.status == DeliveryStatus.assigned 
                        ? (delivery.pickupAddress ?? 'No pickup address')
                        : (delivery.dropoffAddress ?? 'No dropoff address'),
                    style: const TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // External Navigation Button
                  OutlinedButton.icon(
                    onPressed: () => _openInGoogleMaps(delivery),
                    icon: const Icon(Icons.navigation),
                    label: const Text('Open in Google Maps'),
                  ),
                  const Spacer(),
                  
                  // Collapsible Order Summary (PRD §7)
                  _OrderSummaryPanel(delivery: delivery),
                  const SizedBox(height: 16),
                  
                  // Primary Action Button
                  _buildActionButton(context, ref, delivery),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, 
    WidgetRef ref, 
    Delivery delivery,
  ) {
    final notifier = ref.read(deliveryNotifierProvider(deliveryId).notifier);
    final deliveryState = ref.watch(deliveryNotifierProvider(deliveryId));
    final isUpdating = deliveryState.isUpdating;

    String label;
    Color color;
    DeliveryStatus? targetStatus;

    switch (delivery.status) {
      case DeliveryStatus.assigned:
        label = 'Mark Picked Up';
        color = Colors.blue;
        targetStatus = DeliveryStatus.pickedUp;
        break;
      case DeliveryStatus.pickedUp:
      case DeliveryStatus.onTheWay:
        label = 'Mark Delivered';
        color = Colors.green;
        targetStatus = DeliveryStatus.delivered;
        break;
      default:
        label = 'Complete';
        color = Colors.grey;
        targetStatus = null;
    }

    return ElevatedButton(
      onPressed: targetStatus != null && !isUpdating
          ? () => _handleStatusUpdate(context, ref, delivery, targetStatus!)
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: isUpdating
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
    );
  }

  /// Handle status update with confirmation modal for "Mark Delivered".
  /// PRD §7: "Show confirmation modal before terminal state transition."
  Future<void> _handleStatusUpdate(
    BuildContext context,
    WidgetRef ref,
    Delivery delivery,
    DeliveryStatus targetStatus,
  ) async {
    // Show confirmation modal for delivered status (PRD §7)
    if (targetStatus == DeliveryStatus.delivered) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirm Delivery'),
          content: Text('Confirm delivery to ${delivery.dropoffAddress}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Confirm', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      
      if (confirmed != true) return;
    }

    final notifier = ref.read(deliveryNotifierProvider(deliveryId).notifier);
    final result = await notifier.updateStatus(targetStatus);

    // Handle result based on StatusUpdateResult enum
    if (!context.mounted) return;

    switch (result) {
      case StatusUpdateResult.success:
        if (targetStatus == DeliveryStatus.delivered) {
          // Navigate to completion screen (PRD §7: 3-second auto-nav)
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (ctx) => _DeliveryCompleteScreen(orderId: delivery.orderId),
            ),
          );
        }
        break;
        
      case StatusUpdateResult.conflict:
        // 409 Conflict — delivery cancelled remotely (PRD §12)
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delivery Cancelled'),
            content: const Text(
              'This delivery was cancelled by the restaurant. Returning to Home.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.go('/home');
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
        break;
        
      case StatusUpdateResult.failure:
        // Show error banner — button stays enabled for retry
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not update status — tap to retry'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                notifier.retryLastStatusUpdate();
              },
            ),
          ),
        );
        break;
    }
  }

  /// Open Google Maps with destination coordinates (PRD §7).
  /// Uses daddr parameter for turn-by-turn navigation.
  Future<void> _openInGoogleMaps(Delivery delivery) async {
    final lat = delivery.destinationLatitude;
    final lng = delivery.destinationLongitude;
    
    if (lat == null || lng == null) return;

    // Use daddr for destination navigation (turn-by-turn)
    final url = 'https://maps.google.com/?daddr=$lat,$lng';
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Collapsible order summary panel (PRD §7).
class _OrderSummaryPanel extends StatelessWidget {
  final Delivery delivery;
  const _OrderSummaryPanel({required this.delivery});

  @override
  Widget build(BuildContext context) {
    final order = delivery.order;
    if (order == null) return const SizedBox.shrink();

    return ExpansionTile(
      title: const Text(
        'Order Details',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Items
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('• ${item.quantity}x ${item.name}'),
              )),
              const SizedBox(height: 8),
              
              // Special instructions (highlighted if present)
              if (order.specialInstructions != null && 
                  order.specialInstructions!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Note: ${order.specialInstructions}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Delivery completion screen (PRD §7: 3-second auto-nav to Home).
class _DeliveryCompleteScreen extends StatelessWidget {
  final String orderId;
  const _DeliveryCompleteScreen({required this.orderId});

  @override
  Widget build(BuildContext context) {
    // Auto-navigate after 3 seconds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (context.mounted) {
          context.go('/home');
        }
      });
    });
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 24),
            Text(
              'Delivery Complete!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Order #$orderId — Great work!',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
