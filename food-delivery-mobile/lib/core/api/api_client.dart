import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../auth/auth_repository.dart';
import 'api_response.dart';

/// Centralized HTTP client with JWT injection, 401 refresh, and 409 conflict handling.
///
/// All API calls in the app funnel through this client.
/// Repositories use [get], [post], [patch] — never raw Dio.
///
/// Reference: PRD_Driver.md §3, §13
class ApiClient {
  final Dio _dio;
  final AuthRepository _authRepository;
  final Ref _ref;
  bool _isRefreshing = false;

  ApiClient({
    required Ref ref,
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        _ref = ref,
        _dio = Dio(BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
          headers: {'Content-Type': 'application/json'},
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Inject JWT into every request
        final token = await _authRepository.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        final statusCode = error.response?.statusCode;

        // --- 401 Unauthorized: Attempt silent token refresh ---
        if (statusCode == 401 && !_isRefreshing) {
          _isRefreshing = true;
          try {
            await _authRepository.refreshToken();
            // Retry original request with new token
            final token = await _authRepository.getToken();
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            final response = await _dio.fetch(error.requestOptions);
            _isRefreshing = false;
            return handler.resolve(response);
          } catch (e) {
            // Refresh failed — force re-login (PRD §2: "show a re-login screen")
            await _authRepository.logout();
            _isRefreshing = false;
          }
        }

        // --- 409 Conflict: State machine violation ---
        // Don't swallow — let it propagate as a DioException with the
        // parsed error envelope so notifiers can handle it specifically.
        if (statusCode == 409) {
          // Parse the error envelope from the 409 response body
          final responseData = error.response?.data;
          if (responseData is Map<String, dynamic>) {
            // Wrap in a response so callers can inspect the envelope
            return handler.resolve(Response(
              data: responseData,
              statusCode: 409,
              requestOptions: error.requestOptions,
            ));
          }
        }

        return handler.next(error);
      },
    ));
  }

  /// GET request — returns parsed envelope.
  Future<ApiEnvelope> get(String path, {Map<String, dynamic>? queryParams}) async {
    final response = await _dio.get(path, queryParameters: queryParams);
    return _parseEnvelope(response);
  }

  /// POST request — returns parsed envelope.
  Future<ApiEnvelope> post(String path, dynamic data) async {
    final response = await _dio.post(path, data: data);
    return _parseEnvelope(response);
  }

  /// PATCH request — returns parsed envelope.
  Future<ApiEnvelope> patch(String path, dynamic data) async {
    final response = await _dio.patch(path, data: data);
    return _parseEnvelope(response);
  }

  /// Parse raw Dio response into ApiEnvelope.
  ApiEnvelope _parseEnvelope(Response response) {
    final data = response.data as Map<String, dynamic>;
    return ApiEnvelope.fromJson(data);
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final authRepo = ref.read(authRepositoryProvider);
  return ApiClient(ref: ref, authRepository: authRepo);
});