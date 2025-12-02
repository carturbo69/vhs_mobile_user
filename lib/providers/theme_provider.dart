import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/app_settings_dao.dart';

/// Provider để quản lý theme mode (light/dark)
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Load theme mode ngay khi build
    _loadThemeMode();
    return ThemeMode.light; // Default, sẽ được cập nhật sau khi load
  }

  /// Load theme mode từ database
  Future<void> _loadThemeMode() async {
    try {
      final settingsDao = ref.read(appSettingsDaoProvider);
      final savedThemeMode = await settingsDao.getThemeMode();
      
      ThemeMode loadedMode;
      switch (savedThemeMode) {
        case 'light':
          loadedMode = ThemeMode.light;
          break;
        case 'dark':
          loadedMode = ThemeMode.dark;
          break;
        case 'system':
          loadedMode = ThemeMode.system;
          break;
        default:
          loadedMode = ThemeMode.light;
      }
      // Chỉ update state nếu khác với giá trị hiện tại
      if (state != loadedMode) {
        state = loadedMode;
      }
    } catch (e) {
      // Nếu có lỗi, mặc định là light mode
      state = ThemeMode.light;
    }
  }

  /// Lưu theme mode vào database
  Future<void> _saveThemeMode(ThemeMode mode) async {
    try {
      final settingsDao = ref.read(appSettingsDaoProvider);
      String modeString;
      switch (mode) {
        case ThemeMode.light:
          modeString = 'light';
          break;
        case ThemeMode.dark:
          modeString = 'dark';
          break;
        case ThemeMode.system:
          modeString = 'system';
          break;
      }
      await settingsDao.setThemeMode(modeString);
    } catch (e) {
      // Bỏ qua lỗi khi lưu
    }
  }

  /// Toggle giữa light và dark mode
  void toggleTheme() {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newMode;
    _saveThemeMode(newMode);
  }

  /// Set theme mode cụ thể
  void setThemeMode(ThemeMode mode) {
    state = mode;
    _saveThemeMode(mode);
  }

  /// Kiểm tra xem đang ở dark mode không
  bool get isDarkMode => state == ThemeMode.dark;
}

