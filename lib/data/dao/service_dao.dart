import 'package:drift/drift.dart';
import 'package:vhs_mobile_user/data/database/service_database.dart';
import 'package:vhs_mobile_user/data/database/service_table.dart';
part 'service_dao.g.dart';

@DriftAccessor(tables: [Services])
class ServiceDao extends DatabaseAccessor<ServiceDatabase>
    with _$ServiceDaoMixin {
  ServiceDao(ServiceDatabase db) : super(db);

  Future<void> insertAll(List<ServicesCompanion> entries) async {
    await batch((b) => b.insertAllOnConflictUpdate(services, entries));
  }

  Future<void> clearAll() => delete(services).go();

  Future<List<ServiceEntity>> getAll() => select(services).get();

  /// Search theo tiêu đề hoặc mô tả
  Future<List<ServiceEntity>> search(String keyword) async {
    if (keyword.trim().isEmpty) return getAll();
    return (select(services)..where(
          (tbl) =>
              tbl.title.like('%$keyword%') | tbl.description.like('%$keyword%'),
        ))
        .get();
  }

  /// Filter theo category
  Future<List<ServiceEntity>> filterByCategory(String categoryId) {
    return (select(
      services,
    )..where((tbl) => tbl.categoryId.equals(categoryId))).get();
  }

  /// Sort theo giá
  Future<List<ServiceEntity>> sortByPrice({bool ascending = true}) {
    return (select(services)..orderBy([
          (tbl) => ascending
              ? OrderingTerm.asc(tbl.price)
              : OrderingTerm.desc(tbl.price),
        ]))
        .get();
  }

  /// Query kết hợp tất cả điều kiện (tối ưu)
  Future<List<ServiceEntity>> queryFiltered({
    String? keyword,
    String? categoryId,
    bool? sortAsc,
  }) async {
    final query = select(services);

    if (keyword != null && keyword.isNotEmpty) {
      query.where(
        (tbl) =>
            tbl.title.like('%$keyword%') | tbl.description.like('%$keyword%'),
      );
    }

    if (categoryId != null && categoryId.isNotEmpty) {
      query.where((tbl) => tbl.categoryId.equals(categoryId));
    }

    if (sortAsc != null) {
      query.orderBy([
        (tbl) => sortAsc
            ? OrderingTerm.asc(tbl.price)
            : OrderingTerm.desc(tbl.price),
      ]);
    }

    return query.get();
  }

  Future<List<ServiceEntity>> getPage({
    required int limit,
    required int offset,
    String? keyword,
    String? categoryId,
    bool? sortAsc,
  }) async {
    final query = select(services);

    if (keyword != null && keyword.isNotEmpty) {
      query.where(
        (tbl) =>
            tbl.title.like('%$keyword%') | tbl.description.like('%$keyword%'),
      );
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      query.where((tbl) => tbl.categoryId.equals(categoryId));
    }

    if (sortAsc != null) {
      query.orderBy([
        (tbl) => sortAsc
            ? OrderingTerm.asc(tbl.price)
            : OrderingTerm.desc(tbl.price),
      ]);
    }

    query.limit(limit, offset: offset);
    return query.get();
  }
}
