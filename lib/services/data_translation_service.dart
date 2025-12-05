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
  
  /// Bảng mapping đơn vị từ tiếng Anh sang tiếng Việt
  /// Dựa trên các đơn vị trong form Create.cshtml
  static const Map<String, String> _unitTypeMapping = {
    // Đơn vị từ form
    'Hour': 'Giờ',
    'hour': 'Giờ',
    'Hours': 'Giờ',
    'hours': 'Giờ',
    'Day': 'Ngày',
    'day': 'Ngày',
    'Days': 'Ngày',
    'days': 'Ngày',
    'Visit': 'Lần',
    'visit': 'Lần',
    'Visits': 'Lần',
    'visits': 'Lần',
    'Apartment': 'Căn',
    'apartment': 'Căn',
    'Apartments': 'Căn',
    'apartments': 'Căn',
    'Room': 'Phòng',
    'room': 'Phòng',
    'Rooms': 'Phòng',
    'rooms': 'Phòng',
    'SquareMeter': 'Mét vuông (m²)',
    'Square Meter': 'Mét vuông (m²)',
    'square meter': 'Mét vuông (m²)',
    'squaremeter': 'Mét vuông (m²)',
    'SquareMeters': 'Mét vuông (m²)',
    'Square Meters': 'Mét vuông (m²)',
    'square meters': 'Mét vuông (m²)',
    'Person': 'Người',
    'person': 'Người',
    'Persons': 'Người',
    'persons': 'Người',
    'People': 'Người',
    'people': 'Người',
    'Package': 'Gói',
    'package': 'Gói',
    'Packages': 'Gói',
    'packages': 'Gói',
    'Event': 'Sự kiện',
    'event': 'Sự kiện',
    'Events': 'Sự kiện',
    'events': 'Sự kiện',
    // Các đơn vị khác
    'Week': 'Tuần',
    'week': 'Tuần',
    'Weeks': 'Tuần',
    'weeks': 'Tuần',
    'Month': 'Tháng',
    'month': 'Tháng',
    'Months': 'Tháng',
    'months': 'Tháng',
    'Piece': 'Cái',
    'piece': 'Cái',
    'Pieces': 'Cái',
    'pieces': 'Cái',
    'Item': 'Món',
    'item': 'Món',
    'Items': 'Món',
    'items': 'Món',
    'Kilogram': 'Kilogram',
    'kilogram': 'Kilogram',
    'Kilograms': 'Kilogram',
    'kilograms': 'Kilogram',
    'Meter': 'Mét',
    'meter': 'Mét',
    'Meters': 'Mét',
    'meters': 'Mét',
    'Liter': 'Lít',
    'liter': 'Lít',
    'Liters': 'Lít',
    'liters': 'Lít',
  };

  /// Translate unit type sử dụng Google Translate với cache
  /// Backend trả về tiếng Anh, nếu app ở tiếng Việt thì dịch sang tiếng Việt
  /// Nếu app ở tiếng Anh thì giữ nguyên tiếng Anh
  String translateUnitType(String unitType) {
    // Common units không cần translate (giữ nguyên)
    final commonUnits = ['M²', 'Kg', 'm²', 'kg', 'm', 'cm', 'km'];
    if (commonUnits.contains(unitType)) {
      return unitType;
    }
    
    // Nếu app ở tiếng Anh, giữ nguyên (backend đã là tiếng Anh)
    if (!isVietnamese) {
      return unitType;
    }
    
    // Kiểm tra bảng mapping trước
    final normalizedUnit = unitType.trim();
    if (_unitTypeMapping.containsKey(normalizedUnit)) {
      return _unitTypeMapping[normalizedUnit]!;
    }
    
    // Nếu không có trong mapping, thử format lại text (thêm khoảng trắng) trước khi dịch
    // Ví dụ: "SquareMeter" -> "Square Meter"
    String formattedUnit = normalizedUnit;
    if (normalizedUnit.contains(RegExp(r'[A-Z][a-z]+[A-Z]'))) {
      // Tìm pattern như "SquareMeter" và thêm khoảng trắng
      formattedUnit = normalizedUnit.replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'),
        (match) => '${match.group(1)} ${match.group(2)}',
      );
    }
    
    // Kiểm tra lại mapping với text đã format
    if (formattedUnit != normalizedUnit && _unitTypeMapping.containsKey(formattedUnit)) {
      return _unitTypeMapping[formattedUnit]!;
    }
    
    // Nếu vẫn không có, thử dịch với Google Translate
    final cache = ref.read(translationCacheProvider.notifier);
    final translated = cache.getTranslationSync(formattedUnit, from: 'en', to: 'vi');
    
    // Nếu dịch không thành công (trả về text gốc), thử với text gốc
    if (translated == formattedUnit && formattedUnit != normalizedUnit) {
      return cache.getTranslationSync(normalizedUnit, from: 'en', to: 'vi');
    }
    
    return translated;
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


