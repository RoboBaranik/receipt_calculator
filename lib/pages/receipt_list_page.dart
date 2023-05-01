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
        return GestureDetector(
          onTap: null,
          child: Container(
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
                        Text(Helper.valueLongWithCurrency(payment, null)),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => Container(
        height: 1,
        color: Colors.black12,
      ),
    );
  }
}
