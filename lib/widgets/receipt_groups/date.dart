import 'package:flutter/material.dart';
import 'package:receipt_calculator/helper.dart';

class DateWidget extends StatelessWidget {
  final DateTime date;
  const DateWidget({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(date.day.toString(),
              style: TextStyle(
                  height: 1,
                  fontSize: 32,
                  color: Colors.black.withOpacity(0.8))),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: date.year != DateTime.now().year
                ? [
                    Text(Helper.dateToShortMonthString(date).toUpperCase(),
                        style: TextStyle(color: Colors.black.withOpacity(0.8))),
                    const SizedBox(width: 4),
                    Text(Helper.dateToShortYearString(date),
                        style: TextStyle(color: Colors.black.withOpacity(0.8))),
                  ]
                : [
                    Text(Helper.dateToShortMonthString(date).toUpperCase(),
                        style: TextStyle(color: Colors.black.withOpacity(0.8))),
                  ],
          )
        ],
      ),
    );
  }
}
