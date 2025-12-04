import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/providers/locale_provider.dart';
import 'package:vhs_mobile_user/services/data_translation_service.dart';
import 'package:vhs_mobile_user/services/translation_cache_provider.dart';
import 'service_model.dart';
import 'service_detail.dart';

/// Extension để tự động translate data từ server (khi backend chưa hỗ trợ đa ngôn ngữ)
extension ServiceLocalizationExtension on ServiceModel {
  /// Lấy title theo locale hiện tại
  /// Sử dụng DataTranslationService để translate nếu backend chưa hỗ trợ
  String getLocalizedTitle(WidgetRef ref) {
    final locale = ref.read(localeProvider);
    final isVietnamese = locale.languageCode == 'vi';
    
    // Nếu đang dùng tiếng Việt, trả về nguyên bản
    if (isVietnamese) {
      return title;
    }
    
    // Watch translation cache để rebuild khi có translation mới
    ref.watch(translationCacheProvider);
    
    // Sử dụng Google Translate API
    final translationService = DataTranslationService(ref);
    return translationService.translateServiceTitle(title);
  }
  
  /// Lấy description theo locale hiện tại
  String? getLocalizedDescription(WidgetRef ref) {
    final locale = ref.read(localeProvider);
    final isVietnamese = locale.languageCode == 'vi';
    
    if (isVietnamese || description == null) {
      return description;
    }
    
    // Watch translation cache
    ref.watch(translationCacheProvider);
    
    // Sử dụng Google Translate API
    final translationService = DataTranslationService(ref);
    return translationService.smartTranslate(description!);
  }
  
  /// Lấy categoryName theo locale hiện tại
  String getLocalizedCategoryName(WidgetRef ref) {
    final locale = ref.read(localeProvider);
    final isVietnamese = locale.languageCode == 'vi';
    
    if (isVietnamese) {
      return categoryName;
    }
    
    // Watch translation cache
    ref.watch(translationCacheProvider);
    
    // Sử dụng Google Translate API
    final translationService = DataTranslationService(ref);
    return translationService.translateCategoryName(categoryName);
  }
  
  /// Lấy providerName theo locale hiện tại
  /// Provider name thường không cần dịch
  String? getLocalizedProviderName(WidgetRef ref) {
    return providerName;
  }
  
  /// Lấy unitType theo locale hiện tại
  /// Backend trả về tiếng Anh, nếu app ở tiếng Việt thì dịch sang tiếng Việt
  /// Nếu app ở tiếng Anh thì giữ nguyên tiếng Anh
  String getLocalizedUnitType(WidgetRef ref) {
    // Watch locale để rebuild khi đổi ngôn ngữ
    final locale = ref.watch(localeProvider);
    final isVietnamese = locale.languageCode == 'vi';
    
    // Watch translation cache
    ref.watch(translationCacheProvider);
    
    // Sử dụng Google Translate API
    final translationService = DataTranslationService(ref);
    return translationService.translateUnitType(unitType);
  }
}

/// Extension cho ServiceDetail
extension ServiceDetailLocalizationExtension on ServiceDetail {
  /// Lấy title theo locale hiện tại
  String getLocalizedTitle(WidgetRef ref) {
    final locale = ref.read(localeProvider);
    final isVietnamese = locale.languageCode == 'vi';
    
    if (isVietnamese) {
      return title;
    }
    
    // Watch translation cache
    ref.watch(translationCacheProvider);
    
    final translationService = DataTranslationService(ref);
    return translationService.translateServiceTitle(title);
  }
  
  /// Lấy description theo locale hiện tại
  String? getLocalizedDescription(WidgetRef ref) {
    final locale = ref.read(localeProvider);
    final isVietnamese = locale.languageCode == 'vi';
    
    if (isVietnamese || description == null) {
      return description;
    }
    
    // Watch translation cache
    ref.watch(translationCacheProvider);
    
    final translationService = DataTranslationService(ref);
    return translationService.smartTranslate(description!);
  }
  
