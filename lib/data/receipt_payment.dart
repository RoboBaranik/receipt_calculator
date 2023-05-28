import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_item.dart';

class Event {
  final PersonGroup group;
  final List<Person> members;
  final List<Receipt> receipts = [];
  final DateTime timeCreated;
  Event({List<Receipt>? receipts, required this.group, DateTime? created})
      : timeCreated = created ?? DateTime.now(),
        members = group.members {
    if (receipts != null && receipts.isNotEmpty) {
      this.receipts.addAll(receipts);
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
    return receipts.map((receipt) {
      if (receipt.paidBy != member) {
        return receipt.getMemberSum(member);
      }
      return members
          .where((member1) => member1 != member)
          .map((m) => -receipt.getMemberSum(m))
          .sum;
    }).sum;
  }

  /// Only receipts not paid by member
  Map<Receipt, Map<ReceiptItem, Partition>> getMembersDebt(Person member) {
    if (!members.contains(member)) {
      debugPrint('${member.name} not in members group: $members');
      return {};
    }
    Map<Receipt, Map<ReceiptItem, Partition>> paymentMap = {};
    var relevantReceipts = receipts.where((receipt) =>
        receipt.getMembersPartitions([member]).isNotEmpty &&
        receipt.paidBy != member);
    for (var receipt in relevantReceipts) {
      var relevantItems =
          receipt.items.where((item) => item.partsPaid.containsKey(member));
      Map<ReceiptItem, Partition> map = {
        for (var item in relevantItems) item: item.partsPaid[member]!
      };
      paymentMap.putIfAbsent(receipt, () => map);
    }
    return paymentMap;
  }

  Map<Receipt, Map<Person, Partition>> getDebtTowardsMember(Person member) {
    if (!members.contains(member)) {
      debugPrint('${member.name} not in members group: $members');
      return {};
    }
    Map<Receipt, Map<Person, Partition>> paymentMap = {};
    var relevantReceipts = receipts.where((receipt) =>
        receipt
            .getMembersPartitions(
                members.where((member1) => member1 != member).toList())
            .isNotEmpty &&
        receipt.paidBy == member);
    for (var receipt in relevantReceipts) {
      // var relevantItems =
      //     receipt.items.where((item) => !item.partsPaid.containsKey(member));
      var relevantPayments = receipt.getMembersPartitions(
          members.where((member1) => member1 != member).toList());
      Map<Person, Partition> map = {
        for (var payment in relevantPayments) payment.person: payment
      };
      paymentMap.putIfAbsent(receipt, () => map);
    }
    return paymentMap;
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

  List<String> allStoresToString([int? maxLength]) {
    // Join duplicate store names with prefixed multiplicator
    List<String> storeNames = receipts
        .map((receipt) => receipt.name)
        //     [
        //   'LIDL',
        //   'Fresh',
        //   'LIDL',
        //   'LIDL',
        //   'Tesco',
        //   'Klas',
        //   'Kaufland',
        //   'Kaufland',
        //   'Test store'
        // ]
        .groupFoldBy((name) => name, (previous, name) {
          if (previous == null) {
            return 1;
          }
          return (previous as int) + 1;
        })
        .entries
        .map((entry) =>
            entry.value > 1 ? '${entry.value}x ${entry.key}' : entry.key)
        .toList();
    storeNames.sort((a, b) => a.length.compareTo(b.length));

    // Return if full string is not longer than max length
    String asString = storeNames.join(', ');
    int overflowSuffixLength = ' and xxx more'.length;
    if (maxLength == null ||
        maxLength <= overflowSuffixLength ||
        asString.length <= maxLength) {
      return [asString];
    }

    // Append the suffix with number of stores to shorten the string
    List<String> shortened = [''];
    int appended = -1;
    for (String name in storeNames) {
      appended++;
      if (shortened[0].isEmpty) {
        if (name.length + overflowSuffixLength > maxLength) {
          shortened[0] = '${storeNames.length} stores';
          break;
        }
        shortened[0] = name;
      } else {
        if (shortened[0].length + name.length + overflowSuffixLength >
            maxLength) {
          shortened.add(' and ${storeNames.length - appended} more');
          break;
        }
        shortened[0] += ', $name';
      }
    }
    return shortened;
  }

  @override
  String toString() {
    // TODO: implement toString
    return 'Event of group ${group.toString()} created in $timeCreated with ${receipts.length} receipts';
  }
}

class PersonGroup {
  final List<Person> members;
  String name;
  PersonGroup({required this.members, this.name = ''});
  @override
  String toString() {
    if (name.isNotEmpty) {
      return name;
    }
    return members
        .map((member) => member.name)
        .reduce((memberNames, memberName) {
      if (memberNames.isEmpty) {
        return memberName;
      }
      return '$memberNames, $memberName';
    });
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
