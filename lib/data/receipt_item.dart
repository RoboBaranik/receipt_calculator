import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_payment.dart';
import 'package:receipt_calculator/helper.dart';
import 'package:collection/collection.dart';
import 'package:receipt_calculator/routes.dart';

class Receipt {
  final String id;
  ReceiptGroup group;
  final String name;
  String? currency;
  final DateTime timeCreated;
  final List<ReceiptItem> items;
  Receipt(
      {required this.name,
      required this.items,
      required this.timeCreated,
      required this.group,
      required this.id,
      this.currency = Helper.currency});
  static Receipt fromJson(Map<String, dynamic> json) {
    String name = json['receipt']['unit']['name'] ??
        json['receipt']['organization']['name'] ??
        'Store';
    DateTime timeCreated = Helper.jsonDateParse(json['receipt']['issueDate']) ??
        Helper.jsonDateParse(json['receipt']['createDate']) ??
        DateTime.now();
    ReceiptGroup group = Routes.mockedGroup;
    String id = json['receipt']['receiptId'] ?? '';
    List<ReceiptItem> items = (json['receipt']['items'] as List<dynamic>)
        .map((item) => ReceiptItem.fromJson(item))
        .toList();
    return Receipt(
        name: name,
        items: items,
        timeCreated: timeCreated,
        group: group,
        id: id);
  }

  double get sum {
    if (items.isEmpty) return 0;
    if (!items.every((element) => element.currency == items[0].currency)) {
      debugPrint('Inconsistent currency!');
    }
    return items.map((item) => item.price).sum;
  }

  double getMemberSum(Person member) {
    return items.map((item) {
      Partition? payment = item.getMemberPayment(member);
      return payment != null ? payment.payment : 0.0;
    }).sum;
  }

  List<Partition> getMembersPartitions(List<Person> members) {
    return items
        .expand((item) => item.partsPaid.values)
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

  double getMembersPaymentSum(List<Person> members) {
    return items
        .expand((item) => item.partsPaid.values)
        .where((partition) => members.contains(partition.person))
        .map((partition) => partition.payment)
        .sum;
  }

  double assignedPercent() {
    return getMembersPaymentSum(group.members) / (sum / 100);
  }

  @override
  String toString() {
    return 'Store "$name" from ${Helper.dateTimeToString(timeCreated)} with ${items.length} items in $currency.';
  }
}

class ReceiptItem {
  static const String defaultName = 'Unknown';

  String name;
  int quantity;
  double price;
  final String currency;
  Map<Person, Partition> partsPaid = {};

  ReceiptItem(
      {this.name = ReceiptItem.defaultName,
      this.quantity = 1,
      this.price = 0.0,
      this.currency = 'EUR',
      Map<Person, Partition>? partsPaid}) {
    this.partsPaid = partsPaid ?? {};
  }
  static ReceiptItem fromJson(Map<String, dynamic> json) {
    var q = json['quantity'];
    int quantity = 1;
    if (q is int) {
      quantity = q;
    } else if (q is double) {
      quantity = q.floor();
    }
    return ReceiptItem(
        name: json['name'], quantity: quantity, price: json['price']);
  }

  void update(String name, int quantity, double price) {
    this.name = name;
    this.quantity = quantity;
    this.price = price;
  }

  Partition? getMemberPayment(Person member) {
    return partsPaid.containsKey(member) ? partsPaid[member] : null;
    // partsPaid.where((part) => part.person == member).toList();
    // if (itemPayment.isEmpty) {
    //   return null; //Partition(person: member, payment: 0, displayedPartPaid: '0');
    // }
    // if (itemPayment.length > 1) {
    //   debugPrint('Duplicated parts paid, applying first');
    // }
    // return itemPayment.first;
  }

  double getPriceByQuantityPaid(int quantity) {
    return price / this.quantity * quantity;
  }

  static double getPartitionPercent(int index, List<Partition> partitions) {
    double sum = partitions.map((partition) => partition.payment).sum;
    return partitions.elementAt(index).payment / (sum / 100);
  }

  double assignedPercent([Map<Person, Partition>? parts]) {
    double sum =
        (parts ?? partsPaid).values.map((partition) => partition.payment).sum;
    sum = (sum * 100).round() / 100;
    // debugPrint('Sum: $sum Price: $price. Percent: ${sum / (price / 100)}');
    return (sum / (price / 100)).roundToDouble();
  }

  @override
  String toString() {
    return '$name ($quantity) = $price $currency';
  }
}

class ExpandableReceiptItem {
  final ReceiptItem item;
  final ExpandableController controller;
  ExpandableReceiptItem({required this.item, required this.controller});
}

class Partition {
  final Person person;
  String displayedPartPaid;
  double payment;
  int quantity;

  Partition(
      {required this.person,
      this.payment = 0,
      this.quantity = 0,
      this.displayedPartPaid = '0'});
  static Partition withQuantityOne(Person person, ReceiptItem item) {
    double price = item.getPriceByQuantityPaid(1);
    return Partition(
        person: person,
        quantity: 1,
        payment: price,
        displayedPartPaid: price.toStringAsFixed(2));
  }

  void updateFromNewQuantity(int change, ReceiptItem item) {
    if (change == 0 ||
        quantity + change > item.quantity ||
        quantity + change < 0) {
      return;
    }
    // Don't increase quantity paid if already on the limit
    int sumQuantity =
        item.partsPaid.values.map((payment) => payment.quantity).sum;
    if (item.quantity > 1 && change > 0 && sumQuantity >= item.quantity) {
      return;
    }
    quantity += change;
    payment = item.getPriceByQuantityPaid(quantity);
    displayedPartPaid = paymentToString();
  }

  String paymentToString() {
    return payment.toStringAsFixed(2);
  }

  @override
  String toString() {
    return '$person paid $displayedPartPaid ($payment)';
  }
}
