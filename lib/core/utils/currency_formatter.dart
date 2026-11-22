import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String format(double amount, {String symbol = '₹'}) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final formatted = _formatter.format(absAmount).replaceAll('₹', symbol).trim();
    return isNegative ? '-$formatted' : formatted;
  }

  static String formatCompact(double amount, {String symbol = '₹'}) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    String formatted;
    if (absAmount >= 100000) {
      formatted = '$symbol${(absAmount / 100000).toStringAsFixed(2)} L';
    } else if (absAmount >= 1000) {
      formatted = '$symbol${(absAmount / 1000).toStringAsFixed(1)}k';
    } else {
      formatted = '$symbol${absAmount.toStringAsFixed(0)}';
    }
    return isNegative ? '-$formatted' : formatted;
  }
}

