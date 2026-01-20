enum InvoiceStatus {
  pending,
  paid,
  overdue;

  static InvoiceStatus fromString(String status) {
    return InvoiceStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == status.toLowerCase(),
      orElse: () => InvoiceStatus.pending,
    );
  }
}

enum ItemType {
  fixed,
  hourly;

  static ItemType fromString(String type) {
    return ItemType.values.firstWhere(
      (e) => e.name.toLowerCase() == type.toLowerCase(),
      orElse: () => ItemType.fixed,
    );
  }
}
