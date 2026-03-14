import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// TODO: Add connectivity_plus to pubspec.yaml and uncomment
// import 'package:connectivity_plus/connectivity_plus.dart';

/// Connectivity monitoring service.
///
/// Provides reactive online/offline detection for:
/// - Showing offline banner (PRD §12)
/// - Triggering GPS queue flush on reconnect
/// - Disabling status buttons with retry message
///
/// Reference: PRD_Driver.md §12 Offline Handling
abstract class ConnectivityService {
  /// Stream of connectivity state changes.
  Stream<bool> get onConnectivityChanged;

  /// Current connectivity status.
  bool get isOnline;
}

/// Stub implementation — replace with connectivity_plus when added.
class StubConnectivityService implements ConnectivityService {
  // TODO: Replace with real implementation
  //
  // late final StreamSubscription _subscription;
  // bool _isOnline = true;
  // final _controller = StreamController<bool>.broadcast();
  //
  // StubConnectivityService() {
  //   _subscription = Connectivity().onConnectivityChanged.listen((result) {
  //     _isOnline = result != ConnectivityResult.none;
  //     _controller.add(_isOnline);
  //   });
  // }

  @override
  Stream<bool> get onConnectivityChanged => Stream.value(true);

  @override
  bool get isOnline => true;
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return StubConnectivityService();
});
