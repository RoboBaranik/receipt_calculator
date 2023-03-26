import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_item.dart';
import 'package:receipt_calculator/widgets/receipt/list_item.dart';

class ReceiptPage extends StatefulWidget {
  final Receipt receipt;

  const ReceiptPage({super.key, required this.receipt});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receipt.name)),
      body: ListView.separated(
        itemCount: widget.receipt.items.length,
        itemBuilder: (context, index) =>
            ListItem(receipt: widget.receipt, itemIndex: index),
        separatorBuilder: (context, index) => Container(
          height:
              widget.receipt.items.elementAt(index).partsPaid.isEmpty ? 1 : 0,
          color: Colors.black12,
        ),
        // children: widget.receiptItems.map((e) => ListItem(item: e)).toList()),
      ),
    );
  }
}
