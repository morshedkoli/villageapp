import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

/// Lightweight key-value JSON cache backed by Hive.
///
/// Usage:
/// ```dart
/// // Write
/// await HiveCacheService.put('donations', 'list', jsonEncode(data));
///
/// // Read
/// final raw = HiveCacheService.get('donations', 'list');
/// if (raw != null) final list = jsonDecode(raw);
/// ```
abstract final class HiveCacheService {
  static const _keyValue = 'v';

  /// Store [value] (JSON string) under [boxName] + [key].
  static Future<void> put(String boxName, String key, String value) async {
    if (!Hive.isBoxOpen(boxName)) return;
    final box = Hive.box<String>(boxName);
    await box.put(key, value);
  }

  /// Retrieve the cached JSON string, or null if absent/stale.
  static String? get(String boxName, String key) {
    if (!Hive.isBoxOpen(boxName)) return null;
    return Hive.box<String>(boxName).get(key);
  }

  /// Delete a specific cached entry.
  static Future<void> delete(String boxName, String key) async {
    if (!Hive.isBoxOpen(boxName)) return;
    await Hive.box<String>(boxName).delete(key);
  }

  /// Clear all cached entries in a box.
  static Future<void> clearBox(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) return;
    await Hive.box<String>(boxName).clear();
  }

  // ── Convenience helpers for the village-overview singleton ─────────────

  static const _overviewBox = 'village_overview';
  static const _overviewKey = 'overview';

  static Future<void> saveOverview(Map<String, dynamic> map) =>
      put(_overviewBox, _overviewKey, jsonEncode(map));

  static Map<String, dynamic>? loadOverview() {
    final raw = get(_overviewBox, _overviewKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  // ── List helpers ────────────────────────────────────────────────────────

  static Future<void> saveList(String boxName, List<Map<String, dynamic>> items) =>
      put(boxName, _keyValue, jsonEncode(items));

  static List<Map<String, dynamic>>? loadList(String boxName) {
    final raw = get(boxName, _keyValue);
    if (raw == null) return null;
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }
}
