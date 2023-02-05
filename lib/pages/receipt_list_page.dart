import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_item.dart';
import 'package:receipt_calculator/helper.dart';
import 'package:receipt_calculator/widgets/receipt_list/dialog_add.dart';

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
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (_) => const DialogReceiptAdd(),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        itemCount: widget.receipts.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => Navigator.pushNamed(context, Routes.receipt,
              arguments: widget.receipts[index]),
          child: Container(
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
                  Helper.valueWithCurrency(widget.receipts[index].sum,
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
