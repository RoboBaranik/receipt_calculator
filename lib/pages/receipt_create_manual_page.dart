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
  _ActionType _actionType = _ActionType.initial;
  _ReceiptForm formData = _ReceiptForm();
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
        if (time != null) {
          DateTime dateTime =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
          formData.timeCreated = dateTime;
          _timeCreated.text = Helper.dateTimeToString(dateTime);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_actionType == _ActionType.initial ||
        _actionType == _ActionType.onItemAdded) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollController
          .animateTo(_scrollController.position.maxScrollExtent,
              duration: const Duration(seconds: 2),
              curve: Curves.fastOutSlowIn));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Create new receipt')),
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.always,
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
                onChanged: (change) => formData.name = change,
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
                        onDelete: () => onDeleteItem(index),
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
                    onPressed: () {
                      formData.items = items.map((e) => e.item).toList();
                      onCreateReceipt(context, formData.name,
                          formData.timeCreated, formData.items);
                    },
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

  void onCreateReceipt(BuildContext context, String? name,
      DateTime? timeCreated, List<ReceiptItem>? items) {
    if (name == null ||
        name.isEmpty ||
        timeCreated == null ||
        items == null ||
        items.isEmpty) {
      debugPrint(
          'Form data not filled. Name $name, timeCreated $timeCreated, items $items');
      return;
    }
    Receipt newReceipt = Receipt(
        name: name,
        items: items,
        timeCreated: timeCreated,
        group: Routes.mockedGroup);
    Navigator.pop(context, newReceipt);
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
        onItemAction(() {
          items.add(ExpandableReceiptItem(
              item: newReceiptItem, controller: ExpandableController()));
        }, _ActionType.onItemAdded);
        // items.add(ExpandableReceiptItem(
        //     item: newReceiptItem, controller: ExpandableController()));
        // updateControllers();
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
      _actionType = _ActionType.onItemEdited;
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

  void onDeleteItem(int index) {
    if (items.isEmpty || index < 0 || index >= items.length) {
      return;
    }
    ExpandableReceiptItem removedItem = onItemAction(() {
      return items.removeAt(index);
    }, _ActionType.onItemDeleted);
    // Helper.expandableListControllerSetUpRevert(items.map((e) => e.controller));
    // var removedItem = items.removeAt(index);
    // Helper.expandableListControllerSetUp(
    //     _scrollController, items.map((e) => e.controller));
    debugPrint('Item removed');
    final snackBar = SnackBar(
      content: const Text('Item deleted'),
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          removedItem.controller.value = false;
          onItemAction(() => items.insert(index, removedItem),
              _ActionType.onItemDeleted);
          // Helper.expandableListControllerSetUpRevert(
          //     items.map((e) => e.controller));
          // items.insert(index, removedItem);
          // Helper.expandableListControllerSetUp(
          //     _scrollController, items.map((e) => e.controller));
          debugPrint('Item removal reverted');
          setState(() {});
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    setState(() {});
  }

  T onItemAction<T>(T Function() action, _ActionType actionType) {
    _actionType = actionType;
    Helper.expandableListControllerSetUpRevert(items.map((e) => e.controller));
    T result = action();
    Helper.expandableListControllerSetUp(
        _scrollController, items.map((e) => e.controller));
    return result;
  }
}

enum _ActionType { initial, onItemAdded, onItemEdited, onItemDeleted }

class _ReceiptForm {
  String? name;
  DateTime? timeCreated;
  List<ReceiptItem>? items;
}
