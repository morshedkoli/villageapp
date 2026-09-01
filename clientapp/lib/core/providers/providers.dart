import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models.dart';
import '../../services/auth_service.dart';
import '../../services/citizen_service.dart';
import '../../services/donation_service.dart';
import '../../services/fund_service.dart';
import '../../services/notification_service.dart';
import '../../services/problem_service.dart';
import '../../services/project_service.dart';
import '../../services/village_service.dart';

/// Number of items the home screen previews for each section.
const int kHomePreviewLimit = 8;

// ─── Services ───────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((_) => AuthService.instance);
final donationServiceProvider =
    Provider<DonationService>((_) => DonationService.instance);
final problemServiceProvider =
    Provider<ProblemService>((_) => ProblemService.instance);
final notificationServiceProvider =
    Provider<NotificationService>((_) => NotificationService.instance);

// ─── Auth ───────────────────────────────────────────────────────────

final currentFirebaseUserProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authState();
});

final isAuthenticatedProvider = Provider<AsyncValue<bool>>((ref) {
  return ref.watch(currentFirebaseUserProvider).whenData((user) => user != null);
});

/// `true` while an admin has blocked the signed-in account.
final isBlockedProvider = StreamProvider<bool>((ref) {
  return ref.watch(authServiceProvider).blockedState();
});

final currentUserProfileProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  ref.watch(currentFirebaseUserProvider);
  return ref.watch(authServiceProvider).getUserProfile();
});

// ─── Village, donations, problems, projects ─────────────────────────

final dashboardProvider = StreamProvider<VillageOverview>((ref) {
  return VillageService.instance.villageOverview();
});

final donationsProvider = StreamProvider<List<Donation>>((ref) {
  return ref.watch(donationServiceProvider).donations();
});

final recentDonationsProvider = StreamProvider<List<Donation>>((ref) {
  return ref.watch(donationServiceProvider).donations(limit: kHomePreviewLimit);
});

final donationAccountsProvider =
    StreamProvider<List<Map<String, String>>>((ref) {
  return ref.watch(donationServiceProvider).donationAccounts();
});

final myDonationsProvider = StreamProvider<List<Donation>>((ref) {
  ref.watch(currentFirebaseUserProvider);
  return ref.watch(donationServiceProvider).myDonations();
});

final problemsProvider = StreamProvider<List<ProblemReport>>((ref) {
  return ref.watch(problemServiceProvider).problems();
});

final recentProblemsProvider = StreamProvider<List<ProblemReport>>((ref) {
  return ref.watch(problemServiceProvider).problems(limit: kHomePreviewLimit);
});

final myProblemsProvider = StreamProvider<List<ProblemReport>>((ref) {
  ref.watch(currentFirebaseUserProvider);
  return ref.watch(problemServiceProvider).myProblems();
});

/// The signed-in citizen's vote on one problem: `1`, `-1`, or `null`.
final myVoteOnProblemProvider =
    StreamProvider.family<int?, String>((ref, problemId) {
  ref.watch(currentFirebaseUserProvider);
  return ref.watch(problemServiceProvider).myVoteOnProblem(problemId);
});

final projectsProvider = StreamProvider<List<DevelopmentProject>>((ref) {
  return ProjectService.instance.projects();
});

/// A single project by id, sourced from the already-cached projects stream.
final projectByIdProvider =
    Provider.family<AsyncValue<DevelopmentProject?>, String>((ref, id) {
  return ref.watch(projectsProvider).whenData((projects) {
    for (final project in projects) {
      if (project.id == id) return project;
    }
    return null;
  });
});

final citizensProvider = StreamProvider<List<Citizen>>((ref) {
  return CitizenService.instance.citizens();
});

// ─── Notifications ──────────────────────────────────────────────────

final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  return ref.watch(notificationServiceProvider).notifications();
});

final unreadCountProvider = StreamProvider<int>((ref) {
  return ref.watch(notificationServiceProvider).unreadNotificationCount();
});

final notificationReadIdsProvider = StreamProvider<Set<String>>((ref) {
  return ref.watch(notificationServiceProvider).myReadNotificationIds();
});

// ─── Fund ledger ────────────────────────────────────────────────────

final fundTransactionsProvider = StreamProvider<List<FundTransaction>>((ref) {
  return FundService.instance.fundTransactions();
});

final totalExpensesProvider = Provider<AsyncValue<double>>((ref) {
  return ref.watch(fundTransactionsProvider).whenData(
        (all) => all
            .where((t) => t.isExpense)
            .fold<double>(0, (sum, t) => sum + t.amount),
      );
});

// ─── Derived views ──────────────────────────────────────────────────

/// Top five donors by total approved amount.
final topDonorsProvider =
    Provider<AsyncValue<List<MapEntry<String, double>>>>((ref) {
  return ref.watch(donationsProvider).whenData((donations) {
    final totals = <String, double>{};
    for (final donation in donations) {
      if (donation.donorName.isEmpty) continue;
      totals[donation.donorName] =
          (totals[donation.donorName] ?? 0) + donation.amount;
    }
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  });
});

/// A plain text query, shared by the list search fields.
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

final expenseSearchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

final donationSearchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class ExpenseSortNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void setSort(bool newestFirst) => state = newestFirst;
}

final expenseSortNewestFirstProvider =
    NotifierProvider<ExpenseSortNotifier, bool>(ExpenseSortNotifier.new);

/// How the donation list is ordered.
enum DonationSort { newest, largest }

class DonationSortNotifier extends Notifier<DonationSort> {
  @override
  DonationSort build() => DonationSort.newest;

  void setSort(DonationSort sort) => state = sort;
}

final donationSortProvider =
    NotifierProvider<DonationSortNotifier, DonationSort>(
  DonationSortNotifier.new,
);

final filteredExpensesProvider =
    Provider<AsyncValue<List<FundTransaction>>>((ref) {
  final query = ref.watch(expenseSearchQueryProvider).trim().toLowerCase();
  final newestFirst = ref.watch(expenseSortNewestFirstProvider);

  return ref.watch(fundTransactionsProvider).whenData((all) {
    final expenses = all.where((t) => t.isExpense).where((t) {
      if (query.isEmpty) return true;
      return t.reference.toLowerCase().contains(query) ||
          t.note.toLowerCase().contains(query) ||
          t.category.toLowerCase().contains(query) ||
          t.amount.toString().contains(query);
    }).toList();

    expenses.sort(
      (a, b) => newestFirst
          ? b.createdAt.compareTo(a.createdAt)
          : a.createdAt.compareTo(b.createdAt),
    );
    return expenses;
  });
});

final filteredDonationsProvider = Provider<AsyncValue<List<Donation>>>((ref) {
  // Lower-cased here: the raw query used to be compared against lower-cased
  // fields, so any capital letter the user typed matched nothing.
  final query = ref.watch(donationSearchQueryProvider).trim().toLowerCase();
  final sort = ref.watch(donationSortProvider);

  return ref.watch(donationsProvider).whenData((all) {
    final donations = all.where((d) {
      if (query.isEmpty) return true;
      return d.donorName.toLowerCase().contains(query) ||
          d.paymentMethod.toLowerCase().contains(query) ||
          d.amount.toString().contains(query);
    }).toList();

    donations.sort(
      (a, b) => switch (sort) {
        DonationSort.newest => b.createdAt.compareTo(a.createdAt),
        DonationSort.largest => b.amount.compareTo(a.amount),
      },
    );
    return donations;
  });
});
