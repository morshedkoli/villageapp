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

final topDonorsProvider = Provider<AsyncValue<List<MapEntry<String, double>>>>((ref) {
  return ref.watch(donationsProvider).whenData((donations) {
    final totals = <String, double>{};
    for (final d in donations) {
      if (d.donorName.isNotEmpty) {
        totals[d.donorName] = (totals[d.donorName] ?? 0) + d.amount;
      }
    }
    final sorted = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  });
});

class ExpenseSearchNotifier extends Notifier<String> {
  @override
  String build() => '';
  void setQuery(String query) => state = query;
}
final expenseSearchQueryProvider = NotifierProvider<ExpenseSearchNotifier, String>(ExpenseSearchNotifier.new);

class ExpenseSortNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void setSort(bool newestFirst) => state = newestFirst;
}
final expenseSortNewestFirstProvider = NotifierProvider<ExpenseSortNotifier, bool>(ExpenseSortNotifier.new);

final filteredExpensesProvider = Provider<AsyncValue<List<FundTransaction>>>((ref) {
  final txsAsync = ref.watch(fundTransactionsProvider);
  final search = ref.watch(expenseSearchQueryProvider);
  final newestFirst = ref.watch(expenseSortNewestFirstProvider);

  return txsAsync.whenData((allTx) {
    final expenses = allTx.where((t) => t.isExpense).toList();
    final query = search.trim().toLowerCase();
    
    final filtered = query.isEmpty
        ? expenses
        : expenses
            .where((t) =>
                t.reference.toLowerCase().contains(query) ||
                t.note.toLowerCase().contains(query) ||
                t.amount.toString().contains(query))
            .toList();

    if (newestFirst) {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    return filtered;
  });
});

class DonationSearchNotifier extends Notifier<String> {
  @override
  String build() => '';
  void setQuery(String query) => state = query;
}
final donationSearchQueryProvider = NotifierProvider<DonationSearchNotifier, String>(DonationSearchNotifier.new);

class DonationSortNotifier extends Notifier<String> {
  @override
  String build() => 'newest';
  void setSort(String sortType) => state = sortType;
}
final donationSortProvider = NotifierProvider<DonationSortNotifier, String>(DonationSortNotifier.new);

final filteredDonationsProvider = Provider<AsyncValue<List<Donation>>>((ref) {
  final donationsAsync = ref.watch(donationsProvider);
  final search = ref.watch(donationSearchQueryProvider);
  final sort = ref.watch(donationSortProvider);

  return donationsAsync.whenData((all) {
    var list = all.where((d) {
      if (search.isEmpty) return true;
      return d.donorName.toLowerCase().contains(search) ||
          d.amount.toString().contains(search) ||
          d.paymentMethod.toLowerCase().contains(search);
    }).toList();

    if (sort == 'newest') {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      list.sort((a, b) => b.amount.compareTo(a.amount));
    }
    return list;
  });
});

final totalExpensesProvider = Provider<AsyncValue<double>>((ref) {
  return ref.watch(fundTransactionsProvider).whenData((allTx) {
    return allTx.where((t) => t.isExpense).fold<double>(0.0, (sum, t) => sum + t.amount);
  });
});



