import 'dart:async';
import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../config/app_config.dart';

/// GPS location posting service.
///
/// Handles:
/// - 15-second interval posting during active deliveries (PRD §10)
/// - Offline queue with max 10 points, FIFO flush (PRD §12)
/// - Permission management (PRD §10 Permission Request Flow)
///
/// Reference: PRD_Driver.md §10, §12
abstract class LocationService {
  /// Stream of position updates from the device.
  Stream<Position> get locationStream;

  /// Start posting GPS coordinates to the backend.
  Future<void> startPosting({required String driverId, String? deliveryId});

  /// Stop posting GPS coordinates.
  Future<void> stopPosting();

  /// Whether the service is actively posting.
  bool get isPosting;

  /// Number of queued offline location points.
  int get queuedCount;

  /// Check and request location permissions.
  /// Returns true if permissions are granted.
  Future<LocationPermissionResult> checkAndRequestPermission();

  /// Flush any queued offline points (FIFO order).
  Future<void> flushQueue();
}

/// Result of a permission check.
enum LocationPermissionResult {
  granted,
  denied,
  deniedForever,
}

/// A queued location point for offline posting.
class QueuedLocationPoint {
  final double latitude;
  final double longitude;
  final DateTime recordedAt;
  final String? deliveryId;

  QueuedLocationPoint({
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    this.deliveryId,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'recorded_at': recordedAt.toUtc().toIso8601String(),
        'delivery_id': deliveryId,
      };
}

/// Production implementation of [LocationService].
///
/// Note: Background location init (background_locator_2) is TODO —
/// requires platform-specific setup and real-device testing.
class ProductionLocationService implements LocationService {
  final ApiClient _apiClient;

  Timer? _postingTimer;
  String? _driverId;
  String? _deliveryId;
  bool _isPosting = false;

  /// Offline queue — max [AppConfig.maxLocationQueueSize] points.
  /// Flushed FIFO on reconnection (PRD §12, §15 Invariant #6).
  final Queue<QueuedLocationPoint> _offlineQueue = Queue();

  ProductionLocationService(this._apiClient);

  @override
  Stream<Position> get locationStream => Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: AppConfig.gpsDistanceFilter,
        ),
      );

  @override
  bool get isPosting => _isPosting;

  @override
  int get queuedCount => _offlineQueue.length;

  @override
  Future<LocationPermissionResult> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionResult.denied;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationPermissionResult.denied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionResult.deniedForever;
    }

    return LocationPermissionResult.granted;
  }

  @override
  Future<void> startPosting({
    required String driverId,
    String? deliveryId,
  }) async {
    _driverId = driverId;
    _deliveryId = deliveryId;
    _isPosting = true;

    // PRD §10: Post every 15 seconds
    _postingTimer?.cancel();
    _postingTimer = Timer.periodic(AppConfig.gpsPostInterval, (_) {
      _postCurrentLocation();
    });

    // Post immediately on start
    await _postCurrentLocation();
  }

  @override
  Future<void> stopPosting() async {
    _postingTimer?.cancel();
    _postingTimer = null;
    _isPosting = false;
    _deliveryId = null;
  }

  @override
  Future<void> flushQueue() async {
    if (_driverId == null || _offlineQueue.isEmpty) return;

    // PRD §12, §15 Invariant #6: Flush oldest-first (FIFO), sequential.
    while (_offlineQueue.isNotEmpty) {
      final point = _offlineQueue.first;
      try {
        await _apiClient.post(
          Endpoints.driverLocation(_driverId!),
          point.toJson(),
        );
        _offlineQueue.removeFirst(); // Only remove on success
      } catch (_) {
        // Network still down — stop flushing, try again later
        break;
      }
    }
  }

  /// Post the current device location to the backend.
  Future<void> _postCurrentLocation() async {
    if (_driverId == null) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final payload = QueuedLocationPoint(
        latitude: position.latitude,
        longitude: position.longitude,
        recordedAt: DateTime.now(),
        deliveryId: _deliveryId,
      );

      try {
        await _apiClient.post(
          Endpoints.driverLocation(_driverId!),
          payload.toJson(),
        );
      } catch (_) {
        // Network failure — queue the point (PRD §12)
        _enqueue(payload);
      }
    } catch (_) {
      // Location unavailable — skip this interval
    }
  }

  /// Add a point to the offline queue, respecting the max size.
  void _enqueue(QueuedLocationPoint point) {
    if (_offlineQueue.length >= AppConfig.maxLocationQueueSize) {
      _offlineQueue.removeFirst(); // Drop oldest to make room
    }
    _offlineQueue.addLast(point);
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return ProductionLocationService(ref.read(apiClientProvider));
});