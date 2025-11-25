import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/database/service_database.dart';
import 'package:vhs_mobile_user/data/database/service_table.dart';
import 'package:vhs_mobile_user/data/models/service/service_model.dart';
part 'service_dao.g.dart';

// part of your generated drift database file / dao file
@DriftAccessor(tables: [ServicesTable])
class ServicesDao extends DatabaseAccessor<AppDatabase> with _$ServicesDaoMixin {
  ServicesDao(AppDatabase db) : super(db);

  Future<void> upsertServices(List<ServiceModel> services) async {
    return transaction(() async {
      for (final s in services) {
        final companion = ServicesTableCompanion(
          serviceId: Value(s.serviceId),
          providerId: Value(s.providerId),
          categoryId: Value(s.categoryId),
          title: Value(s.title),
          description: Value(s.description),
          price: Value(s.price),
          unitType: Value(s.unitType),
          baseUnit: Value(s.baseUnit),
          images: Value(s.images),
          createdAt: Value(s.createdAt),
          status: Value(s.status),
          deleted: Value(s.deleted),
          averageRating: Value(s.averageRating),
          totalReviews: Value(s.totalReviews),
          categoryName: Value(s.categoryName),
          providerName: Value(s.providerName),
          jsonOptions: Value(jsonEncode(s.serviceOptions.map((o) => o.toJson()).toList())),
        );

        await into(servicesTable).insertOnConflictUpdate(companion);
      }
    });
  }

  Future<List<ServiceModel>> getAllServices() async {
    final rows = await select(servicesTable).get();
    return rows.map((r) {
      final options = r.jsonOptions == null ? [] :
        (jsonDecode(r.jsonOptions!) as List<dynamic>).map((e) => ServiceOption.fromJson(e as Map<String, dynamic>)).toList();
      return ServiceModel(
        serviceId: r.serviceId,
        providerId: r.providerId ?? '',
        categoryId: r.categoryId ?? '',
        title: r.title,
        description: r.description,
        price: r.price,
        unitType: r.unitType ?? '',
        baseUnit: r.baseUnit,
        images: r.images,
        createdAt: r.createdAt,
        status: r.status,
        deleted: r.deleted,
        averageRating: r.averageRating,
        totalReviews: r.totalReviews,
        categoryName: r.categoryName ?? '',
        providerName: r.providerName,
        serviceOptions: options.cast<ServiceOption>(),
      );
    }).toList();
  }

  Future<ServiceModel?> getById(String id) async {
    final row = await (select(servicesTable)..where((t) => t.serviceId.equals(id))).getSingleOrNull();
    if (row == null) return null;
    final options = row.jsonOptions == null ? [] :
      (jsonDecode(row.jsonOptions!) as List<dynamic>).map((e) => ServiceOption.fromJson(e as Map<String, dynamic>)).toList();
    return ServiceModel(
      serviceId: row.serviceId,
      providerId: row.providerId ?? '',
      categoryId: row.categoryId ?? '',
      title: row.title,
      description: row.description,
      price: row.price,
      unitType: row.unitType ?? '',
      baseUnit: row.baseUnit,
      images: row.images,
      createdAt: row.createdAt,
      status: row.status,
      deleted: row.deleted,
      averageRating: row.averageRating,
      totalReviews: row.totalReviews,
      categoryName: row.categoryName ?? '',
      providerName: row.providerName,
      serviceOptions: options.cast<ServiceOption>(),
    );
  }
}
final servicesDaoProvider = Provider<ServicesDao>((ref) {
  final db = ref.read(appDatabaseProvider);
  return ServicesDao(db);
});
