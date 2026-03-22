import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';

/// Service for secure storage of JWT tokens.
/// 
/// Reference: PRD_Driver.md §15 Invariant #7
class TokenService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Read the stored JWT.
  Future<String?> getToken() async {
    return await _storage.read(key: AppConfig.jwtStorageKey);
  }

  /// Store a JWT securely.
  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConfig.jwtStorageKey, value: token);
  }

  /// Clear the stored JWT.
  Future<void> clearToken() async {
    await _storage.delete(key: AppConfig.jwtStorageKey);
  }
}

final tokenServiceProvider = Provider<TokenService>((ref) {
  return TokenService();
});
