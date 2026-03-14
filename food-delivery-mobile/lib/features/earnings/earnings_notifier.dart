import 'package:dio/dio.dart';
import '../../shared/models/earnings.dart';
import 'earnings_repository.dart';

/// Earnings summary state.
class EarningsState {
  final double weekTotal;
  final double monthTotal;
  final int deliveryCount;
  final List<EarningsRecord> recentHistory;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final PaginationMeta? pagination;
  final int currentPage;

  const EarningsState({
    this.weekTotal = 0,
    this.monthTotal = 0,
    this.deliveryCount = 0,
    this.recentHistory = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.pagination,
    this.currentPage = 1,
  });

  EarningsState copyWith({
    double? weekTotal,
    double? monthTotal,
    int? deliveryCount,
    List<EarningsRecord>? recentHistory,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    PaginationMeta? pagination,
    int? currentPage,
  }) {
    return EarningsState(
      weekTotal: weekTotal ?? this.weekTotal,
      monthTotal: monthTotal ?? this.monthTotal,
      deliveryCount: deliveryCount ?? this.deliveryCount,
      recentHistory: recentHistory ?? this.recentHistory,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      pagination: pagination ?? this.pagination,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  bool get hasMore => pagination?.hasMore ?? false;
}

/// Notifier for the Earnings screen.
///
/// PRD_Driver.md §9: Earnings figures computed server-side.
class EarningsNotifier extends StateNotifier<EarningsState> {
  final EarningsRepository _repository;
  final String _driverId;

  EarningsNotifier(this._repository, this._driverId)
      : super(const EarningsState()) {
    loadAll();
  }

  /// Load summary + first page of history.
  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Fetch summary
      final summaryResult = await _repository.getEarningsSummary(_driverId);
      if (summaryResult.hasError) {
        state = state.copyWith(isLoading: false, error: summaryResult.errorMessage);
        return;
      }

      state = state.copyWith(
        weekTotal: summaryResult.weekTotal,
        monthTotal: summaryResult.monthTotal,
        deliveryCount: summaryResult.deliveryCount,
      );

      // Fetch first page of history
      final historyResult = await _repository.getEarningsHistory(_driverId, page: 1);

      if (!historyResult.hasError) {
        state = state.copyWith(
          recentHistory: historyResult.records,
          pagination: historyResult.pagination,
          currentPage: 1,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: historyResult.errorMessage,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        state = state.copyWith(isLoading: false, error: 'Session expired');
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to load earnings');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred');
    }
  }

  /// Load the next page of earnings history (infinite scroll).
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final result = await _repository.getEarningsHistory(_driverId, page: nextPage);

      if (!result.hasError) {
        state = state.copyWith(
          recentHistory: [...state.recentHistory, ...result.records],
          pagination: result.pagination,
          currentPage: nextPage,
          isLoadingMore: false,
        );
      } else {
        state = state.copyWith(
          isLoadingMore: false,
          error: result.errorMessage,
        );
      }
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
}

final earningsNotifierProvider =
    StateNotifierProvider<EarningsNotifier, EarningsState>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final driverId =
      authState is Authenticated ? authState.driverId : 'unknown';
  return EarningsNotifier(ref.read(earningsRepositoryProvider), driverId);
});
