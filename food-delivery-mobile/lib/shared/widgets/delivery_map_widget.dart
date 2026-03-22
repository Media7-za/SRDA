import 'dart:math' show min, max;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../shared/models/delivery.dart';

/// Interactive map widget for the Active Delivery screen.
/// 
/// PRD_Driver.md §7: Shows route from driver to next destination (pickup or dropoff).
/// Real-time driver position updates via currentPosition stream.
class DeliveryMapWidget extends StatefulWidget {
  final Delivery delivery;
  final Position? currentPosition;

  const DeliveryMapWidget({
    super.key,
    required this.delivery,
    this.currentPosition,
  });

  @override
  State<DeliveryMapWidget> createState() => _DeliveryMapWidgetState();
}

class _DeliveryMapWidgetState extends State<DeliveryMapWidget> {
  GoogleMapController? _mapController;
  static const double _cameraJitterThresholdMeters = 50.0;

  @override
  Widget build(BuildContext context) {
    final markers = _buildMarkers();
    final polylines = _buildPolylines();
    
    // Default to Cape Town if no position (fallback)
    final initialPosition = widget.currentPosition != null 
        ? LatLng(widget.currentPosition!.latitude, widget.currentPosition!.longitude)
        : const LatLng(-33.9249, 18.4241);

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 14,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
        _fitMapToBounds(); // Initial bounds fit
      },
      markers: markers,
      polylines: polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      mapType: MapType.normal,
    );
  }

  /// Build markers for pickup and dropoff locations.
  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    // 1. Pickup Marker (Orange)
    if (widget.delivery.pickupLatitude != null && 
        widget.delivery.pickupLongitude != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(
            widget.delivery.pickupLatitude!, 
            widget.delivery.pickupLongitude!,
          ),
          infoWindow: InfoWindow(
            title: 'Pickup',
            snippet: widget.delivery.pickupAddress,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      );
    }

    // 2. Dropoff Marker (Red)
    if (widget.delivery.dropoffLatitude != null && 
        widget.delivery.dropoffLongitude != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('dropoff'),
          position: LatLng(
            widget.delivery.dropoffLatitude!, 
            widget.delivery.dropoffLongitude!,
          ),
          infoWindow: InfoWindow(
            title: 'Dropoff',
            snippet: widget.delivery.dropoffAddress,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    return markers;
  }

  /// Build route polyline from driver to next destination.
  /// PRD §7: Route changes based on delivery status.
  Set<Polyline> _buildPolylines() {
    if (widget.currentPosition == null) return {};
    
    final driverPos = LatLng(
      widget.currentPosition!.latitude, 
      widget.currentPosition!.longitude,
    );
    
    // Determine destination based on status (PRD §7)
    LatLng? destination;
    if (widget.delivery.status == DeliveryStatus.assigned) {
      // Route to pickup
      if (widget.delivery.pickupLatitude != null) {
        destination = LatLng(
          widget.delivery.pickupLatitude!, 
          widget.delivery.pickupLongitude!,
        );
      }
    } else if (widget.delivery.status == DeliveryStatus.pickedUp || 
               widget.delivery.status == DeliveryStatus.onTheWay) {
      // Route to dropoff
      if (widget.delivery.dropoffLatitude != null) {
        destination = LatLng(
          widget.delivery.dropoffLatitude!, 
          widget.delivery.dropoffLongitude!,
        );
      }
    }
    
    if (destination == null) return {};
    
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: [driverPos, destination],
        color: Colors.blue,
        width: 5,
        geodesic: true, // Follows Earth's curvature for accurate routing
      ),
    };
  }

  /// Animate camera when position or status changes.
  @override
  void didUpdateWidget(covariant DeliveryMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animate camera when driver position updates significantly
    if (widget.currentPosition != null && 
        widget.currentPosition != oldWidget.currentPosition && 
        _mapController != null) {
      
      final newLatLng = LatLng(
        widget.currentPosition!.latitude, 
        widget.currentPosition!.longitude,
      );
      
      // Only animate if position changed by >50 meters to avoid jitter (PRD §10)
      if (oldWidget.currentPosition != null) {
        final distance = Geolocator.distanceBetween(
          oldWidget.currentPosition!.latitude,
          oldWidget.currentPosition!.longitude,
          widget.currentPosition!.latitude,
          widget.currentPosition!.longitude,
        );
        if (distance < _cameraJitterThresholdMeters) return;
      }
      
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(newLatLng, 16),
      );
    }
    
    // Refocus camera when status changes (assigned → picked_up → on_the_way)
    if (widget.delivery.status != oldWidget.delivery.status && _mapController != null) {
      _fitMapToBounds();
    }
  }

  /// Fit map bounds to show driver + pickup + dropoff.
  void _fitMapToBounds() {
    final points = <LatLng>[];
    
    if (widget.currentPosition != null) {
      points.add(LatLng(
        widget.currentPosition!.latitude, 
        widget.currentPosition!.longitude,
      ));
    }
    if (widget.delivery.pickupLatitude != null) {
      points.add(LatLng(
        widget.delivery.pickupLatitude!, 
        widget.delivery.pickupLongitude!,
      ));
    }
    if (widget.delivery.dropoffLatitude != null) {
      points.add(LatLng(
        widget.delivery.dropoffLatitude!, 
        widget.delivery.dropoffLongitude!,
      ));
    }
    
    if (points.length >= 2 && _mapController != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              points.map((p) => p.latitude).reduce(min),
              points.map((p) => p.longitude).reduce(min),
            ),
            northeast: LatLng(
              points.map((p) => p.latitude).reduce(max),
              points.map((p) => p.longitude).reduce(max),
            ),
          ),
          50, // padding in pixels
        ),
      );
    }
  }

  @override
  void dispose() {
    _mapController = null;
    super.dispose();
  }
}
