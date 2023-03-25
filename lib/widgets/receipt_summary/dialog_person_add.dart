import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_payment.dart';

class DialogPersonAdd extends StatelessWidget {
  final bool isCreate;
  DialogPersonAdd({super.key, required this.isCreate});

  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 16),
              width: double.infinity,
              child: Text(
                isCreate ? 'Add new person' : 'Edit person',
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            TextFormField(
              controller: nameController,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'Name',
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Empty name of item' : null,
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, Person(nameController.text));
                  },
                  child: Text(isCreate ? 'Create person' : 'Edit person'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
