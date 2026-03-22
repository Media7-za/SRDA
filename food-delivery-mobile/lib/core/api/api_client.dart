import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../auth/token_service.dart';
import 'api_response.dart';
import 'endpoints.dart';

/// Centralized HTTP client with JWT injection, 401 refresh, and 409 conflict handling.
class ApiClient {
  final Dio _dio;
  final TokenService _tokenService;
  bool _isRefreshing = false;

  ApiClient({
    required TokenService tokenService,
  })  : _tokenService = tokenService,
        _dio = Dio(BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
          headers: {'Content-Type': 'application/json'},
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        final statusCode = error.response?.statusCode;

        if (statusCode == 401 && !_isRefreshing) {
          _isRefreshing = true;
          try {
            await _performRefresh();
            final token = await _tokenService.getToken();
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            final response = await _dio.fetch(error.requestOptions);
            _isRefreshing = false;
            return handler.resolve(response);
          } catch (e) {
            await _tokenService.clearToken();
            _isRefreshing = false;
          }
        }

        if (statusCode == 409) {
          final responseData = error.response?.data;
          if (responseData is Map<String, dynamic>) {
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

  /// Perform token refresh using a clean Dio instance to avoid interceptor recursion.
  Future<void> _performRefresh() async {
    final token = await _tokenService.getToken();
    final response = await Dio().post(
      '${AppConfig.baseUrl}${Endpoints.refresh}',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    
    if (response.statusCode == 200) {
      final envelope = ApiEnvelope.fromJson(response.data);
      if (envelope.success && envelope.data != null) {
        final newToken = (envelope.data as Map<String, dynamic>)['token'] as String;
        await _tokenService.saveToken(newToken);
        return;
      }
    }
    throw Exception('Refresh failed');
  }

  Future<ApiEnvelope> get(String path, {Map<String, dynamic>? queryParams}) async {
    final response = await _dio.get(path, queryParameters: queryParams);
    return _parseEnvelope(response);
  }

  Future<ApiEnvelope> post(String path, dynamic data) async {
    final response = await _dio.post(path, data: data);
    return _parseEnvelope(response);
  }

  Future<ApiEnvelope> patch(String path, dynamic data) async {
    final response = await _dio.patch(path, data: data);
    return _parseEnvelope(response);
  }

  ApiEnvelope _parseEnvelope(Response response) {
    if (response.data is Map<String, dynamic>) {
      return ApiEnvelope.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('Invalid API response format');
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenService = ref.read(tokenServiceProvider);
  return ApiClient(tokenService: tokenService);
});