import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_item.dart';
import 'package:receipt_calculator/data/receipt_payment.dart';
import 'package:receipt_calculator/widgets/receipt/list_item.dart';
import 'package:receipt_calculator/widgets/receipt/list_item_single.dart';

class ReceiptPage extends StatefulWidget {
  final Receipt receipt;
  final Person? member;

  const ReceiptPage({super.key, required this.receipt, required this.member});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  @override
  Widget build(BuildContext context) {
    Person? member = widget.member;
    return Scaffold(
      appBar: AppBar(title: Text(widget.receipt.name)),
      body: ListView.separated(
        itemCount: widget.receipt.items.length,
        itemBuilder: (context, index) => member != null
            ? ListItemSingle(
                receipt: widget.receipt, itemIndex: index, member: member)
            : ListItem(receipt: widget.receipt, itemIndex: index),
        separatorBuilder: (context, index) => Container(
          height: 1,
          color: Colors.black12,
        ),
        // children: widget.receiptItems.map((e) => ListItem(item: e)).toList()),
      ),
    );
  }
}
