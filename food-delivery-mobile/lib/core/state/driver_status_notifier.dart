import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'driver_repository.dart';
import '../auth/auth_repository.dart';

/// Global driver status state — cross-cutting concern.
///
/// Consumed by:
/// - HomeScreen (toggle UI)
/// - LocationService (start/stop GPS)
/// - DeliveryNotifier (disable actions when offline)
///
/// Reference: PRD_Driver.md §5, §14 Driver Online Status state machine
class DriverStatusState {
  final String? driverId;
  final String? restaurantId;
  final bool isOnline;
  final bool isLoading;
  final bool hasActiveDelivery;
  final String? error;
  final String? errorCode;
  final bool isInitialized;

  const DriverStatusState({
    this.driverId,
    this.restaurantId,
    this.isOnline = false,
    this.isLoading = false,
    this.hasActiveDelivery = false,
    this.error,
    this.errorCode,
    this.isInitialized = false,
  });

  DriverStatusState copyWith({
    String? driverId,
    String? restaurantId,
    bool? isOnline,
    bool? isLoading,
    bool? hasActiveDelivery,
    String? error,
    String? errorCode,
    bool? isInitialized,
  }) {
    return DriverStatusState(
      driverId: driverId ?? this.driverId,
      restaurantId: restaurantId ?? this.restaurantId,
      isOnline: isOnline ?? this.isOnline,
      isLoading: isLoading ?? this.isLoading,
      hasActiveDelivery: hasActiveDelivery ?? this.hasActiveDelivery,
      error: error,
      errorCode: errorCode,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class DriverStatusNotifier extends StateNotifier<DriverStatusState> {
  final DriverRepository _repository;
  // TODO: Use for FCM re-auth flow (PRD §11) — keep injection point for future phase
  // final AuthRepository _authRepository;

  DriverStatusNotifier(this._repository, AuthRepository authRepository)
      : super(const DriverStatusState());

  /// Initialize from authenticated session — call after login/token restore.
  Future<void> initialize({required String driverId, required String restaurantId}) async {
    // Decision 5: Reset state if switching to different driver
    if (state.driverId != null && state.driverId != driverId) {
      state = const DriverStatusState();
    }
    
    state = state.copyWith(driverId: driverId, restaurantId: restaurantId);
    await fetchStatus();
    
    // Mark as initialized even if fetch failed (so we don't spam requests)
    // The fetchStatus() call above handles its own errors.
    state = state.copyWith(isInitialized: true);
  }

  /// Fetch current driver status from backend.
  /// PRD §5: "On app restart, fetch current status from GET /api/drivers/:id"
  Future<void> fetchStatus() async {
    final driverId = state.driverId;
    if (driverId == null) return;

    state = state.copyWith(isLoading: true, error: null, errorCode: null);
    try {
      final result = await _repository.getStatus(driverId);
      if (result.isSuccess && result.isOnline != null) {
        if (kDebugMode) {
          print('[DriverStatus] Fetch success: isOnline=${result.isOnline}');
        }
        state = state.copyWith(
          isOnline: result.isOnline!,
          isLoading: false,
        );
      } else if (result.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid status response from server',
          errorCode: 'INVALID_RESPONSE',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.errorMessage,
          errorCode: result.errorCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        state = state.copyWith(isLoading: false, error: 'Session expired', errorCode: 'UNAUTHORIZED');
      } else {
        state = state.copyWith(isLoading: false, error: 'Unable to load status', errorCode: 'NETWORK_ERROR');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('[DriverStatusNotifier] fetchStatus error: $e\n$stack');
      }
      state = state.copyWith(
        isLoading: false, 
        error: 'Unable to load status',
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Toggle online/offline via PATCH /api/drivers/:id/status.
  ///
  /// PRD §14: "A driver cannot go offline while they have an active delivery"
  /// Backend returns 409 if this rule is violated — we surface the message.
  ///
  /// Returns `true` if toggle succeeded, `false` otherwise.
  Future<bool> toggleStatus() async {
    final driverId = state.driverId;
    if (driverId == null) return false;

    final newOnlineState = !state.isOnline;
    state = state.copyWith(isLoading: true, error: null, errorCode: null);

    try {
      final result = await _repository.updateStatus(driverId, newOnlineState);

      if (result.isSuccess && result.isOnline != null) {
        if (kDebugMode) {
          print('[DriverStatus] Toggle success: isOnline=${result.isOnline}');
        }
        state = state.copyWith(
          isOnline: result.isOnline!,
          isLoading: false,
        );
        return true;
      } else if (result.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid status response from server',
          errorCode: 'INVALID_RESPONSE',
        );
        return false;
      } else {
        // Decision 1: Specific handling for 409 Conflict: "Cannot go offline"
        if (result.isConflict || result.errorCode == 'CANNOT_GO_OFFLINE') {
          state = state.copyWith(
            isLoading: false,
            error: 'Cannot go offline while a delivery is in progress',
            errorCode: 'CANNOT_GO_OFFLINE',
          );
          return false;
        }

        state = state.copyWith(
          isLoading: false,
          error: result.errorMessage ?? 'Failed to update status',
          errorCode: result.errorCode ?? 'UPDATE_FAILED',
        );
        return false;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        state = state.copyWith(isLoading: false, error: 'Session expired', errorCode: 'UNAUTHORIZED');
      } else {
        state = state.copyWith(isLoading: false, error: 'Connection error', errorCode: 'NETWORK_ERROR');
      }
      return false;
    } catch (e, stack) {
      if (kDebugMode) {
        print('[DriverStatusNotifier] toggleStatus error: $e\n$stack');
      }
      state = state.copyWith(
        isLoading: false, 
        error: 'Connection error',
        errorCode: 'UNKNOWN_ERROR',
      );
      return false;
    }
  }

  /// Update the active delivery flag — called by DeliveryNotifier.
  void setHasActiveDelivery(bool value) {
    state = state.copyWith(hasActiveDelivery: value);
  }

  /// Clear error state (for dismissing error banners).
  void clearError() {
    state = state.copyWith(error: null);
  }
}

final driverStatusProvider =
    StateNotifierProvider<DriverStatusNotifier, DriverStatusState>((ref) {
  return DriverStatusNotifier(
    ref.read(driverRepositoryProvider),
    ref.read(authRepositoryProvider),
  );
});
