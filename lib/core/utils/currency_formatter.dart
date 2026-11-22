import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatterInt = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _formatterDec = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static String format(double amount, {String symbol = '₹'}) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final formatter = (absAmount.truncateToDouble() == absAmount)
        ? _formatterInt
        : _formatterDec;
    final formatted = formatter.format(absAmount).replaceAll('₹', symbol).trim();
    return isNegative ? '-$formatted' : formatted;
  }

  static String formatNumberString(String value, {String locale = 'en_IN'}) {
    if (value.isEmpty || value == '0') return '0';
    final parts = value.split('.');
    final integerStr = parts[0];
    final integerVal = double.tryParse(integerStr) ?? 0;

    final formatter = NumberFormat('#,##,##0', locale);
    final formattedInt = formatter.format(integerVal);

    if (parts.length > 1) {
      return '$formattedInt.${parts[1]}';
    } else if (value.endsWith('.')) {
      return '$formattedInt.';
    }
    return formattedInt;
  }

  static String formatCompact(double amount, {String symbol = '₹'}) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    String formatted;
    if (absAmount >= 10000000) {
      formatted = '$symbol${(absAmount / 10000000).toStringAsFixed(2)} Cr';
    } else if (absAmount >= 100000) {
      formatted = '$symbol${(absAmount / 100000).toStringAsFixed(2)} L';
    } else {
      formatted = format(absAmount, symbol: symbol);
    }
    return isNegative ? '-$formatted' : formatted;
  }
}
