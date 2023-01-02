import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_item.dart';
import 'package:receipt_calculator/widgets/home/list_item.dart';

class ReceiptPage extends StatefulWidget {
  final String title;
  final List<ReceiptItem> receiptItems = [
    ReceiptItem(
      name: 'Ketchup',
      partsPaid: [
        Partition(person: 'A', percentPaid: 10),
        Partition(person: 'B', percentPaid: 50),
        Partition(person: 'C', percentPaid: 20),
        Partition(person: 'D', percentPaid: 5),
        Partition(person: 'E', percentPaid: 25),
      ],
    ),
    ReceiptItem(name: 'Milk'),
    ReceiptItem(name: 'Chips'),
    ReceiptItem(name: 'Yoghurt'),
    ReceiptItem(name: 'Green apple', count: 5),
    ReceiptItem(name: 'Strawberry', count: 120, value: 5),
    ReceiptItem(
        name: 'Intel Core i5-12600K 3.5 GHz, 8-Core',
        count: 54321,
        value: 1234),
    ReceiptItem(name: 'Small mirror', value: 200),
    ReceiptItem(name: 'Coffee cup', value: 50),
    ReceiptItem(name: 'Roll', count: 4321),
    ReceiptItem(name: 'Book', value: 15),
    ReceiptItem(name: 'Better book', value: 15.01),
    ReceiptItem(name: 'Unknown space object', value: 5432987),
  ];

  ReceiptPage({super.key, required this.title});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      // body: ListView.builder(
      //   // padding: const EdgeInsets.all(10.0),
      //   shrinkWrap: false,
      //   itemCount: widget.receiptItems.length,
      //   itemBuilder: (BuildContext context, int index) {
      //     return ListItem(item: widget.receiptItems.elementAt(index));
      //   },
      // ),
      // body: SingleChildScrollView(
      //   child: Container(
      //     child: ItemList(itemList: widget.receiptItems),
      //   ),
      // ),
      body: ListView.separated(
        itemCount: widget.receiptItems.length,
        itemBuilder: (context, index) =>
            ListItem(item: widget.receiptItems.elementAt(index)),
        separatorBuilder: (context, index) => Container(
          height:
              widget.receiptItems.elementAt(index).partsPaid.isEmpty ? 1 : 0,
          color: Colors.black12,
        ),
        // children: widget.receiptItems.map((e) => ListItem(item: e)).toList()),
      ),
    );
  }
}
