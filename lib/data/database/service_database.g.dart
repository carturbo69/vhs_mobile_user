// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_database.dart';

// ignore_for_file: type=lint
class $ServicesTable extends Services
    with TableInfo<$ServicesTable, ServiceEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serviceIdMeta = const VerificationMeta(
    'serviceId',
  );
  @override
  late final GeneratedColumn<String> serviceId = GeneratedColumn<String>(
    'service_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitTypeMeta = const VerificationMeta(
    'unitType',
  );
  @override
  late final GeneratedColumn<String> unitType = GeneratedColumn<String>(
    'unit_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseUnitMeta = const VerificationMeta(
    'baseUnit',
  );
  @override
  late final GeneratedColumn<int> baseUnit = GeneratedColumn<int>(
    'base_unit',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagesMeta = const VerificationMeta('images');
  @override
  late final GeneratedColumn<String> images = GeneratedColumn<String>(
    'images',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _averageRatingMeta = const VerificationMeta(
    'averageRating',
  );
  @override
  late final GeneratedColumn<double> averageRating = GeneratedColumn<double>(
    'average_rating',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalReviewsMeta = const VerificationMeta(
    'totalReviews',
  );
  @override
  late final GeneratedColumn<int> totalReviews = GeneratedColumn<int>(
    'total_reviews',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _categoryNameMeta = const VerificationMeta(
    'categoryName',
  );
  @override
  late final GeneratedColumn<String> categoryName = GeneratedColumn<String>(
    'category_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    serviceId,
    providerId,
    categoryId,
    title,
    description,
    price,
    unitType,
    baseUnit,
    images,
    averageRating,
    totalReviews,
    categoryName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'services';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServiceEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('service_id')) {
      context.handle(
        _serviceIdMeta,
        serviceId.isAcceptableOrUnknown(data['service_id']!, _serviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_serviceIdMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('unit_type')) {
      context.handle(
        _unitTypeMeta,
        unitType.isAcceptableOrUnknown(data['unit_type']!, _unitTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_unitTypeMeta);
    }
    if (data.containsKey('base_unit')) {
      context.handle(
        _baseUnitMeta,
        baseUnit.isAcceptableOrUnknown(data['base_unit']!, _baseUnitMeta),
      );
    }
    if (data.containsKey('images')) {
      context.handle(
        _imagesMeta,
        images.isAcceptableOrUnknown(data['images']!, _imagesMeta),
      );
    }
    if (data.containsKey('average_rating')) {
      context.handle(
        _averageRatingMeta,
        averageRating.isAcceptableOrUnknown(
          data['average_rating']!,
          _averageRatingMeta,
        ),
      );
    }
    if (data.containsKey('total_reviews')) {
      context.handle(
        _totalReviewsMeta,
        totalReviews.isAcceptableOrUnknown(
          data['total_reviews']!,
          _totalReviewsMeta,
        ),
      );
    }
    if (data.containsKey('category_name')) {
      context.handle(
        _categoryNameMeta,
        categoryName.isAcceptableOrUnknown(
          data['category_name']!,
          _categoryNameMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {serviceId};
  @override
  ServiceEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServiceEntity(
      serviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      unitType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_type'],
      )!,
      baseUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_unit'],
      ),
      images: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}images'],
      ),
      averageRating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_rating'],
      )!,
      totalReviews: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_reviews'],
      )!,
      categoryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_name'],
      ),
    );
  }

  @override
  $ServicesTable createAlias(String alias) {
    return $ServicesTable(attachedDatabase, alias);
  }
}

class ServiceEntity extends DataClass implements Insertable<ServiceEntity> {
  final String serviceId;
  final String providerId;
  final String categoryId;
  final String title;
  final String? description;
  final double price;
  final String unitType;
  final int? baseUnit;
  final String? images;
  final double averageRating;
  final int totalReviews;
  final String? categoryName;
  const ServiceEntity({
    required this.serviceId,
    required this.providerId,
    required this.categoryId,
    required this.title,
    this.description,
    required this.price,
    required this.unitType,
    this.baseUnit,
    this.images,
    required this.averageRating,
    required this.totalReviews,
    this.categoryName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['service_id'] = Variable<String>(serviceId);
    map['provider_id'] = Variable<String>(providerId);
    map['category_id'] = Variable<String>(categoryId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['price'] = Variable<double>(price);
    map['unit_type'] = Variable<String>(unitType);
    if (!nullToAbsent || baseUnit != null) {
      map['base_unit'] = Variable<int>(baseUnit);
    }
    if (!nullToAbsent || images != null) {
      map['images'] = Variable<String>(images);
    }
    map['average_rating'] = Variable<double>(averageRating);
    map['total_reviews'] = Variable<int>(totalReviews);
    if (!nullToAbsent || categoryName != null) {
      map['category_name'] = Variable<String>(categoryName);
    }
    return map;
  }

  ServicesCompanion toCompanion(bool nullToAbsent) {
    return ServicesCompanion(
      serviceId: Value(serviceId),
      providerId: Value(providerId),
      categoryId: Value(categoryId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      price: Value(price),
      unitType: Value(unitType),
      baseUnit: baseUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(baseUnit),
      images: images == null && nullToAbsent
          ? const Value.absent()
          : Value(images),
      averageRating: Value(averageRating),
      totalReviews: Value(totalReviews),
      categoryName: categoryName == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryName),
    );
  }

  factory ServiceEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServiceEntity(
      serviceId: serializer.fromJson<String>(json['serviceId']),
      providerId: serializer.fromJson<String>(json['providerId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      price: serializer.fromJson<double>(json['price']),
      unitType: serializer.fromJson<String>(json['unitType']),
      baseUnit: serializer.fromJson<int?>(json['baseUnit']),
      images: serializer.fromJson<String?>(json['images']),
      averageRating: serializer.fromJson<double>(json['averageRating']),
      totalReviews: serializer.fromJson<int>(json['totalReviews']),
      categoryName: serializer.fromJson<String?>(json['categoryName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'serviceId': serializer.toJson<String>(serviceId),
      'providerId': serializer.toJson<String>(providerId),
      'categoryId': serializer.toJson<String>(categoryId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'price': serializer.toJson<double>(price),
      'unitType': serializer.toJson<String>(unitType),
      'baseUnit': serializer.toJson<int?>(baseUnit),
      'images': serializer.toJson<String?>(images),
      'averageRating': serializer.toJson<double>(averageRating),
      'totalReviews': serializer.toJson<int>(totalReviews),
      'categoryName': serializer.toJson<String?>(categoryName),
    };
  }

  ServiceEntity copyWith({
    String? serviceId,
    String? providerId,
    String? categoryId,
    String? title,
    Value<String?> description = const Value.absent(),
    double? price,
    String? unitType,
    Value<int?> baseUnit = const Value.absent(),
    Value<String?> images = const Value.absent(),
    double? averageRating,
    int? totalReviews,
    Value<String?> categoryName = const Value.absent(),
  }) => ServiceEntity(
    serviceId: serviceId ?? this.serviceId,
    providerId: providerId ?? this.providerId,
    categoryId: categoryId ?? this.categoryId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    price: price ?? this.price,
    unitType: unitType ?? this.unitType,
    baseUnit: baseUnit.present ? baseUnit.value : this.baseUnit,
    images: images.present ? images.value : this.images,
    averageRating: averageRating ?? this.averageRating,
    totalReviews: totalReviews ?? this.totalReviews,
    categoryName: categoryName.present ? categoryName.value : this.categoryName,
  );
  ServiceEntity copyWithCompanion(ServicesCompanion data) {
    return ServiceEntity(
      serviceId: data.serviceId.present ? data.serviceId.value : this.serviceId,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      price: data.price.present ? data.price.value : this.price,
      unitType: data.unitType.present ? data.unitType.value : this.unitType,
      baseUnit: data.baseUnit.present ? data.baseUnit.value : this.baseUnit,
      images: data.images.present ? data.images.value : this.images,
      averageRating: data.averageRating.present
          ? data.averageRating.value
          : this.averageRating,
      totalReviews: data.totalReviews.present
          ? data.totalReviews.value
          : this.totalReviews,
      categoryName: data.categoryName.present
          ? data.categoryName.value
          : this.categoryName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServiceEntity(')
          ..write('serviceId: $serviceId, ')
          ..write('providerId: $providerId, ')
          ..write('categoryId: $categoryId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('unitType: $unitType, ')
          ..write('baseUnit: $baseUnit, ')
          ..write('images: $images, ')
          ..write('averageRating: $averageRating, ')
          ..write('totalReviews: $totalReviews, ')
          ..write('categoryName: $categoryName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    serviceId,
    providerId,
    categoryId,
    title,
    description,
    price,
    unitType,
    baseUnit,
    images,
    averageRating,
    totalReviews,
    categoryName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceEntity &&
          other.serviceId == this.serviceId &&
          other.providerId == this.providerId &&
          other.categoryId == this.categoryId &&
          other.title == this.title &&
          other.description == this.description &&
          other.price == this.price &&
          other.unitType == this.unitType &&
          other.baseUnit == this.baseUnit &&
          other.images == this.images &&
          other.averageRating == this.averageRating &&
          other.totalReviews == this.totalReviews &&
          other.categoryName == this.categoryName);
}

class ServicesCompanion extends UpdateCompanion<ServiceEntity> {
  final Value<String> serviceId;
  final Value<String> providerId;
  final Value<String> categoryId;
  final Value<String> title;
  final Value<String?> description;
  final Value<double> price;
  final Value<String> unitType;
  final Value<int?> baseUnit;
  final Value<String?> images;
  final Value<double> averageRating;
  final Value<int> totalReviews;
  final Value<String?> categoryName;
  final Value<int> rowid;
  const ServicesCompanion({
    this.serviceId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.price = const Value.absent(),
    this.unitType = const Value.absent(),
    this.baseUnit = const Value.absent(),
    this.images = const Value.absent(),
    this.averageRating = const Value.absent(),
    this.totalReviews = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServicesCompanion.insert({
    required String serviceId,
    required String providerId,
    required String categoryId,
    required String title,
    this.description = const Value.absent(),
    required double price,
    required String unitType,
    this.baseUnit = const Value.absent(),
    this.images = const Value.absent(),
    this.averageRating = const Value.absent(),
    this.totalReviews = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : serviceId = Value(serviceId),
       providerId = Value(providerId),
       categoryId = Value(categoryId),
       title = Value(title),
       price = Value(price),
       unitType = Value(unitType);
  static Insertable<ServiceEntity> custom({
    Expression<String>? serviceId,
    Expression<String>? providerId,
    Expression<String>? categoryId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<double>? price,
    Expression<String>? unitType,
    Expression<int>? baseUnit,
    Expression<String>? images,
    Expression<double>? averageRating,
    Expression<int>? totalReviews,
    Expression<String>? categoryName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (serviceId != null) 'service_id': serviceId,
      if (providerId != null) 'provider_id': providerId,
      if (categoryId != null) 'category_id': categoryId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (unitType != null) 'unit_type': unitType,
      if (baseUnit != null) 'base_unit': baseUnit,
      if (images != null) 'images': images,
      if (averageRating != null) 'average_rating': averageRating,
      if (totalReviews != null) 'total_reviews': totalReviews,
      if (categoryName != null) 'category_name': categoryName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServicesCompanion copyWith({
    Value<String>? serviceId,
    Value<String>? providerId,
    Value<String>? categoryId,
    Value<String>? title,
    Value<String?>? description,
    Value<double>? price,
    Value<String>? unitType,
    Value<int?>? baseUnit,
    Value<String?>? images,
    Value<double>? averageRating,
    Value<int>? totalReviews,
    Value<String?>? categoryName,
    Value<int>? rowid,
  }) {
    return ServicesCompanion(
      serviceId: serviceId ?? this.serviceId,
      providerId: providerId ?? this.providerId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      unitType: unitType ?? this.unitType,
      baseUnit: baseUnit ?? this.baseUnit,
      images: images ?? this.images,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      categoryName: categoryName ?? this.categoryName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serviceId.present) {
      map['service_id'] = Variable<String>(serviceId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (unitType.present) {
      map['unit_type'] = Variable<String>(unitType.value);
    }
    if (baseUnit.present) {
      map['base_unit'] = Variable<int>(baseUnit.value);
    }
    if (images.present) {
      map['images'] = Variable<String>(images.value);
    }
    if (averageRating.present) {
      map['average_rating'] = Variable<double>(averageRating.value);
    }
    if (totalReviews.present) {
      map['total_reviews'] = Variable<int>(totalReviews.value);
    }
    if (categoryName.present) {
      map['category_name'] = Variable<String>(categoryName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServicesCompanion(')
          ..write('serviceId: $serviceId, ')
          ..write('providerId: $providerId, ')
          ..write('categoryId: $categoryId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('unitType: $unitType, ')
          ..write('baseUnit: $baseUnit, ')
          ..write('images: $images, ')
          ..write('averageRating: $averageRating, ')
          ..write('totalReviews: $totalReviews, ')
          ..write('categoryName: $categoryName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ServiceDatabase extends GeneratedDatabase {
  _$ServiceDatabase(QueryExecutor e) : super(e);
  $ServiceDatabaseManager get managers => $ServiceDatabaseManager(this);
  late final $ServicesTable services = $ServicesTable(this);
  late final ServiceDao serviceDao = ServiceDao(this as ServiceDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [services];
}

typedef $$ServicesTableCreateCompanionBuilder =
    ServicesCompanion Function({
      required String serviceId,
      required String providerId,
      required String categoryId,
      required String title,
      Value<String?> description,
      required double price,
      required String unitType,
      Value<int?> baseUnit,
      Value<String?> images,
      Value<double> averageRating,
      Value<int> totalReviews,
      Value<String?> categoryName,
      Value<int> rowid,
    });
typedef $$ServicesTableUpdateCompanionBuilder =
    ServicesCompanion Function({
      Value<String> serviceId,
      Value<String> providerId,
      Value<String> categoryId,
      Value<String> title,
      Value<String?> description,
      Value<double> price,
      Value<String> unitType,
      Value<int?> baseUnit,
      Value<String?> images,
      Value<double> averageRating,
      Value<int> totalReviews,
      Value<String?> categoryName,
      Value<int> rowid,
    });

class $$ServicesTableFilterComposer
    extends Composer<_$ServiceDatabase, $ServicesTable> {
  $$ServicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get serviceId => $composableBuilder(
    column: $table.serviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseUnit => $composableBuilder(
    column: $table.baseUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get images => $composableBuilder(
    column: $table.images,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageRating => $composableBuilder(
    column: $table.averageRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalReviews => $composableBuilder(
    column: $table.totalReviews,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ServicesTableOrderingComposer
    extends Composer<_$ServiceDatabase, $ServicesTable> {
  $$ServicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get serviceId => $composableBuilder(
    column: $table.serviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseUnit => $composableBuilder(
    column: $table.baseUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get images => $composableBuilder(
    column: $table.images,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageRating => $composableBuilder(
    column: $table.averageRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalReviews => $composableBuilder(
    column: $table.totalReviews,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ServicesTableAnnotationComposer
    extends Composer<_$ServiceDatabase, $ServicesTable> {
  $$ServicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get serviceId =>
      $composableBuilder(column: $table.serviceId, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get unitType =>
      $composableBuilder(column: $table.unitType, builder: (column) => column);

  GeneratedColumn<int> get baseUnit =>
      $composableBuilder(column: $table.baseUnit, builder: (column) => column);

  GeneratedColumn<String> get images =>
      $composableBuilder(column: $table.images, builder: (column) => column);

  GeneratedColumn<double> get averageRating => $composableBuilder(
    column: $table.averageRating,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalReviews => $composableBuilder(
    column: $table.totalReviews,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => column,
  );
}

class $$ServicesTableTableManager
    extends
        RootTableManager<
          _$ServiceDatabase,
          $ServicesTable,
          ServiceEntity,
          $$ServicesTableFilterComposer,
          $$ServicesTableOrderingComposer,
          $$ServicesTableAnnotationComposer,
          $$ServicesTableCreateCompanionBuilder,
          $$ServicesTableUpdateCompanionBuilder,
          (
            ServiceEntity,
            BaseReferences<_$ServiceDatabase, $ServicesTable, ServiceEntity>,
          ),
          ServiceEntity,
          PrefetchHooks Function()
        > {
  $$ServicesTableTableManager(_$ServiceDatabase db, $ServicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> serviceId = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<String> unitType = const Value.absent(),
                Value<int?> baseUnit = const Value.absent(),
                Value<String?> images = const Value.absent(),
                Value<double> averageRating = const Value.absent(),
                Value<int> totalReviews = const Value.absent(),
                Value<String?> categoryName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServicesCompanion(
                serviceId: serviceId,
                providerId: providerId,
                categoryId: categoryId,
                title: title,
                description: description,
                price: price,
                unitType: unitType,
                baseUnit: baseUnit,
                images: images,
                averageRating: averageRating,
                totalReviews: totalReviews,
                categoryName: categoryName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String serviceId,
                required String providerId,
                required String categoryId,
                required String title,
                Value<String?> description = const Value.absent(),
                required double price,
                required String unitType,
                Value<int?> baseUnit = const Value.absent(),
                Value<String?> images = const Value.absent(),
                Value<double> averageRating = const Value.absent(),
                Value<int> totalReviews = const Value.absent(),
                Value<String?> categoryName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServicesCompanion.insert(
                serviceId: serviceId,
                providerId: providerId,
                categoryId: categoryId,
                title: title,
                description: description,
                price: price,
                unitType: unitType,
                baseUnit: baseUnit,
                images: images,
                averageRating: averageRating,
                totalReviews: totalReviews,
                categoryName: categoryName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ServicesTableProcessedTableManager =
    ProcessedTableManager<
      _$ServiceDatabase,
      $ServicesTable,
      ServiceEntity,
      $$ServicesTableFilterComposer,
      $$ServicesTableOrderingComposer,
      $$ServicesTableAnnotationComposer,
      $$ServicesTableCreateCompanionBuilder,
      $$ServicesTableUpdateCompanionBuilder,
      (
        ServiceEntity,
        BaseReferences<_$ServiceDatabase, $ServicesTable, ServiceEntity>,
      ),
      ServiceEntity,
      PrefetchHooks Function()
    >;

class $ServiceDatabaseManager {
  final _$ServiceDatabase _db;
  $ServiceDatabaseManager(this._db);
  $$ServicesTableTableManager get services =>
      $$ServicesTableTableManager(_db, _db.services);
}
