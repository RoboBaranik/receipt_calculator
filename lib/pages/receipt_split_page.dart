import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_item.dart';
import 'package:receipt_calculator/data/receipt_payment.dart';
import 'package:receipt_calculator/helper.dart';
import 'package:receipt_calculator/widgets/payment_progress_bar.dart';

class ReceiptSplitPage extends StatefulWidget {
  static const route = '/split';
  final Receipt receipt;
  final int itemIndex;
  final ReceiptItem item;
  final Map<Person, TextEditingController> personToController;
  final Map<Person, Partition> partsPaid;
  ReceiptSplitPage({super.key, required this.receipt, required this.itemIndex})
      : item = receipt.items[itemIndex],
        partsPaid = Map.from(receipt.items[itemIndex].partsPaid),
        personToController = {
          for (var person in receipt.group.members)
            person: TextEditingController(
                text: receipt.items[itemIndex]
                        .getMemberPayment(person)
                        ?.displayedPartPaid ??
                    '0.0')
        };

  @override
  State<ReceiptSplitPage> createState() => _ReceiptSplitPageState();
}

class _ReceiptSplitPageState extends State<ReceiptSplitPage> {
  bool isQuantity = true;

  // _ReceiptSplitPageState() {
  //   isQuantity = widget.item.quantity > 1;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.receipt.name),
            Text(
              widget.item.name,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        width: double.infinity,
        child: Column(
          children: [
            PaymentProgressBar(
              title: '${widget.item.quantity} items',
              assignedPercent: widget.item.assignedPercent(widget.partsPaid),
              sum: widget.item.price,
            ),
            const SizedBox(height: 16),
            SegmentedButton(
              segments: const [
                ButtonSegment(value: true, label: Text('Quantity')),
                ButtonSegment(value: false, label: Text('Fraction')),
              ],
              selected: {isQuantity},
              onSelectionChanged: (selection) {
                isQuantity = selection.elementAt(0);
                widget.personToController.forEach(
                    (key, value) => value.text = isQuantity ? '0' : '0/1');
                widget.partsPaid.clear();
                debugPrint(selection.toString());
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            Table(
              // border: TableBorder.all(),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FlexColumnWidth(60),
                1: FlexColumnWidth(10),
                2: FlexColumnWidth(20),
                3: FlexColumnWidth(10),
              },
              children: rows(),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
                onPressed: widget.item.assignedPercent(widget.partsPaid) == 100
                    ? () {
                        widget.item.partsPaid = widget.partsPaid;
                        Navigator.pop(context);
                      }
                    : null,
                icon: const Icon(Icons.check),
                label: const Text('Apply'))
          ],
        ),
      ),
      // body:  Table(
      //   defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      //   columnWidths: const {
      //     0: FlexColumnWidth(5),
      //     1: FlexColumnWidth(1),
      //     2: FlexColumnWidth(3),
      //     3: FlexColumnWidth(1)
      //   },
      //   children: rows(),
      // ),
    );
  }

  List<TableRow> rows() {
    List<String> fractions =
        generateFractions(widget.receipt.group.members.length);
    int memberSize = widget.receipt.group.members.length;
    return widget.receipt.group.members
        .map((person) => TableRow(children: [
              Text(person.name),
              tableIcon(Icons.remove, () {
                changePartsPaid(
                    false, isQuantity, widget.item, person, fractions);
              }, () {
                updatePartsPaid(0, 0, isQuantity ? '0' : '0/1', person);
                widget.personToController[person]!.text =
                    isQuantity ? '0' : fractions.first;
                setState(() {});
              }),
              // IconButton(
              //     onPressed: () {}, icon: const Icon(Icons.remove_circle)),
              // IconButton(onPressed: () {}, icon: const Icon(Icons.remove)),
              TextFormField(
                controller: widget.personToController[person],
                // initialValue:
                //     widget.item.getMemberPayment(person).displayedPartPaid,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    isDense: true,
                    suffixText: isQuantity ? Helper.langToCount() : null),
              ),
              tableIcon(Icons.add, () {
                changePartsPaid(
                    true, isQuantity, widget.item, person, fractions);
              }, () {
                updatePartsPaid(
                    widget.item.price,
                    widget.item.quantity,
                    isQuantity
                        ? widget.item.quantity.toString()
                        : '$memberSize/$memberSize',
                    person);
                widget.personToController[person]!.text = isQuantity
                    ? widget.item.quantity.toString()
                    : fractions.last;
                setState(() {});
              }),
              // IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle)),
            ]))
        .toList();
  }

  Widget tableIcon(IconData icon, Function() onPressed, Function() onHold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Material(
            child: InkWell(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Icon(
                  icon,
                ),
              ),
              onTap: onPressed,
              onLongPress: onHold,
            ),
          ),
        )
      ],
    );
    // return Row(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: [
    //     Container(
    //       padding: const EdgeInsets.all(0.0),
    //       width: 30.0, // you can adjust the width as you need
    //       child: IconButton(
    //         icon: Icon(icon),
    //         onPressed: onPressed,
    //       ),
    //     ),
    //   ],
    // );
  }

  void changePartsPaid(bool increase, bool isQuantity, ReceiptItem item,
      Person person, List<String> fractions) {
    if (isQuantity) {
      var quantity = int.tryParse(widget.personToController[person]!.text);
      if (quantity == null) {
        debugPrint('Invalid quantity');
        return;
      }
      if (increase && quantity >= 0 && quantity < item.quantity ||
          !increase && quantity > 0) {
        var newQuantity = (increase ? quantity + 1 : quantity - 1);
        var displayedQuantity = newQuantity.toString();
        var price = widget.item.getPriceByQuantityPaid(newQuantity);
        updatePartsPaid(price, newQuantity, displayedQuantity, person);
        widget.personToController[person]!.text = newQuantity.toString();
        setState(() {});
      }
      return;
    }
    var index = fractions.indexOf(widget.personToController[person]!.text);
    if (increase && index >= 0 && index < fractions.length - 1 ||
        !increase && index > 0) {
      var newFraction = fractions[increase ? index + 1 : index - 1];
      var fractionParts = newFraction
          .split(RegExp(r'/'))
          .map((fPart) => int.tryParse(fPart) ?? 1)
          .toList();
      updatePartsPaid(widget.item.price / fractionParts[1] * fractionParts[0],
          newFraction.startsWith('0') ? 0 : 1, newFraction, person);
      widget.personToController[person]!.text = newFraction;
      setState(() {});
    } else {
      debugPrint('Invalid index');
    }
  }

  List<String> generateFractions(int memberSize) {
    List<String> fractions = ['0/1'];
    if (memberSize < 1) return fractions;
    for (var denominator = 1; denominator <= memberSize; denominator++) {
      for (var numerator = 1; numerator <= denominator; numerator++) {
        fractions.add('$numerator/$denominator');
      }
    }
    return fractions;
  }

  void updatePartsPaid(
      double price, int quantity, String displayedPartPaid, Person person) {
    Partition? paid = widget.partsPaid.containsKey(person)
        ? widget.partsPaid[person]
        : null; // .where((part) => part.person == person).toList();
    if (paid != null) {
      paid.displayedPartPaid = displayedPartPaid;
      paid.payment = price;
    } else {
      widget.partsPaid.putIfAbsent(
          person,
          () => Partition(
              person: person,
              payment: price,
              quantity: quantity,
              displayedPartPaid: displayedPartPaid));
    }
    debugPrint('Updating parts paid: $displayedPartPaid ($price) by $person');
    debugPrint(widget.partsPaid.toString());
  }
}
