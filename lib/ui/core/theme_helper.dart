import 'package:flutter/material.dart';

/// Helper class để lấy màu sắc phù hợp với theme (light/dark)
class ThemeHelper {
  // Màu xanh theo web - Sky blue palette
  static const Color primaryBlue = Color(0xFF0284C7); // Sky-600
  static const Color darkBlue = Color(0xFF0369A1); // Sky-700
  static const Color lightBlue = Color(0xFFE0F2FE); // Sky-100
  static const Color accentBlue = Color(0xFFBAE6FD); // Sky-200

  /// Lấy màu nền scaffold phù hợp với theme
  static Color getScaffoldBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF121212) : Colors.white;
  }

  /// Lấy màu nền card phù hợp với theme
  static Color getCardBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1E1E1E) : Colors.white;
  }

  /// Lấy màu text chính phù hợp với theme
  static Color getTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white : Colors.black87;
  }

  /// Lấy màu text phụ phù hợp với theme
  static Color getSecondaryTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey.shade400 : Colors.grey.shade700;
  }

  /// Lấy màu text mờ phù hợp với theme
  static Color getTertiaryTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey.shade500 : Colors.grey.shade600;
  }

  /// Lấy màu border phù hợp với theme
  static Color getBorderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey.shade800 : Colors.grey.shade200;
  }

  /// Lấy màu nền input field phù hợp với theme
  static Color getInputBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF2D2D2D) : Colors.grey.shade50;
  }

  /// Lấy màu nền container nhẹ phù hợp với theme
  static Color getLightBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF2D2D2D) : Colors.grey.shade50;
  }

  /// Lấy màu nền container xanh nhẹ phù hợp với theme
  static Color getLightBlueBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.blue.shade900.withOpacity(0.3) : lightBlue;
  }

  /// Lấy màu primary phù hợp với theme
  static Color getPrimaryColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.blue.shade300 : primaryBlue;
  }

  /// Lấy màu primary dark phù hợp với theme
  static Color getPrimaryDarkColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.blue.shade400 : darkBlue;
  }

  /// Lấy màu divider phù hợp với theme
  static Color getDividerColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey.shade800 : Colors.grey.shade300;
  }

  /// Lấy màu shadow phù hợp với theme
  static Color getShadowColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.1);
  }

  /// Lấy màu icon phù hợp với theme
  static Color getIconColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white : Colors.black87;
  }

  /// Lấy màu icon phụ phù hợp với theme
  static Color getSecondaryIconColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey.shade400 : Colors.grey.shade600;
  }

  /// Lấy màu nền dialog phù hợp với theme
  static Color getDialogBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1E1E1E) : Colors.white;
  }

  /// Lấy màu nền bottom sheet phù hợp với theme
  static Color getBottomSheetBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1E1E1E) : Colors.white;
  }

  /// Lấy màu nền popup menu phù hợp với theme
  static Color getPopupMenuBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1E1E1E) : Colors.white;
  }

  /// Kiểm tra xem đang ở dark mode không
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}

