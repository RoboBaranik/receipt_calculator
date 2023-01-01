import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helper {
  static String locale = 'sk';
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
  static NumberFormat decimalFormat =
      NumberFormat.decimalPattern(Helper.locale);
  static NumberFormat a = NumberFormat.simpleCurrency();

  static String valueWithCurrency(double value, String currency) {
    NumberFormat format = NumberFormat.compactSimpleCurrency(
        locale: Helper.locale, name: currency, decimalDigits: 2);
    return format.format(value);
  }

  static String countToString(int count) {
    if (count <= 1) {
      return '';
    }
    String countSimple =
        NumberFormat.compact(locale: Helper.locale).format(count);
    switch (Helper.locale) {
      case 'sk':
        return '$countSimple ks';
      case 'en':
      default:
        return '${countSimple}x';
    }
  }
}
