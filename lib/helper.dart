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
  static NumberFormat currencyFormatter(String? currency) =>
      NumberFormat.simpleCurrency(
          locale: Helper.locale,
          name: currency ?? Helper.currency,
          decimalDigits: 2);
  static NumberFormat currencyFormatterCompact(String? currency) =>
      NumberFormat.compactSimpleCurrency(
          locale: Helper.locale,
          name: currency ?? Helper.currency,
          decimalDigits: 2);

  static String dateTimeToString(DateTime time) {
    return DateFormat('d. MMMM y HH:mm', Helper.locale).format(time);
  }

  static String dateToShortMonthString(DateTime time) {
    return DateFormat('MMM', Helper.locale).format(time);
  }

  static String dateToShortYearString(DateTime time) {
    return DateFormat("''yy", Helper.locale).format(time);
  }

  static DateTime mergeDateAndTime(
      [DateTime? date, TimeOfDay? time, DateTime? defaultDate]) {
    defaultDate ??= DateTime.now();
    time ??= TimeOfDay.now();
    if (date == null) {
      return defaultDate;
    }
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  static DateTime? jsonDateParse(String time) {
    try {
      return DateFormat('dd.MM.yyyy HH:mm:ss', Helper.locale).parse(time);
    } catch (e) {
      debugPrint('Not able to parse $time');
      return null;
    }
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

  static String valueShortWithCurrency(double value, String? currency) {
    if (value < 1000) {
      return Helper._valueWithCurrency(
          value, currency, Helper.currencyFormatter(currency));
    }
    return Helper._valueWithCurrency(
        value, currency, Helper.currencyFormatterCompact(currency));
  }

  static String valueLongWithCurrency(double value, String? currency) {
    return Helper._valueWithCurrency(
        value, currency, Helper.currencyFormatter(currency));
  }

  static String _valueWithCurrency(
      double value, String? currency, NumberFormat formatter) {
    double fixedValue = (value * 100).round() / 100;
    if (fixedValue < 1000) {}
    return formatter.format(fixedValue);
  }

  static String countToString(int count, [bool? showQuantityOne]) {
    if (count == 1 && (showQuantityOne == null || !showQuantityOne)) {
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
      ScrollController listScroll, Iterable<ExpandableController> list) {
    if (list.isEmpty) {
      return;
    }
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
    list.last.addListener(() {
      if (list.last.value) {
        listScroll.jumpTo(listScroll.position.maxScrollExtent - 1);
        // listScroll.jumpTo(listScroll.position.maxScrollExtent);
        listScroll.animateTo(listScroll.position.maxScrollExtent + 1000,
            duration: const Duration(seconds: 1, milliseconds: 500),
            curve: Curves.fastOutSlowIn);
      }
    });
  }

  static void expandableListControllerSetUpRevert(
      Iterable<ExpandableController> list) {
    var indicies = List.generate(list.length, (index) => index);
    for (var index in indicies) {
      list.elementAt(index).removeListener(() {});
    }
    list.last.removeListener(() {});
  }
}
