import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

/// Keyed cache of hot, replaying Firestore streams.
///
/// Every service used to hand-roll this: a nullable `BehaviorSubject` field per
/// query, a `clearCache()` that closed each one, and a copy of the same
/// subscribe-and-forward block. Caching by key also replaces the
/// `if (limit <= 8) { ...second cache... }` special case, which silently
/// returned the 8-item stream for any limit under 8.
///
/// The first caller starts the underlying subscription; later callers with the
/// same key share it and immediately receive the latest value.
class StreamCache {
  StreamCache(this.label);

  /// Service name used in debug output.
  final String label;

  final Map<String, BehaviorSubject<Object?>> _subjects = {};
  final Map<String, StreamSubscription<Object?>> _subscriptions = {};

  /// Returns the cached stream for [key], subscribing to [create] on first use.
  ///
  /// [create] is only called when there is no live subscription for the key, so
  /// it is safe to build a Firestore query inside it.
  Stream<T> stream<T>(String key, Stream<T> Function() create) {
    final existing = _subjects[key];
    if (existing != null) return existing.stream.cast<T>();

    final subject = BehaviorSubject<Object?>();
    _subjects[key] = subject;
    _subscriptions[key] = create().listen(
      subject.add,
      onError: (Object error) {
        debugPrint('$label [$key]: cache error $error');
      },
    );

    return subject.stream.cast<T>();
  }

  /// Drops every cached stream. Called on sign-out so the next reader starts a
  /// fresh subscription under the new user's permissions.
  void clear() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    for (final subject in _subjects.values) {
      subject.close();
    }
    _subjects.clear();
  }
}
