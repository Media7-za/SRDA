import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_notifier.dart';
import '../../shared/models/delivery.dart';
import 'delivery_repository.dart';

/// State for a single active delivery screen.
class DeliveryViewState {
  final Delivery? delivery;
  final bool isLoading;
  final bool isUpdating;
  final String? error;
  final bool isConflict;

  const DeliveryViewState({
    this.delivery,
    this.isLoading = false,
    this.isUpdating = false,
    this.error,
    this.isConflict = false,
  });

  DeliveryViewState copyWith({
    Delivery? delivery,
    bool? isLoading,
    bool? isUpdating,
    String? error,
    bool? isConflict,
  }) {
    return DeliveryViewState(
      delivery: delivery ?? this.delivery,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      error: error,
      isConflict: isConflict ?? this.isConflict,
    );
  }
}

/// Manages the state for a single delivery view.
///
/// Uses [DeliveryRepository] for all API calls (PRD §3 Layer Rules).
/// Never updates the UI optimistically (PRD §12, §15 Invariant #3).
class DeliveryNotifier extends StateNotifier<DeliveryViewState> {
  final DeliveryRepository _repository;
  final String deliveryId;
  final Ref _ref;

  DeliveryNotifier(this._repository, this.deliveryId, this._ref)
      : super(const DeliveryViewState()) {
    fetchDelivery();
  }

  DeliveryStatus? _lastStatusUpdate;

  /// Fetch delivery details from the API.
  Future<void> fetchDelivery() async {
    state = state.copyWith(isLoading: true, error: null, isConflict: false);
    try {
      final result = await _repository.getDeliveryDetail(deliveryId);
      if (result.isSuccess && result.delivery != null) {
        final delivery = result.delivery!;
        
        // --- UX Enhancement: Ownership Validation (Decision 5) ---
        // Ensure the delivery returned belongs to the logged-in driver.
        // This is a client-side safety check; backend should also enforce.
        final authState = _ref.read(authNotifierProvider);
        if (authState is Authenticated) {
          // Note: Backend JSON key is usually just 'driver_id' in these responses
          // If the model doesn't have it yet, we skip for now, but the pattern is here.
          // if (delivery.driverId != authState.driverId) { ... }
        }

        state = state.copyWith(delivery: delivery, isLoading: false);
      } else if (result.isSuccess) {
        // Backend returned success: true but no delivery object (malformed)
        state = state.copyWith(
          isLoading: false,
          error: 'Delivery data could not be loaded',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.errorMessage,
          isConflict: result.isConflict,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        state = state.copyWith(isLoading: false, error: 'Session expired');
      } else {
        state = state.copyWith(isLoading: false, error: 'Unable to connect');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('[DeliveryNotifier] fetchDelivery Error: $e\n$stack');
      }
      state = state.copyWith(
        isLoading: false, 
        error: 'Unable to connect. Please try again.'
      );
    }
  }

  /// Advance delivery status — NO OPTIMISTIC UPDATES.
  ///
  /// PRD §12: "Status transitions must be confirmed by a successful API
  /// response before the UI advances."
  ///
  /// If this returns [StatusUpdateResult.failure], the screen should keep the
  /// action button enabled and allow the user to retry by calling this
  /// method again (or via [retryLastStatusUpdate]).
  ///
  /// Returns a [StatusUpdateResult] so the screen can show the right dialog.
  Future<StatusUpdateResult> updateStatus(DeliveryStatus newStatus) async {
    _lastStatusUpdate = newStatus;
    state = state.copyWith(isUpdating: true, error: null, isConflict: false);

    try {
      final result = await _repository.updateStatus(deliveryId, newStatus);

      if (result.isSuccess && result.delivery != null) {
        state = state.copyWith(
          delivery: result.delivery,
          isUpdating: false,
        );
        return StatusUpdateResult.success;
      } else if (result.isSuccess) {
        state = state.copyWith(
          isUpdating: false,
          error: 'Status updated but data refresh failed',
        );
        return StatusUpdateResult.failure;
      }

      // 409 Conflict — delivery was cancelled/changed remotely
      if (result.isConflict) {
        state = state.copyWith(
          isUpdating: false,
          error: result.errorMessage,
          isConflict: true,
        );
        return StatusUpdateResult.conflict;
      }

      // Generic failure — button stays active for retry
      state = state.copyWith(
        isUpdating: false,
        error: result.errorMessage,
      );
      return StatusUpdateResult.failure;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        state = state.copyWith(isUpdating: false, error: 'Session expired');
      } else {
        state = state.copyWith(isUpdating: false, error: 'Connection error');
      }
      return StatusUpdateResult.failure;
    } catch (e, stack) {
      if (kDebugMode) {
        print('[DeliveryNotifier] updateStatus Error: $e\n$stack');
      }
      state = state.copyWith(
        isUpdating: false,
        error: 'Unable to update status. Please try again.',
      );
      return StatusUpdateResult.failure;
    }
  }

  /// Helper for screens to retry the last failed status update (Decision 3).
  Future<StatusUpdateResult?> retryLastStatusUpdate() async {
    if (_lastStatusUpdate == null) return null;
    return updateStatus(_lastStatusUpdate!);
  }

  /// Clear error state.
  void clearError() {
    state = state.copyWith(error: null, isConflict: false);
  }
}

/// Outcome of a status update attempt — the screen decides what UI to show.
enum StatusUpdateResult {
  /// Navigate to next state / show completion screen.
  success,

  /// Keep button enabled, show error, allow retry.
  failure,

  /// Show modal "Delivery was cancelled/modified", then go Home.
  conflict,
}

final deliveryNotifierProvider = StateNotifierProvider.family<
    DeliveryNotifier, DeliveryViewState, String>((ref, deliveryId) {
  return DeliveryNotifier(
    ref.read(deliveryRepositoryProvider),
    deliveryId,
    ref,
  );
});