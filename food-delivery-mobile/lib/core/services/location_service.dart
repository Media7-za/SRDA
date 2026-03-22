import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../api/api_client.dart';
import '../api/endpoints.dart';
import 'connectivity_service.dart';

/// Result of a location permission request attempt.
enum PermissionRequestResult {
  alreadyGranted,
  granted,
  denied,
  deniedForever,
  unknown,
}

/// GPS location service for driver tracking.
/// 
/// Note: Real background tracking (when app is killed) is currently disabled 
/// after removing background_locator_2. 
///
/// PRD_Driver.md §10: Posts location every 15 seconds while online + active delivery.
/// PRD_Driver.md §12: Queues up to 10 locations persistently, flushes FIFO on reconnect.
class LocationService {
  final ApiClient _apiClient;
  final ConnectivityService _connectivityService;
  final String _driverId;
  
  StreamController<geo.Position>? _positionController;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Database? _queueDb;
  bool _isInitialized = false;
  
  static const int _maxQueueSize = 10;
  static const Duration _postInterval = Duration(seconds: 15);
  
  Timer? _postTimer;
  bool _isPosting = false;
  String? _activeDeliveryId;

  LocationService({
    required ApiClient apiClient,
    required ConnectivityService connectivityService,
    required String driverId,
  })  : _apiClient = apiClient,
        _connectivityService = connectivityService,
        _driverId = driverId;

  /// Stream of current position for UI consumption.
  /// PRD §10: UI can watch this for real-time map updates.
  Stream<geo.Position> get positionStream {
    _positionController ??= StreamController<geo.Position>.broadcast();
    return _positionController!.stream;
  }

  /// Initialize location tracking and persistent queue.
  /// Must be called after permissions are granted.
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Initialize Persistent Queue DB
    await _initQueueDb();

    // 2. Listen for connectivity changes to flush offline queue
    _connectivitySubscription = _connectivityService.onConnectivityChanged.listen(
      (result) {
        if (result != ConnectivityResult.none) {
          _flushOfflineQueue();
        }
      },
    );

    _isInitialized = true;
  }

  /// Initialize SQLite database for local location queue (PRD §12).
  Future<void> _initQueueDb() async {
    final dbPath = await getDatabasesPath();
    _queueDb = await openDatabase(
      join(dbPath, 'location_queue.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE queue (id INTEGER PRIMARY KEY AUTOINCREMENT, location TEXT, recorded_at TEXT)',
        );
      },
      version: 1,
    );
  }

  /// Check if location permissions are granted (PRD §10).
  Future<bool> hasRequiredPermissions() async {
    final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;
    
    final permission = await geo.Geolocator.checkPermission();
    return permission == geo.LocationPermission.whileInUse ||
           permission == geo.LocationPermission.always;
  }

  /// Request location permission with educational context (PRD §10).
  Future<PermissionRequestResult> requestPermission() async {
    final currentPermission = await geo.Geolocator.checkPermission();
    if (currentPermission == geo.LocationPermission.whileInUse ||
        currentPermission == geo.LocationPermission.always) {
      return PermissionRequestResult.alreadyGranted;
    }
    
    final permission = await geo.Geolocator.requestPermission();
    
    switch (permission) {
      case geo.LocationPermission.whileInUse:
      case geo.LocationPermission.always:
        return PermissionRequestResult.granted;
      case geo.LocationPermission.denied:
        return PermissionRequestResult.denied;
      case geo.LocationPermission.deniedForever:
        return PermissionRequestResult.deniedForever;
      default:
        return PermissionRequestResult.unknown;
    }
  }

  /// Start GPS posting — only when online + active delivery (PRD §10).
  /// TODO: Re-implement true background tracking without background_locator_2.
  Future<void> startPosting({String? deliveryId}) async {
    if (!_isInitialized) {
      await initialize();
    }
    if (_isPosting) return;
    
    _activeDeliveryId = deliveryId;
    _isPosting = true;
    
    // Start foreground timer for 15-second interval
    _postTimer = Timer.periodic(_postInterval, (_) => _postLocation());
    
    if (kDebugMode) {
      print('[LocationService] Started posting (delivery: $deliveryId)');
    }
  }

  /// Stop GPS posting — when offline or no active delivery.
  Future<void> stopPosting() async {
    _isPosting = false;
    _postTimer?.cancel();
    _postTimer = null;
    _activeDeliveryId = null;

    if (kDebugMode) {
      print('[LocationService] Stopped posting');
    }
  }

  /// Post current location to backend.
  /// Queues locally if offline (PRD §12).
  Future<void> _postLocation() async {
    if (!_isPosting || _activeDeliveryId == null) {
      return; 
    }

    try {
      final position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );

      _positionController?.add(position);

      final locationData = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'recorded_at': DateTime.now().toIso8601String(),
        'delivery_id': _activeDeliveryId,
      };

      final isOnline = await _connectivityService.isConnected();
      
      if (isOnline) {
        await _apiClient.post(
          Endpoints.driverLocation(_driverId),
          locationData,
        );
        
        if (kDebugMode) {
          print('[LocationService] Posted location: ${position.latitude}, ${position.longitude}');
        }
      } else {
        await _queueLocation(locationData);
        
        if (kDebugMode) {
          print('[LocationService] Offline — queued location');
        }
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('[LocationService] Post location error: $e\n$stack');
      }
    }
  }

  /// Queue location for offline posting (PRD §12: max 10, FIFO, Persistent).
  Future<void> _queueLocation(Map<String, dynamic> location) async {
    if (_queueDb == null) return;

    final count = Sqflite.firstIntValue(
      await _queueDb!.rawQuery('SELECT COUNT(*) FROM queue'),
    ) ?? 0;
    
    if (count >= _maxQueueSize) {
      await _queueDb!.rawQuery(
        'DELETE FROM queue WHERE id = (SELECT MIN(id) FROM queue)',
      );
    }
    
    await _queueDb!.insert('queue', {
      'location': jsonEncode(location),
      'recorded_at': location['recorded_at'],
    });
  }

  /// Flush offline queue in chronological order (PRD §12 Invariant #6).
  Future<void> _flushOfflineQueue() async {
    if (_queueDb == null) return;
    
    final rows = await _queueDb!.query('queue', orderBy: 'id ASC');
    if (rows.isEmpty) return;
    
    if (kDebugMode) {
      print('[LocationService] Flushing ${rows.length} queued locations');
    }

    for (final row in rows) {
      try {
        final locationJSON = row['location'] as String;
        final location = jsonDecode(locationJSON) as Map<String, dynamic>;
        await _apiClient.post(Endpoints.driverLocation(_driverId), location);
        
        await _queueDb!.delete('queue', where: 'id = ?', whereArgs: [row['id']]);
      } catch (e) {
        if (kDebugMode) {
          print('[LocationService] Flush failed at id ${row['id']}: $e — stopping to preserve order');
        }
        break; 
      }
    }
  }

  /// Dispose resources.
  void dispose() {
    stopPosting();
    _positionController?.close();
    _connectivitySubscription?.cancel();
    _queueDb?.close();
  }
}