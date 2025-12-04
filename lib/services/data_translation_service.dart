import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/providers/locale_provider.dart';
import 'package:vhs_mobile_user/services/translation_cache_provider.dart';

/// Service để translate data từ server sử dụng Google Translate API
class DataTranslationService {
  final WidgetRef ref;
  
  DataTranslationService(this.ref);
  
  /// Lấy locale hiện tại
  bool get isVietnamese {
    try {
      final locale = ref.read(localeProvider);
      return locale.languageCode == 'vi';
    } catch (e) {
      return true; // Default Vietnamese
    }
  }
  
  /// Translate category name sử dụng Google Translate với cache
  String translateCategoryName(String categoryName) {
    if (isVietnamese) {
      return categoryName;
    }
    
    // Sử dụng translation cache
    final cache = ref.read(translationCacheProvider.notifier);
    return cache.getTranslationSync(categoryName);
  }
  
  /// Async version
  Future<String> translateCategoryNameAsync(String categoryName) async {
    if (isVietnamese) {
      return categoryName;
    }
    
    final cache = ref.read(translationCacheProvider.notifier);
    return await cache.getTranslation(categoryName);
  }
  
  /// Translate service term sử dụng Google Translate với cache
  String translateServiceTerm(String term) {
    if (isVietnamese) {
      return term;
    }
    
    final cache = ref.read(translationCacheProvider.notifier);
    return cache.getTranslationSync(term);
  }
  
  /// Translate service title sử dụng Google Translate với cache
  String translateServiceTitle(String title) {
    if (isVietnamese) {
      return title;
    }
    
    final cache = ref.read(translationCacheProvider.notifier);
    return cache.getTranslationSync(title);
  }
  
  /// Async version
  Future<String> translateServiceTitleAsync(String title) async {
    if (isVietnamese) {
      return title;
    }
    
    final cache = ref.read(translationCacheProvider.notifier);
    return await cache.getTranslation(title);
  }
  
  /// Translate service option name sử dụng Google Translate với cache
  String translateOptionName(String optionName) {
    if (isVietnamese) {
      return optionName;
    }
    
    final cache = ref.read(translationCacheProvider.notifier);
    return cache.getTranslationSync(optionName);
  }
  
  /// Translate unit type sử dụng Google Translate với cache
  String translateUnitType(String unitType) {
    if (isVietnamese) {
      return unitType;
    }
    
    // Common units không cần translate (giữ nguyên)
    final commonUnits = ['M²', 'Kg', 'm²', 'kg', 'm', 'cm', 'km'];
    if (commonUnits.contains(unitType)) {
      return unitType;
    }
    
    final cache = ref.read(translationCacheProvider.notifier);
    return cache.getTranslationSync(unitType);
  }
  
  /// Smart translate - tự động translate bất kỳ text nào với cache
  String smartTranslate(String text) {
    if (isVietnamese) {
      return text;
    }
    
    final cache = ref.read(translationCacheProvider.notifier);
    return cache.getTranslationSync(text);
  }
  
  /// Async version
  Future<String> smartTranslateAsync(String text) async {
    if (isVietnamese) {
      return text;
    }
    
    final cache = ref.read(translationCacheProvider.notifier);
    return await cache.getTranslation(text);
  }
}

/// Provider để tạo DataTranslationService
final dataTranslationServiceProvider = Provider.family<DataTranslationService, WidgetRef>(
  (ref, widgetRef) => DataTranslationService(widgetRef),
);

