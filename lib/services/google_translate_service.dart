import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/src/framework.dart' as riverpod;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vhs_mobile_user/providers/locale_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service để translate text sử dụng Google Translate API (free version)
/// Sử dụng Google Translate web API không cần API key
class GoogleTranslateService {
  final riverpod.Ref ref;
  static const String _cachePrefix = 'translation_cache_';
  
  GoogleTranslateService(this.ref);
  
  /// Lấy locale hiện tại
  bool get isVietnamese {
    try {
      final locale = ref.read(localeProvider);
      return locale.languageCode == 'vi';
    } catch (e) {
      return true;
    }
  }
  
  /// Translate text sử dụng Google Translate (free web API)
  /// Cache kết quả để tránh gọi API nhiều lần
  Future<String> translate(String text, {String? from, String? to}) async {
    // Nếu đang dùng tiếng Việt, không cần translate
    if (isVietnamese) {
      return text;
    }
    
    // Nếu text rỗng, trả về luôn
    if (text.isEmpty || text.trim().isEmpty) {
      return text;
    }
    
    // Kiểm tra cache trước
    final cached = await _getCachedTranslation(text);
    if (cached != null) {
      // Nếu cached translation khác với text gốc, dùng cache
      // Nếu cached translation giống text gốc (có thể do translation failed trước đó),
      // và text có HTML tags hoặc dài, force translate lại với logic mới
      if (cached != text) {
        return cached;
      } else {
        // Cached translation giống text gốc, có thể do translation failed
        // Nếu text có HTML tags hoặc dài, force translate lại
        final hasHtmlTags = text.contains('<') && text.contains('>');
        if (text.length > 2000 || hasHtmlTags) {
          print('⚠️ Cached translation is identical to original text. Force retranslating with new logic...');
          // Xóa cache cũ để force translate lại
          await _removeCachedTranslation(text);
        } else {
          // Text ngắn và không có HTML, dùng cache
          return cached;
        }
      }
    }
    
    try {
      // Sử dụng Google Translate web API (free, không cần API key)
      final fromLang = from ?? 'vi';
      final toLang = to ?? 'en';
      
      // Kiểm tra xem text có chứa HTML tags không
      final hasHtmlTags = text.contains('<') && text.contains('>');
      
      // Nếu text dài hoặc có HTML tags, xử lý đặc biệt
      if (text.length > 2000 || hasHtmlTags) {
        print('📝 Text is long (${text.length} chars) or contains HTML tags, processing specially...');
        
        // Nếu có HTML tags, strip tags trước khi dịch
        String textToTranslate = text;
        List<String> htmlTags = [];
        List<int> tagPositions = [];
        
        if (hasHtmlTags) {
          print('🔧 Stripping HTML tags before translation...');
          // Tìm và lưu lại các HTML tags và vị trí của chúng
          final tagPattern = RegExp(r'<[^>]+>');
          final matches = tagPattern.allMatches(text);
          
          // Lưu tags và vị trí
          for (var match in matches) {
            htmlTags.add(match.group(0)!);
            tagPositions.add(match.start);
          }
          
          // Strip tags để dịch
          textToTranslate = text.replaceAll(tagPattern, ' ');
          print('   Stripped text length: ${textToTranslate.length} (removed ${htmlTags.length} tags)');
        }
        
        // Nếu có HTML tags với <br>, dịch từng dòng riêng biệt
        if (hasHtmlTags && text.contains(RegExp(r'<br\s*/?>', caseSensitive: false))) {
          print('🔧 Text contains <br> tags, translating line by line...');
          final originalParts = text.split(RegExp(r'<br\s*/?>', caseSensitive: false));
          final translatedParts = <String>[];
          
          for (int i = 0; i < originalParts.length; i++) {
            final part = originalParts[i].trim();
            if (part.isNotEmpty) {
              // Strip HTML tags khác nếu có
              final cleanPart = part.replaceAll(RegExp(r'<[^>]+>'), ' ').trim();
              if (cleanPart.isNotEmpty) {
                print('🔄 Translating part ${i + 1}/${originalParts.length} (length: ${cleanPart.length})');
                final partTranslated = await _translateWithGoogleWeb(cleanPart, fromLang, toLang);
                translatedParts.add(partTranslated);
              }
            }
            // Thêm <br> giữa các phần (trừ phần cuối)
            if (i < originalParts.length - 1) {
              translatedParts.add('<br>');
            }
            // Đợi một chút giữa các requests
            if (i < originalParts.length - 1) {
              await Future.delayed(const Duration(milliseconds: 300));
            }
          }
          
          var finalTranslated = translatedParts.join('');
          
          // Kiểm tra xem translation có khác với text gốc không
          if (finalTranslated != text && finalTranslated.isNotEmpty) {
            print('✅ Line-by-line translation successful! Original: ${text.length} chars, Translated: ${finalTranslated.length} chars');
            await _saveCachedTranslation(text, finalTranslated);
            return finalTranslated;
          } else {
            print('⚠️ Line-by-line translation returned original text. This might indicate an API issue.');
          }
        }
        
        // Nếu không có <br> tags hoặc line-by-line translation failed, chia text thành các chunks nhỏ hơn để dịch
        final chunks = _splitTextIntoChunks(textToTranslate, 1500);
        final translatedChunks = <String>[];
        
        for (int i = 0; i < chunks.length; i++) {
          print('🔄 Translating chunk ${i + 1}/${chunks.length} (length: ${chunks[i].length})');
          final chunkTranslated = await _translateWithGoogleWeb(chunks[i].trim(), fromLang, toLang);
          
          // Kiểm tra xem chunk có được dịch không
          if (chunkTranslated == chunks[i].trim()) {
            print('   ⚠️ Chunk ${i + 1} returned original text, might be untranslatable');
          }
          
          translatedChunks.add(chunkTranslated);
          
          // Đợi một chút giữa các requests để tránh rate limit
          if (i < chunks.length - 1) {
            await Future.delayed(const Duration(milliseconds: 500));
          }
        }
        
        var finalTranslated = translatedChunks.join(' ');
        
        // Nếu có HTML tags, thêm lại tags vào vị trí tương ứng
        if (hasHtmlTags && htmlTags.isNotEmpty) {
          print('🔧 Re-adding HTML tags to translated text...');
          
          // Phương pháp tốt hơn: Split text gốc theo <br> tags, dịch từng phần, rồi join lại
          final originalParts = text.split(RegExp(r'<br\s*/?>', caseSensitive: false));
          final translatedParts = <String>[];
          
          for (int i = 0; i < originalParts.length; i++) {
            final part = originalParts[i].trim();
            if (part.isNotEmpty) {
              // Dịch từng phần
              final partTranslated = await _translateWithGoogleWeb(part, fromLang, toLang);
              translatedParts.add(partTranslated);
              if (i < originalParts.length - 1) {
                translatedParts.add('<br>');
              }
              // Đợi một chút giữa các requests
              if (i < originalParts.length - 1) {
                await Future.delayed(const Duration(milliseconds: 300));
              }
            } else if (i < originalParts.length - 1) {
              // Phần rỗng, chỉ thêm <br>
              translatedParts.add('<br>');
            }
          }
          
          finalTranslated = translatedParts.join('');
          print('   Final translated text length: ${finalTranslated.length}');
        }
        
        // Kiểm tra xem translation có khác với text gốc không
        if (finalTranslated != text && finalTranslated.isNotEmpty) {
          print('✅ Chunked translation successful! Original: ${text.length} chars, Translated: ${finalTranslated.length} chars');
          await _saveCachedTranslation(text, finalTranslated);
          return finalTranslated;
        } else {
          print('⚠️ Chunked translation returned original text. This might indicate an API issue.');
        }
      } else {
        // Text ngắn và không có HTML, dịch bình thường
        final translated = await _translateWithGoogleWeb(text, fromLang, toLang);
        
        if (translated != text && translated.isNotEmpty) {
          print('✅ Translation successful! Original: ${text.length} chars, Translated: ${translated.length} chars');
          await _saveCachedTranslation(text, translated);
          return translated;
        } else {
          print('⚠️ Translation returned original text or empty');
        }
      }
      
      // Nếu tất cả đều fail, trả về text gốc
      print('⚠️ Returning original text as translation failed');
      await _saveCachedTranslation(text, text);
      return text;
    } catch (e) {
      print('⚠️ Translation error: $e');
      // Nếu lỗi, trả về text gốc
      return text;
    }
  }
  
