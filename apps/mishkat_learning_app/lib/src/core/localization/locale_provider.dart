import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends Notifier<Locale> {
  static const _localeKey = 'app_locale';

  @override
  Locale build() {
    // We can't use async here directly, so we'll initialize with default
    // and let the loading happen in an initializer.
    // However, for simplicity in build(), we'll return a default
    // and provide a way to load it.
    return const Locale('en');
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey);
    if (languageCode != null) {
      state = Locale(languageCode);
    }
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
