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
  Future<String> getTranslation(String text) async {
    // Nếu đang dùng tiếng Việt, không cần translate
    final locale = ref.read(localeProvider);
    if (locale.languageCode == 'vi') {
      return text;
    }
    
    // Kiểm tra cache
    if (state.containsKey(text)) {
      return state[text]!;
    }
    
    // Translate và cache
    try {
      print('🔄 Calling Google Translate API for text (length: ${text.length})');
      final translated = await _translateService.translate(text, from: 'vi', to: 'en');
      
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
      state = {...state, text: translated};
      print('✅ Cache updated, state now has ${state.length} entries');
      return translated;
    } catch (e) {
      print('⚠️ Translation error: $e');
      return text;
    }
  }
  
  /// Get translation sync (từ cache)
  String getTranslationSync(String text) {
    final locale = ref.read(localeProvider);
    if (locale.languageCode == 'vi') {
      return text;
    }
    
    // Trigger async translation nếu chưa có trong cache
    if (!state.containsKey(text)) {
      getTranslation(text).catchError((e) {
        print('⚠️ Async translation error: $e');
      });
    }
    
    // Trả về từ cache hoặc text gốc
    return state[text] ?? text;
  }
  
  /// Clear cache
  void clearCache() {
    state = {};
  }
}

