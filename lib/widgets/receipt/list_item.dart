import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_item.dart';
import 'package:receipt_calculator/helper.dart';
import 'package:receipt_calculator/widgets/receipt/partition_progress_bar.dart';

class ListItem extends StatelessWidget {
  final ReceiptItem item;

  const ListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ExpandablePanel(
      collapsed: PartitionProgressBar(
        partsPaid: item.partsPaid,
        compact: true,
      ),
      expanded: Column(children: [
        PartitionProgressBar(
          partsPaid: item.partsPaid,
          compact: false,
        ),
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
                Helper.valueWithCurrency(item.value, item.currency),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
