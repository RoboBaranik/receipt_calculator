import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_payment.dart';
import 'package:receipt_calculator/helper.dart';
import 'package:collection/collection.dart';

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
    return items.map((item) => item.value * item.count).sum;
  }

  double getMemberSum(Person member) {
    return items.map((item) => item.getMemberPayment(member)).sum;
  }

  List<Partition> getMembersPartitions(List<Person> members) {
    return items
        .expand((item) => item.partsPaid)
        .where((partition) => members.contains(partition.person))
        .groupFoldBy<Person, Partition>((partition) => partition.person,
            (previous, partition) {
          var partitionSum = (previous ?? Partition(person: partition.person));
          partitionSum.payment += partition.payment;
          return partitionSum;
        })
        .values
        .toList();
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

  double getMemberPayment(Person member) {
    List<Partition> itemPayment =
        partsPaid.where((part) => part.person == member).toList();
    if (itemPayment.isEmpty) {
      return 0;
    }
    return itemPayment.map((e) => e.payment).sum;
  }

  static double getPartitionPercent(int index, List<Partition> partitions) {
    double sum = partitions.map((partition) => partition.payment).sum;
    return partitions.elementAt(index).payment / (sum / 100);
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
  final Person person;
  double payment;

  Partition({required this.person, this.payment = 0});

  @override
  String toString() {
    return '$person paid $payment';
  }
}
