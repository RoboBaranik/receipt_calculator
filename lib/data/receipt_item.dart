class ReceiptItem {
  static const String defaultName = 'Unknown';

  final String name;
  final int count;
  final double value;
  final String currency;
  List<Partition> partsPaid = [];
  // bool isExpanded = false;

  ReceiptItem(
      {this.name = ReceiptItem.defaultName,
      this.count = 1,
      this.value = 0.0,
      this.currency = 'EUR',
      List<Partition>? partsPaid}) {
    this.partsPaid = partsPaid ?? [];
  }

  @override
  String toString() {
    return '$name ($count) = $value $currency';
  }
}

class Partition {
  final String person;
  int percentPaid;

  Partition({required this.person, this.percentPaid = 0});
}
