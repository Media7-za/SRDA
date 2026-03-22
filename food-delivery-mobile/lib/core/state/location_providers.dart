import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/connectivity_service.dart';
import '../api/api_client.dart';
import '../auth/auth_notifier.dart';
import '../state/driver_status_notifier.dart';

/// StreamProvider for real-time driver position.
/// 
/// Watches LocationService.positionStream and emits Position? for UI consumption.
/// PRD §10: UI can watch this for map updates without polling.
final currentPositionProvider = StreamProvider<Position?>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return locationService.positionStream;
});

/// Provider for LocationService instance.
/// 
/// Requires authenticated driverId from AuthNotifier.
/// PRD §10: Handles start/stop lifecycle based on driver status.
final locationServiceProvider = Provider<LocationService>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final driverId = switch (authState) {
    Authenticated(:final driverId) => driverId,
    _ => throw StateError('LocationService requires authenticated driver'),
  };
  
  final service = LocationService(
    apiClient: ref.read(apiClientProvider),
    connectivityService: ref.read(connectivityServiceProvider),
    driverId: driverId,
  );

  // Fix #3: Defer initialization to startPosting() (Lazy Init)
  // service.initialize(); // REMOVED

  // Start/Stop tracking based on Driver Status (PRD §10)
  // Posting only triggers if Online AND active delivery
  ref.listen(driverStatusProvider, (previous, next) {
    if (next.isOnline && next.hasActiveDelivery) {
      service.startPosting(); // This will await initialize() internally
    } else {
      service.stopPosting();
    }
  }, fireImmediately: true);
  
  return service;
});

/// Provider for ConnectivityService.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  service.initialize();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Notifier to manage GPS permission state for UI.
/// 
/// Delegate to LocationService (PRD §10).
class LocationPermissionNotifier extends StateNotifier<LocationPermissionState> {
  final LocationService _locationService;
  
  LocationPermissionNotifier(this._locationService) : super(const LocationPermissionState());

  /// Check current permission status.
  Future<void> checkPermission() async {
    state = const LocationPermissionState(isChecking: true);
    
    try {
      final hasPermission = await _locationService.hasRequiredPermissions();
      
      state = LocationPermissionState(
        hasPermission: hasPermission,
        isDenied: !hasPermission,
      );
    } catch (e) {
      state = const LocationPermissionState(hasError: true);
    }
  }

  /// Request location permission with educational context (PRD §10).
  Future<bool> requestPermission() async {
    state = const LocationPermissionState(isRequesting: true);
    
    try {
      final result = await _locationService.requestPermission();
      
      final granted = result == PermissionRequestResult.granted ||
                      result == PermissionRequestResult.alreadyGranted;
      
      state = LocationPermissionState(
        hasPermission: granted,
        isDenied: !granted,
      );
      
      return granted;
    } catch (e) {
      state = const LocationPermissionState(hasError: true);
      return false;
    }
  }
}

/// State for location permission UI.
class LocationPermissionState {
  final bool hasPermission;
  final bool isDenied;
  final bool isChecking;
  final bool isRequesting;
  final bool hasError;

  const LocationPermissionState({
    this.hasPermission = false,
    this.isDenied = false,
    this.isChecking = false,
    this.isRequesting = false,
    this.hasError = false,
  });
}

final locationPermissionProvider = 
    StateNotifierProvider<LocationPermissionNotifier, LocationPermissionState>(
  (ref) {
    final service = ref.watch(locationServiceProvider);
    return LocationPermissionNotifier(service);
  },
);
