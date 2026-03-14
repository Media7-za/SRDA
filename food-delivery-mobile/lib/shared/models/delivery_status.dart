/// Canonical delivery status enum matching `driver-api.yaml` schema.
///
/// The Driver App may only *submit* [pickedUp], [onTheWay], [delivered].
/// Other statuses ([assigned], [failed], [cancelled]) are read-only
/// — they are set by the Dashboard or backend.
///
/// Reference: PRD_Driver.md §4, §14; driver-api.yaml PATCH /deliveries/:id/status
enum DeliveryStatus {
  assigned('assigned'),
  pickedUp('picked_up'),
  onTheWay('on_the_way'),
  delivered('delivered'),
  failed('failed'),
  cancelled('cancelled');

  final String value;
  const DeliveryStatus(this.value);

  /// Parse from JSON string. Throws [ArgumentError] on unknown status.
  factory DeliveryStatus.fromString(String status) {
    return DeliveryStatus.values.firstWhere(
      (e) => e.value == status,
      orElse: () => throw ArgumentError('Unknown delivery status: $status'),
    );
  }

  /// Serialize to JSON string.
  String toJson() => value;

  /// Returns the human-readable display label for UI.
  String get displayLabel {
    switch (this) {
      case DeliveryStatus.assigned:
        return 'ASSIGNED';
      case DeliveryStatus.pickedUp:
        return 'PICKED UP';
      case DeliveryStatus.onTheWay:
        return 'ON THE WAY';
      case DeliveryStatus.delivered:
        return 'DELIVERED';
      case DeliveryStatus.failed:
        return 'FAILED';
      case DeliveryStatus.cancelled:
        return 'CANCELLED';
    }
  }

  /// Whether this status allows a driver action (PRD §7 button mapping).
  bool get hasDriverAction =>
      this == assigned || this == pickedUp || this == onTheWay;

  /// Returns the next status in the driver-owned transition sequence.
  /// Returns null for terminal or non-actionable states.
  DeliveryStatus? get nextStatus {
    switch (this) {
      case DeliveryStatus.assigned:
        return DeliveryStatus.pickedUp;
      case DeliveryStatus.pickedUp:
        return DeliveryStatus.onTheWay;
      case DeliveryStatus.onTheWay:
        return DeliveryStatus.delivered;
      default:
        return null;
    }
  }

  /// Button label for the primary action button (PRD §7).
  String? get actionButtonLabel {
    switch (this) {
      case DeliveryStatus.assigned:
        return 'PICKED UP';
      case DeliveryStatus.pickedUp:
        return 'ON THE WAY';
      case DeliveryStatus.onTheWay:
        return 'MARK DELIVERED';
      default:
        return null;
    }
  }

  /// Whether this is a terminal state (no further transitions possible).
  bool get isTerminal => this == delivered || this == failed || this == cancelled;

  /// Whether this is an active delivery state (driver should see it).
  bool get isActive => this == assigned || this == pickedUp || this == onTheWay;
}
