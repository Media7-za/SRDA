import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_notifier.dart';
import '../../shared/models/delivery.dart';
import 'delivery_repository.dart';

/// Provider that fetches the current active delivery for the driver.
/// 
/// Reference: PRD_Driver.md §7: "Home shows active delivery (if any)"
final activeDeliveryProvider = FutureProvider<Delivery?>((ref) async {
  final authState = ref.watch(authNotifierProvider);
  
  if (authState is! Authenticated) {
    return null;
  }
  
  final repository = ref.read(deliveryRepositoryProvider);
  return repository.getActiveDelivery(authState.driverId);
});
