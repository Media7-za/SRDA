/// Single earnings record matching EarningsRecord in driver-api.yaml.
class EarningsRecord {
  final String orderId;
  final String orderShortId;
  final double fee;
  final String currency;
  final DateTime completedAt;

  EarningsRecord({
    required this.orderId,
    required this.orderShortId,
    required this.fee,
    required this.currency,
    required this.completedAt,
  });

  factory EarningsRecord.fromJson(Map<String, dynamic> json) {
    return EarningsRecord(
      orderId: json['id'] as String? ?? json['order_id'] as String,
      orderShortId: json['order_short_id'] as String,
      fee: (json['fee'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'ZAR',
      completedAt: DateTime.parse(json['completed_at'] as String),
    );
  }
}
