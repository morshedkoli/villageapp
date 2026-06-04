import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import '../../data_service.dart';
import '../../models.dart';

final dataServiceProvider = Provider<DataService>((ref) => DataService.instance);

final _mockOverview = VillageOverview(
  name: 'আমাদের গ্রাম',
  totalCitizens: 1240,
  totalFundCollected: 1245780,
  totalSpent: 250000,
);

final _mockDonations = List.generate(8, (i) => Donation(
    id: 'd$i',
  donorName: ['রহিম সাহেব', 'করিম সাহেব', 'সুমন আহমেদ', 'নাসরিন বেগম', 'হাসান আলী', 'ফাতেমা খাতুন', 'জয়নাল আবেদীন', 'নুরজাহান বেগম'][i],
  amount: [125000, 92000, 78500, 65000, 54200, 43000, 38000, 25000][i].toDouble(),
  paymentMethod: 'bKash',
  createdAt: DateTime.now().subtract(Duration(hours: i * 3)),
  userId: '',
  status: 'Approved',
  transactionId: '',
  senderNumber: '',
));

final _mockProblems = List.generate(6, (i) {
  final statuses = ['Pending', 'InProgress', 'Resolved', 'Pending', 'Pending', 'Rejected'];
  final titles = [
    'রাস্তা মেরামত প্রয়োজন',
    'নলকূপ স্থাপন',
    'মসজিদ সংস্কার',
    'ড্রেনেজ ব্যবস্থা উন্নয়ন',
    'পুকুর খনন',
    'ব্রিজ নির্মাণ',
  ];
  return ProblemReport(
    id: 'p$i',
    title: titles[i],
    description: 'গ্রামের উন্নয়নের জন্য এই কাজটি জরুরি।',
    status: statuses[i],
    photoUrl: '',
    location: 'উত্তর গ্রাম',
    createdAt: DateTime.now().subtract(Duration(days: i * 2)),
    reportedBy: '',
    upvotes: 24 - i * 3,
    downvotes: 2 + i,
  );
});

final _mockProjects = List.generate(5, (i) {
  final statuses = ['InProgress', 'Completed', 'Planning', 'InProgress', 'Completed'];
  final titles = [
    'মসজিদ সংস্কার প্রকল্প',
    'গ্রামের রাস্তা নির্মাণ',
    'কমিউনিটি সেন্টার',
    'নলকূপ স্থাপন',
    'পুকুর খনন ও সংস্কার',
  ];
  final costs = [1500000, 800000, 2000000, 300000, 500000].map((e) => e.toDouble()).toList();
  final allocated = [1000000, 800000, 200000, 250000, 500000].map((e) => e.toDouble()).toList();
  return DevelopmentProject(
    id: 'pr$i',
    title: titles[i],
    description: 'গ্রামের উন্নয়নের জন্য অত্যন্ত গুরুত্বপূর্ণ একটি প্রকল্প।',
    estimatedCost: costs[i],
    allocatedFunds: allocated[i],
    status: statuses[i],
    photos: const [],
    updates: const ['প্রকল্প শুরু হয়েছে', '৫০% কাজ সম্পন্ন'],
    spendingReport: const [],
  );
});

final _mockCitizens = List.generate(8, (i) {
  final names = ['আব্দুর রহিম', 'মোঃ হাসান আলী', 'ফাতেমা খাতুন', 'করিম মিয়া', 'জয়নাল আবেদীন', 'নুরজাহান বেগম', 'সুমন আহমেদ', 'নাসরিন বেগম'];
  final professions = ['শিক্ষক', 'কৃষক', 'গৃহিণী', 'ব্যবসায়ী', 'অবসরপ্রাপ্ত', 'গৃহিণী', 'চাকরিজীবী', 'শিক্ষিকা'];
  return Citizen(
    id: 'c$i',
    name: names[i],
    profession: professions[i],
    phone: '+880171234567$i',
    photoUrl: '',
    village: 'উত্তর গ্রাম',
  );
});

