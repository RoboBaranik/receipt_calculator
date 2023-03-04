import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_item.dart';
import 'package:receipt_calculator/helper.dart';

class ListItem extends StatelessWidget {
  final ReceiptItem item;
  final ExpandableController controller;
  final Function onEdit;
  final Function onDelete;

  const ListItem(
      {super.key,
      required this.item,
      required this.controller,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ExpandablePanel(
      controller: controller,
      collapsed: Container(),
      expanded: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        OutlinedButton.icon(
          onPressed: () {
            onEdit.call();
          },
          icon: const Icon(Icons.edit),
          label: const Text('Edit'),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () {
            onDelete.call();
          },
          icon: const Icon(Icons.delete),
          label: const Text('Delete'),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
        ),
        const SizedBox(width: 8),
      ]),
      theme: const ExpandableThemeData(hasIcon: false, tapHeaderToExpand: true),
      header: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 7,
              child: Text(
                item.name,
                textAlign: TextAlign.left,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                Helper.countToString(item.count),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                Helper.valueShortWithCurrency(item.value, item.currency),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
