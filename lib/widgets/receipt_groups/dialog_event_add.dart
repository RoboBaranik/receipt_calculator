import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_payment.dart';
import 'package:receipt_calculator/widgets/fullscreen_dialog.dart';
import 'package:receipt_calculator/widgets/person_chip.dart';

class DialogEventAdd extends StatelessWidget {
  final List<PersonGroup> groups;
  const DialogEventAdd({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    return FullscreenDialog(
        title: 'Select group',
        // confirmButton: TextButton(onPressed: () {}, child: const Text('Save')),
        child: ListView.separated(
            itemBuilder: (context, index) {
              PersonGroup group = groups.elementAt(index);
              return buildGroup(group, context);
            },
            separatorBuilder: (context, index) {
              return Container(
                height: 4,
              );
            },
            itemCount: groups.length));
  }

  Widget buildGroup(PersonGroup group, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context, group);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.toString(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: group.members
                  .mapIndexed((memberIndex, member) =>
                      PersonChip(index: memberIndex, member: member))
                  .toList(),
            )
          ],
        ),
      ),
    );
  }
}
