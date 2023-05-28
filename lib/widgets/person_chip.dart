import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_payment.dart';
import 'package:receipt_calculator/helper.dart';

class PersonChip extends StatelessWidget {
  final int index;
  final Person member;
  const PersonChip({super.key, required this.index, required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Helper.colorPerPerson[index % 10].withOpacity(0.05),
          border: Border.all(
              color: Helper.colorPerPerson[index % 10].withOpacity(0.5)),
          borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person,
            color: Helper.colorPerPerson[index % 10],
            shadows: const [Shadow(color: Colors.black, blurRadius: 3)],
          ),
          const SizedBox(width: 4),
          Text(member.name)
        ],
      ),
    );
  }
}
