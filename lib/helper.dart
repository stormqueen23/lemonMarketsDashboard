import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lemon_markets_client/lemon_markets_client.dart';

class AppHelper {

  static DateFormat formatter = DateFormat('dd.MM.yyyy HH:mm');
  static DateFormat formatterHour = DateFormat('HH:mm');

  static String getDateTimeStringForLemonMarket(DateTime time) {
    return formatter.format(time);
  }

  static String toDisplayMoneyString(double? money) {
    if (money != null) {
      return money.toStringAsFixed(2) + ' €';
    } else {
      return '- €';
    }
  }

  static String toDisplayPercentString(double? doubleValue) {
    if (doubleValue == null) {
      return "%";
    }
    return doubleValue.toStringAsFixed(2) + ' %';
  }

  static String getDescription(Instrument instrument) {
    if (instrument.title.isNotEmpty) {
      return instrument.title;
    } else if (instrument.name.isNotEmpty) {
      return instrument.name;
    } else {
      return instrument.isin;
    }
  }

  static double getHeaderScale() {
    return  1.4;
  }

  static Color positiveAmount = Colors.green;

  static Color negativeAmount = Colors.red;

  static Color getAmountColor(double value) {
    if (value >= 0) {
      return positiveAmount;
    } else {
      return negativeAmount;
    }
  }
}