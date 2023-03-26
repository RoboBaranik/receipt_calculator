import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_payment.dart';
import 'package:receipt_calculator/pages/receipt_create_manual_page.dart';
import 'package:receipt_calculator/pages/receipt_list_page.dart';
import 'package:receipt_calculator/pages/receipt_page.dart';
import 'package:receipt_calculator/pages/receipt_scanner_page.dart';
import 'package:receipt_calculator/pages/receipt_split_page.dart';
import 'package:receipt_calculator/pages/receipt_summary_page.dart';

import 'data/receipt_item.dart';

class Routes {
  static const String receiptList = 'receipt_list';
  static const String receiptSummary = '/receipt_summary';
  static const String receipt = '/receipt';
  static const String receiptCreateManual = '/receipt_create_manual';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case receipt:
        return PageRouteBuilder(
            pageBuilder: (context, _, __) =>
                ReceiptPage(receipt: args != null ? args as Receipt : mocked1),
            transitionsBuilder: transition);
      case receiptList:
        return PageRouteBuilder(
            pageBuilder: (context, _, __) => ReceiptListPage(
                  receipts: [mocked1, mocked2],
                ),
            transitionsBuilder: transition);
      case receiptCreateManual:
        return PageRouteBuilder(
            pageBuilder: (context, _, __) => const ReceiptCreateManualPage(),
            transitionsBuilder: transition);
      case receiptSummary:
        return PageRouteBuilder(
            pageBuilder: (context, _, __) => ReceiptSummaryPage(
                receipt: args != null ? args as Receipt : mocked1),
            transitionsBuilder: transition);
      case ReceiptScannerPage.route:
        return PageRouteBuilder(
            pageBuilder: (context, _, __) => const ReceiptScannerPage(),
            transitionsBuilder: transition);
      case ReceiptSplitPage.route:
        if (args == null || args is! Map<String, dynamic>) {
          debugPrint(args.toString());
          return _errorRoute(settings);
        }
        return PageRouteBuilder(
            pageBuilder: (context, _, __) => ReceiptSplitPage(
                receipt: args['receipt'], itemIndex: args['itemIndex']),
            transitionsBuilder: transition);

      default:
        return _errorRoute(settings);
    }
  }

  static Route<dynamic> _errorRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: ((context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('Page not found'),
        ),
      );
    }));
  }

  static Widget transition(BuildContext bc, Animation<double> a1,
          Animation<double> a2, Widget child) =>
      FadeTransition(opacity: a1, child: child);

  static ReceiptGroup mockedGroup = ReceiptGroup(members: [
    Person('Abraham Asertive'),
    Person('Betty Bored'),
    Person('Cindy Clever'),
    Person('DerekDetermined'),
    Person('Eustace Exhausted')
  ]);
  static Receipt mocked1 = Receipt(
      id: 'empty',
      name: 'LIDL',
      timeCreated: DateTime.now(),
      group: mockedGroup,
      items: [
        ReceiptItem(
          name: 'Ketchup',
          partsPaid: [
            Partition(person: Person('Abraham Asertive'), payment: 10),
            Partition(person: Person('Betty Bored'), payment: 50),
            Partition(person: Person('Cindy Clever'), payment: 20),
            Partition(person: Person('DerekDetermined'), payment: 5),
            Partition(person: Person('Eustace Exhausted'), payment: 25),
          ],
        ),
        ReceiptItem(name: 'Milk'),
        ReceiptItem(name: 'Chips'),
        ReceiptItem(name: 'Yoghurt'),
        ReceiptItem(name: 'Green apple', quantity: 5),
        ReceiptItem(name: 'Strawberry', quantity: 120, price: 5),
        ReceiptItem(
            name: 'Intel Core i5-12600K 3.5 GHz, 8-Core',
            quantity: 54321,
            price: 1234),
        ReceiptItem(name: 'Small mirror', price: 200),
        ReceiptItem(name: 'Coffee cup', price: 50),
        ReceiptItem(name: 'Roll', quantity: 4321),
        ReceiptItem(name: 'Book', price: 15),
        ReceiptItem(name: 'Better book', price: 15.01),
        ReceiptItem(name: 'Unknown space object', price: 5432987),
      ]);
  static Receipt mocked2 = Receipt(
      id: 'empty',
      name: 'Fresh',
      timeCreated: DateTime(2019, 9, 11, 12, 50, 0),
      group: mockedGroup,
      items: [
        ReceiptItem(name: 'Milk', price: 4.53),
        ReceiptItem(
          name: 'Ketchup',
          price: 110,
          partsPaid: [
            Partition(person: Person('Abraham Asertive'), payment: 10),
            Partition(person: Person('Betty Bored'), payment: 50),
            Partition(person: Person('Cindy Clever'), payment: 20),
            Partition(person: Person('DerekDetermined'), payment: 5),
            Partition(person: Person('Eustace Exhausted'), payment: 25),
          ],
        ),
      ]);
}
