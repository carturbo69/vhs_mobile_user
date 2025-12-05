import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/services/google_translate_service.dart';
import 'package:vhs_mobile_user/providers/locale_provider.dart';

/// Provider để cache translations và trigger rebuild khi có translation mới
final translationCacheProvider = NotifierProvider<TranslationCacheNotifier, Map<String, String>>(() {
  return TranslationCacheNotifier();
});

class TranslationCacheNotifier extends Notifier<Map<String, String>> {
  late final GoogleTranslateService _translateService;
  
  @override
  Map<String, String> build() {
    _translateService = GoogleTranslateService(ref);
    _init();
    return {};
  }
  
  void _init() {
    // Watch locale để clear cache khi đổi ngôn ngữ
    ref.listen(localeProvider, (previous, next) {
      if (previous != null && previous.languageCode != next.languageCode) {
        clearCache();
      }
    });
  }
  
  /// Get translation từ cache hoặc translate mới
  /// Mặc định: backend trả về tiếng Việt, dịch sang tiếng Anh khi app ở tiếng Anh
  /// Có thể override bằng cách truyền from/to (ví dụ: unit type từ tiếng Anh sang tiếng Việt)
  Future<String> getTranslation(String text, {String? from, String? to}) async {
    final locale = ref.read(localeProvider);
    final isVietnamese = locale.languageCode == 'vi';
    
    // Xác định ngôn ngữ nguồn và đích
    // Mặc định: backend trả về tiếng Việt, dịch sang tiếng Anh khi app ở tiếng Anh
    final fromLang = from ?? (isVietnamese ? 'vi' : 'vi');
    final toLang = to ?? (isVietnamese ? 'vi' : 'en');
    
    // Kiểm tra cache với key bao gồm cả ngôn ngữ
    final cacheKey = '${fromLang}_${toLang}_$text';
    if (state.containsKey(cacheKey)) {
      return state[cacheKey]!;
    }
    
    // Translate và cache
    try {
      print('🔄 Calling Google Translate API for text (length: ${text.length}) from $fromLang to $toLang');
      final translated = await _translateService.translate(text, from: fromLang, to: toLang);
      
      // Debug: Kiểm tra xem translation có khác với text gốc không
      if (translated == text) {
        print('⚠️ WARNING: Translation returned original text! This might indicate an issue.');
        print('   Original: ${text.substring(0, text.length > 100 ? 100 : text.length)}...');
        print('   Translated: ${translated.substring(0, translated.length > 100 ? 100 : translated.length)}...');
      } else {
        print('✅ Translation successful! Original length: ${text.length}, Translated length: ${translated.length}');
        print('   Original start: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
        print('   Translated start: ${translated.substring(0, translated.length > 50 ? 50 : translated.length)}...');
      }
      
      // Update state để trigger rebuild
      state = {...state, cacheKey: translated};
      print('✅ Cache updated, state now has ${state.length} entries');
      return translated;
    } catch (e) {
      print('⚠️ Translation error: $e');
      return text;
    }
  }
  
  /// Get translation sync (từ cache)
  /// Mặc định: backend trả về tiếng Việt, dịch sang tiếng Anh khi app ở tiếng Anh
  /// Có thể override bằng cách truyền from/to (ví dụ: unit type từ tiếng Anh sang tiếng Việt)
  String getTranslationSync(String text, {String? from, String? to}) {
    final locale = ref.read(localeProvider);
    final isVietnamese = locale.languageCode == 'vi';
    
    // Xác định ngôn ngữ nguồn và đích
    // Mặc định: backend trả về tiếng Việt, dịch sang tiếng Anh khi app ở tiếng Anh
    final fromLang = from ?? (isVietnamese ? 'vi' : 'vi');
    final toLang = to ?? (isVietnamese ? 'vi' : 'en');
    
    // Kiểm tra cache với key bao gồm cả ngôn ngữ
    final cacheKey = '${fromLang}_${toLang}_$text';
    
    // Trigger async translation nếu chưa có trong cache
    if (!state.containsKey(cacheKey)) {
      getTranslation(text, from: fromLang, to: toLang).catchError((e) {
        print('⚠️ Async translation error: $e');
      });
    }
    
    // Trả về từ cache hoặc text gốc
    return state[cacheKey] ?? text;
  }
  
  /// Clear cache
  void clearCache() {
    state = {};
  }
}

