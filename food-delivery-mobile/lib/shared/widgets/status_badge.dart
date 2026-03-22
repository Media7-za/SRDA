import 'package:flutter/material.dart';
import '../models/delivery.dart';

class StatusBadge extends StatelessWidget {
  final DeliveryStatus status;
  
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case DeliveryStatus.assigned:
        color = Colors.orange;
        label = 'ASSIGNED';
        break;
      case DeliveryStatus.pickedUp:
        color = Colors.purple;
        label = 'PICKED UP';
        break;
      case DeliveryStatus.onTheWay:
        color = Colors.blue;
        label = 'ON THE WAY';
        break;
      case DeliveryStatus.delivered:
        color = Colors.green;
        label = 'DELIVERED';
        break;
      case DeliveryStatus.failed:
        color = Colors.red;
        label = 'FAILED';
        break;
      case DeliveryStatus.cancelled:
        color = Colors.grey;
        label = 'CANCELLED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
