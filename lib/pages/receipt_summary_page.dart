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
    var totalSumBackground = List<Color>.generate(100, (i) {
      var assign = widget.receipt.assignedPercent();
      if (assign > 0 &&
          (i < 10 || assign >= i + 1) &&
          (i < 90 || assign >= 100)) {
        return Theme.of(context).primaryColor.withOpacity(0.7);
      } else {
        return Theme.of(context).scaffoldBackgroundColor;
      }
    });
    List<Partition> memberPayments =
        widget.receipt.getMembersPartitions(widget.receipt.group.members);
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).primaryColor, width: 4),
                    gradient: LinearGradient(colors: totalSumBackground),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Column(
                  children: [
                    Text('Total'.toUpperCase()),
                    Text(
                      Helper.valueLongWithCurrency(widget.receipt.sum, null),
                      style: const TextStyle(fontSize: 32),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              children: buildMemberPayments(memberPayments, context),
            ),
          ],
        ),
      ),
    );
  }

  List<TableRow> buildMemberPayments(
      List<Partition> memberPayments, BuildContext context) {
    double assignedSum =
        widget.receipt.getMembersPaymentSum(widget.receipt.group.members);
    List<TableRow> payments = memberPayments
        .map<TableRow>((Partition payment) => TableRow(children: [
              Text(
                '${payment.person.name}:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              Text(Helper.valueLongWithCurrency(payment.payment, null))
            ]))
        .toList();
    payments.add(TableRow(children: [
      Text(
        'Assigned'.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(
        width: 4,
      ),
      Text(
        Helper.valueLongWithCurrency(assignedSum, null),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ]));
    if (widget.receipt.sum > assignedSum) {
      payments.add(TableRow(children: [
        const Text(
          'Missing',
          style: TextStyle(color: Colors.red),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          Helper.valueLongWithCurrency(widget.receipt.sum - assignedSum, null),
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
      ]));
    }
    return payments;
  }
}