final _mockNotifications = List.generate(8, (i) {
  final types = ['donation', 'project', 'problem', 'donation', 'project', 'problem', 'donation', 'system'];
  final titles = ['নতুন অনুদান', 'প্রকল্প আপডেট', 'সমস্যা রিপোর্ট', 'বড় অনুদান', 'প্রকল্প সম্পন্ন', 'সমস্যা সমাধান', 'অনুদান ফিরে দেখা', 'সিস্টেম আপডেট'];
  final bodies = [
    'রহিম ৳৫,০০০ অনুদান দিয়েছেন',
    'মসজিদ সংস্কার ৭০% সম্পন্ন',
    'রাস্তা মেরামতের অনুরোধ',
    'করিম সাহেব ৳৫০,০০০ দান করেছেন',
    'পুকুর খনন প্রকল্প সম্পন্ন',
    'ড্রেনেজ সমস্যা সমাধান করা হয়েছে',
    'গত মাসে সর্বমোট ৳২,৩০,০০০ সংগ্রহ',
    'নতুন সংস্করণ ২.০.০ প্রকাশিত',
  ];
  return AppNotification(
    id: 'n$i',
    type: types[i],
    title: titles[i],
    body: bodies[i],
    createdAt: DateTime.now().subtract(Duration(hours: i * 4)),
  );
});

final dashboardProvider = StreamProvider<VillageOverview>((ref) {
  return DataService.instance.villageOverview().startWith(_mockOverview);
});

final donationsProvider = StreamProvider<List<Donation>>((ref) {
  return DataService.instance.donations(limit: 100).startWith(_mockDonations);
});

final recentDonationsProvider = StreamProvider<List<Donation>>((ref) {
  return DataService.instance.donations(limit: 8).startWith(_mockDonations);
});

final problemsProvider = StreamProvider<List<ProblemReport>>((ref) {
  return DataService.instance.problems(limit: 100).startWith(_mockProblems);
});

final recentProblemsProvider = StreamProvider<List<ProblemReport>>((ref) {
  return DataService.instance.problems(limit: 8).startWith(_mockProblems);
});

final projectsProvider = StreamProvider<List<DevelopmentProject>>((ref) {
  return DataService.instance.projects(limit: 100).startWith(_mockProjects);
});

// Mock expense transactions shown while real data loads
final _mockExpenses = List.generate(5, (i) {
  final refs = [
    'মসজিদ সংস্কার প্রকল্প',
    'গ্রামের রাস্তা নির্মাণ',
    'কমিউনিটি সেন্টার',
    'নলকূপ স্থাপন',
    'পুকুর খনন ও সংস্কার',
  ];
  final amounts = [120000.0, 85000.0, 60000.0, 45000.0, 30000.0];
  return FundTransaction(
    id: 'ex$i',
    type: 'expense',
    amount: amounts[i],
    reference: refs[i],
    note: 'নির্মাণ সামগ্রী ও শ্রম খরচ',
    createdAt: DateTime.now().subtract(Duration(days: i * 7)),
  );
});

final fundTransactionsProvider =
    StreamProvider<List<FundTransaction>>((ref) {
  return DataService.instance
      .fundTransactions()
      .startWith(_mockExpenses);
});

// Mock donation accounts shown while real data loads from Firestore
final _mockDonationAccounts = <Map<String, String>>[
  {'id': 'bkash_1', 'type': 'bKash', 'number': '01XXXXXXXXX', 'name': 'গ্রাম উন্নয়ন তহবিল'},
  {'id': 'nagad_1', 'type': 'Nagad', 'number': '01XXXXXXXXX', 'name': 'গ্রাম উন্নয়ন তহবিল'},
];

final donationAccountsProvider =
    StreamProvider<List<Map<String, String>>>((ref) {
  return DataService.instance
      .donationAccounts()
      .startWith(_mockDonationAccounts);
});

final citizensProvider = StreamProvider<List<Citizen>>((ref) {
  return DataService.instance.citizens().startWith(_mockCitizens);
});

final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  return DataService.instance.notifications(limit: 100).startWith(_mockNotifications);
});

final unreadCountProvider = StreamProvider<int>((ref) {
  return DataService.instance.unreadNotificationCount().startWith(3);
});

