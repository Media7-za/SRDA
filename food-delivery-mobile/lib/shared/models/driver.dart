class Driver {
  final String id;
  final String userId;
  final String restaurantId;
  final String status; // online, offline
  final double? lastLatitude;
  final double? lastLongitude;
  final DateTime? lastLocationAt;

  Driver({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.status,
    this.lastLatitude,
    this.lastLongitude,
    this.lastLocationAt,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      restaurantId: json['restaurant_id'] as String,
      status: json['status'] as String,
      lastLatitude: (json['current_location']?['lat'] as num?)?.toDouble(),
      lastLongitude: (json['current_location']?['lng'] as num?)?.toDouble(),
      lastLocationAt: json['last_location_at'] != null ? DateTime.parse(json['last_location_at'] as String) : null,
    );
  }
}
