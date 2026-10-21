
import 'package:intl/intl.dart';

class Formatters {
  // Format currency
  static String currency(
    num amount, {
    String currencyCode = 'IDR',
    String locale = 'id_ID',
  }) {
    return NumberFormat.currency(
      locale: locale,
      name: currencyCode,
      decimalDigits: currencyCode == 'IDR' ? 0 : 2,
    ).format(amount);
  }

  static String number(
    num value, {
    String locale = 'id_ID',
    int decimalDigits = 0,
  }) {
    return NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: decimalDigits,
    ).format(value);
  }

  static String date(
    DateTime value, {
    String locale = 'id_ID',
    String pattern = 'dd MMM yyyy',
  }) {
    return DateFormat(pattern, locale).format(value);
  }

  static String dateTime(
    DateTime value, {
    String locale = 'id_ID',
  }) {
    return DateFormat('dd MMM yyyy, HH:mm', locale).format(value);
  }
}
