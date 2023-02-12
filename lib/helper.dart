import 'dart:io';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helper {
  static String locale = Platform.localeName;
  static const String currency = 'EUR';
  static int maxPeople = 10;
  static List<Color> colorPerPerson = [
    Colors.blue,
    Colors.red,
    Colors.lime,
    Colors.purple,
    Colors.yellow,
    Colors.brown,
    Colors.cyan,
    Colors.orange,
    Colors.indigo,
    Colors.green
  ];
  static Map<String, String> langToCountMap = {'en': 'x', 'sk': 'ks'};
  static NumberFormat decimalFormat =
      NumberFormat.decimalPattern(Helper.locale);
  static NumberFormat a = NumberFormat.simpleCurrency();

  static String dateTimeToString(DateTime time) {
    return DateFormat('d. MMMM y HH:mm', Helper.locale).format(time);
  }

  static Locale getLocale() {
    var match = RegExp(r'^[a-z]{2,}_[A-Z]{2,}').firstMatch(locale);
    if (match != null) {
      var parts = match[0]?.split('_');
      if (parts != null && parts.length > 1) {
        return Locale(parts[0], parts[1]);
      }
    }
    return Locale(locale.substring(0, 2));
  }

  static String valueWithCurrency(double value, String? currency) {
    NumberFormat format = NumberFormat.compactSimpleCurrency(
        locale: Helper.locale,
        name: currency ?? Helper.currency,
        decimalDigits: 2);
    return format.format(value);
  }

  static String countToString(int count) {
    if (count == 1) {
      return '';
    }
    String countSimple =
        NumberFormat.compact(locale: Helper.locale).format(count);
    var countSuffix = Helper.langToCount();
    switch (Helper.locale.substring(0, 2)) {
      case 'sk':
        return '$countSimple $countSuffix';
      case 'en':
      default:
        return '$countSimple$countSuffix';
    }
  }

  static String langToCount() {
    var count = Helper.langToCountMap[Helper.locale.substring(0, 2)];
    return count ?? 'x';
  }

  static void expandableListControllerSetUp(
      Iterable<ExpandableController> list) {
    var indicies = List.generate(list.length, (index) => index);
    for (var index in indicies) {
      var others = indicies.where((element) => element != index);
      list.elementAt(index).addListener(() {
        if (!list.elementAt(index).value) return;
        for (var element in others) {
          list.elementAt(element).value = false;
        }
      });
    }
  }
}
