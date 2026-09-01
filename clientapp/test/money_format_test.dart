import 'package:doulatpara/core/format/bengali_number.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatTakaExact', () {
    test('groups thousands', () {
      expect(formatTakaExact(1500), '৳1,500');
      expect(formatTakaExact(1250000), '৳1,250,000');
    });

    test('prints small amounts without separators', () {
      expect(formatTakaExact(0), '৳0');
      expect(formatTakaExact(750), '৳750');
    });

    test('rounds away the fractional part', () {
      expect(formatTakaExact(1500.4), '৳1,500');
    });
  });

  group('formatTakaExact vs formatTaka', () {
    test('the exact form keeps every digit the abbreviated one drops', () {
      // The donation screen shows precise figures; the home screen abbreviates.
      expect(formatTakaExact(125000), '৳125,000');
      expect(formatTaka(125000), '৳১ লাখ ২৫ হাজার');
    });
  });
}
