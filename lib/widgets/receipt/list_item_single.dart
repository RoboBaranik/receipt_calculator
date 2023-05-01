import 'dart:ffi';
import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_item.dart';
import 'package:receipt_calculator/data/receipt_payment.dart';
import 'package:receipt_calculator/helper.dart';
import 'package:receipt_calculator/widgets/receipt/list_item_single_controller.dart';

class ListItemSingle extends StatefulWidget {
  final Receipt receipt;
  final int itemIndex;
  final Person member;
  final ReceiptItem item;
  final ListController controller;

  ListItemSingle(
      {super.key,
      required this.receipt,
      required this.itemIndex,
      required this.member,
      required this.controller})
      : item = receipt.items[itemIndex];

  @override
  State<ListItemSingle> createState() => _ListItemSingleState();
}

class _ListItemSingleState extends State<ListItemSingle> {
  bool isSelected = false;
  Color getTextColor() {
    Partition? memberPayment = widget.item.getMemberPayment(widget.member);
    if (memberPayment != null && memberPayment.quantity != 0) {
      debugPrint(
          '${widget.item.name} - Member payment = ${memberPayment.payment}');
      return Colors.black;
    } else {
      debugPrint(
          '${widget.item.name} - Member payment exist = ${memberPayment != null}');
      return Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.controller.onOpen = () {
      setState(() {
        isSelected = true;
      });
    };
    widget.controller.onClose = () {
      setState(() {
        isSelected = false;
      });
    };
    return Stack(
      children: isSelected
          ? [backgroundPayment(), mainContent(), filter(), quantityChanger()]
          : [backgroundPayment(), mainContent()],
    );
  }

  void changeQuantityPaid(int? change) {
    if (change != null && change == 0) return;
    Partition? payment = widget.item.getMemberPayment(widget.member);
    if (payment == null) {
      Partition newPartition = Partition(person: widget.member);
      newPartition.updateQuantity(change, widget.item);
      widget.item.partsPaid.putIfAbsent(widget.member, () => newPartition);
      setState(() {});
      return;
    }
    payment.updateQuantity(change, widget.item);
    setState(() {});
  }

  void changeQuantityPaidSingular() {
    Partition? payment = widget.item.getMemberPayment(widget.member);
    if (payment == null) {
      widget.item.partsPaid.putIfAbsent(widget.member,
          () => Partition.withQuantityOne(widget.member, widget.item));
    } else {
      widget.item.partsPaid.remove(widget.member);
    }
    setState(() {});
  }

  Widget quantityChanger() {
    Partition? payment = widget.item.getMemberPayment(widget.member);
    int memberQuantity = payment != null ? payment.quantity : 0;
    return Positioned.fill(
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => changeQuantityPaid(-1),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.red.withOpacity(0.1),
                child: const Icon(Icons.remove, color: Colors.red, size: 40),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.controller.close();
              },
              child: Center(
                child: Text(
                  Helper.countToString(memberQuantity, true),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => changeQuantityPaid(1),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.blue.withOpacity(0.1),
                child: const Icon(Icons.add, color: Colors.blue, size: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget filter() {
    return Positioned.fill(
        child: ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 1.0,
          sigmaY: 1.0,
        ),
        child: Container(color: Colors.white.withOpacity(0.5)),
      ),
    ));
  }

  Widget mainContent() {
    bool isQuantityMultiple = widget.item.quantity > 1;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isQuantityMultiple
          ? () {
              debugPrint('Tap ${widget.itemIndex}');
              widget.controller.open();
            }
          : () {
              changeQuantityPaidSingular();
            },
      onLongPress: isQuantityMultiple
          ? () {
              debugPrint('Hold');
              changeQuantityPaid(null);
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 12,
              child: Text(
                widget.item.name,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: getTextColor()),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 4,
              child: Text(Helper.countToString(widget.item.quantity),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: getTextColor())),
            ),
            Expanded(
              flex: 4,
              child: Text(
                  Helper.valueShortWithCurrency(
                      widget.item.price, widget.item.currency),
                  textAlign: TextAlign.right,
                  style: TextStyle(color: getTextColor())),
            ),
          ],
        ),
      ),
    );
  }

  Widget backgroundPayment() {
    Map<Person, Partition> partsPaidCopy = Map.from(widget.item.partsPaid);
    // List<Partition> currentMemberFirst =
    //     partsPaidCopy.values.sorted((a, b) => a.person == widget.member
    //         ? -1
    //         : b.person == widget.member
    //             ? 1
    //             : 0);
    List<Partition> withoutCurrentMember = [];
    // partsPaidCopy.values
    //     .where((payment) => payment.person != widget.member)
    //     .toList();
    for (var member in widget.receipt.group.members) {
      if (member != widget.member && partsPaidCopy.containsKey(member)) {
        withoutCurrentMember.add(partsPaidCopy[member]!);
      }
    }
    int quantitySum =
        partsPaidCopy.values.map((payment) => payment.quantity).sum;
    int maxQuantity = max(widget.item.quantity, quantitySum);
    // debugPrint('Item ${widget.item.name} quantity sum = $maxQuantity');
    // currentMemberFirst.forEach(
    //   (element) => debugPrint('--- ${element.person} = ${element.quantity}'),
    // );
    List<Expanded> progressBar = [];
    if (partsPaidCopy.containsKey(widget.member)) {
      int flex = getFlexFromQuantity(
          partsPaidCopy[widget.member]!.quantity, maxQuantity);
      progressBar
          .add(Expanded(flex: flex, child: Container(color: Colors.black12)));
    }
    progressBar.addAll(List.generate(
      withoutCurrentMember.length,
      (index) {
        int flex =
            (withoutCurrentMember[index].quantity / (maxQuantity / 100) * 100)
                .round();
        // debugPrint('Flex = $flex');
        int indexOfMember = widget.receipt.group.members
            .indexOf(withoutCurrentMember[index].person);
        Color colorOfMember = indexOfMember >= 0
            ? Helper.colorPerPerson[indexOfMember % 10].withOpacity(0.20)
            : Colors.black12;
        return Expanded(
          flex: flex,
          child: Container(
            // height: 10,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                // begin: Alignment.topLeft,
                end: const Alignment(-0.4, 0),
                stops: const [0.0, 0.5, 0.5, 1],
                transform: GradientRotation(pi / 4 * (index % 2 == 0 ? 1 : -1)),
                colors: [
                  colorOfMember,
                  colorOfMember,
                  Colors.transparent,
                  Colors.transparent,
                ],
                tileMode: TileMode.repeated,
              ),
            ),
          ),
        );
      },
    ));
    if (widget.item.quantity > quantitySum) {
      int missingQuantity = widget.item.quantity - quantitySum;
      // debugPrint('Missing quantity = $missingQuantity');
      int flex = getFlexFromQuantity(missingQuantity, maxQuantity);
      progressBar.add(Expanded(
        flex: flex,
        child: Container(
          // height: 10,
          color: Colors.transparent,
        ),
      ));
    }
    return Positioned.fill(
      child: Row(
        children: progressBar,
      ),
    );
  }

  int getFlexFromQuantity(int q, int maxQuantity) =>
      (q / (maxQuantity / 100) * 100).round();
}
