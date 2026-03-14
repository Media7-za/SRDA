import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../config/app_config.dart';
import 'auth_exception.dart';

/// Repository for authentication API calls and token management.
///
/// JWT is stored in `flutter_secure_storage` ONLY (PRD §15 Invariant #7).
/// Never use SharedPreferences or plain local storage.
class AuthRepository {
  final FlutterSecureStorage _storage;
  final ApiClient _apiClient;

  AuthRepository({required ApiClient apiClient})
      : _apiClient = apiClient,
        _storage = const FlutterSecureStorage();

  /// Read the stored JWT.
  Future<String?> getToken() async {
    return await _storage.read(key: AppConfig.jwtStorageKey);
  }

  /// Store a JWT securely.
  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConfig.jwtStorageKey, value: token);
  }

  /// Clear the stored JWT (local only — use [logout] for full cleanup).
  Future<void> clearToken() async {
    await _storage.delete(key: AppConfig.jwtStorageKey);
  }

  /// Login with email and password.
  /// API: POST /api/auth/driver/login
  ///
  /// Returns the JWT string on success.
  /// Throws [AuthException] with a structured error code on failure.
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
        await saveToken(token);
        return token;
      }

      // Backend returned a structured error
      final errorCode = envelope.error?.code;
      final errorMsg = envelope.error?.message ?? 'Login failed';
      throw AuthException(errorMsg, code: errorCode ?? AuthException.unknown);
    } on AuthException {
      rethrow; // Don't re-wrap our own exceptions
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException(
          'Invalid email or password',
          code: AuthException.invalidCredentials,
        );
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Account not authorized',
          code: AuthException.forbidden,
        );
      }
      throw AuthException(
        'Unable to connect to server',
        code: AuthException.networkError,
      );
    } catch (e) {
      throw AuthException(
        'An unexpected error occurred',
        code: AuthException.unknown,
      );
    }
  }

  /// Logout — clears local token AND invalidates server session.
  /// API: POST /api/auth/driver/logout
  ///
  /// PRD §13: This endpoint must be called to clean up server-side
  /// session and FCM tokens.
  Future<void> logout() async {
    try {
      await _apiClient.post(Endpoints.logout, {});
    } catch (e) {
      // Best-effort — log for diagnostics, still clear local token
      // ignore: avoid_print
      print('[Auth] Logout API failed: $e');
    }
    await clearToken();
  }

  /// Refresh an expired JWT.
  /// API: POST /api/auth/driver/refresh
  ///
  /// Called by ApiClient's 401 interceptor for silent refresh.
  /// Throws [AuthException] with specific code so the interceptor can
  /// distinguish "token expired" (force re-login) vs. "network error".
  Future<void> refreshToken() async {
    try {
      final envelope = await _apiClient.post(Endpoints.refresh, {});

      if (envelope.success && envelope.data != null) {
        final data = envelope.data as Map<String, dynamic>;
        final newToken = data['token'] as String?;
        if (newToken == null || newToken.isEmpty) {
          throw AuthException(
            'Invalid refresh response',
            code: AuthException.malformedResponse,
          );
        }
        await saveToken(newToken);
        return;
      }

      // Check specific backend error code
      final errorCode = envelope.error?.code;
      if (errorCode == 'RE_AUTH_REQUIRED' || errorCode == 'TOKEN_EXPIRED') {
        await clearToken();
        throw AuthException(
          'Session expired',
          code: AuthException.reAuthRequired,
        );
      }

      throw AuthException(
        'Token refresh failed',
        code: AuthException.refreshFailed,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        'Token refresh failed',
        code: AuthException.refreshFailed,
      );
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(apiClient: ref.read(apiClientProvider));
});