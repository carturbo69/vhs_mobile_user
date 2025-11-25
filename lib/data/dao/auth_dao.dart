// lib/data/local/auth_dao.dart
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/database/auth_table.dart';
import 'package:vhs_mobile_user/data/database/service_database.dart';

part 'auth_dao.g.dart';

@DriftAccessor(tables: [AuthsTable])
class AuthDao extends DatabaseAccessor<AppDatabase> with _$AuthDaoMixin {
  AuthDao(AppDatabase db) : super(db);

  Future<void> upsertLogin({
    String? token,
    String? role,
    String? accountId,
  }) async {
    final companion = AuthsTableCompanion(
      id: const Value('auth'),
      token: Value(token),
      role: Value(role),
      accountId: Value(accountId),
      savedAt: Value(DateTime.now()),
    );
    await into(authsTable).insertOnConflictUpdate(companion);
  }

  Future<Map<String, dynamic>?> getSavedAuth() async {
    final row = await (select(
      authsTable,
    )..where((t) => t.id.equals('auth'))).getSingleOrNull();
    if (row == null) return null;
    return {
      'token': row.token,
      'role': row.role,
      'accountId': row.accountId,
      'savedAt': row.savedAt,
    };
  }

  Future<void> clearAuth() async {
    await (delete(authsTable)..where((t) => t.id.equals('auth'))).go();
  }

  Future<String?> getToken() async {
    final row = await (select(
      authsTable,
    )..where((t) => t.id.equals('auth'))).getSingleOrNull();

    return row?.token;
  }
}

final authDaoProvider = Provider<AuthDao>((ref) {
  final db = ref.read(appDatabaseProvider);
  return AuthDao(db);
});
