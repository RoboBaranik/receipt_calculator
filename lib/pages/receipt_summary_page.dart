import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_item.dart';
import 'package:receipt_calculator/helper.dart';

class ReceiptSummaryPage extends StatefulWidget {
  final Receipt receipt;

  const ReceiptSummaryPage({super.key, required this.receipt});

  @override
  State<ReceiptSummaryPage> createState() => _ReceiptSummaryPageState();
}

class _ReceiptSummaryPageState extends State<ReceiptSummaryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.receipt.name),
            Text(
              Helper.dateTimeToString(widget.receipt.timeCreated),
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Total: ${Helper.valueLongWithCurrency(widget.receipt.sum, null)}')
          ],
        ),
      ),
    );
  }
}
