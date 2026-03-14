import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'delivery_notifier.dart';
import '../../shared/models/delivery.dart';
import '../../shared/models/delivery_status.dart';
import '../../core/config/app_config.dart';

/// Active delivery screen — the core operational screen.
///
/// Shows map, delivery info, and primary status action button.
/// PRD_Driver.md §7
class ActiveDeliveryScreen extends ConsumerWidget {
  final String deliveryId;

  const ActiveDeliveryScreen({super.key, required this.deliveryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deliveryNotifierProvider(deliveryId));

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.error != null && state.delivery == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                state.isConflict ? Icons.warning_amber : Icons.error_outline,
                size: 48,
                color: state.isConflict ? Colors.orange : Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                state.isConflict
                    ? 'Delivery Status Changed'
                    : 'Error Loading Delivery',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  state.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 24),
              if (state.isConflict)
                ElevatedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Back to Home'),
                )
              else
                ElevatedButton(
                  onPressed: () => ref
                      .read(deliveryNotifierProvider(deliveryId).notifier)
                      .fetchDelivery(),
                  child: const Text('Retry'),
                ),
            ],
          ),
        ),
      );
    }

    final delivery = state.delivery;
    if (delivery == null) {
      return const Scaffold(body: Center(child: Text('Delivery not found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${delivery.orderShortId}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: _statusColor(delivery.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _statusColor(delivery.status)),
            ),
            child: Text(
              delivery.status.displayLabel,
              style: TextStyle(
                color: _statusColor(delivery.status),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map placeholder (Google Maps API key required for rendering)
          const _DeliveryMapPlaceholder(),

          // Bottom panel: info + actions
          Align(
            alignment: Alignment.bottomCenter,
            child: _DeliveryActionsPanel(delivery: delivery),
          ),
        ],
      ),
    );
  }

  Color _statusColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.assigned:
        return Colors.blue;
      case DeliveryStatus.pickedUp:
        return Colors.orange;
      case DeliveryStatus.onTheWay:
        return Colors.deepOrange;
      case DeliveryStatus.delivered:
        return Colors.green;
      case DeliveryStatus.failed:
      case DeliveryStatus.cancelled:
        return Colors.red;
    }
  }
}

class _DeliveryMapPlaceholder extends StatelessWidget {
  const _DeliveryMapPlaceholder();

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with GoogleMap widget once API key is configured
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Google Maps View',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '(API Key Required)',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom panel with delivery info and status action button.
class _DeliveryActionsPanel extends ConsumerWidget {
  final Delivery delivery;
  const _DeliveryActionsPanel({required this.delivery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(deliveryNotifierProvider(delivery.id));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Destination address (switches based on status per PRD §7)
          Text(
            delivery.destinationAddress,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Customer: ${delivery.customerName}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),

          // Order summary (collapsible) — PRD §7 Order Summary
          _OrderSummary(delivery: delivery),
          const SizedBox(height: 12),

          // Error banner for failed status updates
          if (viewState.error != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: viewState.isConflict
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    viewState.isConflict ? Icons.warning_amber : Icons.error,
                    size: 18,
                    color: viewState.isConflict ? Colors.orange : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      viewState.error!,
                      style: TextStyle(
                        color: viewState.isConflict ? Colors.orange[900] : Colors.red,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // External navigation button
          OutlinedButton.icon(
            onPressed: () => _launchNavigation(
              delivery.destinationLatitude,
              delivery.destinationLongitude,
            ),
            icon: const Icon(Icons.navigation),
            label: const Text('Open in Google Maps'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Primary status action button (PRD §7)
          if (delivery.status.hasDriverAction)
            _StatusActionButton(delivery: delivery),
        ],
      ),
    );
  }

  Future<void> _launchNavigation(double? lat, double? lng) async {
    if (lat == null || lng == null) return;
    // PRD §7: Deep-link to Google Maps with destination pre-filled
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}

/// Collapsible order summary panel.
/// PRD §7: "Item names and quantities, Customer name, Special instructions"
class _OrderSummary extends StatelessWidget {
  final Delivery delivery;
  const _OrderSummary({required this.delivery});

  @override
  Widget build(BuildContext context) {
    if (delivery.items.isEmpty) return const SizedBox.shrink();

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        'Order Summary (${delivery.items.length} items)',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      children: [
        ...delivery.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(item.name)),
                  Text('×${item.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )),
        if (delivery.specialInstructions != null &&
            delivery.specialInstructions!.isNotEmpty) ...[
          const Divider(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.note, size: 16, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  delivery.specialInstructions!,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Primary action button — drives the delivery forward.
///
/// PRD §7: One button that changes based on current status.
/// PRD §12: NO OPTIMISTIC UI — only advances after API 200.
class _StatusActionButton extends ConsumerWidget {
  final Delivery delivery;
  const _StatusActionButton({required this.delivery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(deliveryNotifierProvider(delivery.id));
    final nextStatus = delivery.status.nextStatus;
    final label = delivery.status.actionButtonLabel;

    if (nextStatus == null || label == null) return const SizedBox.shrink();

    return ElevatedButton(
      onPressed: viewState.isUpdating
          ? null
          : () => _handleStatusUpdate(context, ref, nextStatus),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: viewState.isUpdating
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
    );
  }

  Future<void> _handleStatusUpdate(
    BuildContext context,
    WidgetRef ref,
    DeliveryStatus nextStatus,
  ) async {
    // PRD §7: "Mark Delivered" requires confirmation modal
    if (nextStatus == DeliveryStatus.delivered) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirm Delivery'),
          content: Text(
            'Confirm delivery to ${delivery.dropoffAddress}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    final result = await ref
        .read(deliveryNotifierProvider(delivery.id).notifier)
        .updateStatus(nextStatus);

    if (!context.mounted) return;

    switch (result) {
      case StatusUpdateResult.success:
        if (nextStatus == DeliveryStatus.delivered) {
          _showCompletionScreen(context);
        }
        break;
      case StatusUpdateResult.conflict:
        // 409 — delivery was cancelled/changed remotely
        // Error is already shown in the panel via viewState.error
        break;
      case StatusUpdateResult.failure:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not update status — you appear to be offline. Tap to retry.',
            ),
          ),
        );
        break;
    }
  }

  /// PRD §7: "Show a brief completion screen, after 3 seconds → navigate back to Home"
  void _showCompletionScreen(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        // Auto-dismiss after 3 seconds
        Future.delayed(AppConfig.completionScreenDuration, () {
          if (ctx.mounted) {
            Navigator.of(ctx).pop();
            context.go('/home');
          }
        });

        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Delivery Complete!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Great work.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      },
    );
  }
}
