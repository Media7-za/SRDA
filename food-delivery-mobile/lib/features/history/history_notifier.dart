import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_notifier.dart';
import '../../shared/models/delivery.dart';
import '../../core/api/api_response.dart';
import '../delivery/delivery_repository.dart';

/// State for the delivery history screen with pagination.
class HistoryState {
  final List<Delivery> deliveries;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final PaginationMeta? pagination;
  final int currentPage;
  final DeliveryHistoryFilter filter;

  const HistoryState({
    this.deliveries = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.pagination,
    this.currentPage = 1,
    this.filter = DeliveryHistoryFilter.completed,
  });

  HistoryState copyWith({
    List<Delivery>? deliveries,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    PaginationMeta? pagination,
    int? currentPage,
    DeliveryHistoryFilter? filter,
  }) {
    return HistoryState(
      deliveries: deliveries ?? this.deliveries,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      pagination: pagination ?? this.pagination,
      currentPage: currentPage ?? this.currentPage,
      filter: filter ?? this.filter,
    );
  }

  bool get hasMore => pagination?.hasMore ?? false;
}

/// Notifier for delivery history with infinite scroll pagination.
///
/// PRD_Driver.md §8: Load 20 items per page. Infinite scroll.
class HistoryNotifier extends StateNotifier<HistoryState> {
  final DeliveryRepository _repository;
  final String _driverId;

  HistoryNotifier(this._repository, this._driverId)
      : super(const HistoryState()) {
    loadInitial();
  }

  /// Load the first page.
  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.getHistory(
        _driverId,
        page: 1,
        filter: state.filter,
      );
      if (result.hasError) {
        state = state.copyWith(isLoading: false, error: result.errorMessage);
        return;
      }
      state = state.copyWith(
        deliveries: result.deliveries,
        pagination: result.pagination,
        currentPage: 1,
        isLoading: false,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        state = state.copyWith(isLoading: false, error: 'Session expired');
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to load history');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred');
    }
  }

  /// Load the next page (infinite scroll).
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final result = await _repository.getHistory(
        _driverId,
        page: nextPage,
        filter: state.filter,
      );
      if (result.hasError) {
        state = state.copyWith(isLoadingMore: false, error: result.errorMessage);
        return;
      }
      state = state.copyWith(
        deliveries: [...state.deliveries, ...result.deliveries],
        pagination: result.pagination,
        currentPage: nextPage,
        isLoadingMore: false,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        state = state.copyWith(isLoadingMore: false, error: 'Session expired');
      } else {
        state = state.copyWith(isLoadingMore: false, error: 'Failed to load more');
      }
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: 'An unexpected error occurred');
    }
  }

  /// Change filter and reload.
  void setFilter(DeliveryHistoryFilter filter) {
    if (state.filter == filter) return;
    state = state.copyWith(filter: filter);
    loadInitial();
  }
}

final historyNotifierProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final driverId =
      authState is Authenticated ? authState.driverId : 'unknown';
  return HistoryNotifier(ref.read(deliveryRepositoryProvider), driverId);
});
