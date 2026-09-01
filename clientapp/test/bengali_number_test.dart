import 'package:doulatpara/core/format/bengali_number.dart';
import 'package:doulatpara/features/home/widgets/home_header.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toBengaliDigits', () {
    test('converts every ASCII digit', () {
      expect(toBengaliDigits('0123456789'), '০১২৩৪৫৬৭৮৯');
    });

    test('leaves non-digits alone', () {
      expect(toBengaliDigits('৳1,500'), '৳১,৫০০');
      expect(toBengaliDigits('abc'), 'abc');
      expect(toBengaliDigits(''), '');
    });
  });

  group('formatBengaliAmount', () {
    test('prints small amounts in full', () {
      expect(formatBengaliAmount(0), '০');
      expect(formatBengaliAmount(750), '৭৫০');
      expect(formatBengaliAmount(99999), '৯৯৯৯৯');
    });

    test('abbreviates to lakh', () {
      expect(formatBengaliAmount(100000), '১ লাখ');
      expect(formatBengaliAmount(500000), '৫ লাখ');
    });

    test('adds thousands after the lakh when present', () {
      expect(formatBengaliAmount(125000), '১ লাখ ২৫ হাজার');
    });

    test('drops the fractional part', () {
      expect(formatBengaliAmount(750.9), '৭৫০');
    });
  });

  group('formatTaka', () {
    test('prefixes the taka sign', () {
      expect(formatTaka(1500), '৳১৫০০');
    });

    test('shows a placeholder when nothing has loaded', () {
      expect(formatTaka(null), '--');
    });
  });

  group('formatBengaliCount', () {
    test('converts a plain count', () {
      expect(formatBengaliCount(0), '০');
      expect(formatBengaliCount(42), '৪২');
    });
  });

  group('greetingForHour', () {
    test('picks the greeting for the time of day', () {
      expect(greetingForHour(0), 'শুভ সকাল');
      expect(greetingForHour(11), 'শুভ সকাল');
      expect(greetingForHour(12), 'শুভ বিকাল');
      expect(greetingForHour(16), 'শুভ বিকাল');
      expect(greetingForHour(17), 'শুভ সন্ধ্যা');
      expect(greetingForHour(23), 'শুভ সন্ধ্যা');
    });
  });
}
