import 'package:flutter_test/flutter_test.dart';
import 'package:doulatpara/services/donation_service.dart';

void main() {
  group('DonationService.normalizePaymentType', () {
    test('normalizes known lowercase/mixed-case admin values', () {
      expect(DonationService.normalizePaymentType('bkash'), 'bKash');
      expect(DonationService.normalizePaymentType('BKASH'), 'bKash');
      expect(DonationService.normalizePaymentType('nagad'), 'Nagad');
      expect(DonationService.normalizePaymentType('rocket'), 'Rocket');
      expect(DonationService.normalizePaymentType('bank'), 'Bank');
    });

    test('returns unknown types unchanged', () {
      expect(DonationService.normalizePaymentType('Upay'), 'Upay');
    });
  });
  group('DonationService.parsePaymentAccounts', () {
    test('reads the array shape written by the admin panel', () {
      final accounts = DonationService.parsePaymentAccounts([
        {
          'id': 'acct-1',
          'type': 'bkash',
          'number': ' 01700000000 ',
          'name': ' Village Fund ',
        },
        {'id': 'acct-2', 'type': 'bank', 'number': '123', 'name': 'Bank Ltd'},
      ]);

      expect(accounts, hasLength(2));
      expect(accounts.first['id'], 'acct-1');
      expect(accounts.first['type'], 'bKash');
      expect(accounts.first['number'], '01700000000');
      expect(accounts.first['name'], 'Village Fund');
      expect(accounts.last['type'], 'Bank');
    });

    test('synthesizes an id when the admin panel stored none', () {
      final accounts = DonationService.parsePaymentAccounts([
        {'type': 'nagad', 'number': '017', 'name': 'Fund'},
      ]);

      expect(accounts.single['id'], 'nagad_1');
    });

    test('omits bank fields that are absent', () {
      final accounts = DonationService.parsePaymentAccounts([
        {'id': 'a', 'type': 'bkash', 'number': '017', 'name': 'Fund'},
      ]);

      expect(accounts.single.containsKey('bankName'), isFalse);
      expect(accounts.single.containsKey('branch'), isFalse);
    });

    test('keeps bank name and branch when present', () {
      final accounts = DonationService.parsePaymentAccounts([
        {
          'id': 'a',
          'type': 'bank',
          'number': '123',
          'name': 'Fund',
          'bankName': 'Sonali',
          'branch': 'Main',
        },
      ]);

      expect(accounts.single['bankName'], 'Sonali');
      expect(accounts.single['branch'], 'Main');
    });

    test('reads the legacy map shape keyed by payment type', () {
      final accounts = DonationService.parsePaymentAccounts({
        'bkash': {'number': '017', 'name': 'Fund'},
      });

      expect(accounts.single['type'], 'bKash');
      expect(accounts.single['number'], '017');
      expect(accounts.single['id'], 'bkash_1');
    });

    test('reads a legacy entry stored as a bare number', () {
      final accounts = DonationService.parsePaymentAccounts({'nagad': '017'});

      expect(accounts.single['type'], 'Nagad');
      expect(accounts.single['number'], '017');
      expect(accounts.single['name'], isEmpty);
    });

    test('skips non-map entries in the array shape', () {
      final accounts = DonationService.parsePaymentAccounts([
        'garbage',
        {'id': 'a', 'type': 'bkash', 'number': '017', 'name': 'Fund'},
      ]);

      expect(accounts, hasLength(1));
    });

    test('returns nothing when the field is missing or the wrong type', () {
      expect(DonationService.parsePaymentAccounts(null), isEmpty);
      expect(DonationService.parsePaymentAccounts('nope'), isEmpty);
    });
  });
}
