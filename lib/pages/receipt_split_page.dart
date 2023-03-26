import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_item.dart';

class ReceiptSplitPage extends StatefulWidget {
  static const route = '/split';
  final Receipt receipt;
  final int itemIndex;
  final ReceiptItem item;
  ReceiptSplitPage({super.key, required this.receipt, required this.itemIndex})
      : item = receipt.items[itemIndex];

  @override
  State<ReceiptSplitPage> createState() => _ReceiptSplitPageState();
}

class _ReceiptSplitPageState extends State<ReceiptSplitPage> {
  bool isQuantity = true;

  // _ReceiptSplitPageState() {
  //   isQuantity = widget.item.quantity > 1;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.receipt.name),
            Text(
              widget.item.name,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        width: double.infinity,
        child: Column(
          children: [
            Table(
              // border: TableBorder.all(),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FlexColumnWidth(60),
                1: FlexColumnWidth(10),
                2: FlexColumnWidth(20),
                3: FlexColumnWidth(10),
              },
              children: rows(),
            ),
            const SizedBox(height: 16),
            SegmentedButton(
              segments: const [
                ButtonSegment(value: true, label: Text('Quantity')),
                ButtonSegment(value: false, label: Text('Fraction')),
              ],
              selected: {isQuantity},
              onSelectionChanged: (selection) {
                isQuantity = selection.elementAt(0);
                debugPrint(selection.toString());
                setState(() {});
              },
            )
          ],
        ),
      ),
      // body:  Table(
      //   defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      //   columnWidths: const {
      //     0: FlexColumnWidth(5),
      //     1: FlexColumnWidth(1),
      //     2: FlexColumnWidth(3),
      //     3: FlexColumnWidth(1)
      //   },
      //   children: rows(),
      // ),
    );
  }

  List<TableRow> rows() {
    return widget.receipt.group.members
        .map((person) => TableRow(children: [
              Text(person.name),
              tableIcon(Icons.remove, () {}, () {}),
              // IconButton(
              //     onPressed: () {}, icon: const Icon(Icons.remove_circle)),
              // IconButton(onPressed: () {}, icon: const Icon(Icons.remove)),
              TextFormField(
                initialValue: '0',
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  isDense: true,
                ),
              ),
              tableIcon(Icons.add, () {}, () {}),
              // IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle)),
            ]))
        .toList();
  }

  Widget tableIcon(IconData icon, Function() onPressed, Function() onHold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Material(
            child: InkWell(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Icon(
                  icon,
                ),
              ),
              onTap: onPressed,
              onLongPress: onHold,
            ),
          ),
        )
      ],
    );
    // return Row(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: [
    //     Container(
    //       padding: const EdgeInsets.all(0.0),
    //       width: 30.0, // you can adjust the width as you need
    //       child: IconButton(
    //         icon: Icon(icon),
    //         onPressed: onPressed,
    //       ),
    //     ),
    //   ],
    // );
  }

  // List<String> generateFractions(int memberSize) {}
}
