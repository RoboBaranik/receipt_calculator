import 'package:collection/collection.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_item.dart';
import 'package:receipt_calculator/data/receipt_payment.dart';
import 'package:receipt_calculator/helper.dart';
import 'package:receipt_calculator/widgets/receipt_list/dialog_receipt_add.dart';

import '../routes.dart';
import '../widgets/drawer.dart';

class ReceiptListPage extends StatefulWidget {
  final ReceiptGroup group;
  ReceiptListPage({super.key, required this.group}) {
    // TODO Remove later
    if (group.receipts.isEmpty) {
      group.receipts.addAll([Routes.mocked1, Routes.mocked2]);
    }
  }

  @override
  State<ReceiptListPage> createState() => _ReceiptListPageState();
}

enum _ReceiptListPageTab { list, payments }

class _ReceiptListPageState extends State<ReceiptListPage> {
  _ReceiptListPageTab selectedTab = _ReceiptListPageTab.list;
  @override
  Widget build(BuildContext context) {
    widget.group.receipts
        .sort((a, b) => b.timeCreated.compareTo(a.timeCreated));
    return Scaffold(
      appBar: AppBar(title: const Text('New Receipt list')),
      drawer: const Drawer(
        child: AppDrawer(currentRoute: Routes.receiptList),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog<Receipt>(
            context: context,
            builder: (_) => const DialogReceiptAdd(),
          ).then((createdReceipt) {
            if (createdReceipt != null) {
              debugPrint('New receipt $createdReceipt');
              widget.group.receipts.add(createdReceipt);
              setState(() {});
            }
          });
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedTab.index,
        onTap: (tabIndex) => setState(() {
          selectedTab = _ReceiptListPageTab.values[tabIndex];
        }),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.list), label: 'Receipt list'),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Payments'),
        ],
      ),
      body: [listTab(), paymentTab()][selectedTab.index],
    );
  }

  Widget listTab() {
    return ListView.separated(
      itemCount: widget.group.receipts.length,
      itemBuilder: (context, index) => GestureDetector(
        // onTap: () => Navigator.pushNamed(context, Routes.receipt,
        //     arguments: widget.receipts[index]),
        onTap: () => Navigator.pushNamed(context, Routes.receiptSummary,
            arguments: widget.group.receipts[index]),
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          // height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    // height: 16,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.group.receipts[index].name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    // height: 16,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      Helper.dateTimeToString(
                          widget.group.receipts[index].timeCreated),
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                ],
              ),
              Text(
                Helper.valueShortWithCurrency(widget.group.receipts[index].sum,
                    widget.group.receipts[index].currency),
                style: const TextStyle(fontSize: 16),
              )
            ],
          ),
        ),
      ),
      separatorBuilder: (context, index) => Container(
        height: 1,
        color: Colors.black12,
      ),
    );
  }

  Widget paymentTab() {
    return ListView.separated(
      itemCount: widget.group.members.length,
      itemBuilder: (context, index) {
        Person member = widget.group.members[index];
        Color memberIconColor = Helper.colorPerPerson[index % 10];
        double payment = widget.group.getMemberPayment(member);
        Icon totalPayIcon;
        Color totalPayColor;
        if (payment > 0) {
          totalPayColor = Colors.red;
          totalPayIcon =
              const Icon(Icons.keyboard_arrow_left, color: Colors.red);
        } else if (payment == 0) {
          totalPayColor = Colors.black45;
          totalPayIcon =
              const Icon(Icons.circle_outlined, color: Colors.black45);
        } else {
          totalPayColor = Colors.lime.shade600;
          totalPayIcon =
              Icon(Icons.keyboard_arrow_right, color: Colors.lime.shade600);
        }
        return ExpandablePanel(
            theme: const ExpandableThemeData(
                hasIcon: false, tapHeaderToExpand: true),
            header: Container(
              decoration: const BoxDecoration(color: Colors.white),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              // height: 64,
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: memberIconColor,
                        size: 35,
                        shadows: const [
                          Shadow(color: Colors.black, blurRadius: 2)
                        ],
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          // const SizedBox(height: 4),
                          Row(
                            children: [
                              totalPayIcon,
                              Text(
                                Helper.valueLongWithCurrency(
                                    payment.abs(), null),
                                style: TextStyle(color: totalPayColor),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
            collapsed: Container(),
            expanded: paymentDetails(member));
        // return GestureDetector(
        //   onTap: null,
        //   child: Container(
        //     decoration: const BoxDecoration(color: Colors.white),
        //     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        //     // height: 64,
        //     child: Column(
        //       children: [
        //         Row(
        //           children: [
        //             Icon(
        //               Icons.person,
        //               color: memberIconColor,
        //               size: 35,
        //               shadows: const [
        //                 Shadow(color: Colors.black, blurRadius: 2)
        //               ],
        //             ),
        //             const SizedBox(width: 8),
        //             Column(
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               children: [
        //                 Text(
        //                   member.name,
        //                   style: const TextStyle(fontWeight: FontWeight.bold),
        //                 ),
        //                 // const SizedBox(height: 4),
        //                 Row(
        //                   children: [
        //                     totalPayIcon,
        //                     Text(
        //                       Helper.valueLongWithCurrency(payment.abs(), null),
        //                       style: TextStyle(color: totalPayColor),
        //                     ),
        //                   ],
        //                 ),
        //               ],
        //             )
        //           ],
        //         )
        //       ],
        //     ),
        //   ),
        // );
      },
      separatorBuilder: (context, index) => Container(
        height: 1,
        color: Colors.black12,
      ),
    );
  }

  Widget paymentDetails(Person member) {
    List<Widget> paymentDetails = [];
    var towards = paymentDetailsDebtTowards(member);
    var from = paymentDetailsDebtFrom(member);
    paymentDetails.addAll(towards);
    if (towards.isNotEmpty && from.isNotEmpty) {
      paymentDetails.add(const SizedBox(height: 8));
    }
    paymentDetails.addAll(from);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: paymentDetails,
      ),
    );
  }

  List<Widget> paymentDetailsDebtTowards(Person member) {
    var debtMap = widget.group.getDebtTowardsMember(member);
    List<Widget> debtItems = [];
    debtMap.forEach((receipt, paymentMap) {
      String totalDebtForReceipt = Helper.valueLongWithCurrency(
          paymentMap.values.map((payment) => payment.payment).sum, null);
      Widget debtItem = Row(children: [
        Text(receipt.name, style: TextStyle(fontWeight: FontWeight.bold)),
        Icon(Icons.keyboard_arrow_right, color: Colors.lime.shade600),
        Text(totalDebtForReceipt,
            style: TextStyle(color: Colors.lime.shade600)),
      ]);
      debtItems.add(debtItem);
      for (var payment in paymentMap.values) {
        Color memberIconColor = Colors.black;
        int index = widget.group.members.indexOf(payment.person);
        if (index >= 0) {
          memberIconColor = Helper.colorPerPerson[index % 10];
        }
        String totalDebtForPerson =
            Helper.valueLongWithCurrency(payment.payment, null);
        Widget debtItemMember = Row(
          children: [
            const SizedBox(width: 16),
            Icon(Icons.person, color: memberIconColor),
            Text(payment.person.name),
            Icon(Icons.keyboard_arrow_right, color: Colors.lime.shade600),
            Text(totalDebtForPerson,
                style: TextStyle(color: Colors.lime.shade600)),
          ],
        );
        debtItems.add(debtItemMember);
      }
    });
    return debtItems;
  }

  List<Widget> paymentDetailsDebtFrom(Person member) {
    var debtMap = widget.group.getMembersDebt(member);
    List<Widget> debtItems = [];
    debtMap.forEach((receipt, itemMap) {
      Color memberIconColor = Colors.black;
      Text paidByName =
          const Text('Payer not set', style: TextStyle(color: Colors.black45));
      if (receipt.paidBy != null) {
        paidByName = Text(
          receipt.paidBy!.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
        int index = widget.group.members.indexOf(receipt.paidBy!);
        if (index >= 0) {
          memberIconColor = Helper.colorPerPerson[index % 10];
        }
      }
      String totalDebtForReceipt =
          Helper.valueLongWithCurrency(receipt.getMemberSum(member), null);

      bool specifyStoreDate = debtMap.keys.any((receipt1) =>
          receipt1 != receipt && receipt1.name.compareTo(receipt.name) == 0);
      Widget debtItem = Row(
        children: [
          Icon(Icons.person, color: memberIconColor),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              paidByName,
              Row(
                  children: specifyStoreDate
                      ? [
                          Text(receipt.name,
                              style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(Helper.dateTimeToString(receipt.timeCreated),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black45)),
                        ]
                      : [
                          Text(receipt.name,
                              style: const TextStyle(fontSize: 12)),
                        ]),
            ],
          ),
          const Icon(Icons.keyboard_arrow_left, color: Colors.red),
          Text(totalDebtForReceipt, style: const TextStyle(color: Colors.red)),
        ],
      );
      debtItems.add(debtItem);
    });
    return debtItems;
  }
}
