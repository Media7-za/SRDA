import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/endpoints.dart';

class DriverStatusResult {
  final bool isSuccess;
  final bool? isOnline;
  final String? errorMessage;
  final String? errorCode;
  final bool isConflict;

  DriverStatusResult({
    required this.isSuccess,
    this.isOnline,
    this.errorMessage,
    this.errorCode,
    this.isConflict = false,
  });
}

class DriverRepository {
  final ApiClient _apiClient;

  DriverRepository(this._apiClient);

  /// GET /api/drivers/:id
  Future<DriverStatusResult> getStatus(String driverId) async {
    try {
      final envelope = await _apiClient.get(Endpoints.driverProfile(driverId));
      if (envelope.success && envelope.data != null) {
        final data = envelope.data as Map<String, dynamic>;
        return DriverStatusResult(
          isSuccess: true,
          isOnline: data['status'] == 'online',
        );
      }
      return DriverStatusResult(
        isSuccess: false,
        errorMessage: envelope.error?.message ?? 'Failed to load status',
        errorCode: envelope.error?.code,
      );
    } catch (e) {
      return DriverStatusResult(
        isSuccess: false,
        errorMessage: 'Network error',
      );
    }
  }

  /// PATCH /api/drivers/:id/status
  Future<DriverStatusResult> updateStatus(String driverId, bool isOnline) async {
    try {
      final envelope = await _apiClient.patch(
        Endpoints.driverStatus(driverId),
        {'status': isOnline ? 'online' : 'offline'},
      );

      if (envelope.success && envelope.data != null) {
        final data = envelope.data as Map<String, dynamic>;
        return DriverStatusResult(
          isSuccess: true,
          isOnline: data['status'] == 'online',
        );
      }

      final isConflict = envelope.error?.code == 'STATE_CONFLICT' || envelope.error?.code == 'CANNOT_GO_OFFLINE';

      return DriverStatusResult(
        isSuccess: false,
        errorMessage: envelope.error?.message ?? 'Failed to update status',
        errorCode: envelope.error?.code,
        isConflict: isConflict,
      );
    } catch (e) {
      return DriverStatusResult(
        isSuccess: false,
        errorMessage: 'Network error',
      );
    }
  }
}

final driverRepositoryProvider = Provider<DriverRepository>((ref) {
  return DriverRepository(ref.read(apiClientProvider));
});
