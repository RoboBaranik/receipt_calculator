import 'dart:developer';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:receipt_calculator/data/receipt_item.dart';
import 'package:receipt_calculator/helper.dart';
import 'package:receipt_calculator/widgets/home/partition_progress_bar.dart';

// class ItemList extends StatefulWidget {
//   final List<ReceiptItem> itemList;
//   const ItemList({super.key, required this.itemList});

//   @override
//   State<ItemList> createState() => _ItemListState();
// }

// class _ItemListState extends State<ItemList> {
//   Widget _buildHeader(ReceiptItem item) {
//     return Container(
//       color: Colors.amber,
//       padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Expanded(
//             flex: 7,
//             child: Text(
//               item.name,
//               textAlign: TextAlign.left,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//           Expanded(
//             flex: 2,
//             child: Text(
//               Helper.countToString(item.count),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           Expanded(
//             flex: 2,
//             child: Text(
//               Helper.valueWithCurrency(item.value, item.currency),
//               textAlign: TextAlign.right,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBody(ReceiptItem item) {
//     return Column(children: [
//       Container(
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: Colors.black,
//           ),
//           borderRadius: const BorderRadius.all(Radius.circular(8)),
//         ),
//         margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
//         child: PartitionProgressBar(partsPaid: item.partsPaid),
//       )
//     ]);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ExpansionPanelList(
//       expansionCallback: (int index, bool isExpanded) {
//         setState(() {
//           widget.itemList[index].isExpanded = !isExpanded;
//         });
//       },
//       children: widget.itemList.map<ExpansionPanel>((ReceiptItem item) {
//         return ExpansionPanel(
//           headerBuilder: (BuildContext context, bool isExpanded) {
//             return Container(
//               child: _buildHeader(item),
//             );
//             return ListTile(
//               // visualDensity: const VisualDensity(horizontal: 0, vertical: 0),
//               // contentPadding: const EdgeInsets.all(0),
//               // leading: const SizedBox(width: 0, height: 0),
//               title: _buildHeader(item),
//               // subtitle: const SizedBox(width: 0, height: 0),
//               trailing: const SizedBox.shrink(),
//             );
//           },
//           body: ListTile(title: _buildBody(item)),
//           isExpanded: item.isExpanded,
//         );
//       }).toList(),
//     );
//   }
// }

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
        // Container(
        //   decoration: BoxDecoration(
        //     border: Border.all(color: Colors.black, width: 4),
        //     borderRadius: const BorderRadius.all(Radius.circular(100)),
        //   ),
        //   margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        //   child: PartitionProgressBar(partsPaid: item.partsPaid),
        // )
      ]),
      theme: const ExpandableThemeData(hasIcon: false, tapHeaderToExpand: true),
      header: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
