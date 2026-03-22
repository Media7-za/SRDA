import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';

/// FCM notification service stub.
///
/// Handles:
/// - FCM token registration on app launch and refresh (PRD §11)
/// - Foreground notification display (in-app modal)
/// - Background/killed notification routing
///
/// Reference: PRD_Driver.md §11, §15 Invariant #10
///
/// TODO: Setup Instructions:
/// 1. Run `flutterfire configure` to generate firebase_options.dart
/// 2. Add google-services.json (Android) and GoogleService-Info.plist (iOS)
/// 3. Uncomment Firebase.initializeApp() in main.dart
/// 4. Uncomment the implementation below
abstract class NotificationService {
  /// Register the device's FCM token with the backend.
  Future<void> registerToken(String driverId);

  /// Initialize foreground and background message handlers.
  Future<void> initializeHandlers();

  /// Check for a notification that launched the app from killed state.
  Future<String?> getInitialDeliveryId();
}

/// Stub implementation — replace with FirebaseMessaging when configured.
class StubNotificationService implements NotificationService {
  StubNotificationService(ApiClient apiClient);

  @override
  Future<void> registerToken(String driverId) async {
    // TODO: Implement when Firebase is configured
    //
    // final token = await FirebaseMessaging.instance.getToken();
    // if (token != null) {
    //   await _apiClient.post(
    //     Endpoints.fcmToken(driverId),
    //     {
    //       'token': token,
    //       'platform': Platform.isAndroid ? 'android' : 'ios',
    //     },
    //   );
    // }
    //
    // // Listen for token refresh (PRD §15 Invariant #10)
    // FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    //   _apiClient.post(
    //     Endpoints.fcmToken(driverId),
    //     {
    //       'token': newToken,
    //       'platform': Platform.isAndroid ? 'android' : 'ios',
    //     },
    //   );
    // });
  }

  @override
  Future<void> initializeHandlers() async {
    // TODO: Implement when Firebase is configured
    //
    // // Foreground: show in-app modal (PRD §6)
    // FirebaseMessaging.onMessage.listen((message) {
    //   final type = message.data['type'];
    //   if (type == 'delivery_assigned') {
    //     // Show modal overlay with delivery info
    //   } else if (type == 'delivery_cancelled') {
    //     // Show cancellation notice
    //   }
    // });
    //
    // // Background → foreground: navigate to delivery (PRD §6)
    // FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //   final deliveryId = message.data['delivery_id'];
    //   if (deliveryId != null) {
    //     // Navigate to /delivery/$deliveryId
    //   }
    // });
  }

  @override
  Future<String?> getInitialDeliveryId() async {
    // TODO: Implement when Firebase is configured
    //
    // final message = await FirebaseMessaging.instance.getInitialMessage();
    // return message?.data['delivery_id'];
    return null;
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return StubNotificationService(ref.read(apiClientProvider));
});