  /// Translate sử dụng Google Translate web API (free)
  Future<String> _translateWithGoogleWeb(String text, String from, String to) async {
    try {
      // URL encode text
      final encodedText = Uri.encodeComponent(text);
      
      // Google Translate web API endpoint (free, không cần API key)
      final url = 'https://translate.googleapis.com/translate_a/single?'
          'client=gtx&'
          'sl=$from&'
          'tl=$to&'
          'dt=t&'
          'q=$encodedText';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Debug: Log response structure
        print('🔍 Google Translate API response type: ${data.runtimeType}');
        if (data is List) {
          print('🔍 Response is List with ${data.length} items');
          if (data.isNotEmpty && data[0] is List) {
            print('🔍 First item is List with ${(data[0] as List).length} items');
          }
        }
        
        // Parse response từ Google Translate API
        if (data is List && data.isNotEmpty && data[0] is List) {
          final translations = data[0] as List;
          print('🔍 Found ${translations.length} translation segments');
          
          // Combine tất cả các translations lại thành một string
          final translatedParts = <String>[];
          for (int i = 0; i < translations.length; i++) {
            var translation = translations[i];
            if (translation is List && translation.isNotEmpty) {
              final translatedText = translation[0];
              if (translatedText != null && translatedText.toString().isNotEmpty) {
                final text = translatedText.toString();
                translatedParts.add(text);
                if (i < 3) { // Log first 3 segments for debugging
                  print('🔍 Segment $i: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
                }
              }
            }
          }
          if (translatedParts.isNotEmpty) {
            final result = translatedParts.join('');
            print('✅ Translation result length: ${result.length} (original: ${text.length})');
            // Kiểm tra xem có thực sự được dịch không (so sánh một phần đầu)
            if (result.length > 0 && text.length > 0) {
              final originalStart = text.substring(0, text.length > 100 ? 100 : text.length);
              final translatedStart = result.substring(0, result.length > 100 ? 100 : result.length);
              if (originalStart == translatedStart) {
                print('⚠️ WARNING: Translation result appears to be identical to original text!');
              } else {
                print('✅ Translation appears successful (first 100 chars differ)');
              }
            }
            return result;
          }
        }
      } else {
        print('⚠️ Google Translate API returned status code: ${response.statusCode}');
        print('⚠️ Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      }
      
      // Nếu parse không được, trả về text gốc
      print('⚠️ Failed to parse translation response, returning original text');
      return text;
    } catch (e) {
      print('⚠️ Google Translate API error: $e');
      return text;
    }
  }
  
  /// Chia text thành các chunks nhỏ hơn để dịch
  List<String> _splitTextIntoChunks(String text, int maxChunkSize) {
    final chunks = <String>[];
    int start = 0;
    
    while (start < text.length) {
      int end = start + maxChunkSize;
      if (end >= text.length) {
        chunks.add(text.substring(start));
        break;
      }
      // Tìm vị trí tốt để cắt (ưu tiên cắt ở dấu xuống dòng hoặc khoảng trắng)
      int cutPoint = end;
      for (int i = end; i > start && i > end - 200; i--) {
        if (text[i] == '\n' || text[i] == '\r' || text[i] == ' ') {
          cutPoint = i + 1;
          break;
        }
      }
      chunks.add(text.substring(start, cutPoint));
      start = cutPoint;
    }
    
    return chunks;
  }
  
  /// Lấy translation từ cache
  Future<String?> _getCachedTranslation(String text) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix${text.hashCode}';
      return prefs.getString(cacheKey);
    } catch (e) {
      return null;
    }
  }
  
  /// Lưu translation vào cache
  /// Xóa cached translation
  Future<void> _removeCachedTranslation(String text) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix${text.hashCode}';
      await prefs.remove(cacheKey);
      print('🗑️ Removed cached translation for text (hash: ${text.hashCode})');
    } catch (e) {
      print('⚠️ Error removing cached translation: $e');
    }
  }
  
  Future<void> _saveCachedTranslation(String original, String translated) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix${original.hashCode}';
      await prefs.setString(cacheKey, translated);
    } catch (e) {
      print('⚠️ Cache save error: $e');
    }
  }
  
  /// Clear translation cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cachePrefix));
      for (var key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      print('⚠️ Cache clear error: $e');
    }
  }
  
  /// Batch translate nhiều texts cùng lúc
  Future<Map<String, String>> translateBatch(List<String> texts) async {
    final results = <String, String>{};
    
    for (var text in texts) {
      if (text.isNotEmpty) {
        results[text] = await translate(text);
      }
    }
    
    return results;
  }
}

/// Provider để tạo GoogleTranslateService
final googleTranslateServiceProvider = Provider.family<GoogleTranslateService, riverpod.Ref>(
  (ref, widgetRef) => GoogleTranslateService(widgetRef),
);

