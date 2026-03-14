import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_exception.dart';
import 'auth_repository.dart';

/// Authentication states for the app.
abstract class AuthState {}

class Unauthenticated extends AuthState {}

class Authenticated extends AuthState {
  final String driverId;
  final String restaurantId;
  final String driverName;
  Authenticated({
    required this.driverId,
    required this.restaurantId,
    this.driverName = '',
  });
}

class AuthLoading extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

/// Manages authentication state.
///
/// PRD_Driver.md §2: JWT stored in flutter_secure_storage only.
/// On expiry: show re-login screen. Do not silently fail API calls.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(Unauthenticated()) {
    _checkAuthStatus();
  }

  /// On app start: check if we have a valid stored JWT.
  Future<void> _checkAuthStatus() async {
    state = AuthLoading();
    try {
      final token = await _repository.getToken();
      if (token != null) {
        final claims = _decodeJwt(token);
        if (claims != null && !_isTokenExpired(claims)) {
          state = Authenticated(
            driverId: claims['driver_id'] as String? ?? claims['sub'] as String,
            restaurantId: claims['restaurant_id'] as String,
            driverName: claims['name'] as String? ?? '',
          );
          return;
        }
        // Token exists but is expired — try refresh
        try {
          await _repository.refreshToken();
          final newToken = await _repository.getToken();
          final newClaims = _decodeJwt(newToken!);
          if (newClaims != null) {
            state = Authenticated(
              driverId: newClaims['driver_id'] as String? ?? newClaims['sub'] as String,
              restaurantId: newClaims['restaurant_id'] as String,
              driverName: newClaims['name'] as String? ?? '',
            );
            return;
          }
        } catch (_) {
          // Refresh failed — need re-login
          await _repository.clearToken();
        }
      }
      state = Unauthenticated();
    } catch (e) {
      state = Unauthenticated();
    }
  }

  /// Login with email and password.
  /// API: POST /api/auth/driver/login
  Future<void> login(String email, String password) async {
    state = AuthLoading();
    try {
      // Repository now throws AuthException on failure (never returns null)
      final token = await _repository.login(email, password);
      final claims = _decodeJwt(token);
      if (claims != null) {
        state = Authenticated(
          driverId: claims['driver_id'] as String? ?? claims['sub'] as String,
          restaurantId: claims['restaurant_id'] as String,
          driverName: claims['name'] as String? ?? '',
        );
        return;
      }
      state = AuthError('Unable to process login response');
    } on AuthException catch (e) {
      // Structured error from repository — surface the message directly
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError('An unexpected error occurred');
    }
  }

  /// Logout — clears local token and invalidates server session.
  /// API: POST /api/auth/driver/logout
  Future<void> logout() async {
    await _repository.logout();
    state = Unauthenticated();
  }

  /// Force logout (called by 401 interceptor when refresh fails).
  Future<void> forceLogout() async {
    await _repository.clearToken();
    state = Unauthenticated();
  }

  /// Decode JWT payload (base64 segment 1).
  /// Returns null if token is malformed.
  Map<String, dynamic>? _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      // Base64 needs padding
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Check if JWT has expired.
  bool _isTokenExpired(Map<String, dynamic> claims) {
    final exp = claims['exp'] as int?;
    if (exp == null) return true;
    final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expiry);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});