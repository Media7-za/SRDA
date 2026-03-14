/// App-wide configuration constants.
///
/// API base URL is injected via `--dart-define` at build time.
/// Never hardcode environment-specific values here.
///
/// Reference: PRD_Driver.md §3, Critical Failure #4
class AppConfig {
  AppConfig._();

  // --- API Configuration ---
  /// Injected via: `flutter run --dart-define=API_BASE_URL=https://...`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  // --- Secure Storage Keys ---
  static const String jwtStorageKey = 'driver_jwt_token';
  static const String refreshTokenKey = 'driver_refresh_token';

  // --- GPS Configuration (PRD §10) ---
  /// Interval between GPS posts during active delivery.
  static const Duration gpsPostInterval = Duration(seconds: 15);

  /// Maximum queued location points when offline (PRD §12).
  static const int maxLocationQueueSize = 10;

  /// Minimum movement in meters before a new location is recorded.
  static const int gpsDistanceFilter = 10;

  // --- Timeouts ---
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // --- Delivery Completion ---
  /// Seconds to show "Delivery complete!" before redirecting (PRD §7).
  static const Duration completionScreenDuration = Duration(seconds: 3);
}