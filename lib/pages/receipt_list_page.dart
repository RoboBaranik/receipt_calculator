import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_item.dart';
import 'package:receipt_calculator/helper.dart';
import 'package:receipt_calculator/widgets/receipt_list/dialog_receipt_add.dart';

import '../routes.dart';
import '../widgets/drawer.dart';

class ReceiptListPage extends StatefulWidget {
  final List<Receipt> receipts = [];
  ReceiptListPage({super.key, List<Receipt>? receipts}) {
    if (receipts != null) {
      this.receipts.addAll(receipts);
    }
  }

  @override
  State<ReceiptListPage> createState() => _ReceiptListPageState();
}

class _ReceiptListPageState extends State<ReceiptListPage> {
  @override
  Widget build(BuildContext context) {
    widget.receipts.sort((a, b) => b.timeCreated.compareTo(a.timeCreated));
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
              widget.receipts.add(createdReceipt);
              setState(() {});
            }
          });
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(items: const [
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Receipt list'),
        BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Payments'),
      ]),
      body: ListView.separated(
        itemCount: widget.receipts.length,
        itemBuilder: (context, index) => GestureDetector(
          // onTap: () => Navigator.pushNamed(context, Routes.receipt,
          //     arguments: widget.receipts[index]),
          onTap: () => Navigator.pushNamed(context, Routes.receiptSummary,
              arguments: widget.receipts[index]),
          child: Container(
            decoration: const BoxDecoration(color: Colors.white),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.receipts[index].name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      height: 16,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        Helper.dateTimeToString(
                            widget.receipts[index].timeCreated),
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
                Text(
                  Helper.valueShortWithCurrency(widget.receipts[index].sum,
                      widget.receipts[index].currency),
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
      ),
    );
  }
}
