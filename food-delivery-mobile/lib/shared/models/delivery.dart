import 'delivery_status.dart';

/// Delivery model matching the `Delivery` schema in `driver-api.yaml`.
///
/// Pure data class — no business logic.
/// Uses [DeliveryStatus] enum for type-safe status handling.
///
/// Reference: PRD_Driver.md §4, §7; driver-api.yaml Delivery schema
class Delivery {
  final String id;
  final String orderShortId;
  final DeliveryStatus status;
  final String pickupAddress;
  final String dropoffAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? dropoffLatitude;
  final double? dropoffLongitude;
  final String customerName;
  final String? customerContactPhone; // Masked or proxied per tenant config
  final String? specialInstructions;
  final List<DeliveryItem> items;
  final DateTime? createdAt;

  Delivery({
    required this.id,
    required this.orderShortId,
    required this.status,
    required this.pickupAddress,
    required this.dropoffAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffLatitude,
    this.dropoffLongitude,
    required this.customerName,
    this.customerContactPhone,
    this.specialInstructions,
    required this.items,
    this.createdAt,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] as String,
      orderShortId: json['order_short_id'] as String,
      status: DeliveryStatus.fromString(json['status'] as String),
      pickupAddress: json['pickup_address'] as String,
      dropoffAddress: json['dropoff_address'] as String,
      pickupLatitude: (json['dropoff_coordinates'] as Map<String, dynamic>?)?['latitude'] as double?,
      pickupLongitude: (json['pickup_coordinates'] as Map<String, dynamic>?)?['longitude'] as double?,
      dropoffLatitude: (json['dropoff_coordinates'] as Map<String, dynamic>?)?['latitude'] as double?,
      dropoffLongitude: (json['dropoff_coordinates'] as Map<String, dynamic>?)?['longitude'] as double?,
      customerName: json['customer_name'] as String,
      customerContactPhone: json['customer_contact_phone'] as String?,
      specialInstructions: json['special_instructions'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => DeliveryItem.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Convenience: the destination coordinates based on current status.
  /// While [assigned] → pickup (restaurant). Otherwise → dropoff (customer).
  /// Reference: PRD_Driver.md §7 Map Display
  double? get destinationLatitude =>
      status == DeliveryStatus.assigned ? pickupLatitude : dropoffLatitude;

  double? get destinationLongitude =>
      status == DeliveryStatus.assigned ? pickupLongitude : dropoffLongitude;

  /// Convenience: the destination address based on current status.
  String get destinationAddress =>
      status == DeliveryStatus.assigned ? pickupAddress : dropoffAddress;
}

class DeliveryItem {
  final String name;
  final int quantity;
  final List<String>? modifiers;

  DeliveryItem({required this.name, required this.quantity, this.modifiers});

  factory DeliveryItem.fromJson(Map<String, dynamic> json) {
    return DeliveryItem(
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      modifiers: json['modifiers'] != null
          ? List<String>.from(json['modifiers'] as List)
          : null,
    );
  }
}