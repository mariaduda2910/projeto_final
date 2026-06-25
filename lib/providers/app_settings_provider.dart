import 'package:flutter/material.dart';

import '../services/storage_service.dart';

class AppSettingsProvider extends ChangeNotifier {
  static const String _defaultLocaleCode = 'pt';

  Locale _locale = const Locale(_defaultLocaleCode);

  Locale get locale => _locale;
  String get localeCode => _locale.languageCode;

  Future<void> loadPreferences() async {
    final code = StorageService().obterIdioma() ?? _defaultLocaleCode;
    _locale = _localeFromCode(code);
    notifyListeners();
  }

  Future<void> setLocale(String code) async {
    _locale = _localeFromCode(code);
    await StorageService().guardarIdioma(_locale.languageCode);
    notifyListeners();
  }

  Locale _localeFromCode(String code) {
    switch (code.toLowerCase()) {
      case 'en':
        return const Locale('en');
      case 'fr':
        return const Locale('fr');
      case 'es':
        return const Locale('es');
      default:
        return const Locale('pt');
    }
  }
}
