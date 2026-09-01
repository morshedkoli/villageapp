import 'package:doulatpara/features/onboarding/onboarding_pages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('kOnboardingPageCount', () {
    test('is the feature slides plus the notification slide', () {
      expect(kOnboardingPageCount, kFeaturePages.length + 1);
    });

    test('counts more than just the feature slides', () {
      // Derived rather than hardcoded, so adding a feature page cannot leave
      // the progress bar and the PageView disagreeing.
      expect(kOnboardingPageCount, greaterThan(kFeaturePages.length));
    });
  });

  group('isNotificationPage', () {
    test('is false for every feature slide', () {
      for (var i = 0; i < kFeaturePages.length; i++) {
        expect(isNotificationPage(i), isFalse, reason: 'page $i');
      }
    });

    test('is true for the final slide', () {
      expect(isNotificationPage(kOnboardingPageCount - 1), isTrue);
    });
  });

  group('kFeaturePages', () {
    test('every slide carries copy for the reader', () {
      expect(kFeaturePages, isNotEmpty);
      for (final page in kFeaturePages) {
        expect(page.titleBn, isNotEmpty);
        expect(page.descBn, isNotEmpty);
      }
    });
  });
}
