import 'package:cloud_firestore/cloud_firestore.dart';

DateTime _readDate(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  return DateTime.fromMillisecondsSinceEpoch(0);
}

double _readDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return 0;
}

/// Counters written with `FieldValue.increment` can come back as either an int
/// or a double depending on how they were seeded, so they are read as `num`
/// rather than cast to `int`.
int _readInt(dynamic value) {
  if (value is num) {
    return value.toInt();
  }
  return 0;
}

String _readString(dynamic value, [String fallback = '']) {
  if (value is String && value.isNotEmpty) return value;
  return fallback;
}

/// `cast<String>()` defers its type check to iteration, so a single non-string
/// entry throws deep inside a widget build. Filtering up front keeps a
/// malformed document from taking down the screen.
List<String> _readStringList(dynamic value) {
  if (value is! List) return const <String>[];
  return value.whereType<String>().toList(growable: false);
}

DateTime? _readOptionalDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}

class VillageOverview {
  const VillageOverview({
    required this.name,
    required this.totalCitizens,
    required this.totalFundCollected,
    required this.totalSpent,
  });

  final String name;
  final int totalCitizens;
  final double totalFundCollected;
  final double totalSpent;

  double get availableBalance => totalFundCollected - totalSpent;

  factory VillageOverview.fromMap(Map<String, dynamic> map) {
    return VillageOverview(
      name: _readString(map['name'], 'Our Village'),
      totalCitizens: _readInt(map['totalCitizens']),
      totalFundCollected: _readDouble(map['totalFundCollected']),
      totalSpent: _readDouble(map['totalSpent']),
    );
  }
}

class Donation {
  const Donation({
    required this.id,
    required this.donorName,
    required this.amount,
    required this.paymentMethod,
    required this.createdAt,
    required this.userId,
    required this.status,
    required this.transactionId,
    required this.senderNumber,
    this.receivedAccountId = '',
    this.receivedAccountLabel = '',
  });

  final String id;
  final String donorName;
  final double amount;
  final String paymentMethod;
  final DateTime createdAt;
  final String userId;
  final String status;
  final String transactionId;
  final String senderNumber;

  /// Id of the village payment account the money was sent to, as recorded by
  /// the admin panel. Empty for cash and for donations logged before the
  /// account was chosen explicitly.
  final String receivedAccountId;

  /// Human-readable form of [receivedAccountId] (`"bkash • 0170… • Fund"`),
  /// denormalized by the admin panel so it survives an account being deleted.
  final String receivedAccountLabel;

  bool get isPending => status == 'Pending';
  bool get isApproved => status == 'Approved';
  bool get isRejected => status == 'Rejected';

  factory Donation.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Donation.fromMap(doc.id, doc.data() ?? const <String, dynamic>{});

  /// Parses a Firestore document body. Separate from [Donation.fromDoc]
  /// so parsing can be tested without constructing a snapshot.
  factory Donation.fromMap(String id, Map<String, dynamic> map) {
    return Donation(
      id: id,
      donorName: _readString(map['donorName'], 'Anonymous'),
      amount: _readDouble(map['amount']),
      paymentMethod: _readString(map['paymentMethod'], 'Manual Transfer'),
      createdAt: _readDate(map['createdAt']),
      userId: _readString(map['userId']),
      status: _readString(map['status'], 'Approved'),
      transactionId: _readString(map['transactionId']),
      senderNumber: _readString(map['senderNumber']),
      receivedAccountId: _readString(map['receivedAccountId']),
      receivedAccountLabel: _readString(map['receivedAccountLabel']),
    );
  }
}

class ProblemReport {
  const ProblemReport({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.photoUrl,
    required this.location,
    required this.createdAt,
    required this.reportedBy,
    required this.upvotes,
    required this.downvotes,
  });

  final String id;
  final String title;
  final String description;
  final String status;
  final String photoUrl;
  final String location;
  final DateTime createdAt;

  /// Display name of the reporter. Firestore holds the account identity in
  /// `reportedBy` and the display name in `reportedByName`; only the name is
  /// ever shown, so that is what this field carries.
  final String reportedBy;
  final int upvotes;
  final int downvotes;

  bool get isPending => status == 'Pending';
  bool get isApproved => status == 'Approved';
  bool get isCompleted => status == 'Completed';

  /// Net vote score (upvotes - downvotes)
  int get voteScore => upvotes - downvotes;

  factory ProblemReport.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      ProblemReport.fromMap(doc.id, doc.data() ?? const <String, dynamic>{});

  /// Parses a Firestore document body. Separate from [ProblemReport.fromDoc]
  /// so parsing can be tested without constructing a snapshot.
  factory ProblemReport.fromMap(String id, Map<String, dynamic> map) {
    return ProblemReport(
      id: id,
      title: _readString(map['title']),
      description: _readString(map['description']),
      status: _readString(map['status'], 'Pending'),
      photoUrl: _readString(map['photoUrl']),
      location: _readString(map['location']),
      createdAt: _readDate(map['createdAt']),
      reportedBy: _readString(map['reportedByName'], 'Citizen'),
      upvotes: _readInt(map['upvotes']),
      downvotes: _readInt(map['downvotes']),
    );
  }
}

