import 'package:intl/intl.dart';

class NumberFormatters {
  static String formatIndianCurrency(num price) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '',
      decimalDigits: 0,
    );
    return formatter.format(price).trim();
  }
}
