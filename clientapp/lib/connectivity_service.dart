import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Global singleton providing real-time connectivity status.
class ConnectivityService extends ValueNotifier<bool> {
  ConnectivityService._() : super(true);

  static final ConnectivityService instance = ConnectivityService._();

  StreamSubscription<List<ConnectivityResult>>? _sub;

  /// Whether the device currently has an internet connection.
  bool get isOnline => value;

  /// Initialize the service. Call once at startup.
  Future<void> initialize() async {
    final results = await Connectivity().checkConnectivity();
    value = _hasConnection(results);

    _sub = Connectivity().onConnectivityChanged.listen((results) {
      final online = _hasConnection(results);
      if (value != online) {
        value = online;
        debugPrint('ConnectivityService: ${online ? "ONLINE" : "OFFLINE"}');
      }
    });
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _sub = null;
    super.dispose();
  }
}