  /// Lấy categoryName theo locale hiện tại
  String getLocalizedCategoryName(WidgetRef ref) {
    final locale = ref.read(localeProvider);
    final isVietnamese = locale.languageCode == 'vi';
    
    if (isVietnamese) {
      return categoryName;
    }
    
    // Watch translation cache
    ref.watch(translationCacheProvider);
    
    final translationService = DataTranslationService(ref);
    return translationService.translateCategoryName(categoryName);
  }
  
  /// Lấy unitType theo locale hiện tại
  /// Backend trả về tiếng Anh, nếu app ở tiếng Việt thì dịch sang tiếng Việt
  /// Nếu app ở tiếng Anh thì giữ nguyên tiếng Anh
  String getLocalizedUnitType(WidgetRef ref) {
    // Watch locale để rebuild khi đổi ngôn ngữ
    final locale = ref.watch(localeProvider);
    
    // Watch translation cache
    ref.watch(translationCacheProvider);
    
    final translationService = DataTranslationService(ref);
    return translationService.translateUnitType(unitType);
  }
}

/// Extension cho ServiceOption
extension ServiceOptionLocalizationExtension on ServiceOption {
  /// Lấy optionName theo locale hiện tại
  String getLocalizedOptionName(WidgetRef ref) {
    final locale = ref.read(localeProvider);
    final isVietnamese = locale.languageCode == 'vi';
    
    if (isVietnamese) {
      return optionName;
    }
    
    // Watch translation cache
    ref.watch(translationCacheProvider);
    
    final translationService = DataTranslationService(ref);
    return translationService.translateOptionName(optionName);
  }
  
  /// Lấy value theo locale hiện tại (cho textarea/text options)
  String? getLocalizedValue(WidgetRef ref) {
    if (value == null || value!.isEmpty) {
      return value;
    }
    
    final locale = ref.read(localeProvider);
    final isVietnamese = locale.languageCode == 'vi';
    
    if (isVietnamese) {
      return value;
    }
    
    // Watch translation cache
    ref.watch(translationCacheProvider);
    
    final translationService = DataTranslationService(ref);
    return translationService.smartTranslate(value!);
  }
}

/// Extension cho ServiceOptionDetail
extension ServiceOptionDetailLocalizationExtension on ServiceOptionDetail {
  /// Lấy optionName theo locale hiện tại
  String getLocalizedOptionName(WidgetRef ref) {
    final locale = ref.read(localeProvider);
    final isVietnamese = locale.languageCode == 'vi';
    
    if (isVietnamese) {
      return optionName;
    }
    
    // Watch translation cache
    ref.watch(translationCacheProvider);
    
    final translationService = DataTranslationService(ref);
    return translationService.translateOptionName(optionName);
  }
  
  /// Lấy value theo locale hiện tại (cho textarea/text options)
  String? getLocalizedValue(WidgetRef ref) {
    if (value == null || value!.isEmpty) {
      return value;
    }
    
    final locale = ref.read(localeProvider);
    final isVietnamese = locale.languageCode == 'vi';
    
    if (isVietnamese) {
      return value;
    }
    
    // Watch translation cache
    ref.watch(translationCacheProvider);
    
    final translationService = DataTranslationService(ref);
    return translationService.smartTranslate(value!);
  }
}

/// Extension cho ServiceTag
extension ServiceTagLocalizationExtension on ServiceTag {
  /// Lấy tag name theo locale hiện tại
  String getLocalizedName(WidgetRef ref) {
    final locale = ref.read(localeProvider);
    final isVietnamese = locale.languageCode == 'vi';
    
    if (isVietnamese) {
      return name;
    }
    
    // Watch translation cache
    ref.watch(translationCacheProvider);
    
    final translationService = DataTranslationService(ref);
    return translationService.smartTranslate(name);
  }
}

