import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_item.dart';

class ReceiptGroup {
  final List<Person> members = [];
  final List<Receipt> receipts = [];
  ReceiptGroup({List<Receipt>? receipts, List<Person>? members}) {
    if (receipts != null && receipts.isNotEmpty) {
      this.receipts.addAll(receipts);
    }
    if (members != null && members.isNotEmpty) {
      this.members.addAll(members);
    }
  }
  get totalSum {
    return receipts.map((receipt) => receipt.sum).sum;
  }

  double getMemberPayment(Person member) {
    if (!members.contains(member)) {
      debugPrint('${member.name} not in members group: $members');
      return 0;
    }
    return receipts.map((receipt) => receipt.getMemberSum(member)).sum;
  }

  List<Partition> getPartitionsSum(List<Person> members) {
    if (!members.every((member) {
      bool contains = this.members.contains(member);
      if (!contains) {
        debugPrint('Members ${this.members} do not contain member $member');
      }
      return contains;
    })) {
      debugPrint('One or more members are not part of group: $members');
      return [];
    }
    return receipts
        .map((receipt) => receipt.getMembersPartitions(members))
        .expand((partition) => partition)
        .groupFoldBy<Person, Partition>((partition) => partition.person,
            (previous, partition) {
          var partitionSum = (previous ?? Partition(person: partition.person));
          partitionSum.payment += partition.payment;
          return partitionSum;
        })
        .values
        .toList();
  }
}

class Person {
  String name;
  Person(this.name);

  @override
  String toString() {
    return name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is Person) {
      return name == other.name;
    }
    return this == other;
  }
}
