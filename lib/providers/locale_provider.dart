import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider để quản lý ngôn ngữ
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(() {
  return LocaleNotifier();
});

class LocaleNotifier extends Notifier<Locale> {
  static const String _localeKey = 'app_locale';
  
  @override
  Locale build() {
    // Load locale từ SharedPreferences khi khởi tạo
    _loadLocale();
    return const Locale('vi', 'VN'); // Default locale
  }

  // Load ngôn ngữ đã lưu từ SharedPreferences
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey);
      
      if (localeCode != null) {
        if (localeCode == 'en') {
          state = const Locale('en', 'US');
        } else {
          state = const Locale('vi', 'VN');
        }
      }
    } catch (e) {
      print('⚠️ Error loading locale: $e');
    }
  }

  // Đổi ngôn ngữ
  Future<void> toggleLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (state.languageCode == 'vi') {
        state = const Locale('en', 'US');
        await prefs.setString(_localeKey, 'en');
      } else {
        state = const Locale('vi', 'VN');
        await prefs.setString(_localeKey, 'vi');
      }
      
      print('🌐 Locale changed to: ${state.languageCode}');
    } catch (e) {
      print('⚠️ Error toggling locale: $e');
    }
  }

  // Set ngôn ngữ cụ thể
  Future<void> setLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = locale;
      await prefs.setString(_localeKey, locale.languageCode);
      print('🌐 Locale set to: ${locale.languageCode}');
    } catch (e) {
      print('⚠️ Error setting locale: $e');
    }
  }
}

