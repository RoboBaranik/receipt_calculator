import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_item.dart';
import 'package:receipt_calculator/helper.dart';
import 'package:receipt_calculator/routes.dart';

class MemberPaidTotalListItem extends StatelessWidget {
  final Partition payment;
  final Receipt receipt;
  final Function onReturn;
  final Color memberIconColor;
  const MemberPaidTotalListItem(
      {super.key,
      required this.payment,
      required this.receipt,
      required this.onReturn,
      required this.memberIconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(
          children: [
            Icon(
              Icons.person,
              color: memberIconColor,
              shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
            ),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.person.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                // const SizedBox(height: 4),
                Text(Helper.valueLongWithCurrency(payment.payment, null)),
              ],
            ),
          ],
        ),
        IconButton(
            onPressed: () {
              Navigator.pushNamed(context, Routes.receipt,
                  arguments: [receipt, true]).then((value) {
                onReturn.call();
              });
            },
            icon: Icon(
              Icons.paid,
              color: Theme.of(context).primaryColor,
            )),
      ]),
    );
  }
}
