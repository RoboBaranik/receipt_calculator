import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_item.dart';
import 'package:receipt_calculator/helper.dart';

class ListItemSingle extends StatefulWidget {
  final Receipt receipt;
  final int itemIndex;
  final ReceiptItem item;

  ListItemSingle({super.key, required this.receipt, required this.itemIndex})
      : item = receipt.items[itemIndex];

  @override
  State<ListItemSingle> createState() => _ListItemSingleState();
}

class _ListItemSingleState extends State<ListItemSingle> {
  bool isSelected = false;
  Color getTextColor() {
    if (widget.item.partsPaid.isNotEmpty) {
      return Colors.black;
    } else {
      return Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isQuantityMultiple = widget.item.quantity > 1;
    return GestureDetector(
      onTap: isQuantityMultiple
          ? null
          : () {
              debugPrint('Tap ${widget.itemIndex}');
              setState(() {
                isSelected = !isSelected;
              });
            },
      onLongPress: isQuantityMultiple
          ? null
          : () {
              debugPrint('Hold');
            },
      child: Stack(
        children: isSelected
            ? [mainContent(), filter(), quantityChanger()]
            : [mainContent()],
      ),
    );
  }

  Widget quantityChanger() {
    return Positioned.fill(
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.red.withOpacity(0.1),
              child: const Icon(Icons.remove, color: Colors.red, size: 40),
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(),
          ),
          Flexible(
            flex: 1,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.blue.withOpacity(0.1),
              child: const Icon(Icons.add, color: Colors.blue, size: 40),
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
        child: Container(color: Colors.transparent),
      ),
    ));
  }

  Widget mainContent() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 7,
            child: Text(
              widget.item.name,
              textAlign: TextAlign.left,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: getTextColor()),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(Helper.countToString(widget.item.quantity),
                textAlign: TextAlign.center,
                style: TextStyle(color: getTextColor())),
          ),
          Expanded(
            flex: 2,
            child: Text(
                Helper.valueShortWithCurrency(
                    widget.item.price, widget.item.currency),
                textAlign: TextAlign.right,
                style: TextStyle(color: getTextColor())),
          ),
        ],
      ),
    );
  }
}
