import 'package:flutter/material.dart';
import 'translations/vi.dart';
import 'translations/en.dart';

class AppLocalizations {
  final Locale locale;
  final Map<String, String> _translations;

  AppLocalizations(this.locale) 
      : _translations = locale.languageCode == 'vi' ? viTranslations : enTranslations;

  // Helper để lấy instance từ context
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Helper để check xem có hỗ trợ locale không
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('vi', 'VN'),
    Locale('en', 'US'),
  ];

  // Get translated string
  String translate(String key) {
    return _translations[key] ?? key;
  }

  // Shorthand
  String t(String key) => translate(key);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['vi', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

