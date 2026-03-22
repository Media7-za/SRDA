/// Model for a queued location point during offline periods.
/// 
/// Reference: PRD_Driver.md §12 Offline Data Queueing
class LocationQueueItem {
  final double latitude;
  final double longitude;
  final DateTime recordedAt;
  final String? deliveryId;

  LocationQueueItem({
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

  factory LocationQueueItem.fromJson(Map<String, dynamic> json) {
    return LocationQueueItem(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      recordedAt: DateTime.parse(json['recorded_at'] as String).toLocal(),
      deliveryId: json['delivery_id'] as String?,
    );
  }
}
