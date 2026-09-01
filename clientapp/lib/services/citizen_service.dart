import 'package:rxdart/rxdart.dart';

import '../models.dart';
import 'firestore_refs.dart';
import 'stream_cache.dart';

/// Registered citizens, merged from `users` (isCitizen == true) and the
/// legacy `citizens` collection.
class CitizenService {
  CitizenService._();

  static final CitizenService instance = CitizenService._();

  final StreamCache _cache = StreamCache('CitizenService');

  void clearCache() => _cache.clear();

  /// Registered citizens, blocked accounts excluded, sorted by name.
  Stream<List<Citizen>> citizens() {
    return _cache.stream('citizens', _citizensStream);
  }

  Stream<List<Citizen>> _citizensStream() {
    // Filter server-side for isCitizen == true when possible
    final usersStream = Db.collection(Db.users)
        .where('isCitizen', isEqualTo: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => citizenFromMap(doc.id, doc.data()))
              .toList(),
        )
        .onErrorReturn(const <Citizen>[]);

    final legacyCitizensStream = Db.collection(Db.citizens)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => citizenFromMap(doc.id, doc.data()))
              .toList(),
        )
        .onErrorReturn(const <Citizen>[]);

    return CombineLatestStream.combine2(
      usersStream,
      legacyCitizensStream,
      mergeCitizens,
    );
  }

  /// Merges the two sources, preferring the `users` record when the same person
  /// appears in both, and drops anyone an admin has blocked.
  static List<Citizen> mergeCitizens(
    List<Citizen> users,
    List<Citizen> legacyCitizens,
  ) {
    final merged = <String, Citizen>{};
    for (final citizen in users) {
      merged[citizenIdentity(citizen)] = citizen;
    }
    for (final citizen in legacyCitizens) {
      merged.putIfAbsent(citizenIdentity(citizen), () => citizen);
    }

    return merged.values.where((c) => !c.blocked).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  /// Reads a citizen record, tolerating the field names used by older
  /// versions of the app and by the legacy  collection.
  static Citizen citizenFromMap(String id, Map<String, dynamic> map) {
    String pick(List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
      return '';
    }

    return Citizen(
      id: id,
      name: pick(['name', 'fullName', 'displayName', 'email']),
      profession: pick(['profession', 'occupation', 'job']),
      phone: pick(['phone', 'phoneNumber', 'mobile']),
      photoUrl: pick(['photoUrl', 'profileImage', 'avatar']),
      village: pick(['village', 'address', 'location']),
      address: pick(['address']),
      email: pick(['email']),
      bloodGroup: pick(['bloodGroup']),
      dateOfBirth: pick(['dateOfBirth']),
      blocked: map['blocked'] == true,
    );
  }

  static String citizenIdentity(Citizen c) {
    final cleanPhone = c.phone.replaceAll(RegExp(r'[^0-9+]'), '').toLowerCase();
    if (cleanPhone.isNotEmpty) return 'phone:$cleanPhone';
    final cleanName = c.name.trim().toLowerCase();
    final cleanVillage = c.village.trim().toLowerCase();
    if (cleanName.isNotEmpty) return 'name:$cleanName|village:$cleanVillage';
    return 'id:${c.id}';
  }
}
