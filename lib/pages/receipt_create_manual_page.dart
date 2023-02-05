import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_item.dart';
import 'package:receipt_calculator/helper.dart';
import 'package:receipt_calculator/routes.dart';
import 'package:receipt_calculator/widgets/receipt_list/list_item.dart';

class ReceiptCreateManualPage extends StatefulWidget {
  const ReceiptCreateManualPage({super.key});

  @override
  State<ReceiptCreateManualPage> createState() =>
      _ReceiptCreateManualPageState();
}

class _ReceiptCreateManualPageState extends State<ReceiptCreateManualPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _timeCreated = TextEditingController();
  final List<ReceiptItem> items = Routes.mocked1.items;

  void getDateAndTime() {
    FocusScope.of(context).requestFocus(FocusNode());
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime(3000),
      locale: Helper.getLocale(),
    ).then((date) {
      showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      ).then((time) {
        _timeCreated.text = date != null && time != null
            ? Helper.dateTimeToString(DateTime(
                date.year, date.month, date.day, time.hour, time.minute))
            : '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create new receipt')),
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
              child: TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  isDense: true,
                  labelText: 'Store name',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
              child: TextFormField(
                controller: _timeCreated,
                readOnly: true,
                decoration: const InputDecoration(
                  isDense: true,
                  labelText: 'Date created',
                ),
                onTap: () {
                  getDateAndTime();
                },
              ),
            ),
            Expanded(
              child: ListView.separated(
                  itemBuilder: (context, index) => ListItem(item: items[index]),
                  separatorBuilder: (context, index) => Container(
                        height: 1,
                        color: Colors.black12,
                      ),
                  itemCount: items.length),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Add item'),
                    style: TextButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.create_sharp),
                    label: const Text('Create'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