final citizenCountProvider = StreamProvider<int>((ref) {
  return DataService.instance.citizenCount().startWith(1240);
});

final problemsCountProvider = StreamProvider<int>((ref) {
  return DataService.instance.pendingProblemsCount().startWith(15);
});

final projectsCountProvider = StreamProvider<int>((ref) {
  return DataService.instance.projectsCount().startWith(12);
});

final leadersProvider = Provider<List<Leader>>((ref) {
  return _mockLeaders;
});

final problemCommentsProvider = Provider.family<List<Comment>, String>((ref, problemId) {
  return _mockComments;
});

final isAuthenticatedProvider = StreamProvider<bool>((ref) {
  return DataService.instance.authState().map((user) => user != null);
});

/// The live Firebase [User] object — null when signed out.
final currentFirebaseUserProvider = StreamProvider<User?>((ref) {
  return DataService.instance.authState();
});

final currentUserProvider = Provider<UserProfile?>((ref) {
  return _mockUserProfile;
});

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.village,
    required this.profession,
    required this.totalDonations,
    required this.joinedProjects,
    required this.reportedProblems,
    required this.volunteerHours,
  });

  final String name;
  final String email;
  final String phone;
  final String photoUrl;
  final String village;
  final String profession;
  final int totalDonations;
  final int joinedProjects;
  final int reportedProblems;
  final int volunteerHours;
}

final _mockUserProfile = const UserProfile(
  name: 'রহিম সাহেব',
  email: 'rahim@example.com',
  phone: '+8801712345678',
  photoUrl: '',
  village: 'উত্তর গ্রাম',
  profession: 'শিক্ষক',
  totalDonations: 23500,
  joinedProjects: 12,
  reportedProblems: 8,
  volunteerHours: 147,
);

final _mockLeaders = [
  Leader(id: '1', name: 'আব্দুর রহিম', role: 'সভাপতি', experience: '১২+ বছর', photoUrl: '', isOnline: true, phone: '+8801711111111', email: 'rahim@example.com'),
  Leader(id: '2', name: 'মোঃ হাসান আলী', role: 'সহ-সভাপতি', experience: '১০+ বছর', photoUrl: '', isOnline: true, phone: '+8801711111112', email: 'hasan@example.com'),
  Leader(id: '3', name: 'ফাতেমা খাতুন', role: 'সাধারণ সম্পাদক', experience: '৮+ বছর', photoUrl: '', isOnline: false, phone: '+8801711111113', email: 'fatema@example.com'),
  Leader(id: '4', name: 'করিম মিয়া', role: 'যুগ্ম সম্পাদক', experience: '৬+ বছর', photoUrl: '', isOnline: true, phone: '+8801711111114', email: 'karim@example.com'),
  Leader(id: '5', name: 'জয়নাল আবেদীন', role: 'কোষাধ্যক্ষ', experience: '১৫+ বছর', photoUrl: '', isOnline: false, phone: '+8801711111115', email: 'joynal@example.com'),
  Leader(id: '6', name: 'নুরজাহান বেগম', role: 'সাংস্কৃতিক সম্পাদক', experience: '৫+ বছর', photoUrl: '', isOnline: true, phone: '+8801711111116', email: 'nurjahan@example.com'),
];

final _mockComments = [
  Comment(id: '1', authorName: 'আব্দুর রহিম', text: 'এটি একটি গুরুত্বপূর্ণ সমস্যা। দ্রুত সমাধান প্রয়োজন।', createdAt: DateTime.now().subtract(const Duration(hours: 2))),
  Comment(id: '2', authorName: 'মোঃ হাসান আলী', text: 'আমরা এই বিষয়ে কাজ শুরু করেছি। সবাইকে ধন্যবাদ।', createdAt: DateTime.now().subtract(const Duration(hours: 5))),
  Comment(id: '3', authorName: 'ফাতেমা খাতুন', text: 'স্থানীয় প্রশাসনের সাথে যোগাযোগ করা হয়েছে।', createdAt: DateTime.now().subtract(const Duration(days: 1))),
];
