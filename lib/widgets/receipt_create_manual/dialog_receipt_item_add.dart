import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:receipt_calculator/data/receipt_item.dart';
import 'package:receipt_calculator/helper.dart';

class DialogReceiptItemAdd extends StatelessWidget {
  final bool isCreate;
  DialogReceiptItemAdd(
      {super.key,
      required this.isCreate,
      String? name,
      int? count,
      double? value}) {
    if (!isCreate) {
      nameController.text = name ?? '';
      countController.text = count != null ? count.toString() : '';
      valueController.text = value != null ? value.toStringAsFixed(2) : '';
    }
  }
  final TextEditingController nameController = TextEditingController();
  final TextEditingController countController = TextEditingController();
  final TextEditingController valueController = TextEditingController();

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
                isCreate ? 'Add new item' : 'Edit item',
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
            TextFormField(
              controller: countController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[1-9][0-9]*")),
              ],
              keyboardType: const TextInputType.numberWithOptions(
                  signed: false, decimal: true),
              decoration: InputDecoration(
                  isDense: true,
                  labelText: 'Count',
                  suffixText: Helper.langToCount()),
            ),
            TextFormField(
              controller: valueController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[0-9.-]")),
              ],
              onChanged: (value) {
                if (value.trim().isEmpty) return;
                var matched = RegExp(r'^-?(0|([1-9][0-9]*))(\.(\d(\d)?)?)?$')
                    .hasMatch(value);
                // var matches = RegExp(r'-?(0|([1-9][0-9]*))(\.(\d(\d)?)?)?')
                //     .allMatches(value);
                // debugPrint('Matched: $matched. Matches: ${matches.length}');
                // for (final m in matches) {
                //   debugPrint(m[0]!);
                // }
                if (!matched) {
                  var offset = valueController.selection.baseOffset;
                  valueController.value = TextEditingValue(
                      text: valueController.text.substring(0, offset - 1) +
                          valueController.text.substring(offset),
                      selection: TextSelection.collapsed(offset: offset - 1));
                  // var match = matches.reduce(
                  //     (value, element) => value[0]!.length == element[0]!.length
                  //         ? element
                  //         : value[0]!.length > element[0]!.length
                  //             ? value
                  //             : element)[0]!;
                  // valueController.value = TextEditingValue(
                  //     text: match,
                  //     selection: TextSelection.collapsed(
                  //         offset: valueController.selection.baseOffset <
                  //                 match.length
                  //             ? valueController.selection.baseOffset - 1
                  //             : match.length));
                }
              },
              keyboardType: const TextInputType.numberWithOptions(
                  signed: true, decimal: true),
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'Value',
                suffixText: '€',
              ),
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
                    Navigator.pop(
                        context,
                        ReceiptItem(
                            name: nameController.text,
                            count: int.tryParse(countController.text) ?? 1,
                            value: double.tryParse(valueController.text) ?? 0));
                  },
                  child: Text(isCreate ? 'Create item' : 'Edit item'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
