import 'package:flutter/material.dart';
import 'package:receipt_calculator/pages/receipt_create_manual_page.dart';
import 'package:receipt_calculator/pages/receipt_list_page.dart';
import 'package:receipt_calculator/pages/receipt_page.dart';

import 'data/receipt_item.dart';

class Routes {
  static const String receipt = '/receipt';
  static const String receiptList = 'receipt_list';
  static const String receiptCreateManual = '/receipt_create_manual';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case receipt:
        return PageRouteBuilder(
          pageBuilder: (context, _, __) =>
              ReceiptPage(receipt: args != null ? args as Receipt : mocked1),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        );
      case receiptList:
        return PageRouteBuilder(
          pageBuilder: (context, _, __) => ReceiptListPage(
            receipts: [mocked1, mocked2],
          ),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        );
      case receiptCreateManual:
        return PageRouteBuilder(
          pageBuilder: (context, _, __) => const ReceiptCreateManualPage(),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        );

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

  static Receipt mocked1 =
      Receipt(name: 'LIDL', timeCreated: DateTime.now(), items: [
    ReceiptItem(
      name: 'Ketchup',
      partsPaid: [
        Partition(person: 'A', percentPaid: 10),
        Partition(person: 'B', percentPaid: 50),
        Partition(person: 'C', percentPaid: 20),
        Partition(person: 'D', percentPaid: 5),
        Partition(person: 'E', percentPaid: 25),
      ],
    ),
    ReceiptItem(name: 'Milk'),
    ReceiptItem(name: 'Chips'),
    ReceiptItem(name: 'Yoghurt'),
    ReceiptItem(name: 'Green apple', count: 5),
    ReceiptItem(name: 'Strawberry', count: 120, value: 5),
    ReceiptItem(
        name: 'Intel Core i5-12600K 3.5 GHz, 8-Core',
        count: 54321,
        value: 1234),
    ReceiptItem(name: 'Small mirror', value: 200),
    ReceiptItem(name: 'Coffee cup', value: 50),
    ReceiptItem(name: 'Roll', count: 4321),
    ReceiptItem(name: 'Book', value: 15),
    ReceiptItem(name: 'Better book', value: 15.01),
    ReceiptItem(name: 'Unknown space object', value: 5432987),
  ]);
  static Receipt mocked2 = Receipt(
      name: 'Fresh',
      timeCreated: DateTime(2019, 9, 11, 12, 50, 0),
      items: [
        ReceiptItem(name: 'Milk'),
        ReceiptItem(
          name: 'Ketchup',
          partsPaid: [
            Partition(person: 'A', percentPaid: 10),
            Partition(person: 'B', percentPaid: 50),
            Partition(person: 'C', percentPaid: 20),
            Partition(person: 'D', percentPaid: 5),
            Partition(person: 'E', percentPaid: 25),
          ],
        ),
      ]);
}
