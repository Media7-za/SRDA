class OrderSummary {
  final String id;
  final String shortId;
  final String status;
  final String? specialInstructions;
  final List<OrderItem> items;

  OrderSummary({
    required this.id,
    required this.shortId,
    required this.status,
    this.specialInstructions,
    this.items = const [],
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      id: json['id'] as String,
      shortId: json['short_id'] as String? ?? json['id'].toString().substring(0, 6).toUpperCase(),
      status: json['status'] as String,
      specialInstructions: json['special_instructions'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class OrderItem {
  final String name;
  final int quantity;

  OrderItem({required this.name, required this.quantity});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'] as String,
      quantity: json['quantity'] as int,
    );
  }
}
