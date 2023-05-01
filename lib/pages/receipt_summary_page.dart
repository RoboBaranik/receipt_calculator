import 'package:collection/collection.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_item.dart';
import 'package:receipt_calculator/data/receipt_payment.dart';
import 'package:receipt_calculator/helper.dart';
import 'package:receipt_calculator/routes.dart';
import 'package:receipt_calculator/widgets/payment_progress_bar.dart';
import 'package:receipt_calculator/widgets/receipt_summary/dialog_person_add.dart';
import 'package:receipt_calculator/widgets/receipt_summary/member_paid_total_list_item.dart';

class ReceiptSummaryPage extends StatefulWidget {
  static const String route = '/receipt_summary';
  final Receipt receipt;

  const ReceiptSummaryPage({super.key, required this.receipt});

  @override
  State<ReceiptSummaryPage> createState() => _ReceiptSummaryPageState();
}

class _ReceiptSummaryPageState extends State<ReceiptSummaryPage> {
  // Person? paidBy;
  @override
  Widget build(BuildContext context) {
    debugPrint(widget.receipt.id);
    return WillPopScope(
        child: Scaffold(
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
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: bodyColumnContents(),
            ),
          ),
          bottomSheet: BottomSheet(
            enableDrag: false,
            onClosing: () {},
            builder: (context) {
              double assigned = widget.receipt
                  .getMembersPaymentSum(widget.receipt.group.members);
              double sum = widget.receipt.sum;
              return Container(
                padding: EdgeInsets.only(top: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: assigned < sum
                          ? [
                              Text(
                                  'Assigned: ${Helper.valueLongWithCurrency(assigned, null)}'),
                              Text(
                                'Missing: ${Helper.valueLongWithCurrency(sum - assigned, null)}',
                                style: TextStyle(color: Colors.red),
                              ),
                            ]
                          : [
                              Text(
                                  'Assigned: ${Helper.valueLongWithCurrency(assigned, null)}'),
                            ],
                    ),
                    // ElevatedButton(onPressed: null, child: Text('Split')),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.receipt,
                              arguments: [widget.receipt, null]).then((value) {
                            setState(() {});
                          });
                        },
                        icon: const Icon(Icons.groups),
                        label: const Text('Split receipt')),
                    Text(
                      'UID: ${widget.receipt.id}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        onWillPop: () async {
          Navigator.pop(context, widget.receipt);
          return false;
        });
  }

  List<Widget> bodyColumnContents() {
    List<Partition> memberPayments =
        widget.receipt.getMembersPartitions(widget.receipt.group.members);
    return [
      Align(
        alignment: Alignment.center,
        child: PaymentProgressBar(
          title: 'Total'.toUpperCase(),
          assignedPercent: widget.receipt.assignedPercent(),
          sum: widget.receipt.sum,
        ),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          const SizedBox(width: 32),
          Expanded(
              child: DropdownButtonFormField<Person>(
                  hint: const Text('Receipt paid by ...'),
                  value: widget.receipt.paidBy,
                  items: widget.receipt.group.members
                      .map((person) => DropdownMenuItem<Person>(
                            value: person,
                            child: Text(
                              person.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ))
                      .toList(),
                  onChanged: (personNew) {
                    setState(() {
                      widget.receipt.paidBy = personNew!;
                    });
                  })),
          const SizedBox(width: 4),
          IconButton(
              onPressed: () {
                showDialog<Person>(
                  context: context,
                  builder: (_) => DialogPersonAdd(isCreate: true),
                ).then((createdPerson) {
                  if (createdPerson != null) {
                    debugPrint('New person $createdPerson');
                    widget.receipt.group.members.add(createdPerson);
                    setState(() {});
                  }
                });
              },
              icon: const Icon(Icons.add)),
          const SizedBox(width: 32),
        ],
      ),
      const SizedBox(height: 16),
      Flexible(
          // constraints: BoxConstraints(maxHeight: 300),
          child: ListView.separated(
              itemBuilder: (context, index) {
                Partition payment = memberPayments[index];
                return MemberPaidTotalListItem(
                    payment: payment,
                    receipt: widget.receipt,
                    onReturn: () {
                      setState(() {});
                    },
                    memberIconColor: Helper.colorPerPerson[index % 10]);
              },
              separatorBuilder: (context, index) =>
                  Container(height: 1, color: Colors.black12),
              itemCount: memberPayments.length)),
      // Table(
      //   defaultColumnWidth: const IntrinsicColumnWidth(),
      //   defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      //   children: buildMemberPayments(memberPayments, context),
      // ),
      const SizedBox(height: 16),
      // Text(
      //   'Paid by:',
      //   style: TextStyle(
      //       fontSize: 12, color: Theme.of(context).primaryColor),
      // ),
    ];
  }

  // Widget buildPaymentProgress() {
  //   var totalSumBackground = List<Color>.generate(100, (i) {
  //     var assign = widget.receipt.assignedPercent();
  //     if (assign > 0 &&
  //         (i < 10 || assign >= i + 1) &&
  //         (i < 90 || assign >= 100)) {
  //       return Theme.of(context).primaryColor.withOpacity(0.7);
  //     } else {
  //       return Theme.of(context).scaffoldBackgroundColor;
  //     }
  //   });
  //   return Container(
  //     decoration: BoxDecoration(
  //         border: Border.all(color: Theme.of(context).primaryColor, width: 4),
  //         gradient: LinearGradient(colors: totalSumBackground),
  //         borderRadius: const BorderRadius.all(Radius.circular(10))),
  //     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  //     child: Column(
  //       children: [
  //         Text('Total'.toUpperCase()),
  //         Text(
  //           Helper.valueLongWithCurrency(widget.receipt.sum, null),
  //           style: const TextStyle(fontSize: 32),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  List<TableRow> buildMemberPayments(
      List<Partition> memberPayments, BuildContext context) {
    double assignedSum =
        widget.receipt.getMembersPaymentSum(widget.receipt.group.members);
    List<TableRow> payments = memberPayments
        .mapIndexed<TableRow>(
            (int index, Partition payment) => TableRow(children: [
                  Icon(
                    Icons.person,
                    color: Helper.colorPerPerson[index % 10],
                    shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
                  ),
                  Text(
                    '${payment.person.name}:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Text(Helper.valueLongWithCurrency(payment.payment, null))
                ]))
        .toList();
    // SUM
    payments.add(TableRow(
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black))),
        children: [
          const Icon(Icons.functions),
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
    // Missing
    if (widget.receipt.sum > assignedSum) {
      payments.add(TableRow(children: [
        const Icon(Icons.error_outline, color: Colors.red),
        const Text('Missing', style: TextStyle(color: Colors.red)),
        const SizedBox(width: 4),
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