class DevelopmentProject {
  const DevelopmentProject({
    required this.id,
    required this.title,
    required this.description,
    required this.estimatedCost,
    required this.allocatedFunds,
    required this.status,
    required this.photos,
    required this.updates,
    required this.spendingReport,
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final double estimatedCost;
  final double allocatedFunds;
  final String status;
  final List<String> photos;
  final List<String> updates;
  final List<String> spendingReport;

  /// Absent on projects created before the admin panel started stamping it.
  final DateTime? createdAt;

  /// Share of the estimated cost that has been funded, as a 0..1 fraction.
  double get fundingProgress {
    if (estimatedCost <= 0) return 0;
    return (allocatedFunds / estimatedCost).clamp(0.0, 1.0);
  }

  /// Amount still needed to fully fund the project.
  double get remainingCost {
    final remaining = estimatedCost - allocatedFunds;
    return remaining < 0 ? 0 : remaining;
  }

  factory DevelopmentProject.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      DevelopmentProject.fromMap(doc.id, doc.data() ?? const <String, dynamic>{});

  /// Parses a Firestore document body. Separate from [DevelopmentProject.fromDoc]
  /// so parsing can be tested without constructing a snapshot.
  factory DevelopmentProject.fromMap(String id, Map<String, dynamic> map) {
    return DevelopmentProject(
      id: id,
      title: _readString(map['title']),
      description: _readString(map['description']),
      estimatedCost: _readDouble(map['estimatedCost']),
      allocatedFunds: _readDouble(map['allocatedFunds']),
      status: _readString(map['status'], 'Planning'),
      photos: _readStringList(map['photos']),
      updates: _readStringList(map['updates']),
      spendingReport: _readStringList(map['spendingReport']),
      createdAt: _readOptionalDate(map['createdAt']),
    );
  }
}

/// Represents a single entry in the `fund_transactions` Firestore collection.
/// type = 'donation' means a donation was confirmed;
/// type = 'expense'  means admin recorded a fund expenditure.
class FundTransaction {
  const FundTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.reference,
    required this.note,
    required this.createdAt,
    this.category = '',
    this.donationId = '',
  });

  final String id;
  final String type;      // 'expense' | 'donation'
  final double amount;
  final String reference; // e.g. project title or donor name
  final String note;      // free-text description
  final DateTime createdAt;

  /// Expense category chosen by the admin (e.g. "Construction", "Other").
  final String category;

  /// For `type == 'donation'`, the donation this ledger row was created from.
  /// The admin panel uses it to reverse the row if the donation is later
  /// rejected or deleted. Empty on rows written before that link existed.
  final String donationId;

  bool get isExpense => type != 'donation';

  factory FundTransaction.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      FundTransaction.fromMap(doc.id, doc.data() ?? const <String, dynamic>{});

  /// Parses a Firestore document body. Separate from [FundTransaction.fromDoc]
  /// so parsing can be tested without constructing a snapshot.
  factory FundTransaction.fromMap(String id, Map<String, dynamic> map) {
    return FundTransaction(
      id: id,
      type: _readString(map['type'], 'expense'),
      amount: _readDouble(map['amount']),
      // The admin panel writes both `project` and `reference` for expenses;
      // donations only carry `reference` (the donor name).
      reference: _readString(map['reference'], _readString(map['project'])),
      // The admin panel writes `notes`; older app-created docs use `note`.
      note: _readString(map['note'], _readString(map['notes'])),
      createdAt: _readDate(map['createdAt']),
      category: _readString(map['category']),
      donationId: _readString(map['donationId']),
    );
  }
}

class Citizen {
  const Citizen({
    required this.id,
    required this.name,
    required this.profession,
    required this.phone,
    required this.photoUrl,
    required this.village,
    this.address = '',
    this.email = '',
    this.bloodGroup = '',
    this.dateOfBirth = '',
    this.blocked = false,
  });

  final String id;
  final String name;
  final String profession;
  final String phone;
  final String photoUrl;
  final String village;
  final String address;
  final String email;
  final String bloodGroup;
  final String dateOfBirth;

  /// Set by an admin from the web panel. Blocked citizens are hidden from the
  /// public directory and are signed out of the app.
  final bool blocked;

  factory Citizen.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Citizen.fromMap(doc.id, doc.data() ?? const <String, dynamic>{});

  /// Parses a Firestore document body. Separate from [Citizen.fromDoc]
  /// so parsing can be tested without constructing a snapshot.
  factory Citizen.fromMap(String id, Map<String, dynamic> map) {
    return Citizen(
      id: id,
      name: _readString(map['name']),
      profession: _readString(map['profession']),
      phone: _readString(map['phone']),
      photoUrl: _readString(map['photoUrl']),
      village: _readString(map['village']),
      address: _readString(map['address']),
      email: _readString(map['email']),
      bloodGroup: _readString(map['bloodGroup']),
      dateOfBirth: _readString(map['dateOfBirth']),
      blocked: (map['blocked'] as bool?) ?? false,
    );
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final DateTime createdAt;

  /// Combined display text: shows title + body when both exist.
  String get message {
    if (title.isNotEmpty && body.isNotEmpty) return '$title\n$body';
    if (title.isNotEmpty) return title;
    if (body.isNotEmpty) return body;
    return 'Village update available';
  }

  factory AppNotification.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      AppNotification.fromMap(doc.id, doc.data() ?? const <String, dynamic>{});

  /// Parses a Firestore document body. Separate from [AppNotification.fromDoc]
  /// so parsing can be tested without constructing a snapshot.
  factory AppNotification.fromMap(String id, Map<String, dynamic> map) {
    return AppNotification(
      id: id,
      type: _readString(map['type'], 'project'),
      title: _readString(map['title']),
      body: _readString(map['body']),
      createdAt: _readDate(map['createdAt']),
    );
  }
}
