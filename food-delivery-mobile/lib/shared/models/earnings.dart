class EarningsSummary {
  final double weeklyTotal;
  final int weeklyCount;
  final double monthlyTotal;
  final int monthlyCount;
  final String currency;

  EarningsSummary({
    required this.weeklyTotal,
    required this.weeklyCount,
    required this.monthlyTotal,
    required this.monthlyCount,
    this.currency = 'ZAR',
  });

  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      weeklyTotal: (json['weekly_total'] as num).toDouble(),
      weeklyCount: json['weekly_count'] as int,
      monthlyTotal: (json['monthly_total'] as num).toDouble(),
      monthlyCount: json['monthly_count'] as int,
      currency: json['currency'] as String? ?? 'ZAR',
    );
  }
}

class EarningsRecord {
  final String orderShortId;
  final double fee;
  final DateTime date;

  EarningsRecord({
    required this.orderShortId,
    required this.fee,
    required this.date,
  });

  factory EarningsRecord.fromJson(Map<String, dynamic> json) {
    return EarningsRecord(
      orderShortId: json['order_short_id'] as String,
      fee: (json['fee'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }
}
