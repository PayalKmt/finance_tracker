import 'package:intl/intl.dart';

class Formatters {
  static String currency(double amount, {bool showSign = false}) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final result = formatter.format(amount.abs());
    if (showSign) {
      return amount >= 0 ? '+$result' : '-$result';
    }
    return result;
  }

  static String date(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat('EEEE').format(date);
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String shortDate(DateTime date) =>
      DateFormat('dd MMM').format(date);

  static String fullDate(DateTime date) =>
      DateFormat('EEEE, dd MMMM yyyy').format(date);

  static String monthYear(DateTime date) =>
      DateFormat('MMMM yyyy').format(date);
}
