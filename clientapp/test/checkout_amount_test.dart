import 'package:doulatpara/features/donation/checkout/checkout_amount.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toAsciiDigits', () {
    test('rewrites Bengali digits', () {
      expect(toAsciiDigits('৫০০'), '500');
      expect(toAsciiDigits('১০,০০০'), '10,000');
    });

    test('leaves ASCII digits and other characters alone', () {
      expect(toAsciiDigits('1,000'), '1,000');
      expect(toAsciiDigits('৳৫০০'), '৳500');
    });
  });

  group('parseDonationAmount', () {
    test('parses every quick-pick amount', () {
      // These are Bengali numerals, which `double.tryParse` cannot read.
      // Selecting one and submitting used to fail validation outright.
      expect(kQuickAmounts, isNotEmpty);
      for (final amount in kQuickAmounts) {
        expect(
          parseDonationAmount(amount),
          isNotNull,
          reason: 'quick amount $amount should parse',
        );
      }
    });

    test('parses the specific quick amounts correctly', () {
      expect(parseDonationAmount('৫০০'), 500);
      expect(parseDonationAmount('১,০০০'), 1000);
      expect(parseDonationAmount('১০,০০০'), 10000);
    });

    test('parses an ASCII amount typed into the custom field', () {
      expect(parseDonationAmount('750'), 750);
      expect(parseDonationAmount('1,250'), 1250);
      expect(parseDonationAmount(' 300 '), 300);
    });

    test('parses a decimal amount', () {
      expect(parseDonationAmount('99.5'), 99.5);
    });

    test('rejects an empty or non-numeric entry', () {
      expect(parseDonationAmount(''), isNull);
      expect(parseDonationAmount('   '), isNull);
      expect(parseDonationAmount('abc'), isNull);
    });

    test('rejects zero and negative amounts', () {
      expect(parseDonationAmount('0'), isNull);
      expect(parseDonationAmount('০'), isNull);
      expect(parseDonationAmount('-100'), isNull);
    });
  });
}
