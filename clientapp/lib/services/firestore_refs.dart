import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore collection names and the single village document every aggregate
/// counter lives on. Previously each service declared its own
/// `villageDocId = 'main_village'`, so a rename meant finding four copies.
class Db {
  const Db._();

  static const String villageDocId = 'main_village';

  static const String villages = 'villages';
  static const String users = 'users';
  static const String donations = 'donations';
  static const String problems = 'problems';
  static const String projects = 'projects';
  static const String notifications = 'notifications';
  static const String fundTransactions = 'fund_transactions';

  /// Legacy standalone citizen records, superseded by `users`.
  static const String citizens = 'citizens';

  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> collection(String name) =>
      _db.collection(name);

  static DocumentReference<Map<String, dynamic>> village() =>
      _db.collection(villages).doc(villageDocId);
}
