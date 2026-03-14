/// Structured authentication error for type-safe error handling
/// across AuthRepository → AuthNotifier → UI layers.
class AuthException implements Exception {
  final String message;
  final String code;

  AuthException(this.message, {required this.code});

  /// Well-known error codes
  static const invalidCredentials = 'INVALID_CREDENTIALS';
  static const forbidden = 'FORBIDDEN';
  static const networkError = 'NETWORK_ERROR';
  static const reAuthRequired = 'RE_AUTH_REQUIRED';
  static const refreshFailed = 'REFRESH_FAILED';
  static const malformedResponse = 'MALFORMED_RESPONSE';
  static const unknown = 'UNKNOWN';

  @override
  String toString() => 'AuthException($code): $message';
}
