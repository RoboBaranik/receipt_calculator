import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_payment.dart';
import 'package:receipt_calculator/pages/receipt_create_manual_page.dart';
import 'package:receipt_calculator/pages/receipt_groups_page.dart';
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
        bool argsValid = args != null && (args as List<Object>).length == 2;
        List<Object> arguments = args as List<Object>;
        return PageRouteBuilder(
            pageBuilder: (context, _, __) => ReceiptPage(
                  receipt: argsValid ? arguments[0] as Receipt : mocked1,
                  member: argsValid ? arguments[1] as Person? : null,
                ),
            transitionsBuilder: transition);
      case receiptList:
        return PageRouteBuilder(
            pageBuilder: (context, _, __) =>
                ReceiptListPage(group: mockedEvent),
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
      case ReceiptGroupsPage.route:
        return PageRouteBuilder(
            pageBuilder: (context, _, __) =>
                ReceiptGroupsPage(groups: [mockedEvent]),
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

  static Person personA = Person('Abraham Asertive');
  static Person personB = Person('Betty Bored');
  static Person personC = Person('Cindy Clever');
  static Person personD = Person('DerekDetermined');
  static Person personE = Person('Eustace Exhausted');

  static PersonGroup mockedGroup =
      PersonGroup(members: [personA, personB, personC, personD, personE]);
  static Event mockedEvent = Event(
    group: mockedGroup,
    created: DateTime(1998, 12, 31, 13, 50),
  );
  static Receipt mocked1 = Receipt(
      id: 'empty',
      name: 'LIDL',
      timeCreated: DateTime.now(),
      group: mockedEvent,
      items: [
        ReceiptItem(
          name: 'Ketchup',
          quantity: 5,
          price: 15,
          partsPaid: {
            personA: Partition(person: personA, payment: 3, quantity: 1),
            personB: Partition(person: personB, payment: 3, quantity: 1),
            personC: Partition(person: personC, payment: 3, quantity: 1),
            personD: Partition(person: personD, payment: 3, quantity: 1),
            personE: Partition(person: personE, payment: 3, quantity: 1),
          },
        ),
        ReceiptItem(name: 'Milk', price: 2),
        ReceiptItem(name: 'Chips', price: 0.5),
        ReceiptItem(name: 'Yoghurt', price: 0.2),
        ReceiptItem(name: 'Green apple', quantity: 5, price: 20),
        ReceiptItem(name: 'Strawberry', quantity: 12, price: 5),
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
      group: mockedEvent,
      items: [
        ReceiptItem(name: 'Milk', price: 4.53),
        ReceiptItem(
          name: 'Ketchup',
          price: 110,
          partsPaid: {
            personA: Partition(person: personA, payment: 10, quantity: 1),
            personB: Partition(person: personB, payment: 50, quantity: 1),
            personC: Partition(person: personC, payment: 20, quantity: 1),
            personD: Partition(person: personD, payment: 5, quantity: 1),
            personE: Partition(person: personE, payment: 25, quantity: 1),
          },
        ),
      ]);
}
