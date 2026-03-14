import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_response.dart';
import '../../core/api/endpoints.dart';
import '../../shared/models/delivery.dart';
import '../../shared/models/delivery_status.dart';

/// Filter options for delivery history.
enum DeliveryHistoryFilter {
  completed('completed'),
  failed('failed'),
  all('all');

  final String apiValue;
  const DeliveryHistoryFilter(this.apiValue);
}

/// Repository for all delivery-related API calls.
///
/// This is the **only** file that references delivery endpoint paths.
/// Notifiers call this — screens never call this directly.
///
/// Reference: PRD_Driver.md §3 Layer Rules
class DeliveryRepository {
  final ApiClient _apiClient;

  DeliveryRepository(this._apiClient);

  /// Helper for safe extraction of data from envelope to avoid runtime TypeErrors.
  T? _extractData<T>(ApiEnvelope envelope) {
    if (!envelope.success || envelope.data == null) return null;
    if (envelope.data is! T) {
      // ignore: avoid_print
      print('[DeliveryRepo] Type mismatch: expected $T, got ${envelope.data.runtimeType}');
      return null;
    }
    return envelope.data as T;
  }

  /// Fetch active delivery for the current driver.
  /// Returns null if no active delivery exists.
  /// API: GET /api/drivers/:id/deliveries/active
  Future<Delivery?> getActiveDelivery(String driverId) async {
    try {
      final envelope = await _apiClient.get(Endpoints.activeDelivery(driverId));
      final data = _extractData<Map<String, dynamic>>(envelope);
      if (data != null) {
        return Delivery.fromJson(data);
      }
    } catch (e) {
      // ignore: avoid_print
      print('[DeliveryRepo] getActiveDelivery failed: $e');
    }
    return null;
  }

  /// Fetch full delivery detail by ID.
  /// API: GET /api/deliveries/:id
  Future<DeliveryResult> getDeliveryDetail(String deliveryId) async {
    try {
      final envelope = await _apiClient.get(Endpoints.deliveryDetail(deliveryId));
      final data = _extractData<Map<String, dynamic>>(envelope);
      
      if (envelope.success && data != null) {
        return DeliveryResult.success(Delivery.fromJson(data));
      }
      
      return DeliveryResult.failure(
        envelope.error?.message ?? 'Failed to load delivery',
        isConflict: envelope.isConflict,
        errorCode: envelope.error?.code,
      );
    } catch (e) {
      // ignore: avoid_print
      print('[DeliveryRepo] getDeliveryDetail failed: $e');
      return DeliveryResult.failure('Network error', errorCode: 'NETWORK_ERROR');
    }
  }

  /// Advance delivery status.
  /// API: PATCH /api/deliveries/:id/status
  ///
  /// Returns [DeliveryResult] with conflict detection for 409 responses.
  /// PRD §12: "Never advance delivery status optimistically."
  Future<DeliveryResult> updateStatus(
    String deliveryId,
    DeliveryStatus newStatus,
  ) async {
    try {
      final envelope = await _apiClient.patch(
        Endpoints.deliveryStatus(deliveryId),
        {'status': newStatus.value},
      );

      if (envelope.success) {
        // Re-fetch to get the authoritative state from server
        final detailResult = await getDeliveryDetail(deliveryId);
        if (detailResult.isSuccess) {
          return detailResult;
        }
        // Re-fetch failed but status update succeeded — return partial success
        // so UI can decide to show stale data or retry refresh.
        return DeliveryResult.failure(
          'Status updated but details could not be refreshed',
          errorCode: 'PARTIAL_SUCCESS',
        );
      }

      return DeliveryResult.failure(
        envelope.error?.message ?? 'Status update failed',
        isConflict: envelope.isConflict,
        errorCode: envelope.error?.code,
      );
    } catch (e) {
      // ignore: avoid_print
      print('[DeliveryRepo] updateStatus failed: $e');
      return DeliveryResult.failure('Network error', errorCode: 'NETWORK_ERROR');
    }
  }

  /// Fetch delivery history with pagination.
  /// API: GET /api/drivers/:id/deliveries?status=completed&page=N&limit=N
  Future<DeliveryListResult> getHistory(
    String driverId, {
    DeliveryHistoryFilter filter = DeliveryHistoryFilter.completed,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final envelope = await _apiClient.get(
        Endpoints.deliveryHistory(driverId),
        queryParams: {
          'status': filter.apiValue,
          'page': page,
          'limit': limit,
        },
      );

      final dataList = _extractData<List<dynamic>>(envelope);
      if (envelope.success && dataList != null) {
        final items = dataList
            .whereType<Map<String, dynamic>>()
            .map((json) => Delivery.fromJson(json))
            .toList();
        return DeliveryListResult(
          deliveries: items,
          pagination: envelope.pagination,
        );
      }
      
      return DeliveryListResult(
        deliveries: [],
        errorMessage: envelope.error?.message ?? 'Failed to load history',
      );
    } catch (e) {
      // ignore: avoid_print
      print('[DeliveryRepo] getHistory failed: $e');
      return DeliveryListResult(
        deliveries: [],
        errorMessage: 'Network error',
      );
    }
  }
}

/// Result wrapper for single-delivery operations.
class DeliveryResult {
  final Delivery? delivery;
  final String? errorMessage;
  final bool isConflict;
  final String? errorCode;

  DeliveryResult._({
    this.delivery,
    this.errorMessage,
    this.isConflict = false,
    this.errorCode,
  });

  factory DeliveryResult.success(Delivery delivery) =>
      DeliveryResult._(delivery: delivery);

  factory DeliveryResult.failure(
    String message, {
    bool isConflict = false,
    String? errorCode,
  }) =>
      DeliveryResult._(
        errorMessage: message,
        isConflict: isConflict,
        errorCode: errorCode,
      );

  bool get isSuccess => delivery != null;
}

/// Result wrapper for paginated delivery lists.
class DeliveryListResult {
  final List<Delivery> deliveries;
  final PaginationMeta? pagination;
  final String? errorMessage;

  DeliveryListResult({
    required this.deliveries,
    this.pagination,
    this.errorMessage,
  });

  bool get hasError => errorMessage != null;
  bool get hasMore => pagination?.hasMore ?? false;
}

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  return DeliveryRepository(ref.read(apiClientProvider));
});
