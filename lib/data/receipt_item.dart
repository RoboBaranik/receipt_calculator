import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:receipt_calculator/helper.dart';

class Receipt {
  final String name;
  String? currency;
  final DateTime timeCreated;
  final List<ReceiptItem> items;
  Receipt(
      {required this.name,
      required this.items,
      required this.timeCreated,
      this.currency = Helper.currency});

  double get sum {
    if (items.isEmpty) return 0;
    if (!items.every((element) => element.currency == items[0].currency)) {
      debugPrint('Inconsistent currency!');
    }
    return items
        .map((item) => item.value * item.count)
        .reduce((value, element) => value + element);
  }

  @override
  String toString() {
    return 'Store "$name" from ${Helper.dateTimeToString(timeCreated)} with ${items.length} items in $currency.';
  }
}

class ReceiptItem {
  static const String defaultName = 'Unknown';

  String name;
  int count;
  double value;
  final String currency;
  List<Partition> partsPaid = [];

  ReceiptItem(
      {this.name = ReceiptItem.defaultName,
      this.count = 1,
      this.value = 0.0,
      this.currency = 'EUR',
      List<Partition>? partsPaid}) {
    this.partsPaid = partsPaid ?? [];
  }
  void update(String name, int count, double value) {
    this.name = name;
    this.count = count;
    this.value = value;
  }

  @override
  String toString() {
    return '$name ($count) = $value $currency';
  }
}

class ExpandableReceiptItem {
  final ReceiptItem item;
  final ExpandableController controller;
  ExpandableReceiptItem({required this.item, required this.controller});
}

class Partition {
  final String person;
  int percentPaid;

  Partition({required this.person, this.percentPaid = 0});
}
