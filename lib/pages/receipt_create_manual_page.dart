import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_item.dart';
import 'package:receipt_calculator/helper.dart';
import 'package:receipt_calculator/routes.dart';
import 'package:receipt_calculator/widgets/receipt_create_manual/dialog_receipt_item_add.dart';
import 'package:receipt_calculator/widgets/receipt_create_manual/list_item.dart';

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
  final ScrollController _scrollController = ScrollController();
  final List<ExpandableReceiptItem> items = Routes.mocked1.items
      .map((e) =>
          ExpandableReceiptItem(item: e, controller: ExpandableController()))
      .toList();
  // final Map<ReceiptItem, ExpandableController> items = {
  //   for (var key in Routes.mocked1.items) key: ExpandableController()
  // };
  _ReceiptCreateManualPageState() {
    Helper.expandableListControllerSetUp(
        _scrollController, items.map((e) => e.controller));
  }
  updateControllers() {
    Helper.expandableListControllerSetUpRevert(items.map((e) => e.controller));
    Helper.expandableListControllerSetUp(
        _scrollController, items.map((e) => e.controller));
  }

  @override
  void dispose() {
    super.dispose();
    Helper.expandableListControllerSetUpRevert(items.map((e) => e.controller));
  }

  void getDateAndTime() {
    FocusScope.of(context).requestFocus(FocusNode());
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime(3000),
      locale: Helper.getLocale(),
    ).then((date) {
      if (date == null) {
        return;
      }
      showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      ).then((time) {
        _timeCreated.text = time != null
            ? Helper.dateTimeToString(DateTime(
                date.year, date.month, date.day, time.hour, time.minute))
            : '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(seconds: 2), curve: Curves.fastOutSlowIn));

    return Scaffold(
      appBar: AppBar(title: const Text('Create new receipt')),
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            //
            //
            // Text inputs
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
              child: TextFormField(
                controller: _name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                    isDense: true, labelText: 'Store name'),
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
                    isDense: true, labelText: 'Date created'),
                onTap: () {
                  getDateAndTime();
                },
              ),
            ),
            //
            //
            // Item list
            Expanded(
              child: ListView.separated(
                  controller: _scrollController,
                  itemBuilder: (context, index) => ListItem(
                        item: items[index].item,
                        controller: items[index].controller,
                        onEdit: () => onEditItem(index),
                        onDelete: () => debugPrint('Delete of $index'),
                      ),
                  separatorBuilder: (context, index) =>
                      Container(height: 1, color: Colors.black12),
                  itemCount: items.length),
            ),
            //
            //
            // Bottom buttons
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      onAddItem(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add item'),
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.lime.shade700),
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

  void onAddItem(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => DialogReceiptItemAdd(isCreate: true),
    ).then((newReceiptItem) {
      if (newReceiptItem == null) {
        debugPrint('Item creation canceled');
        return;
      }
      debugPrint('Created item: $newReceiptItem');
      setState(() {
        items.add(ExpandableReceiptItem(
            item: newReceiptItem, controller: ExpandableController()));
        updateControllers();
      });
    });
  }

  void onEditItem(int index) {
    if (items.isEmpty || index < 0 || index >= items.length) {
      return;
    }
    var item = items[index].item;
    showDialog<ReceiptItem>(
      context: context,
      builder: (_) => DialogReceiptItemAdd(
        isCreate: false,
        name: item.name,
        count: item.count,
        value: item.value,
      ),
    ).then((editedReceiptItem) {
      if (editedReceiptItem == null) {
        debugPrint('Item edit canceled');
        return;
      }
      debugPrint('Edited item #$index: $editedReceiptItem');
      setState(() {
        item.update(editedReceiptItem.name, editedReceiptItem.count,
            editedReceiptItem.value);
        items[index].controller.value = false;
        // items.add(ExpandableReceiptItem(
        //     item: editedReceiptItem, controller: ExpandableController()));
        // updateControllers();
      });
    });
  }
}
