class AuthException implements Exception {
  final String message;
  final String code;

  AuthException(this.message, {required this.code});

  @override
  String toString() => 'AuthException: $message (code: $code)';

  // Canonical codes
  static const String unknown = 'UNKNOWN_ERROR';
  static const String networkError = 'NETWORK_ERROR';
  static const String invalidCredentials = 'INVALID_CREDENTIALS';
  static const String forbidden = 'FORBIDDEN';
  static const String malformedResponse = 'MALFORMED_RESPONSE';
  static const String reAuthRequired = 'RE_AUTH_REQUIRED';
  static const String refreshFailed = 'REFRESH_FAILED';
}
