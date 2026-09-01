import 'package:doulatpara/core/providers/providers.dart';
import 'package:doulatpara/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Donation donation({
  required String id,
  required String donorName,
  required double amount,
  required DateTime createdAt,
  String paymentMethod = 'bKash',
}) {
  return Donation(
    id: id,
    donorName: donorName,
    amount: amount,
    paymentMethod: paymentMethod,
    createdAt: createdAt,
    userId: 'u1',
    status: 'Approved',
    transactionId: '',
    senderNumber: '',
  );
}

FundTransaction expense({
  required String id,
  required String reference,
  required double amount,
  required DateTime createdAt,
  String note = '',
  String category = '',
}) {
  return FundTransaction(
    id: id,
    type: 'expense',
    amount: amount,
    reference: reference,
    note: note,
    createdAt: createdAt,
    category: category,
  );
}

/// Builds a container where [donationsProvider] resolves to [donations].
ProviderContainer donationContainer(List<Donation> donations) {
  return ProviderContainer(
    overrides: [
      donationsProvider.overrideWith((_) => Stream.value(donations)),
    ],
  );
}

ProviderContainer expenseContainer(List<FundTransaction> transactions) {
  return ProviderContainer(
    overrides: [
      fundTransactionsProvider.overrideWith((_) => Stream.value(transactions)),
    ],
  );
}

Future<void> settle(ProviderContainer container, ProviderListenable<Object?> p) async {
  container.listen(p, (_, __) {});
  await Future<void>.delayed(Duration.zero);
}

void main() {
  final day1 = DateTime.utc(2026, 1, 1);
  final day2 = DateTime.utc(2026, 1, 2);
  final day3 = DateTime.utc(2026, 1, 3);

  group('filteredDonationsProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = donationContainer([
        donation(id: 'a', donorName: 'Rahim', amount: 100, createdAt: day1),
        donation(id: 'b', donorName: 'Karim', amount: 900, createdAt: day2),
        donation(
          id: 'c',
          donorName: 'Ayesha',
          amount: 500,
          createdAt: day3,
          paymentMethod: 'Nagad',
        ),
      ]);
      addTearDown(container.dispose);
    });

    Future<List<Donation>> read() async {
      await settle(container, filteredDonationsProvider);
      return container.read(filteredDonationsProvider).value ?? const [];
    }

    test('sorts newest first by default', () async {
      expect((await read()).map((d) => d.id), ['c', 'b', 'a']);
    });

    test('sorts by amount when asked', () async {
      container.read(donationSortProvider.notifier).setSort(DonationSort.largest);
      expect((await read()).map((d) => d.id), ['b', 'c', 'a']);
    });

    test('matches a donor name regardless of the case typed', () async {
      // The query used to be compared raw against lower-cased fields, so a
      // capitalised search matched nothing.
      container.read(donationSearchQueryProvider.notifier).setQuery('RAHIM');
      expect((await read()).map((d) => d.id), ['a']);
    });

    test('matches on payment method and amount', () async {
      container.read(donationSearchQueryProvider.notifier).setQuery('nagad');
      expect((await read()).map((d) => d.id), ['c']);

      container.read(donationSearchQueryProvider.notifier).setQuery('900');
      expect((await read()).map((d) => d.id), ['b']);
    });

    test('ignores surrounding whitespace in the query', () async {
      container.read(donationSearchQueryProvider.notifier).setQuery('  karim  ');
      expect((await read()).map((d) => d.id), ['b']);
    });

    test('returns everything for an empty query', () async {
      container.read(donationSearchQueryProvider.notifier).setQuery('');
      expect(await read(), hasLength(3));
    });
  });

  group('topDonorsProvider', () {
    test('sums per donor and returns the top five', () async {
      final container = donationContainer([
        donation(id: 'a', donorName: 'Rahim', amount: 100, createdAt: day1),
        donation(id: 'b', donorName: 'Rahim', amount: 250, createdAt: day2),
        donation(id: 'c', donorName: 'Karim', amount: 300, createdAt: day3),
      ]);
      addTearDown(container.dispose);

      await settle(container, topDonorsProvider);
      final top = container.read(topDonorsProvider).value ?? const [];

      expect(top.first.key, 'Rahim');
      expect(top.first.value, 350);
      expect(top.last.key, 'Karim');
    });
  });

  group('filteredExpensesProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = expenseContainer([
        expense(id: 'e1', reference: 'Road repair', amount: 100, createdAt: day1),
        expense(
          id: 'e2',
          reference: 'School',
          amount: 200,
          createdAt: day2,
          note: 'cement',
          category: 'Civil',
        ),
        FundTransaction(
          id: 'd1',
          type: 'donation',
          amount: 999,
          reference: 'Rahim',
          note: '',
          createdAt: day3,
        ),
      ]);
      addTearDown(container.dispose);
    });

    Future<List<FundTransaction>> read() async {
      await settle(container, filteredExpensesProvider);
      return container.read(filteredExpensesProvider).value ?? const [];
    }

    test('excludes donation ledger rows', () async {
      expect((await read()).map((t) => t.id), ['e2', 'e1']);
    });

    test('sorts oldest first when asked', () async {
      container.read(expenseSortNewestFirstProvider.notifier).setSort(false);
      expect((await read()).map((t) => t.id), ['e1', 'e2']);
    });

    test('searches reference, note and category', () async {
      container.read(expenseSearchQueryProvider.notifier).setQuery('road');
      expect((await read()).map((t) => t.id), ['e1']);

      container.read(expenseSearchQueryProvider.notifier).setQuery('cement');
      expect((await read()).map((t) => t.id), ['e2']);

      container.read(expenseSearchQueryProvider.notifier).setQuery('civil');
      expect((await read()).map((t) => t.id), ['e2']);
    });
  });

  group('totalExpensesProvider', () {
    test('sums expenses and ignores donations', () async {
      final container = expenseContainer([
        expense(id: 'e1', reference: 'a', amount: 100, createdAt: day1),
        expense(id: 'e2', reference: 'b', amount: 250, createdAt: day2),
        FundTransaction(
          id: 'd1',
          type: 'donation',
          amount: 999,
          reference: 'Rahim',
          note: '',
          createdAt: day3,
        ),
      ]);
      addTearDown(container.dispose);

      await settle(container, totalExpensesProvider);
      expect(container.read(totalExpensesProvider).value, 350);
    });
  });
}
