import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doulatpara/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VillageOverview.fromMap', () {
    test('reads the counters the admin panel maintains', () {
      final overview = VillageOverview.fromMap({
        'name': 'Doulatpara',
        'totalCitizens': 42,
        'totalFundCollected': 15000,
        'totalSpent': 5000,
      });

      expect(overview.name, 'Doulatpara');
      expect(overview.totalCitizens, 42);
      expect(overview.availableBalance, 10000);
    });

    test('reads a counter stored as a double', () {
      // FieldValue.increment can leave the counter as a double, which the
      // previous `as int?` cast silently turned into 0.
      final overview = VillageOverview.fromMap({'totalCitizens': 42.0});
      expect(overview.totalCitizens, 42);
    });

    test('falls back when the document is empty', () {
      final overview = VillageOverview.fromMap(const {});
      expect(overview.name, 'Our Village');
      expect(overview.totalCitizens, 0);
      expect(overview.availableBalance, 0);
    });
  });

  group('Donation.fromMap', () {
    test('keeps the receiving account the admin panel records', () {
      final donation = Donation.fromMap('d1', {
        'donorName': 'Rahim',
        'amount': 500,
        'paymentMethod': 'bkash',
        'status': 'Approved',
        'receivedAccountId': 'acct-1',
        'receivedAccountLabel': 'bkash • 0170 • Fund',
        'createdAt': Timestamp.fromDate(DateTime.utc(2026, 1, 2)),
      });

      expect(donation.id, 'd1');
      expect(donation.receivedAccountId, 'acct-1');
      expect(donation.receivedAccountLabel, 'bkash • 0170 • Fund');
      expect(donation.createdAt.toUtc(), DateTime.utc(2026, 1, 2));
      expect(donation.isApproved, isTrue);
    });

    test('defaults an unnamed donor and a missing account', () {
      final donation = Donation.fromMap('d2', const {'amount': 100});

      expect(donation.donorName, 'Anonymous');
      expect(donation.receivedAccountId, isEmpty);
      expect(donation.receivedAccountLabel, isEmpty);
    });

    test('exposes the status as booleans', () {
      expect(Donation.fromMap('d', const {'status': 'Pending'}).isPending, isTrue);
      expect(
        Donation.fromMap('d', const {'status': 'Rejected'}).isRejected,
        isTrue,
      );
    });
  });

  group('ProblemReport.fromMap', () {
    test('shows the reporter display name, not the account id', () {
      final problem = ProblemReport.fromMap('p1', const {
        'title': 'Road damage',
        'reportedBy': 'uid-123',
        'reportedByName': 'Karim',
        'upvotes': 5,
        'downvotes': 2,
      });

      expect(problem.reportedBy, 'Karim');
      expect(problem.voteScore, 3);
    });

    test('falls back to Citizen when no name was stored', () {
      final problem = ProblemReport.fromMap('p2', const {'title': 'x'});
      expect(problem.reportedBy, 'Citizen');
      expect(problem.isPending, isTrue);
    });
  });

  group('DevelopmentProject.fromMap', () {
    test('reads createdAt written by the admin panel', () {
      final project = DevelopmentProject.fromMap('pr1', {
        'title': 'Bridge',
        'estimatedCost': 1000,
        'allocatedFunds': 250,
        'createdAt': Timestamp.fromDate(DateTime.utc(2026, 3, 4)),
      });

      expect(project.createdAt?.toUtc(), DateTime.utc(2026, 3, 4));
      expect(project.fundingProgress, 0.25);
      expect(project.remainingCost, 750);
    });

    test('leaves createdAt null on older documents', () {
      expect(DevelopmentProject.fromMap('pr2', const {}).createdAt, isNull);
    });

    test('clamps funding progress and remaining cost when over-funded', () {
      final project = DevelopmentProject.fromMap('pr3', const {
        'estimatedCost': 100,
        'allocatedFunds': 250,
      });

      expect(project.fundingProgress, 1.0);
      expect(project.remainingCost, 0);
    });

    test('skips non-string entries in list fields', () {
      // `cast<String>()` used to throw during the widget build instead.
      final project = DevelopmentProject.fromMap('pr4', const {
        'photos': ['a.jpg', 7, null, 'b.jpg'],
      });

      expect(project.photos, ['a.jpg', 'b.jpg']);
    });

    test('tolerates a list field stored as something else entirely', () {
      final project = DevelopmentProject.fromMap('pr5', const {'photos': 'a.jpg'});
      expect(project.photos, isEmpty);
    });
  });

  group('FundTransaction.fromMap', () {
    test('reads an expense written by the admin panel', () {
      final tx = FundTransaction.fromMap('t1', const {
        'type': 'expense',
        'amount': 750,
        'reference': 'Road repair',
        'project': 'Road repair',
        'category': 'Civil',
        'notes': 'Bought cement',
      });

      expect(tx.isExpense, isTrue);
      expect(tx.reference, 'Road repair');
      expect(tx.category, 'Civil');
      expect(tx.note, 'Bought cement');
    });

    test('falls back to `project` when no reference was written', () {
      final tx = FundTransaction.fromMap('t2', const {'project': 'School'});
      expect(tx.reference, 'School');
    });

    test('still reads the older `note` spelling', () {
      final tx = FundTransaction.fromMap('t3', const {'note': 'legacy'});
      expect(tx.note, 'legacy');
    });

    test('keeps the donation link used to reverse a ledger row', () {
      final tx = FundTransaction.fromMap('t4', const {
        'type': 'donation',
        'donationId': 'd9',
      });

      expect(tx.isExpense, isFalse);
      expect(tx.donationId, 'd9');
    });
  });

  group('AppNotification', () {
    test('joins title and body for display', () {
      final n = AppNotification.fromMap('n1', const {
        'title': 'নতুন অনুদান',
        'body': 'Rahim donated',
      });
      expect(n.message, 'নতুন অনুদান\nRahim donated');
    });

    test('uses whichever half exists', () {
      expect(
        AppNotification.fromMap('n2', const {'title': 'only title'}).message,
        'only title',
      );
      expect(
        AppNotification.fromMap('n3', const {'body': 'only body'}).message,
        'only body',
      );
    });

    test('falls back when the document carries neither', () {
      expect(
        AppNotification.fromMap('n4', const {}).message,
        'Village update available',
      );
    });
  });
}
