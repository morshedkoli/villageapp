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
      name: (map['name'] as String?) ?? 'Our Village',
      totalCitizens: (map['totalCitizens'] as int?) ?? 0,
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

  factory Donation.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? <String, dynamic>{};
    return Donation(
      id: doc.id,
      donorName: (map['donorName'] as String?) ?? 'Anonymous',
      amount: _readDouble(map['amount']),
      paymentMethod: (map['paymentMethod'] as String?) ?? 'Manual Transfer',
      createdAt: _readDate(map['createdAt']),
      userId: (map['userId'] as String?) ?? '',
      status: (map['status'] as String?) ?? 'Approved',
      transactionId: (map['transactionId'] as String?) ?? '',
      senderNumber: (map['senderNumber'] as String?) ?? '',
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
  final String reportedBy;
  final int upvotes;
  final int downvotes;

  /// Net vote score (upvotes - downvotes)
  int get voteScore => upvotes - downvotes;

  factory ProblemReport.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? <String, dynamic>{};
    return ProblemReport(
      id: doc.id,
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      status: (map['status'] as String?) ?? 'Pending',
      photoUrl: (map['photoUrl'] as String?) ?? '',
      location: (map['location'] as String?) ?? '',
      createdAt: _readDate(map['createdAt']),
      reportedBy: (map['reportedByName'] as String?) ?? 'Citizen',
      upvotes: (map['upvotes'] as int?) ?? 0,
      downvotes: (map['downvotes'] as int?) ?? 0,
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

  factory DevelopmentProject.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final map = doc.data() ?? <String, dynamic>{};
    return DevelopmentProject(
      id: doc.id,
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      estimatedCost: _readDouble(map['estimatedCost']),
      allocatedFunds: _readDouble(map['allocatedFunds']),
      status: (map['status'] as String?) ?? 'Planning',
      photos: (map['photos'] as List<dynamic>? ?? const []).cast<String>(),
      updates: (map['updates'] as List<dynamic>? ?? const []).cast<String>(),
      spendingReport: (map['spendingReport'] as List<dynamic>? ?? const [])
          .cast<String>(),
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
  });

  final String id;
  final String type;      // 'expense' | 'donation'
  final double amount;
  final String reference; // e.g. project title or donor name
  final String note;      // free-text description
  final DateTime createdAt;

  bool get isExpense => type != 'donation';

  factory FundTransaction.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final map = doc.data() ?? <String, dynamic>{};
    return FundTransaction(
      id: doc.id,
      type: (map['type'] as String?) ?? 'expense',
      amount: _readDouble(map['amount']),
      reference: (map['reference'] as String?) ?? '',
      note: (map['note'] as String?) ?? '',
      createdAt: _readDate(map['createdAt']),
    );
  }
}

/// Represents a payment account added by admin from which users can
/// send donations (e.g. bKash, Nagad, Bank account).
/// Admin manages this in the `donation_accounts` Firestore collection.
class DonationAccount {
  const DonationAccount({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.provider,
    required this.isActive,
    this.instructions = '',
  });

  final String id;
  final String name;          // e.g. "গ্রাম উন্নয়ন তহবিল"
  final String accountNumber; // e.g. "01XXXXXXXXX"
  final String provider;      // 'bKash' | 'Nagad' | 'Dutch-Bangla' | 'Bank' | ...
  final bool isActive;
  final String instructions;  // optional note from admin

  factory DonationAccount.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final map = doc.data() ?? <String, dynamic>{};
    return DonationAccount(
      id: doc.id,
      name: (map['name'] as String?) ?? '',
      accountNumber: (map['accountNumber'] as String?) ?? '',
      provider: (map['provider'] as String?) ?? 'bKash',
      isActive: (map['isActive'] as bool?) ?? true,
      instructions: (map['instructions'] as String?) ?? '',
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
  });

  final String id;
  final String name;
  final String profession;
  final String phone;
  final String photoUrl;
  final String village;

  factory Citizen.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? <String, dynamic>{};
    return Citizen(
      id: doc.id,
      name: (map['name'] as String?) ?? '',
      profession: (map['profession'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
      photoUrl: (map['photoUrl'] as String?) ?? '',
      village: (map['village'] as String?) ?? '',
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

  factory AppNotification.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? <String, dynamic>{};
    return AppNotification(
      id: doc.id,
      type: (map['type'] as String?) ?? 'project',
      title: (map['title'] as String?) ?? '',
      body: (map['body'] as String?) ?? '',
      createdAt: _readDate(map['createdAt']),
    );
  }
}

class Leader {
  const Leader({
    required this.id,
    required this.name,
    required this.role,
    required this.experience,
    required this.photoUrl,
    required this.isOnline,
    required this.phone,
    required this.email,
  });

  final String id;
  final String name;
  final String role;
  final String experience;
  final String photoUrl;
  final bool isOnline;
  final String phone;
  final String email;
}

class Comment {
  const Comment({
    required this.id,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String authorName;
  final String text;
  final DateTime createdAt;
}
