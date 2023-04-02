import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_item.dart';
import 'package:receipt_calculator/helper.dart';

class PaymentProgressBar extends StatelessWidget {
  final String title;
  final double assignedPercent;
  final double sum;
  const PaymentProgressBar(
      {super.key,
      required this.assignedPercent,
      required this.sum,
      required this.title});

  @override
  Widget build(BuildContext context) {
    var totalSumBackground = List<Color>.generate(100, (i) {
      var assign = assignedPercent;
      if (assign > 100) {
        return Colors.red.withOpacity(0.7);
      }
      if (assign > 0 &&
          (i < 10 || assign >= i + 1) &&
          (i < 90 || assign == 100)) {
        return Theme.of(context).primaryColor.withOpacity(0.7);
      } else {
        return Theme.of(context).scaffoldBackgroundColor;
      }
    });
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
              color: assignedPercent > 100
                  ? Colors.red
                  : Theme.of(context).primaryColor,
              width: 4),
          gradient: LinearGradient(colors: totalSumBackground),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          Text(title),
          Text(
            Helper.valueLongWithCurrency(sum, null),
            style: const TextStyle(fontSize: 32),
          ),
        ],
      ),
    );
  }
}
