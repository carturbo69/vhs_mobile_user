import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/database/app_database.dart';
import 'package:vhs_mobile_user/data/database/app_settings_table.dart';

part 'app_settings_dao.g.dart';

@DriftAccessor(tables: [AppSettingsTable])
class AppSettingsDao extends DatabaseAccessor<AppDatabase> with _$AppSettingsDaoMixin {
  AppSettingsDao(AppDatabase db) : super(db);

  /// Lấy theme mode từ database
  Future<String> getThemeMode() async {
    final settings = await (select(appSettingsTable)..limit(1)).getSingleOrNull();
    return settings?.themeMode ?? 'light';
  }

  /// Lưu theme mode vào database
  Future<void> setThemeMode(String themeMode) async {
    await into(appSettingsTable).insertOnConflictUpdate(
      AppSettingsTableCompanion(
        id: const Value('settings'),
        themeMode: Value(themeMode),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

// Provider cho AppSettingsDao
final appSettingsDaoProvider = Provider<AppSettingsDao>((ref) {
  final db = ref.read(appDatabaseProvider);
  return AppSettingsDao(db);
});

