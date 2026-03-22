import 'delivery_status.dart';
export 'delivery_status.dart';
import 'order_summary.dart';

class Delivery {
  final String id;
  final String orderId;
  final String restaurantId;
  final String driverId;
  final DeliveryStatus status;
  final String? pickupAddress;
  final String? dropoffAddress;
  
  // Coordinates for map display (PRD §7)
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? dropoffLatitude;
  final double? dropoffLongitude;
  
  // Current driver location (as reported by backend)
  final double? currentLatitude;
  final double? currentLongitude;

  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final OrderSummary? order;

  Delivery({
    required this.id,
    required this.orderId,
    required this.restaurantId,
    required this.driverId,
    required this.status,
    this.pickupAddress,
    this.dropoffAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.currentLatitude,
    this.currentLongitude,
    this.pickedUpAt,
    this.deliveredAt,
    required this.createdAt,
    required this.updatedAt,
    this.order,
  });

  /// Helper to get the next destination coordinate based on status.
  double? get destinationLatitude => status == DeliveryStatus.assigned ? pickupLatitude : dropoffLatitude;
  double? get destinationLongitude => status == DeliveryStatus.assigned ? pickupLongitude : dropoffLongitude;

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      restaurantId: json['restaurant_id'] as String,
      driverId: json['driver_id'] as String,
      status: DeliveryStatus.fromString(json['status'] as String),
      pickupAddress: json['pickup_address'] as String?,
      dropoffAddress: json['dropoff_address'] as String?,
      pickupLatitude: (json['pickup_latitude'] as num?)?.toDouble(),
      pickupLongitude: (json['pickup_longitude'] as num?)?.toDouble(),
      dropoffLatitude: (json['dropoff_latitude'] as num?)?.toDouble(),
      dropoffLongitude: (json['dropoff_longitude'] as num?)?.toDouble(),
      currentLatitude: (json['current_latitude'] as num?)?.toDouble(),
      currentLongitude: (json['current_longitude'] as num?)?.toDouble(),
      pickedUpAt: json['picked_up_at'] != null ? DateTime.parse(json['picked_up_at'] as String) : null,
      deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      order: json['order'] != null ? OrderSummary.fromJson(json['order'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'restaurant_id': restaurantId,
        'driver_id': driverId,
        'status': status.name,
        'pickup_address': pickupAddress,
        'dropoff_address': dropoffAddress,
        'pickup_latitude': pickupLatitude,
        'pickup_longitude': pickupLongitude,
        'dropoff_latitude': dropoffLatitude,
        'dropoff_longitude': dropoffLongitude,
        'current_latitude': currentLatitude,
        'current_longitude': currentLongitude,
        'picked_up_at': pickedUpAt?.toIso8601String(),
        'delivered_at': deliveredAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}