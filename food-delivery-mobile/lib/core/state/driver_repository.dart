import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_response.dart';
import '../../core/api/endpoints.dart';

/// Repository for driver profile and status management.
class DriverRepository {
  final ApiClient _apiClient;

  DriverRepository(this._apiClient);

  /// Helper for safe extraction.
  T? _extractData<T>(ApiEnvelope envelope) {
    if (!envelope.success || envelope.data == null) return null;
    if (envelope.data is! T) {
      // ignore: avoid_print
      print('[DriverRepo] Type mismatch: expected $T, got ${envelope.data.runtimeType}');
      return null;
    }
    return envelope.data as T;
  }

  /// Fetch driver profile (including status).
  Future<DriverStatusResult> getStatus(String driverId) async {
    try {
      final envelope = await _apiClient.get(Endpoints.driverProfile(driverId));
      final data = _extractData<Map<String, dynamic>>(envelope);
      
      if (envelope.success && data != null) {
        return DriverStatusResult.success(data['status'] == 'online');
      }
      
      return DriverStatusResult.failure(
        envelope.error?.message ?? 'Failed to load status',
        errorCode: envelope.error?.code,
      );
    } catch (e) {
      // ignore: avoid_print
      print('[DriverRepo] getStatus error: $e');
      return DriverStatusResult.failure('Network error');
    }
  }

  /// Update driver status.
  Future<DriverStatusResult> updateStatus(String driverId, bool isOnline) async {
    try {
      final envelope = await _apiClient.patch(
        Endpoints.driverStatus(driverId),
        {'status': isOnline ? 'online' : 'offline'},
      );
      
      if (envelope.success) {
        return DriverStatusResult.success(isOnline);
      }
      
      return DriverStatusResult.failure(
        envelope.error?.message ?? 'Failed to update status',
        isConflict: envelope.isConflict,
        errorCode: envelope.error?.code,
      );
    } catch (e) {
      // ignore: avoid_print
      print('[DriverRepo] updateStatus error: $e');
      return DriverStatusResult.failure('Network error');
    }
  }
}

class DriverStatusResult {
  final bool? isOnline;
  final String? errorMessage;
  final bool isConflict;
  final String? errorCode;

  DriverStatusResult._({
    this.isOnline,
    this.errorMessage,
    this.isConflict = false,
    this.errorCode,
  });

  factory DriverStatusResult.success(bool isOnline) =>
      DriverStatusResult._(isOnline: isOnline);

  factory DriverStatusResult.failure(
    String message, {
    bool isConflict = false,
    String? errorCode,
  }) =>
      DriverStatusResult._(
        errorMessage: message,
        isConflict: isConflict,
        errorCode: errorCode,
      );

  bool get isSuccess => isOnline != null;
}

final driverRepositoryProvider = Provider<DriverRepository>((ref) {
  return DriverRepository(ref.read(apiClientProvider));
});
