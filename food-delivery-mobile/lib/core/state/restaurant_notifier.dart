import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';

/// Restaurant features configuration.
///
/// Reference: PRD_Driver.md §15 Invariant #8
class RestaurantFeatures {
  final bool earningsEnabled;

  const RestaurantFeatures({
    this.earningsEnabled = false,
  });

  factory RestaurantFeatures.fromJson(Map<String, dynamic> json) {
    // Expected path: json['features']['earnings_enabled']
    final features = json['features'] as Map<String, dynamic>? ?? {};
    return RestaurantFeatures(
      earningsEnabled: features['earnings_enabled'] as bool? ?? false,
    );
  }
}

/// Notifier for restaurant configuration — gates UI features like Earnings.
class RestaurantNotifier extends StateNotifier<RestaurantFeatures?> {
  final ApiClient _apiClient;

  RestaurantNotifier(this._apiClient) : super(null);

  /// Fetch features for the given restaurant.
  /// API: GET /api/restaurants/:id
  Future<void> fetchFeatures(String restaurantId) async {
    try {
      final envelope = await _apiClient.get('/api/restaurants/$restaurantId');
      if (envelope.success && envelope.data != null) {
        state = RestaurantFeatures.fromJson(envelope.data as Map<String, dynamic>);
      }
    } catch (e) {
      // ignore: avoid_print
      print('[RestaurantNotifier] Failed to fetch features: $e');
      // Keep state as null or use default if it was never loaded
    }
  }
}

final restaurantFeaturesProvider = StateNotifierProvider<RestaurantNotifier, RestaurantFeatures?>((ref) {
  return RestaurantNotifier(ref.read(apiClientProvider));
});
