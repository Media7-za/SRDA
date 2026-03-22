import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/state/driver_status_notifier.dart';
import '../../core/auth/auth_notifier.dart';
import '../../core/services/location_service.dart';
import '../../core/state/location_providers.dart';
import '../delivery/active_delivery_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverStatus = ref.watch(driverStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Direct'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh both status and active delivery
          await ref.read(driverStatusProvider.notifier).fetchStatus();
          ref.invalidate(activeDeliveryProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatusCard(context, ref, driverStatus),
              const SizedBox(height: 24),
              _buildActiveDeliveryCard(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, WidgetRef ref, DriverStatusState status) {
    final isOnline = status.isOnline;
    final isChanging = status.isLoading;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOnline ? 'ONLINE' : 'OFFLINE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isOnline ? Colors.green : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isOnline
                        ? 'Eligible for delivery assignments'
                        : 'Tap to start receiving jobs',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Switch(
              value: isOnline,
              activeColor: Colors.green,
              onChanged: isChanging
                  ? null
                  : (val) async {
                      if (val) {
                        // Turning ON: Check permissions (PRD §10)
                        final result = await ref.read(locationServiceProvider).requestPermission();
                        if (result != PermissionRequestResult.granted && 
                            result != PermissionRequestResult.alreadyGranted) {
                          if (context.mounted) {
                            _showPermissionDeniedDialog(context, result == PermissionRequestResult.deniedForever);
                          }
                          return;
                        }
                      }
                      
                      final success = await ref.read(driverStatusProvider.notifier).toggleStatus();
                      if (!success && context.mounted) {
                        final errorState = ref.read(driverStatusProvider);
                        
                        // Fix #4: Specific 409 "Cannot go offline" error handling (PRD §14 Invariant #4)
                        if (errorState.errorCode == 'CANNOT_GO_OFFLINE') {
                          _showErrorSnackBar(
                            context, 
                            'Cannot go offline while a delivery is in progress',
                            isWarning: true,
                          );
                        } else {
                          _showErrorSnackBar(context, errorState.error ?? 'Failed to update status');
                        }
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message, {bool isWarning = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isWarning ? Colors.orange[800] : Colors.red[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showPermissionDeniedDialog(BuildContext context, bool isPermanent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Required'),
        content: Text(
          isPermanent
              ? 'Location permissions are permanently denied. Please enable them in system settings to go online.'
              : 'We need your location to show customers where their order is. Please grant permission to go online.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          if (isPermanent)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings(); // PRD §10: Recovery from permanent denial
              },
              child: const Text('Open Settings'),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveDeliveryCard(BuildContext context, WidgetRef ref) {
    final activeDeliveryAsync = ref.watch(activeDeliveryProvider);

    return activeDeliveryAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 12),
              const Text('Failed to load active delivery'),
              TextButton(
                onPressed: () => ref.invalidate(activeDeliveryProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (delivery) {
        if (delivery == null) {
          return const Card(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Text(
                  'No active delivery.\nYou\'re ready for the next job.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          );
        }

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ACTIVE DELIVERY',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    Text(
                      '#${delivery.orderId}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        delivery.dropoffAddress ?? 'No drop-off address',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/delivery/${delivery.id}');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('View Delivery Details', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
