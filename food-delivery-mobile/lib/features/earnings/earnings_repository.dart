import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_response.dart';
import '../../core/api/endpoints.dart';
import 'earnings_notifier.dart';

/// Repository for earnings-related API calls.
///
/// Reference: PRD_Driver.md §3 Layer Rules
class EarningsRepository {
  final ApiClient _apiClient;

  EarningsRepository(this._apiClient);

  /// Helper for safe extraction of data from envelope.
  T? _extractData<T>(ApiEnvelope envelope) {
    if (!envelope.success || envelope.data == null) return null;
    if (envelope.data is! T) {
      // ignore: avoid_print
      print('[EarningsRepo] Type mismatch: expected $T, got ${envelope.data.runtimeType}');
      return null;
    }
    return envelope.data as T;
  }

  /// Fetch earnings summary (week/month totals).
  Future<EarningsSummaryResult> getEarningsSummary(String driverId) async {
    try {
      final envelope = await _apiClient.get(Endpoints.earningsSummary(driverId));
      final data = _extractData<Map<String, dynamic>>(envelope);
      
      if (envelope.success && data != null) {
        return EarningsSummaryResult.success(
          weekTotal: (data['week_total'] as num?)?.toDouble() ?? 0,
          monthTotal: (data['month_total'] as num?)?.toDouble() ?? 0,
          deliveryCount: data['delivery_count'] as int? ?? 0,
        );
      }
      
      return EarningsSummaryResult.failure(
        envelope.error?.message ?? 'Failed to load earnings summary',
      );
    } catch (e) {
      // ignore: avoid_print
      print('[EarningsRepo] getEarningsSummary failed: $e');
      return EarningsSummaryResult.failure('Network error');
    }
  }

  /// Fetch earnings history with pagination.
  Future<EarningsHistoryResult> getEarningsHistory(
    String driverId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final envelope = await _apiClient.get(
        Endpoints.earningsHistory(driverId),
        queryParams: {'page': page, 'limit': limit},
      );

      final dataList = _extractData<List<dynamic>>(envelope);
      if (envelope.success && dataList != null) {
        final items = dataList
            .whereType<Map<String, dynamic>>()
            .map((json) => EarningsRecord.fromJson(json))
            .toList();
        return EarningsHistoryResult.success(
          records: items,
          pagination: envelope.pagination,
        );
      }
      
      return EarningsHistoryResult.failure(
        envelope.error?.message ?? 'Failed to load earnings history',
      );
    } catch (e) {
      // ignore: avoid_print
      print('[EarningsRepo] getEarningsHistory failed: $e');
      return EarningsHistoryResult.failure('Network error');
    }
  }
}

/// Result wrapper for earnings summary.
class EarningsSummaryResult {
  final double weekTotal;
  final double monthTotal;
  final int deliveryCount;
  final String? errorMessage;

  EarningsSummaryResult._({
    this.weekTotal = 0,
    this.monthTotal = 0,
    this.deliveryCount = 0,
    this.errorMessage,
  });

  factory EarningsSummaryResult.success({
    required double weekTotal,
    required double monthTotal,
    required int deliveryCount,
  }) => EarningsSummaryResult._(
    weekTotal: weekTotal,
    monthTotal: monthTotal,
    deliveryCount: deliveryCount,
  );

  factory EarningsSummaryResult.failure(String message) =>
      EarningsSummaryResult._(errorMessage: message);

  bool get hasError => errorMessage != null;
}

/// Result wrapper for earnings history.
class EarningsHistoryResult {
  final List<EarningsRecord> records;
  final PaginationMeta? pagination;
  final String? errorMessage;

  EarningsHistoryResult._({
    this.records = const [],
    this.pagination,
    this.errorMessage,
  });

  factory EarningsHistoryResult.success({
    required List<EarningsRecord> records,
    PaginationMeta? pagination,
  }) => EarningsHistoryResult._(
    records: records,
    pagination: pagination,
  );

  factory EarningsHistoryResult.failure(String message) =>
      EarningsHistoryResult._(errorMessage: message);

  bool get hasError => errorMessage != null;
}

final earningsRepositoryProvider = Provider<EarningsRepository>((ref) {
  return EarningsRepository(ref.read(apiClientProvider));
});
