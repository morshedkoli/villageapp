import 'package:flutter_test/flutter_test.dart';
import 'package:doulatpara/models.dart';
import 'package:doulatpara/services/citizen_service.dart';

void main() {
  group('CitizenService.citizenFromMap', () {
    test('prefers primary field names', () {
      final c = CitizenService.citizenFromMap('id1', {
        'name': 'Alice',
        'profession': 'Farmer',
        'phone': '017',
        'photoUrl': 'p.jpg',
        'village': 'North',
      });
      expect(c.name, 'Alice');
      expect(c.profession, 'Farmer');
      expect(c.phone, '017');
      expect(c.photoUrl, 'p.jpg');
      expect(c.village, 'North');
    });

    test('falls back to legacy field names when primary is missing', () {
      final c = CitizenService.citizenFromMap('id2', {
        'fullName': 'Bob',
        'occupation': 'Teacher',
        'phoneNumber': '018',
        'profileImage': 'q.jpg',
        'address': 'South',
      });
      expect(c.name, 'Bob');
      expect(c.profession, 'Teacher');
      expect(c.phone, '018');
      expect(c.photoUrl, 'q.jpg');
      expect(c.village, 'South');
    });

    test('defaults to empty strings when nothing matches', () {
      final c = CitizenService.citizenFromMap('id3', {});
      expect(c.name, '');
      expect(c.phone, '');
    });
  });

  group('CitizenService.citizenIdentity', () {
    Citizen citizen({String phone = '', String name = '', String village = '', String id = 'x'}) =>
        Citizen(id: id, name: name, profession: '', phone: phone, photoUrl: '', village: village);

    test('keys by normalized phone when present', () {
      final id = CitizenService.citizenIdentity(citizen(phone: '+880 171-234 5678'));
      expect(id, 'phone:+8801712345678');
    });

    test('falls back to name+village when phone is empty', () {
      final id = CitizenService.citizenIdentity(citizen(name: 'Alice', village: 'North'));
      expect(id, 'name:alice|village:north');
    });

    test('falls back to doc id when name and phone are both empty', () {
      final id = CitizenService.citizenIdentity(citizen(id: 'doc42'));
      expect(id, 'id:doc42');
    });
  });
  group('CitizenService.mergeCitizens', () {
    Citizen citizen(
      String id, {
      String name = '',
      String phone = '',
      String village = '',
      bool blocked = false,
    }) {
      return Citizen(
        id: id,
        name: name,
        profession: '',
        phone: phone,
        photoUrl: '',
        village: village,
        blocked: blocked,
      );
    }

    test('prefers the users record when the same person is in both sources', () {
      final merged = CitizenService.mergeCitizens(
        [citizen('u1', name: 'Rahim (users)', phone: '01700000000')],
        [citizen('c1', name: 'Rahim (legacy)', phone: '01700000000')],
      );

      expect(merged, hasLength(1));
      expect(merged.single.name, 'Rahim (users)');
    });

    test('keeps a legacy-only citizen', () {
      final merged = CitizenService.mergeCitizens(
        [citizen('u1', name: 'Rahim', phone: '017')],
        [citizen('c1', name: 'Karim', phone: '018')],
      );

      expect(merged.map((c) => c.name), ['Karim', 'Rahim']);
    });

    test('hides citizens an admin has blocked', () {
      final merged = CitizenService.mergeCitizens(
        [
          citizen('u1', name: 'Rahim', phone: '017'),
          citizen('u2', name: 'Blocked', phone: '018', blocked: true),
        ],
        const [],
      );

      expect(merged.map((c) => c.name), ['Rahim']);
    });

    test('sorts by name, case-insensitively', () {
      final merged = CitizenService.mergeCitizens(
        [
          citizen('u1', name: 'zahir', phone: '017'),
          citizen('u2', name: 'Abdul', phone: '018'),
        ],
        const [],
      );

      expect(merged.map((c) => c.name), ['Abdul', 'zahir']);
    });

    test('treats differently formatted phone numbers as the same person', () {
      final merged = CitizenService.mergeCitizens(
        [citizen('u1', name: 'Rahim', phone: '017-000-0000')],
        [citizen('c1', name: 'Rahim legacy', phone: '0170000000')],
      );

      expect(merged, hasLength(1));
    });

    test('returns nothing when both sources are empty', () {
      expect(CitizenService.mergeCitizens(const [], const []), isEmpty);
    });
  });
}
