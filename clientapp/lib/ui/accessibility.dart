import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class AccessibilitySettings {
  const AccessibilitySettings({
    this.largeText = false,
    this.highContrast = false,
    this.languageCode = 'bn',
  });

  final bool largeText;
  final bool highContrast;
  final String languageCode;

  AccessibilitySettings copyWith({
    bool? largeText,
    bool? highContrast,
    String? languageCode,
  }) {
    return AccessibilitySettings(
      largeText: largeText ?? this.largeText,
      highContrast: highContrast ?? this.highContrast,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

class AccessibilityController extends ValueNotifier<AccessibilitySettings> {
  AccessibilityController() : super(const AccessibilitySettings());

  static const _keyLang = 'pref_language';
  static const _keyLargeText = 'pref_large_text';
  static const _keyHighContrast = 'pref_high_contrast';

  /// Load saved preferences from disk. Call once at startup.
  Future<void> loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(_keyLang) ?? 'bn';
    final large = prefs.getBool(_keyLargeText) ?? false;
    final contrast = prefs.getBool(_keyHighContrast) ?? false;
    value = AccessibilitySettings(
      languageCode: lang,
      largeText: large,
      highContrast: contrast,
    );
  }

  void setLargeText(bool v) {
    value = value.copyWith(largeText: v);
    SharedPreferences.getInstance().then((p) => p.setBool(_keyLargeText, v));
  }

  void setHighContrast(bool v) {
    value = value.copyWith(highContrast: v);
    SharedPreferences.getInstance().then((p) => p.setBool(_keyHighContrast, v));
  }

  void setLanguageCode(String v) {
    final code = v == 'bn' ? 'bn' : 'en';
    value = value.copyWith(languageCode: code);
    SharedPreferences.getInstance().then((p) => p.setString(_keyLang, code));
  }
}

String tr(String en, String bn) {
  return accessibilityController.value.languageCode == 'bn' ? bn : en;
}

final AccessibilityController accessibilityController =
    AccessibilityController();
