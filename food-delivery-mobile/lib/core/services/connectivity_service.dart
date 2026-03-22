import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Monitors network connectivity and exposes connection state.
///
/// Used by LocationService to determine when to flush offline location queue.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _subscription;
  final _controller = StreamController<ConnectivityResult>.broadcast();

  /// Stream of connectivity changes for other services to watch.
  /// Emits single ConnectivityResult values (not lists) per connectivity_plus ^5.0.2
  Stream<ConnectivityResult> get onConnectivityChanged => _controller.stream;

  /// Initialize the service and start listening for changes.
  void initialize() {
    // onConnectivityChanged emits ConnectivityResult (single), NOT List<ConnectivityResult>
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      if (kDebugMode) {
        print('[ConnectivityService] Changed to: $result');
      }
      _controller.add(result); // Emit the single result directly
    });
  }

  /// Check if device currently has any network connection.
  /// Note: checkConnectivity() returns Future<List<ConnectivityResult>>, so .any() IS valid here.
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      // In version 5.0.2, checkConnectivity returns a single ConnectivityResult
      return result != ConnectivityResult.none;
    } catch (e) {
      if (kDebugMode) {
        print('[ConnectivityService] Connection check failed: $e');
      }
      return false;
    }
  }

  /// Dispose resources.
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
