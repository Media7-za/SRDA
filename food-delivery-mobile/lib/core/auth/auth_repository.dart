import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../config/app_config.dart';
import 'auth_exception.dart';
import 'token_service.dart';

/// Repository for authentication API calls.
/// Uses TokenService for actual storage to break circular dependencies.
class AuthRepository {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  AuthRepository({
    required ApiClient apiClient,
    required TokenService tokenService,
  })  : _apiClient = apiClient,
        _tokenService = tokenService;

  Future<String?> getToken() => _tokenService.getToken();
  
  Future<void> clearToken() => _tokenService.clearToken();

  Future<String> login(String email, String password) async {
    try {
      final envelope = await _apiClient.post(
        Endpoints.login,
        {'email': email, 'password': password},
      );

      if (envelope.success && envelope.data != null) {
        final data = envelope.data as Map<String, dynamic>;
        final token = data['token'] as String?;
        if (token == null || token.isEmpty) {
          throw AuthException(
            'Invalid authentication response',
            code: AuthException.malformedResponse,
          );
        }
        await _tokenService.saveToken(token);
        return token;
      } else {
        final errorCode = envelope.error?.code;
        final errorMsg = envelope.error?.message ?? 'Login failed';
        throw AuthException(errorMsg, code: errorCode ?? AuthException.unknown);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException(
          'Invalid email or password',
          code: AuthException.invalidCredentials,
        );
      }
      throw AuthException(
        'Unable to connect to server',
        code: AuthException.networkError,
      );
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(Endpoints.logout, {});
    } catch (_) {
      // Best effort
    } finally {
      await _tokenService.clearToken();
    }
  }

  Future<void> refreshToken() async {
    final token = await _tokenService.getToken();
    final response = await Dio().post(
      '${AppConfig.baseUrl}${Endpoints.refresh}',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      final newToken = data['data']['token'] as String;
      await _tokenService.saveToken(newToken);
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});