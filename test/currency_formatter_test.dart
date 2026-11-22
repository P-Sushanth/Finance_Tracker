import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('formats integers with Indian commas', () {
      expect(CurrencyFormatter.format(0), '₹0');
      expect(CurrencyFormatter.format(500), '₹500');
      expect(CurrencyFormatter.format(20000), '₹20,000');
      expect(CurrencyFormatter.format(100000), '₹1,00,000');
      expect(CurrencyFormatter.format(1234567), '₹12,34,567');
      expect(CurrencyFormatter.format(-20000), '-₹20,000');
    });

    test('formats decimals with commas when non-integer', () {
      expect(CurrencyFormatter.format(20000.5), '₹20,000.50');
      expect(CurrencyFormatter.format(100000.75), '₹1,00,000.75');
    });

    test('formatNumberString formats numeric strings while typing', () {
      expect(CurrencyFormatter.formatNumberString('0'), '0');
      expect(CurrencyFormatter.formatNumberString('500'), '500');
      expect(CurrencyFormatter.formatNumberString('20000'), '20,000');
      expect(CurrencyFormatter.formatNumberString('100000'), '1,00,000');
      expect(CurrencyFormatter.formatNumberString('20000.'), '20,000.');
      expect(CurrencyFormatter.formatNumberString('20000.5'), '20,000.5');
    });
  });
}
