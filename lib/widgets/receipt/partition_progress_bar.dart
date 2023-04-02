import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_item.dart';
import 'package:receipt_calculator/helper.dart';

class PartitionProgressBar extends StatefulWidget {
  final Receipt receipt;
  final List<Partition> partsPaid;
  final bool compact;
  const PartitionProgressBar(
      {super.key,
      required this.receipt,
      required this.partsPaid,
      this.compact = false});

  double height() {
    return compact ? 5 : 10;
  }

  @override
  State<PartitionProgressBar> createState() => _PartitionProgressBarState();
}

class _PartitionProgressBarState extends State<PartitionProgressBar> {
  List<Expanded> _buildBarParts() {
    List<Expanded> parts = [];
    // var index = -1;
    // for (var pp in widget.partsPaid) {
    //   index++;
    //   if (pp.payment == 0) continue;
    //   if (index > 0) {
    //     parts.add(Expanded(
    //       flex: 1,
    //       child: Container(
    //         color: Colors.black,
    //         height: widget.height(),
    //       ),
    //     ));
    //   }
    //   parts.add(Expanded(
    //     flex: ReceiptItem.getPartitionPercent(index, widget.partsPaid).round() *
    //         2,
    //     child: Container(
    //       decoration: BoxDecoration(
    //         color: Helper.colorPerPerson.elementAt(index),
    //         borderRadius: BorderRadius.horizontal(
    //           left: index == 0 ? const Radius.circular(8) : Radius.zero,
    //           right: index + 1 == widget.partsPaid.length
    //               ? const Radius.circular(8)
    //               : Radius.zero,
    //         ),
    //       ),
    //       height: widget.height(),
    //     ),
    //   ));
    // }
    // debugPrint(parts.toString());
    var relevantParts = widget.partsPaid.where((p) => p.payment != 0).toList();

    relevantParts.asMap().forEach((index, part) {
      if (index > 0) {
        parts.add(Expanded(
          flex: 1,
          child: Container(
            color: Colors.black,
            height: widget.height(),
          ),
        ));
      }
      int personIndex = widget.receipt.group.members.indexOf(part.person);
      Color color =
          Helper.colorPerPerson.elementAt(personIndex >= 0 ? personIndex : 0);
      parts.add(Expanded(
        flex: ReceiptItem.getPartitionPercent(index, relevantParts).round() * 2,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: widget.compact
                ? null
                : BorderRadius.horizontal(
                    left: index == 0 ? const Radius.circular(8) : Radius.zero,
                    right: index + 1 == relevantParts.length
                        ? const Radius.circular(8)
                        : Radius.zero,
                  ),
          ),
          height: widget.height(),
        ),
      ));
    });
    return parts;
  }

  Widget _buildBar(List<Expanded> parts) {
    var core = parts.isEmpty && !widget.compact
        ? Container(height: widget.height())
        : Row(children: parts);
    if (widget.compact) {
      return core;
    } else {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 4),
          borderRadius: const BorderRadius.all(Radius.circular(100)),
        ),
        margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: core,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var parts = _buildBarParts();
    var progressBar = _buildBar(parts);
    return Stack(
      children: [
        Container(
          color: Colors.transparent,
          height: parts.isEmpty && !widget.compact ? widget.height() : 0,
        ),
        progressBar,
      ],
    );
  }
}
