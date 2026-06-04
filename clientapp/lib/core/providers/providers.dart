import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data_service.dart';
import '../../models.dart';

final dataServiceProvider = Provider<DataService>((ref) => DataService.instance);

final dashboardProvider = StreamProvider<VillageOverview>((ref) {
  return DataService.instance.villageOverview();
});

final donationsProvider = StreamProvider<List<Donation>>((ref) {
  return DataService.instance.donations(limit: 100);
});

final recentDonationsProvider = StreamProvider<List<Donation>>((ref) {
  return DataService.instance.donations(limit: 8);
});

final problemsProvider = StreamProvider<List<ProblemReport>>((ref) {
  return DataService.instance.problems(limit: 100);
});

final recentProblemsProvider = StreamProvider<List<ProblemReport>>((ref) {
  return DataService.instance.problems(limit: 8);
});

final projectsProvider = StreamProvider<List<DevelopmentProject>>((ref) {
  return DataService.instance.projects(limit: 100);
});

final fundTransactionsProvider = StreamProvider<List<FundTransaction>>((ref) {
  return DataService.instance.fundTransactions();
});

final donationAccountsProvider = StreamProvider<List<Map<String, String>>>((ref) {
  return DataService.instance.donationAccounts();
});

final citizensProvider = StreamProvider<List<Citizen>>((ref) {
  return DataService.instance.citizens();
});

final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  return DataService.instance.notifications(limit: 100);
});

final unreadCountProvider = StreamProvider<int>((ref) {
  return DataService.instance.unreadNotificationCount();
});

final notificationReadIdsProvider = StreamProvider<Set<String>>((ref) {
  return DataService.instance.myReadNotificationIds();
});

final citizenCountProvider = StreamProvider<int>((ref) {
  return DataService.instance.citizenCount();
});

final problemsCountProvider = StreamProvider<int>((ref) {
  return DataService.instance.pendingProblemsCount();
});

final projectsCountProvider = StreamProvider<int>((ref) {
  return DataService.instance.projectsCount();
});

final isAuthenticatedProvider = StreamProvider<bool>((ref) {
  return DataService.instance.authState().map((user) => user != null);
});

final currentFirebaseUserProvider = StreamProvider<User?>((ref) {
  return DataService.instance.authState();
});

final myDonationsProvider = StreamProvider<List<Donation>>((ref) {
  ref.watch(currentFirebaseUserProvider);
  return DataService.instance.myDonations();
});

final myProblemsProvider = StreamProvider<List<ProblemReport>>((ref) {
  ref.watch(currentFirebaseUserProvider);
  return DataService.instance.myProblems();
});

final currentUserProfileProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  ref.watch(currentFirebaseUserProvider);
  return DataService.instance.getUserProfile();
});
