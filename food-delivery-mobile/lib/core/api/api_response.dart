/// Global response envelope matching `driver-api.yaml` SuccessEnvelope / ErrorEnvelope.
///
/// All API responses are unwrapped through this model.
/// Reference: PRD_Driver.md §13
class ApiEnvelope<T> {
  final bool success;
  final T? data;
  final ApiError? error;
  final PaginationMeta? pagination;

  ApiEnvelope({
    required this.success,
    this.data,
    this.error,
    this.pagination,
  });

  factory ApiEnvelope.fromJson(Map<String, dynamic> json) {
    return ApiEnvelope(
      success: json['success'] as bool,
      data: json['data'] != null ? json['data'] as T : null,
      error: json['error'] != null
          ? ApiError.fromJson(json['error'] as Map<String, dynamic>)
          : null,
      pagination: json['pagination'] != null
          ? PaginationMeta.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Whether this response indicates a state conflict (409).
  bool get isConflict => error?.code == 'STATE_CONFLICT';

  /// Whether this response indicates re-authentication is required.
  bool get isReAuthRequired => error?.code == 'RE_AUTH_REQUIRED';
}

/// Structured error from the API error envelope.
class ApiError {
  final String code;
  final String message;

  ApiError({required this.code, required this.message});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] as String? ?? 'UNKNOWN',
      message: json['message'] as String? ?? 'An unknown error occurred',
    );
  }
}

/// Pagination metadata from `SuccessListEnvelope` in driver-api.yaml.
///
/// Used by History and Earnings list endpoints for infinite scroll.
class PaginationMeta {
  final int totalCount;
  final int totalPages;
  final int currentPage;
  final int limit;
  final bool hasMore;

  PaginationMeta({
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.limit,
    required this.hasMore,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      totalCount: json['total_count'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 1,
      currentPage: json['current_page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      hasMore: json['has_more'] as bool? ?? false,
    );
  }
}