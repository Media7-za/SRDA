/// Canonical API endpoint constants for the Driver App.
/// 
/// All API paths are defined here as the single source of truth.
/// Repositories import this file — screens and notifiers never reference
/// raw URL strings directly.
/// 
/// Reference: PRD_Driver.md §13, driver-api.yaml
class Endpoints {
  Endpoints._();

  // --- Authentication ---
  static const String login = '/api/auth/driver/login';
  static const String logout = '/api/auth/driver/logout';
  static const String refresh = '/api/auth/driver/refresh';

  // --- Driver Profile & Status ---
  static String driverProfile(String driverId) => '/api/drivers/$driverId';
  static String driverStatus(String driverId) => '/api/drivers/$driverId/status';

  // --- GPS Location ---
  static String driverLocation(String driverId) => '/api/drivers/$driverId/location';

  // --- FCM Device Token ---
  static String fcmToken(String driverId) => '/api/drivers/$driverId/fcm-token';

  // --- Deliveries ---
  static String activeDelivery(String driverId) => '/api/drivers/$driverId/deliveries/active';
  static String deliveryDetail(String deliveryId) => '/api/deliveries/$deliveryId';
  static String deliveryStatus(String deliveryId) => '/api/deliveries/$deliveryId/status';
  static String deliveryHistory(String driverId) => '/api/drivers/$driverId/deliveries';

  // --- Earnings (Tenant-Gated) ---
  static String earningsSummary(String driverId) => '/api/drivers/$driverId/earnings/summary';
  static String earningsHistory(String driverId) => '/api/drivers/$driverId/earnings/history';
}
