import 'package:flutter/material.dart';
import '../app_localizations.dart';

// Extension để dễ dàng sử dụng localization trong context
extension LocalizationExtension on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this);
  
  String tr(String key) => AppLocalizations.of(this).translate(key);
}

