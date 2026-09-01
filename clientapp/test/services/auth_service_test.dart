import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doulatpara/services/auth_service.dart';

void main() {
  group('AuthService.normalizePhone', () {
    test('strips spaces and non-digits, keeps leading +', () {
      expect(AuthService.normalizePhone('+880 171 234 5678'), '+8801712345678');
    });

    test('strips non-digits without a leading +', () {
      expect(AuthService.normalizePhone('01712345678'), '01712345678');
      expect(AuthService.normalizePhone('01712-345-678'), '01712345678');
    });

    test('trims surrounding whitespace', () {
      expect(AuthService.normalizePhone('  01712345678  '), '01712345678');
    });
  });

  group('AuthService.friendlyAuthError', () {
    Exception errorFor(String code) =>
        AuthService.friendlyAuthError(FirebaseAuthException(code: code));

    test('maps known codes to Bengali messages', () {
      expect(
        errorFor('wrong-password').toString(),
        contains('ফোন নম্বর বা পাসওয়ার্ড সঠিক নয়'),
      );
      expect(
        errorFor('user-not-found').toString(),
        contains('ফোন নম্বর বা পাসওয়ার্ড সঠিক নয়'),
      );
      expect(
        errorFor('user-disabled').toString(),
        contains('ব্লক করা হয়েছে'),
      );
      expect(
        errorFor('too-many-requests').toString(),
        contains('অনেকবার ভুল হয়েছে'),
      );
      expect(
        errorFor('network-request-failed').toString(),
        contains('ইন্টারনেট সংযোগ নেই'),
      );
    });

    test('falls back to the Firebase message for unknown codes', () {
      final error = AuthService.friendlyAuthError(
        FirebaseAuthException(code: 'some-unmapped-code', message: 'raw message'),
      );
      expect(error.toString(), contains('raw message'));
    });
  });
}
