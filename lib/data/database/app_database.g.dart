// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ServicesTableTable extends ServicesTable
    with TableInfo<$ServicesTableTable, ServicesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServicesTableTable(this.attachedDatabase, [this._alias]);
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _unitTypeMeta = const VerificationMeta(
    'unitType',
  );
  @override
  late final GeneratedColumn<String> unitType = GeneratedColumn<String>(
    'unit_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
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
  static const VerificationMeta _providerNameMeta = const VerificationMeta(
    'providerName',
  );
  @override
  late final GeneratedColumn<String> providerName = GeneratedColumn<String>(
    'provider_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jsonOptionsMeta = const VerificationMeta(
    'jsonOptions',
  );
  @override
  late final GeneratedColumn<String> jsonOptions = GeneratedColumn<String>(
    'json_options',
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
    createdAt,
    status,
    deleted,
    averageRating,
    totalReviews,
    categoryName,
    providerName,
    jsonOptions,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'services_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServicesTableData> instance, {
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
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
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
    }
    if (data.containsKey('unit_type')) {
      context.handle(
        _unitTypeMeta,
        unitType.isAcceptableOrUnknown(data['unit_type']!, _unitTypeMeta),
      );
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
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
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
    if (data.containsKey('provider_name')) {
      context.handle(
        _providerNameMeta,
        providerName.isAcceptableOrUnknown(
          data['provider_name']!,
          _providerNameMeta,
        ),
      );
    }
    if (data.containsKey('json_options')) {
      context.handle(
        _jsonOptionsMeta,
        jsonOptions.isAcceptableOrUnknown(
          data['json_options']!,
          _jsonOptionsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {serviceId};
  @override
  ServicesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServicesTableData(
      serviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
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
      ),
      baseUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_unit'],
      ),
      images: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}images'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
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
      providerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_name'],
      ),
      jsonOptions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json_options'],
      ),
    );
  }

  @override
  $ServicesTableTable createAlias(String alias) {
    return $ServicesTableTable(attachedDatabase, alias);
  }
}

class ServicesTableData extends DataClass
    implements Insertable<ServicesTableData> {
  final String serviceId;
  final String? providerId;
  final String? categoryId;
  final String title;
  final String? description;
  final double price;
  final String? unitType;
  final int? baseUnit;
  final String? images;
  final DateTime? createdAt;
  final String? status;
  final bool? deleted;
  final double averageRating;
  final int totalReviews;
  final String? categoryName;
  final String? providerName;
  final String? jsonOptions;
  const ServicesTableData({
    required this.serviceId,
    this.providerId,
    this.categoryId,
    required this.title,
    this.description,
    required this.price,
    this.unitType,
    this.baseUnit,
    this.images,
    this.createdAt,
    this.status,
    this.deleted,
    required this.averageRating,
    required this.totalReviews,
    this.categoryName,
    this.providerName,
    this.jsonOptions,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['service_id'] = Variable<String>(serviceId);
    if (!nullToAbsent || providerId != null) {
      map['provider_id'] = Variable<String>(providerId);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['price'] = Variable<double>(price);
    if (!nullToAbsent || unitType != null) {
      map['unit_type'] = Variable<String>(unitType);
    }
    if (!nullToAbsent || baseUnit != null) {
      map['base_unit'] = Variable<int>(baseUnit);
    }
    if (!nullToAbsent || images != null) {
      map['images'] = Variable<String>(images);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || deleted != null) {
      map['deleted'] = Variable<bool>(deleted);
    }
    map['average_rating'] = Variable<double>(averageRating);
    map['total_reviews'] = Variable<int>(totalReviews);
    if (!nullToAbsent || categoryName != null) {
      map['category_name'] = Variable<String>(categoryName);
    }
    if (!nullToAbsent || providerName != null) {
      map['provider_name'] = Variable<String>(providerName);
    }
    if (!nullToAbsent || jsonOptions != null) {
      map['json_options'] = Variable<String>(jsonOptions);
    }
    return map;
  }

  ServicesTableCompanion toCompanion(bool nullToAbsent) {
    return ServicesTableCompanion(
      serviceId: Value(serviceId),
      providerId: providerId == null && nullToAbsent
          ? const Value.absent()
          : Value(providerId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      price: Value(price),
      unitType: unitType == null && nullToAbsent
          ? const Value.absent()
          : Value(unitType),
      baseUnit: baseUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(baseUnit),
      images: images == null && nullToAbsent
          ? const Value.absent()
          : Value(images),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      deleted: deleted == null && nullToAbsent
          ? const Value.absent()
          : Value(deleted),
      averageRating: Value(averageRating),
      totalReviews: Value(totalReviews),
      categoryName: categoryName == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryName),
      providerName: providerName == null && nullToAbsent
          ? const Value.absent()
          : Value(providerName),
      jsonOptions: jsonOptions == null && nullToAbsent
          ? const Value.absent()
          : Value(jsonOptions),
    );
  }

  factory ServicesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServicesTableData(
      serviceId: serializer.fromJson<String>(json['serviceId']),
      providerId: serializer.fromJson<String?>(json['providerId']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      price: serializer.fromJson<double>(json['price']),
      unitType: serializer.fromJson<String?>(json['unitType']),
      baseUnit: serializer.fromJson<int?>(json['baseUnit']),
      images: serializer.fromJson<String?>(json['images']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      status: serializer.fromJson<String?>(json['status']),
      deleted: serializer.fromJson<bool?>(json['deleted']),
      averageRating: serializer.fromJson<double>(json['averageRating']),
      totalReviews: serializer.fromJson<int>(json['totalReviews']),
      categoryName: serializer.fromJson<String?>(json['categoryName']),
      providerName: serializer.fromJson<String?>(json['providerName']),
      jsonOptions: serializer.fromJson<String?>(json['jsonOptions']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'serviceId': serializer.toJson<String>(serviceId),
      'providerId': serializer.toJson<String?>(providerId),
      'categoryId': serializer.toJson<String?>(categoryId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'price': serializer.toJson<double>(price),
      'unitType': serializer.toJson<String?>(unitType),
      'baseUnit': serializer.toJson<int?>(baseUnit),
      'images': serializer.toJson<String?>(images),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'status': serializer.toJson<String?>(status),
      'deleted': serializer.toJson<bool?>(deleted),
      'averageRating': serializer.toJson<double>(averageRating),
      'totalReviews': serializer.toJson<int>(totalReviews),
      'categoryName': serializer.toJson<String?>(categoryName),
      'providerName': serializer.toJson<String?>(providerName),
      'jsonOptions': serializer.toJson<String?>(jsonOptions),
    };
  }

  ServicesTableData copyWith({
    String? serviceId,
    Value<String?> providerId = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    String? title,
    Value<String?> description = const Value.absent(),
    double? price,
    Value<String?> unitType = const Value.absent(),
    Value<int?> baseUnit = const Value.absent(),
    Value<String?> images = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<String?> status = const Value.absent(),
    Value<bool?> deleted = const Value.absent(),
    double? averageRating,
    int? totalReviews,
    Value<String?> categoryName = const Value.absent(),
    Value<String?> providerName = const Value.absent(),
    Value<String?> jsonOptions = const Value.absent(),
  }) => ServicesTableData(
    serviceId: serviceId ?? this.serviceId,
    providerId: providerId.present ? providerId.value : this.providerId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    price: price ?? this.price,
    unitType: unitType.present ? unitType.value : this.unitType,
    baseUnit: baseUnit.present ? baseUnit.value : this.baseUnit,
    images: images.present ? images.value : this.images,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    status: status.present ? status.value : this.status,
    deleted: deleted.present ? deleted.value : this.deleted,
    averageRating: averageRating ?? this.averageRating,
    totalReviews: totalReviews ?? this.totalReviews,
    categoryName: categoryName.present ? categoryName.value : this.categoryName,
    providerName: providerName.present ? providerName.value : this.providerName,
    jsonOptions: jsonOptions.present ? jsonOptions.value : this.jsonOptions,
  );
  ServicesTableData copyWithCompanion(ServicesTableCompanion data) {
    return ServicesTableData(
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
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      status: data.status.present ? data.status.value : this.status,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      averageRating: data.averageRating.present
          ? data.averageRating.value
          : this.averageRating,
      totalReviews: data.totalReviews.present
          ? data.totalReviews.value
          : this.totalReviews,
      categoryName: data.categoryName.present
          ? data.categoryName.value
          : this.categoryName,
      providerName: data.providerName.present
          ? data.providerName.value
          : this.providerName,
      jsonOptions: data.jsonOptions.present
          ? data.jsonOptions.value
          : this.jsonOptions,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServicesTableData(')
          ..write('serviceId: $serviceId, ')
          ..write('providerId: $providerId, ')
          ..write('categoryId: $categoryId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('unitType: $unitType, ')
          ..write('baseUnit: $baseUnit, ')
          ..write('images: $images, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status, ')
          ..write('deleted: $deleted, ')
          ..write('averageRating: $averageRating, ')
          ..write('totalReviews: $totalReviews, ')
          ..write('categoryName: $categoryName, ')
          ..write('providerName: $providerName, ')
          ..write('jsonOptions: $jsonOptions')
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
    createdAt,
    status,
    deleted,
    averageRating,
    totalReviews,
    categoryName,
    providerName,
    jsonOptions,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServicesTableData &&
          other.serviceId == this.serviceId &&
          other.providerId == this.providerId &&
          other.categoryId == this.categoryId &&
          other.title == this.title &&
          other.description == this.description &&
          other.price == this.price &&
          other.unitType == this.unitType &&
          other.baseUnit == this.baseUnit &&
          other.images == this.images &&
          other.createdAt == this.createdAt &&
          other.status == this.status &&
          other.deleted == this.deleted &&
          other.averageRating == this.averageRating &&
          other.totalReviews == this.totalReviews &&
          other.categoryName == this.categoryName &&
          other.providerName == this.providerName &&
          other.jsonOptions == this.jsonOptions);
}

class ServicesTableCompanion extends UpdateCompanion<ServicesTableData> {
  final Value<String> serviceId;
  final Value<String?> providerId;
  final Value<String?> categoryId;
  final Value<String> title;
  final Value<String?> description;
  final Value<double> price;
  final Value<String?> unitType;
  final Value<int?> baseUnit;
  final Value<String?> images;
  final Value<DateTime?> createdAt;
  final Value<String?> status;
  final Value<bool?> deleted;
  final Value<double> averageRating;
  final Value<int> totalReviews;
  final Value<String?> categoryName;
  final Value<String?> providerName;
  final Value<String?> jsonOptions;
  final Value<int> rowid;
  const ServicesTableCompanion({
    this.serviceId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.price = const Value.absent(),
    this.unitType = const Value.absent(),
    this.baseUnit = const Value.absent(),
    this.images = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.status = const Value.absent(),
    this.deleted = const Value.absent(),
    this.averageRating = const Value.absent(),
    this.totalReviews = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.providerName = const Value.absent(),
    this.jsonOptions = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServicesTableCompanion.insert({
    required String serviceId,
    this.providerId = const Value.absent(),
    this.categoryId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.price = const Value.absent(),
    this.unitType = const Value.absent(),
    this.baseUnit = const Value.absent(),
    this.images = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.status = const Value.absent(),
    this.deleted = const Value.absent(),
    this.averageRating = const Value.absent(),
    this.totalReviews = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.providerName = const Value.absent(),
    this.jsonOptions = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : serviceId = Value(serviceId),
       title = Value(title);
  static Insertable<ServicesTableData> custom({
    Expression<String>? serviceId,
    Expression<String>? providerId,
    Expression<String>? categoryId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<double>? price,
    Expression<String>? unitType,
    Expression<int>? baseUnit,
    Expression<String>? images,
    Expression<DateTime>? createdAt,
    Expression<String>? status,
    Expression<bool>? deleted,
    Expression<double>? averageRating,
    Expression<int>? totalReviews,
    Expression<String>? categoryName,
    Expression<String>? providerName,
    Expression<String>? jsonOptions,
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
      if (createdAt != null) 'created_at': createdAt,
      if (status != null) 'status': status,
      if (deleted != null) 'deleted': deleted,
      if (averageRating != null) 'average_rating': averageRating,
      if (totalReviews != null) 'total_reviews': totalReviews,
      if (categoryName != null) 'category_name': categoryName,
      if (providerName != null) 'provider_name': providerName,
      if (jsonOptions != null) 'json_options': jsonOptions,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServicesTableCompanion copyWith({
    Value<String>? serviceId,
    Value<String?>? providerId,
    Value<String?>? categoryId,
    Value<String>? title,
    Value<String?>? description,
    Value<double>? price,
    Value<String?>? unitType,
    Value<int?>? baseUnit,
    Value<String?>? images,
    Value<DateTime?>? createdAt,
    Value<String?>? status,
    Value<bool?>? deleted,
    Value<double>? averageRating,
    Value<int>? totalReviews,
    Value<String?>? categoryName,
    Value<String?>? providerName,
    Value<String?>? jsonOptions,
    Value<int>? rowid,
  }) {
    return ServicesTableCompanion(
      serviceId: serviceId ?? this.serviceId,
      providerId: providerId ?? this.providerId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      unitType: unitType ?? this.unitType,
      baseUnit: baseUnit ?? this.baseUnit,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      deleted: deleted ?? this.deleted,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      categoryName: categoryName ?? this.categoryName,
      providerName: providerName ?? this.providerName,
      jsonOptions: jsonOptions ?? this.jsonOptions,
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
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
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
    if (providerName.present) {
      map['provider_name'] = Variable<String>(providerName.value);
    }
    if (jsonOptions.present) {
      map['json_options'] = Variable<String>(jsonOptions.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServicesTableCompanion(')
          ..write('serviceId: $serviceId, ')
          ..write('providerId: $providerId, ')
          ..write('categoryId: $categoryId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('unitType: $unitType, ')
          ..write('baseUnit: $baseUnit, ')
          ..write('images: $images, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status, ')
          ..write('deleted: $deleted, ')
          ..write('averageRating: $averageRating, ')
          ..write('totalReviews: $totalReviews, ')
          ..write('categoryName: $categoryName, ')
          ..write('providerName: $providerName, ')
          ..write('jsonOptions: $jsonOptions, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuthsTableTable extends AuthsTable
    with TableInfo<$AuthsTableTable, AuthsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuthsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => 'auth',
  );
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
    'token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, token, role, accountId, savedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'auths_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuthsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('token')) {
      context.handle(
        _tokenMeta,
        token.isAcceptableOrUnknown(data['token']!, _tokenMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuthsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuthsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      token: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      ),
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      ),
    );
  }

  @override
  $AuthsTableTable createAlias(String alias) {
    return $AuthsTableTable(attachedDatabase, alias);
  }
}

class AuthsTableData extends DataClass implements Insertable<AuthsTableData> {
  final String id;
  final String? token;
  final String? role;
  final String? accountId;
  final DateTime? savedAt;
  const AuthsTableData({
    required this.id,
    this.token,
    this.role,
    this.accountId,
    this.savedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || token != null) {
      map['token'] = Variable<String>(token);
    }
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    if (!nullToAbsent || savedAt != null) {
      map['saved_at'] = Variable<DateTime>(savedAt);
    }
    return map;
  }

  AuthsTableCompanion toCompanion(bool nullToAbsent) {
    return AuthsTableCompanion(
      id: Value(id),
      token: token == null && nullToAbsent
          ? const Value.absent()
          : Value(token),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      savedAt: savedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(savedAt),
    );
  }

  factory AuthsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuthsTableData(
      id: serializer.fromJson<String>(json['id']),
      token: serializer.fromJson<String?>(json['token']),
      role: serializer.fromJson<String?>(json['role']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      savedAt: serializer.fromJson<DateTime?>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'token': serializer.toJson<String?>(token),
      'role': serializer.toJson<String?>(role),
      'accountId': serializer.toJson<String?>(accountId),
      'savedAt': serializer.toJson<DateTime?>(savedAt),
    };
  }

  AuthsTableData copyWith({
    String? id,
    Value<String?> token = const Value.absent(),
    Value<String?> role = const Value.absent(),
    Value<String?> accountId = const Value.absent(),
    Value<DateTime?> savedAt = const Value.absent(),
  }) => AuthsTableData(
    id: id ?? this.id,
    token: token.present ? token.value : this.token,
    role: role.present ? role.value : this.role,
    accountId: accountId.present ? accountId.value : this.accountId,
    savedAt: savedAt.present ? savedAt.value : this.savedAt,
  );
  AuthsTableData copyWithCompanion(AuthsTableCompanion data) {
    return AuthsTableData(
      id: data.id.present ? data.id.value : this.id,
      token: data.token.present ? data.token.value : this.token,
      role: data.role.present ? data.role.value : this.role,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuthsTableData(')
          ..write('id: $id, ')
          ..write('token: $token, ')
          ..write('role: $role, ')
          ..write('accountId: $accountId, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, token, role, accountId, savedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthsTableData &&
          other.id == this.id &&
          other.token == this.token &&
          other.role == this.role &&
          other.accountId == this.accountId &&
          other.savedAt == this.savedAt);
}

class AuthsTableCompanion extends UpdateCompanion<AuthsTableData> {
  final Value<String> id;
  final Value<String?> token;
  final Value<String?> role;
  final Value<String?> accountId;
  final Value<DateTime?> savedAt;
  final Value<int> rowid;
  const AuthsTableCompanion({
    this.id = const Value.absent(),
    this.token = const Value.absent(),
    this.role = const Value.absent(),
    this.accountId = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuthsTableCompanion.insert({
    this.id = const Value.absent(),
    this.token = const Value.absent(),
    this.role = const Value.absent(),
    this.accountId = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<AuthsTableData> custom({
    Expression<String>? id,
    Expression<String>? token,
    Expression<String>? role,
    Expression<String>? accountId,
    Expression<DateTime>? savedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (token != null) 'token': token,
      if (role != null) 'role': role,
      if (accountId != null) 'account_id': accountId,
      if (savedAt != null) 'saved_at': savedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuthsTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? token,
    Value<String?>? role,
    Value<String?>? accountId,
    Value<DateTime?>? savedAt,
    Value<int>? rowid,
  }) {
    return AuthsTableCompanion(
      id: id ?? this.id,
      token: token ?? this.token,
      role: role ?? this.role,
      accountId: accountId ?? this.accountId,
      savedAt: savedAt ?? this.savedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuthsTableCompanion(')
          ..write('id: $id, ')
          ..write('token: $token, ')
          ..write('role: $role, ')
          ..write('accountId: $accountId, ')
          ..write('savedAt: $savedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfileTableTable extends ProfileTable
    with TableInfo<$ProfileTableTable, ProfileTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountNameMeta = const VerificationMeta(
    'accountName',
  );
  @override
  late final GeneratedColumn<String> accountName = GeneratedColumn<String>(
    'account_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    accountId,
    accountName,
    email,
    role,
    fullName,
    phoneNumber,
    images,
    address,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('account_name')) {
      context.handle(
        _accountNameMeta,
        accountName.isAcceptableOrUnknown(
          data['account_name']!,
          _accountNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accountNameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    }
    if (data.containsKey('images')) {
      context.handle(
        _imagesMeta,
        images.isAcceptableOrUnknown(data['images']!, _imagesMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  ProfileTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileTableData(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      accountName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      ),
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      ),
      images: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}images'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
    );
  }

  @override
  $ProfileTableTable createAlias(String alias) {
    return $ProfileTableTable(attachedDatabase, alias);
  }
}

class ProfileTableData extends DataClass
    implements Insertable<ProfileTableData> {
  final String userId;
  final String accountId;
  final String accountName;
  final String email;
  final String role;
  final String? fullName;
  final String? phoneNumber;
  final String? images;
  final String? address;
  const ProfileTableData({
    required this.userId,
    required this.accountId,
    required this.accountName,
    required this.email,
    required this.role,
    this.fullName,
    this.phoneNumber,
    this.images,
    this.address,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['account_id'] = Variable<String>(accountId);
    map['account_name'] = Variable<String>(accountName);
    map['email'] = Variable<String>(email);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || fullName != null) {
      map['full_name'] = Variable<String>(fullName);
    }
    if (!nullToAbsent || phoneNumber != null) {
      map['phone_number'] = Variable<String>(phoneNumber);
    }
    if (!nullToAbsent || images != null) {
      map['images'] = Variable<String>(images);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    return map;
  }

  ProfileTableCompanion toCompanion(bool nullToAbsent) {
    return ProfileTableCompanion(
      userId: Value(userId),
      accountId: Value(accountId),
      accountName: Value(accountName),
      email: Value(email),
      role: Value(role),
      fullName: fullName == null && nullToAbsent
          ? const Value.absent()
          : Value(fullName),
      phoneNumber: phoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneNumber),
      images: images == null && nullToAbsent
          ? const Value.absent()
          : Value(images),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
    );
  }

  factory ProfileTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileTableData(
      userId: serializer.fromJson<String>(json['userId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      accountName: serializer.fromJson<String>(json['accountName']),
      email: serializer.fromJson<String>(json['email']),
      role: serializer.fromJson<String>(json['role']),
      fullName: serializer.fromJson<String?>(json['fullName']),
      phoneNumber: serializer.fromJson<String?>(json['phoneNumber']),
      images: serializer.fromJson<String?>(json['images']),
      address: serializer.fromJson<String?>(json['address']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'accountId': serializer.toJson<String>(accountId),
      'accountName': serializer.toJson<String>(accountName),
      'email': serializer.toJson<String>(email),
      'role': serializer.toJson<String>(role),
      'fullName': serializer.toJson<String?>(fullName),
      'phoneNumber': serializer.toJson<String?>(phoneNumber),
      'images': serializer.toJson<String?>(images),
      'address': serializer.toJson<String?>(address),
    };
  }

  ProfileTableData copyWith({
    String? userId,
    String? accountId,
    String? accountName,
    String? email,
    String? role,
    Value<String?> fullName = const Value.absent(),
    Value<String?> phoneNumber = const Value.absent(),
    Value<String?> images = const Value.absent(),
    Value<String?> address = const Value.absent(),
  }) => ProfileTableData(
    userId: userId ?? this.userId,
    accountId: accountId ?? this.accountId,
    accountName: accountName ?? this.accountName,
    email: email ?? this.email,
    role: role ?? this.role,
    fullName: fullName.present ? fullName.value : this.fullName,
    phoneNumber: phoneNumber.present ? phoneNumber.value : this.phoneNumber,
    images: images.present ? images.value : this.images,
    address: address.present ? address.value : this.address,
  );
  ProfileTableData copyWithCompanion(ProfileTableCompanion data) {
    return ProfileTableData(
      userId: data.userId.present ? data.userId.value : this.userId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      accountName: data.accountName.present
          ? data.accountName.value
          : this.accountName,
      email: data.email.present ? data.email.value : this.email,
      role: data.role.present ? data.role.value : this.role,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      images: data.images.present ? data.images.value : this.images,
      address: data.address.present ? data.address.value : this.address,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileTableData(')
          ..write('userId: $userId, ')
          ..write('accountId: $accountId, ')
          ..write('accountName: $accountName, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('fullName: $fullName, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('images: $images, ')
          ..write('address: $address')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    accountId,
    accountName,
    email,
    role,
    fullName,
    phoneNumber,
    images,
    address,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileTableData &&
          other.userId == this.userId &&
          other.accountId == this.accountId &&
          other.accountName == this.accountName &&
          other.email == this.email &&
          other.role == this.role &&
          other.fullName == this.fullName &&
          other.phoneNumber == this.phoneNumber &&
          other.images == this.images &&
          other.address == this.address);
}

class ProfileTableCompanion extends UpdateCompanion<ProfileTableData> {
  final Value<String> userId;
  final Value<String> accountId;
  final Value<String> accountName;
  final Value<String> email;
  final Value<String> role;
  final Value<String?> fullName;
  final Value<String?> phoneNumber;
  final Value<String?> images;
  final Value<String?> address;
  final Value<int> rowid;
  const ProfileTableCompanion({
    this.userId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.accountName = const Value.absent(),
    this.email = const Value.absent(),
    this.role = const Value.absent(),
    this.fullName = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.images = const Value.absent(),
    this.address = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfileTableCompanion.insert({
    required String userId,
    required String accountId,
    required String accountName,
    required String email,
    required String role,
    this.fullName = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.images = const Value.absent(),
    this.address = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       accountId = Value(accountId),
       accountName = Value(accountName),
       email = Value(email),
       role = Value(role);
  static Insertable<ProfileTableData> custom({
    Expression<String>? userId,
    Expression<String>? accountId,
    Expression<String>? accountName,
    Expression<String>? email,
    Expression<String>? role,
    Expression<String>? fullName,
    Expression<String>? phoneNumber,
    Expression<String>? images,
    Expression<String>? address,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (accountId != null) 'account_id': accountId,
      if (accountName != null) 'account_name': accountName,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
      if (fullName != null) 'full_name': fullName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (images != null) 'images': images,
      if (address != null) 'address': address,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfileTableCompanion copyWith({
    Value<String>? userId,
    Value<String>? accountId,
    Value<String>? accountName,
    Value<String>? email,
    Value<String>? role,
    Value<String?>? fullName,
    Value<String?>? phoneNumber,
    Value<String?>? images,
    Value<String?>? address,
    Value<int>? rowid,
  }) {
    return ProfileTableCompanion(
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
      email: email ?? this.email,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      images: images ?? this.images,
      address: address ?? this.address,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (accountName.present) {
      map['account_name'] = Variable<String>(accountName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (images.present) {
      map['images'] = Variable<String>(images.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileTableCompanion(')
          ..write('userId: $userId, ')
          ..write('accountId: $accountId, ')
          ..write('accountName: $accountName, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('fullName: $fullName, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('images: $images, ')
          ..write('address: $address, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserAddressTableTable extends UserAddressTable
    with TableInfo<$UserAddressTableTable, UserAddressTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserAddressTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _addressIdMeta = const VerificationMeta(
    'addressId',
  );
  @override
  late final GeneratedColumn<String> addressId = GeneratedColumn<String>(
    'address_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _provinceNameMeta = const VerificationMeta(
    'provinceName',
  );
  @override
  late final GeneratedColumn<String> provinceName = GeneratedColumn<String>(
    'province_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _districtNameMeta = const VerificationMeta(
    'districtName',
  );
  @override
  late final GeneratedColumn<String> districtName = GeneratedColumn<String>(
    'district_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wardNameMeta = const VerificationMeta(
    'wardName',
  );
  @override
  late final GeneratedColumn<String> wardName = GeneratedColumn<String>(
    'ward_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _streetAddressMeta = const VerificationMeta(
    'streetAddress',
  );
  @override
  late final GeneratedColumn<String> streetAddress = GeneratedColumn<String>(
    'street_address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipientNameMeta = const VerificationMeta(
    'recipientName',
  );
  @override
  late final GeneratedColumn<String> recipientName = GeneratedColumn<String>(
    'recipient_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recipientPhoneMeta = const VerificationMeta(
    'recipientPhone',
  );
  @override
  late final GeneratedColumn<String> recipientPhone = GeneratedColumn<String>(
    'recipient_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fullAddressMeta = const VerificationMeta(
    'fullAddress',
  );
  @override
  late final GeneratedColumn<String> fullAddress = GeneratedColumn<String>(
    'full_address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    addressId,
    provinceName,
    districtName,
    wardName,
    streetAddress,
    recipientName,
    recipientPhone,
    latitude,
    longitude,
    createdAt,
    fullAddress,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_address_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserAddressTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('address_id')) {
      context.handle(
        _addressIdMeta,
        addressId.isAcceptableOrUnknown(data['address_id']!, _addressIdMeta),
      );
    } else if (isInserting) {
      context.missing(_addressIdMeta);
    }
    if (data.containsKey('province_name')) {
      context.handle(
        _provinceNameMeta,
        provinceName.isAcceptableOrUnknown(
          data['province_name']!,
          _provinceNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_provinceNameMeta);
    }
    if (data.containsKey('district_name')) {
      context.handle(
        _districtNameMeta,
        districtName.isAcceptableOrUnknown(
          data['district_name']!,
          _districtNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_districtNameMeta);
    }
    if (data.containsKey('ward_name')) {
      context.handle(
        _wardNameMeta,
        wardName.isAcceptableOrUnknown(data['ward_name']!, _wardNameMeta),
      );
    } else if (isInserting) {
      context.missing(_wardNameMeta);
    }
    if (data.containsKey('street_address')) {
      context.handle(
        _streetAddressMeta,
        streetAddress.isAcceptableOrUnknown(
          data['street_address']!,
          _streetAddressMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_streetAddressMeta);
    }
    if (data.containsKey('recipient_name')) {
      context.handle(
        _recipientNameMeta,
        recipientName.isAcceptableOrUnknown(
          data['recipient_name']!,
          _recipientNameMeta,
        ),
      );
    }
    if (data.containsKey('recipient_phone')) {
      context.handle(
        _recipientPhoneMeta,
        recipientPhone.isAcceptableOrUnknown(
          data['recipient_phone']!,
          _recipientPhoneMeta,
        ),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('full_address')) {
      context.handle(
        _fullAddressMeta,
        fullAddress.isAcceptableOrUnknown(
          data['full_address']!,
          _fullAddressMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fullAddressMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {addressId};
  @override
  UserAddressTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserAddressTableData(
      addressId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_id'],
      )!,
      provinceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}province_name'],
      )!,
      districtName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}district_name'],
      )!,
      wardName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ward_name'],
      )!,
      streetAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}street_address'],
      )!,
      recipientName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipient_name'],
      ),
      recipientPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipient_phone'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      fullAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_address'],
      )!,
    );
  }

  @override
  $UserAddressTableTable createAlias(String alias) {
    return $UserAddressTableTable(attachedDatabase, alias);
  }
}

class UserAddressTableData extends DataClass
    implements Insertable<UserAddressTableData> {
  final String addressId;
  final String provinceName;
  final String districtName;
  final String wardName;
  final String streetAddress;
  final String? recipientName;
  final String? recipientPhone;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final String fullAddress;
  const UserAddressTableData({
    required this.addressId,
    required this.provinceName,
    required this.districtName,
    required this.wardName,
    required this.streetAddress,
    this.recipientName,
    this.recipientPhone,
    this.latitude,
    this.longitude,
    this.createdAt,
    required this.fullAddress,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['address_id'] = Variable<String>(addressId);
    map['province_name'] = Variable<String>(provinceName);
    map['district_name'] = Variable<String>(districtName);
    map['ward_name'] = Variable<String>(wardName);
    map['street_address'] = Variable<String>(streetAddress);
    if (!nullToAbsent || recipientName != null) {
      map['recipient_name'] = Variable<String>(recipientName);
    }
    if (!nullToAbsent || recipientPhone != null) {
      map['recipient_phone'] = Variable<String>(recipientPhone);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['full_address'] = Variable<String>(fullAddress);
    return map;
  }

  UserAddressTableCompanion toCompanion(bool nullToAbsent) {
    return UserAddressTableCompanion(
      addressId: Value(addressId),
      provinceName: Value(provinceName),
      districtName: Value(districtName),
      wardName: Value(wardName),
      streetAddress: Value(streetAddress),
      recipientName: recipientName == null && nullToAbsent
          ? const Value.absent()
          : Value(recipientName),
      recipientPhone: recipientPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(recipientPhone),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      fullAddress: Value(fullAddress),
    );
  }

  factory UserAddressTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserAddressTableData(
      addressId: serializer.fromJson<String>(json['addressId']),
      provinceName: serializer.fromJson<String>(json['provinceName']),
      districtName: serializer.fromJson<String>(json['districtName']),
      wardName: serializer.fromJson<String>(json['wardName']),
      streetAddress: serializer.fromJson<String>(json['streetAddress']),
      recipientName: serializer.fromJson<String?>(json['recipientName']),
      recipientPhone: serializer.fromJson<String?>(json['recipientPhone']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      fullAddress: serializer.fromJson<String>(json['fullAddress']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'addressId': serializer.toJson<String>(addressId),
      'provinceName': serializer.toJson<String>(provinceName),
      'districtName': serializer.toJson<String>(districtName),
      'wardName': serializer.toJson<String>(wardName),
      'streetAddress': serializer.toJson<String>(streetAddress),
      'recipientName': serializer.toJson<String?>(recipientName),
      'recipientPhone': serializer.toJson<String?>(recipientPhone),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'fullAddress': serializer.toJson<String>(fullAddress),
    };
  }

  UserAddressTableData copyWith({
    String? addressId,
    String? provinceName,
    String? districtName,
    String? wardName,
    String? streetAddress,
    Value<String?> recipientName = const Value.absent(),
    Value<String?> recipientPhone = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    String? fullAddress,
  }) => UserAddressTableData(
    addressId: addressId ?? this.addressId,
    provinceName: provinceName ?? this.provinceName,
    districtName: districtName ?? this.districtName,
    wardName: wardName ?? this.wardName,
    streetAddress: streetAddress ?? this.streetAddress,
    recipientName: recipientName.present
        ? recipientName.value
        : this.recipientName,
    recipientPhone: recipientPhone.present
        ? recipientPhone.value
        : this.recipientPhone,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    fullAddress: fullAddress ?? this.fullAddress,
  );
  UserAddressTableData copyWithCompanion(UserAddressTableCompanion data) {
    return UserAddressTableData(
      addressId: data.addressId.present ? data.addressId.value : this.addressId,
      provinceName: data.provinceName.present
          ? data.provinceName.value
          : this.provinceName,
      districtName: data.districtName.present
          ? data.districtName.value
          : this.districtName,
      wardName: data.wardName.present ? data.wardName.value : this.wardName,
      streetAddress: data.streetAddress.present
          ? data.streetAddress.value
          : this.streetAddress,
      recipientName: data.recipientName.present
          ? data.recipientName.value
          : this.recipientName,
      recipientPhone: data.recipientPhone.present
          ? data.recipientPhone.value
          : this.recipientPhone,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      fullAddress: data.fullAddress.present
          ? data.fullAddress.value
          : this.fullAddress,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserAddressTableData(')
          ..write('addressId: $addressId, ')
          ..write('provinceName: $provinceName, ')
          ..write('districtName: $districtName, ')
          ..write('wardName: $wardName, ')
          ..write('streetAddress: $streetAddress, ')
          ..write('recipientName: $recipientName, ')
          ..write('recipientPhone: $recipientPhone, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('createdAt: $createdAt, ')
          ..write('fullAddress: $fullAddress')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    addressId,
    provinceName,
    districtName,
    wardName,
    streetAddress,
    recipientName,
    recipientPhone,
    latitude,
    longitude,
    createdAt,
    fullAddress,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserAddressTableData &&
          other.addressId == this.addressId &&
          other.provinceName == this.provinceName &&
          other.districtName == this.districtName &&
          other.wardName == this.wardName &&
          other.streetAddress == this.streetAddress &&
          other.recipientName == this.recipientName &&
          other.recipientPhone == this.recipientPhone &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.createdAt == this.createdAt &&
          other.fullAddress == this.fullAddress);
}

class UserAddressTableCompanion extends UpdateCompanion<UserAddressTableData> {
  final Value<String> addressId;
  final Value<String> provinceName;
  final Value<String> districtName;
  final Value<String> wardName;
  final Value<String> streetAddress;
  final Value<String?> recipientName;
  final Value<String?> recipientPhone;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<DateTime?> createdAt;
  final Value<String> fullAddress;
  final Value<int> rowid;
  const UserAddressTableCompanion({
    this.addressId = const Value.absent(),
    this.provinceName = const Value.absent(),
    this.districtName = const Value.absent(),
    this.wardName = const Value.absent(),
    this.streetAddress = const Value.absent(),
    this.recipientName = const Value.absent(),
    this.recipientPhone = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.fullAddress = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserAddressTableCompanion.insert({
    required String addressId,
    required String provinceName,
    required String districtName,
    required String wardName,
    required String streetAddress,
    this.recipientName = const Value.absent(),
    this.recipientPhone = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String fullAddress,
    this.rowid = const Value.absent(),
  }) : addressId = Value(addressId),
       provinceName = Value(provinceName),
       districtName = Value(districtName),
       wardName = Value(wardName),
       streetAddress = Value(streetAddress),
       fullAddress = Value(fullAddress);
  static Insertable<UserAddressTableData> custom({
    Expression<String>? addressId,
    Expression<String>? provinceName,
    Expression<String>? districtName,
    Expression<String>? wardName,
    Expression<String>? streetAddress,
    Expression<String>? recipientName,
    Expression<String>? recipientPhone,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<DateTime>? createdAt,
    Expression<String>? fullAddress,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (addressId != null) 'address_id': addressId,
      if (provinceName != null) 'province_name': provinceName,
      if (districtName != null) 'district_name': districtName,
      if (wardName != null) 'ward_name': wardName,
      if (streetAddress != null) 'street_address': streetAddress,
      if (recipientName != null) 'recipient_name': recipientName,
      if (recipientPhone != null) 'recipient_phone': recipientPhone,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (createdAt != null) 'created_at': createdAt,
      if (fullAddress != null) 'full_address': fullAddress,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserAddressTableCompanion copyWith({
    Value<String>? addressId,
    Value<String>? provinceName,
    Value<String>? districtName,
    Value<String>? wardName,
    Value<String>? streetAddress,
    Value<String?>? recipientName,
    Value<String?>? recipientPhone,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<DateTime?>? createdAt,
    Value<String>? fullAddress,
    Value<int>? rowid,
  }) {
    return UserAddressTableCompanion(
      addressId: addressId ?? this.addressId,
      provinceName: provinceName ?? this.provinceName,
      districtName: districtName ?? this.districtName,
      wardName: wardName ?? this.wardName,
      streetAddress: streetAddress ?? this.streetAddress,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      fullAddress: fullAddress ?? this.fullAddress,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (addressId.present) {
      map['address_id'] = Variable<String>(addressId.value);
    }
    if (provinceName.present) {
      map['province_name'] = Variable<String>(provinceName.value);
    }
    if (districtName.present) {
      map['district_name'] = Variable<String>(districtName.value);
    }
    if (wardName.present) {
      map['ward_name'] = Variable<String>(wardName.value);
    }
    if (streetAddress.present) {
      map['street_address'] = Variable<String>(streetAddress.value);
    }
    if (recipientName.present) {
      map['recipient_name'] = Variable<String>(recipientName.value);
    }
    if (recipientPhone.present) {
      map['recipient_phone'] = Variable<String>(recipientPhone.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (fullAddress.present) {
      map['full_address'] = Variable<String>(fullAddress.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserAddressTableCompanion(')
          ..write('addressId: $addressId, ')
          ..write('provinceName: $provinceName, ')
          ..write('districtName: $districtName, ')
          ..write('wardName: $wardName, ')
          ..write('streetAddress: $streetAddress, ')
          ..write('recipientName: $recipientName, ')
          ..write('recipientPhone: $recipientPhone, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('createdAt: $createdAt, ')
          ..write('fullAddress: $fullAddress, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CartTableTable extends CartTable
    with TableInfo<$CartTableTable, CartTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CartTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cartItemIdMeta = const VerificationMeta(
    'cartItemId',
  );
  @override
  late final GeneratedColumn<String> cartItemId = GeneratedColumn<String>(
    'cart_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cartIdMeta = const VerificationMeta('cartId');
  @override
  late final GeneratedColumn<String> cartId = GeneratedColumn<String>(
    'cart_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serviceNameMeta = const VerificationMeta(
    'serviceName',
  );
  @override
  late final GeneratedColumn<String> serviceName = GeneratedColumn<String>(
    'service_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _servicePriceMeta = const VerificationMeta(
    'servicePrice',
  );
  @override
  late final GeneratedColumn<double> servicePrice = GeneratedColumn<double>(
    'service_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serviceImagesMeta = const VerificationMeta(
    'serviceImages',
  );
  @override
  late final GeneratedColumn<String> serviceImages = GeneratedColumn<String>(
    'service_images',
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
  static const VerificationMeta _providerNameMeta = const VerificationMeta(
    'providerName',
  );
  @override
  late final GeneratedColumn<String> providerName = GeneratedColumn<String>(
    'provider_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerImagesMeta = const VerificationMeta(
    'providerImages',
  );
  @override
  late final GeneratedColumn<String> providerImages = GeneratedColumn<String>(
    'provider_images',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _optionsJsonMeta = const VerificationMeta(
    'optionsJson',
  );
  @override
  late final GeneratedColumn<String> optionsJson = GeneratedColumn<String>(
    'options_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    cartItemId,
    cartId,
    serviceId,
    createdAt,
    serviceName,
    servicePrice,
    serviceImages,
    providerId,
    providerName,
    providerImages,
    optionsJson,
    quantity,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cart_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CartTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cart_item_id')) {
      context.handle(
        _cartItemIdMeta,
        cartItemId.isAcceptableOrUnknown(
          data['cart_item_id']!,
          _cartItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cartItemIdMeta);
    }
    if (data.containsKey('cart_id')) {
      context.handle(
        _cartIdMeta,
        cartId.isAcceptableOrUnknown(data['cart_id']!, _cartIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cartIdMeta);
    }
    if (data.containsKey('service_id')) {
      context.handle(
        _serviceIdMeta,
        serviceId.isAcceptableOrUnknown(data['service_id']!, _serviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_serviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('service_name')) {
      context.handle(
        _serviceNameMeta,
        serviceName.isAcceptableOrUnknown(
          data['service_name']!,
          _serviceNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serviceNameMeta);
    }
    if (data.containsKey('service_price')) {
      context.handle(
        _servicePriceMeta,
        servicePrice.isAcceptableOrUnknown(
          data['service_price']!,
          _servicePriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_servicePriceMeta);
    }
    if (data.containsKey('service_images')) {
      context.handle(
        _serviceImagesMeta,
        serviceImages.isAcceptableOrUnknown(
          data['service_images']!,
          _serviceImagesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serviceImagesMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('provider_name')) {
      context.handle(
        _providerNameMeta,
        providerName.isAcceptableOrUnknown(
          data['provider_name']!,
          _providerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_providerNameMeta);
    }
    if (data.containsKey('provider_images')) {
      context.handle(
        _providerImagesMeta,
        providerImages.isAcceptableOrUnknown(
          data['provider_images']!,
          _providerImagesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_providerImagesMeta);
    }
    if (data.containsKey('options_json')) {
      context.handle(
        _optionsJsonMeta,
        optionsJson.isAcceptableOrUnknown(
          data['options_json']!,
          _optionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cartItemId};
  @override
  CartTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CartTableData(
      cartItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cart_item_id'],
      )!,
      cartId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cart_id'],
      )!,
      serviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      serviceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_name'],
      )!,
      servicePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}service_price'],
      )!,
      serviceImages: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_images'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      providerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_name'],
      )!,
      providerImages: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_images'],
      )!,
      optionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}options_json'],
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
    );
  }

  @override
  $CartTableTable createAlias(String alias) {
    return $CartTableTable(attachedDatabase, alias);
  }
}

class CartTableData extends DataClass implements Insertable<CartTableData> {
  final String cartItemId;
  final String cartId;
  final String serviceId;
  final String createdAt;
  final String serviceName;
  final double servicePrice;
  final String serviceImages;
  final String providerId;
  final String providerName;
  final String providerImages;
  final String? optionsJson;
  final int quantity;
  const CartTableData({
    required this.cartItemId,
    required this.cartId,
    required this.serviceId,
    required this.createdAt,
    required this.serviceName,
    required this.servicePrice,
    required this.serviceImages,
    required this.providerId,
    required this.providerName,
    required this.providerImages,
    this.optionsJson,
    required this.quantity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cart_item_id'] = Variable<String>(cartItemId);
    map['cart_id'] = Variable<String>(cartId);
    map['service_id'] = Variable<String>(serviceId);
    map['created_at'] = Variable<String>(createdAt);
    map['service_name'] = Variable<String>(serviceName);
    map['service_price'] = Variable<double>(servicePrice);
    map['service_images'] = Variable<String>(serviceImages);
    map['provider_id'] = Variable<String>(providerId);
    map['provider_name'] = Variable<String>(providerName);
    map['provider_images'] = Variable<String>(providerImages);
    if (!nullToAbsent || optionsJson != null) {
      map['options_json'] = Variable<String>(optionsJson);
    }
    map['quantity'] = Variable<int>(quantity);
    return map;
  }

  CartTableCompanion toCompanion(bool nullToAbsent) {
    return CartTableCompanion(
      cartItemId: Value(cartItemId),
      cartId: Value(cartId),
      serviceId: Value(serviceId),
      createdAt: Value(createdAt),
      serviceName: Value(serviceName),
      servicePrice: Value(servicePrice),
      serviceImages: Value(serviceImages),
      providerId: Value(providerId),
      providerName: Value(providerName),
      providerImages: Value(providerImages),
      optionsJson: optionsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(optionsJson),
      quantity: Value(quantity),
    );
  }

  factory CartTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CartTableData(
      cartItemId: serializer.fromJson<String>(json['cartItemId']),
      cartId: serializer.fromJson<String>(json['cartId']),
      serviceId: serializer.fromJson<String>(json['serviceId']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      serviceName: serializer.fromJson<String>(json['serviceName']),
      servicePrice: serializer.fromJson<double>(json['servicePrice']),
      serviceImages: serializer.fromJson<String>(json['serviceImages']),
      providerId: serializer.fromJson<String>(json['providerId']),
      providerName: serializer.fromJson<String>(json['providerName']),
      providerImages: serializer.fromJson<String>(json['providerImages']),
      optionsJson: serializer.fromJson<String?>(json['optionsJson']),
      quantity: serializer.fromJson<int>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cartItemId': serializer.toJson<String>(cartItemId),
      'cartId': serializer.toJson<String>(cartId),
      'serviceId': serializer.toJson<String>(serviceId),
      'createdAt': serializer.toJson<String>(createdAt),
      'serviceName': serializer.toJson<String>(serviceName),
      'servicePrice': serializer.toJson<double>(servicePrice),
      'serviceImages': serializer.toJson<String>(serviceImages),
      'providerId': serializer.toJson<String>(providerId),
      'providerName': serializer.toJson<String>(providerName),
      'providerImages': serializer.toJson<String>(providerImages),
      'optionsJson': serializer.toJson<String?>(optionsJson),
      'quantity': serializer.toJson<int>(quantity),
    };
  }

  CartTableData copyWith({
    String? cartItemId,
    String? cartId,
    String? serviceId,
    String? createdAt,
    String? serviceName,
    double? servicePrice,
    String? serviceImages,
    String? providerId,
    String? providerName,
    String? providerImages,
    Value<String?> optionsJson = const Value.absent(),
    int? quantity,
  }) => CartTableData(
    cartItemId: cartItemId ?? this.cartItemId,
    cartId: cartId ?? this.cartId,
    serviceId: serviceId ?? this.serviceId,
    createdAt: createdAt ?? this.createdAt,
    serviceName: serviceName ?? this.serviceName,
    servicePrice: servicePrice ?? this.servicePrice,
    serviceImages: serviceImages ?? this.serviceImages,
    providerId: providerId ?? this.providerId,
    providerName: providerName ?? this.providerName,
    providerImages: providerImages ?? this.providerImages,
    optionsJson: optionsJson.present ? optionsJson.value : this.optionsJson,
    quantity: quantity ?? this.quantity,
  );
  CartTableData copyWithCompanion(CartTableCompanion data) {
    return CartTableData(
      cartItemId: data.cartItemId.present
          ? data.cartItemId.value
          : this.cartItemId,
      cartId: data.cartId.present ? data.cartId.value : this.cartId,
      serviceId: data.serviceId.present ? data.serviceId.value : this.serviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      serviceName: data.serviceName.present
          ? data.serviceName.value
          : this.serviceName,
      servicePrice: data.servicePrice.present
          ? data.servicePrice.value
          : this.servicePrice,
      serviceImages: data.serviceImages.present
          ? data.serviceImages.value
          : this.serviceImages,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      providerName: data.providerName.present
          ? data.providerName.value
          : this.providerName,
      providerImages: data.providerImages.present
          ? data.providerImages.value
          : this.providerImages,
      optionsJson: data.optionsJson.present
          ? data.optionsJson.value
          : this.optionsJson,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CartTableData(')
          ..write('cartItemId: $cartItemId, ')
          ..write('cartId: $cartId, ')
          ..write('serviceId: $serviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('serviceName: $serviceName, ')
          ..write('servicePrice: $servicePrice, ')
          ..write('serviceImages: $serviceImages, ')
          ..write('providerId: $providerId, ')
          ..write('providerName: $providerName, ')
          ..write('providerImages: $providerImages, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    cartItemId,
    cartId,
    serviceId,
    createdAt,
    serviceName,
    servicePrice,
    serviceImages,
    providerId,
    providerName,
    providerImages,
    optionsJson,
    quantity,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CartTableData &&
          other.cartItemId == this.cartItemId &&
          other.cartId == this.cartId &&
          other.serviceId == this.serviceId &&
          other.createdAt == this.createdAt &&
          other.serviceName == this.serviceName &&
          other.servicePrice == this.servicePrice &&
          other.serviceImages == this.serviceImages &&
          other.providerId == this.providerId &&
          other.providerName == this.providerName &&
          other.providerImages == this.providerImages &&
          other.optionsJson == this.optionsJson &&
          other.quantity == this.quantity);
}

class CartTableCompanion extends UpdateCompanion<CartTableData> {
  final Value<String> cartItemId;
  final Value<String> cartId;
  final Value<String> serviceId;
  final Value<String> createdAt;
  final Value<String> serviceName;
  final Value<double> servicePrice;
  final Value<String> serviceImages;
  final Value<String> providerId;
  final Value<String> providerName;
  final Value<String> providerImages;
  final Value<String?> optionsJson;
  final Value<int> quantity;
  final Value<int> rowid;
  const CartTableCompanion({
    this.cartItemId = const Value.absent(),
    this.cartId = const Value.absent(),
    this.serviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serviceName = const Value.absent(),
    this.servicePrice = const Value.absent(),
    this.serviceImages = const Value.absent(),
    this.providerId = const Value.absent(),
    this.providerName = const Value.absent(),
    this.providerImages = const Value.absent(),
    this.optionsJson = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CartTableCompanion.insert({
    required String cartItemId,
    required String cartId,
    required String serviceId,
    required String createdAt,
    required String serviceName,
    required double servicePrice,
    required String serviceImages,
    required String providerId,
    required String providerName,
    required String providerImages,
    this.optionsJson = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : cartItemId = Value(cartItemId),
       cartId = Value(cartId),
       serviceId = Value(serviceId),
       createdAt = Value(createdAt),
       serviceName = Value(serviceName),
       servicePrice = Value(servicePrice),
       serviceImages = Value(serviceImages),
       providerId = Value(providerId),
       providerName = Value(providerName),
       providerImages = Value(providerImages);
  static Insertable<CartTableData> custom({
    Expression<String>? cartItemId,
    Expression<String>? cartId,
    Expression<String>? serviceId,
    Expression<String>? createdAt,
    Expression<String>? serviceName,
    Expression<double>? servicePrice,
    Expression<String>? serviceImages,
    Expression<String>? providerId,
    Expression<String>? providerName,
    Expression<String>? providerImages,
    Expression<String>? optionsJson,
    Expression<int>? quantity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cartItemId != null) 'cart_item_id': cartItemId,
      if (cartId != null) 'cart_id': cartId,
      if (serviceId != null) 'service_id': serviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (serviceName != null) 'service_name': serviceName,
      if (servicePrice != null) 'service_price': servicePrice,
      if (serviceImages != null) 'service_images': serviceImages,
      if (providerId != null) 'provider_id': providerId,
      if (providerName != null) 'provider_name': providerName,
      if (providerImages != null) 'provider_images': providerImages,
      if (optionsJson != null) 'options_json': optionsJson,
      if (quantity != null) 'quantity': quantity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CartTableCompanion copyWith({
    Value<String>? cartItemId,
    Value<String>? cartId,
    Value<String>? serviceId,
    Value<String>? createdAt,
    Value<String>? serviceName,
    Value<double>? servicePrice,
    Value<String>? serviceImages,
    Value<String>? providerId,
    Value<String>? providerName,
    Value<String>? providerImages,
    Value<String?>? optionsJson,
    Value<int>? quantity,
    Value<int>? rowid,
  }) {
    return CartTableCompanion(
      cartItemId: cartItemId ?? this.cartItemId,
      cartId: cartId ?? this.cartId,
      serviceId: serviceId ?? this.serviceId,
      createdAt: createdAt ?? this.createdAt,
      serviceName: serviceName ?? this.serviceName,
      servicePrice: servicePrice ?? this.servicePrice,
      serviceImages: serviceImages ?? this.serviceImages,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      providerImages: providerImages ?? this.providerImages,
      optionsJson: optionsJson ?? this.optionsJson,
      quantity: quantity ?? this.quantity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cartItemId.present) {
      map['cart_item_id'] = Variable<String>(cartItemId.value);
    }
    if (cartId.present) {
      map['cart_id'] = Variable<String>(cartId.value);
    }
    if (serviceId.present) {
      map['service_id'] = Variable<String>(serviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (serviceName.present) {
      map['service_name'] = Variable<String>(serviceName.value);
    }
    if (servicePrice.present) {
      map['service_price'] = Variable<double>(servicePrice.value);
    }
    if (serviceImages.present) {
      map['service_images'] = Variable<String>(serviceImages.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (providerName.present) {
      map['provider_name'] = Variable<String>(providerName.value);
    }
    if (providerImages.present) {
      map['provider_images'] = Variable<String>(providerImages.value);
    }
    if (optionsJson.present) {
      map['options_json'] = Variable<String>(optionsJson.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CartTableCompanion(')
          ..write('cartItemId: $cartItemId, ')
          ..write('cartId: $cartId, ')
          ..write('serviceId: $serviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('serviceName: $serviceName, ')
          ..write('servicePrice: $servicePrice, ')
          ..write('serviceImages: $serviceImages, ')
          ..write('providerId: $providerId, ')
          ..write('providerName: $providerName, ')
          ..write('providerImages: $providerImages, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('quantity: $quantity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookingHistoryTableTable extends BookingHistoryTable
    with TableInfo<$BookingHistoryTableTable, BookingHistoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookingHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookingIdMeta = const VerificationMeta(
    'bookingId',
  );
  @override
  late final GeneratedColumn<String> bookingId = GeneratedColumn<String>(
    'booking_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [bookingId, json, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'booking_history_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookingHistoryTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('booking_id')) {
      context.handle(
        _bookingIdMeta,
        bookingId.isAcceptableOrUnknown(data['booking_id']!, _bookingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookingIdMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookingId};
  @override
  BookingHistoryTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookingHistoryTableData(
      bookingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}booking_id'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BookingHistoryTableTable createAlias(String alias) {
    return $BookingHistoryTableTable(attachedDatabase, alias);
  }
}

class BookingHistoryTableData extends DataClass
    implements Insertable<BookingHistoryTableData> {
  final String bookingId;
  final String json;
  final DateTime createdAt;
  const BookingHistoryTableData({
    required this.bookingId,
    required this.json,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['booking_id'] = Variable<String>(bookingId);
    map['json'] = Variable<String>(json);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BookingHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return BookingHistoryTableCompanion(
      bookingId: Value(bookingId),
      json: Value(json),
      createdAt: Value(createdAt),
    );
  }

  factory BookingHistoryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookingHistoryTableData(
      bookingId: serializer.fromJson<String>(json['bookingId']),
      json: serializer.fromJson<String>(json['json']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookingId': serializer.toJson<String>(bookingId),
      'json': serializer.toJson<String>(json),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BookingHistoryTableData copyWith({
    String? bookingId,
    String? json,
    DateTime? createdAt,
  }) => BookingHistoryTableData(
    bookingId: bookingId ?? this.bookingId,
    json: json ?? this.json,
    createdAt: createdAt ?? this.createdAt,
  );
  BookingHistoryTableData copyWithCompanion(BookingHistoryTableCompanion data) {
    return BookingHistoryTableData(
      bookingId: data.bookingId.present ? data.bookingId.value : this.bookingId,
      json: data.json.present ? data.json.value : this.json,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookingHistoryTableData(')
          ..write('bookingId: $bookingId, ')
          ..write('json: $json, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookingId, json, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookingHistoryTableData &&
          other.bookingId == this.bookingId &&
          other.json == this.json &&
          other.createdAt == this.createdAt);
}

class BookingHistoryTableCompanion
    extends UpdateCompanion<BookingHistoryTableData> {
  final Value<String> bookingId;
  final Value<String> json;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BookingHistoryTableCompanion({
    this.bookingId = const Value.absent(),
    this.json = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookingHistoryTableCompanion.insert({
    required String bookingId,
    required String json,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : bookingId = Value(bookingId),
       json = Value(json),
       createdAt = Value(createdAt);
  static Insertable<BookingHistoryTableData> custom({
    Expression<String>? bookingId,
    Expression<String>? json,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookingId != null) 'booking_id': bookingId,
      if (json != null) 'json': json,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookingHistoryTableCompanion copyWith({
    Value<String>? bookingId,
    Value<String>? json,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BookingHistoryTableCompanion(
      bookingId: bookingId ?? this.bookingId,
      json: json ?? this.json,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookingId.present) {
      map['booking_id'] = Variable<String>(bookingId.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookingHistoryTableCompanion(')
          ..write('bookingId: $bookingId, ')
          ..write('json: $json, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTableTable extends AppSettingsTable
    with TableInfo<$AppSettingsTableTable, AppSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => 'settings',
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('light'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, themeMode, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $AppSettingsTableTable createAlias(String alias) {
    return $AppSettingsTableTable(attachedDatabase, alias);
  }
}

class AppSettingsTableData extends DataClass
    implements Insertable<AppSettingsTableData> {
  final String id;
  final String themeMode;
  final DateTime? updatedAt;
  const AppSettingsTableData({
    required this.id,
    required this.themeMode,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['theme_mode'] = Variable<String>(themeMode);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  AppSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsTableCompanion(
      id: Value(id),
      themeMode: Value(themeMode),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory AppSettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsTableData(
      id: serializer.fromJson<String>(json['id']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'themeMode': serializer.toJson<String>(themeMode),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  AppSettingsTableData copyWith({
    String? id,
    String? themeMode,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => AppSettingsTableData(
    id: id ?? this.id,
    themeMode: themeMode ?? this.themeMode,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  AppSettingsTableData copyWithCompanion(AppSettingsTableCompanion data) {
    return AppSettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableData(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, themeMode, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsTableData &&
          other.id == this.id &&
          other.themeMode == this.themeMode &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsTableCompanion extends UpdateCompanion<AppSettingsTableData> {
  final Value<String> id;
  final Value<String> themeMode;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const AppSettingsTableCompanion({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<AppSettingsTableData> custom({
    Expression<String>? id,
    Expression<String>? themeMode,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeMode != null) 'theme_mode': themeMode,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? themeMode,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsTableCompanion(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ServicesTableTable servicesTable = $ServicesTableTable(this);
  late final $AuthsTableTable authsTable = $AuthsTableTable(this);
  late final $ProfileTableTable profileTable = $ProfileTableTable(this);
  late final $UserAddressTableTable userAddressTable = $UserAddressTableTable(
    this,
  );
  late final $CartTableTable cartTable = $CartTableTable(this);
  late final $BookingHistoryTableTable bookingHistoryTable =
      $BookingHistoryTableTable(this);
  late final $AppSettingsTableTable appSettingsTable = $AppSettingsTableTable(
    this,
  );
  late final ServicesDao servicesDao = ServicesDao(this as AppDatabase);
  late final AuthDao authDao = AuthDao(this as AppDatabase);
  late final ProfileDao profileDao = ProfileDao(this as AppDatabase);
  late final UserAddressDao userAddressDao = UserAddressDao(
    this as AppDatabase,
  );
  late final CartDao cartDao = CartDao(this as AppDatabase);
  late final BookingHistoryDao bookingHistoryDao = BookingHistoryDao(
    this as AppDatabase,
  );
  late final AppSettingsDao appSettingsDao = AppSettingsDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    servicesTable,
    authsTable,
    profileTable,
    userAddressTable,
    cartTable,
    bookingHistoryTable,
    appSettingsTable,
  ];
}

typedef $$ServicesTableTableCreateCompanionBuilder =
    ServicesTableCompanion Function({
      required String serviceId,
      Value<String?> providerId,
      Value<String?> categoryId,
      required String title,
      Value<String?> description,
      Value<double> price,
      Value<String?> unitType,
      Value<int?> baseUnit,
      Value<String?> images,
      Value<DateTime?> createdAt,
      Value<String?> status,
      Value<bool?> deleted,
      Value<double> averageRating,
      Value<int> totalReviews,
      Value<String?> categoryName,
      Value<String?> providerName,
      Value<String?> jsonOptions,
      Value<int> rowid,
    });
typedef $$ServicesTableTableUpdateCompanionBuilder =
    ServicesTableCompanion Function({
      Value<String> serviceId,
      Value<String?> providerId,
      Value<String?> categoryId,
      Value<String> title,
      Value<String?> description,
      Value<double> price,
      Value<String?> unitType,
      Value<int?> baseUnit,
      Value<String?> images,
      Value<DateTime?> createdAt,
      Value<String?> status,
      Value<bool?> deleted,
      Value<double> averageRating,
      Value<int> totalReviews,
      Value<String?> categoryName,
      Value<String?> providerName,
      Value<String?> jsonOptions,
      Value<int> rowid,
    });

class $$ServicesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ServicesTableTable> {
  $$ServicesTableTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
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

  ColumnFilters<String> get providerName => $composableBuilder(
    column: $table.providerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonOptions => $composableBuilder(
    column: $table.jsonOptions,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ServicesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ServicesTableTable> {
  $$ServicesTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
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

  ColumnOrderings<String> get providerName => $composableBuilder(
    column: $table.providerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonOptions => $composableBuilder(
    column: $table.jsonOptions,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ServicesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServicesTableTable> {
  $$ServicesTableTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

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

  GeneratedColumn<String> get providerName => $composableBuilder(
    column: $table.providerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jsonOptions => $composableBuilder(
    column: $table.jsonOptions,
    builder: (column) => column,
  );
}

class $$ServicesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServicesTableTable,
          ServicesTableData,
          $$ServicesTableTableFilterComposer,
          $$ServicesTableTableOrderingComposer,
          $$ServicesTableTableAnnotationComposer,
          $$ServicesTableTableCreateCompanionBuilder,
          $$ServicesTableTableUpdateCompanionBuilder,
          (
            ServicesTableData,
            BaseReferences<
              _$AppDatabase,
              $ServicesTableTable,
              ServicesTableData
            >,
          ),
          ServicesTableData,
          PrefetchHooks Function()
        > {
  $$ServicesTableTableTableManager(_$AppDatabase db, $ServicesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServicesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServicesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServicesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> serviceId = const Value.absent(),
                Value<String?> providerId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<String?> unitType = const Value.absent(),
                Value<int?> baseUnit = const Value.absent(),
                Value<String?> images = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<bool?> deleted = const Value.absent(),
                Value<double> averageRating = const Value.absent(),
                Value<int> totalReviews = const Value.absent(),
                Value<String?> categoryName = const Value.absent(),
                Value<String?> providerName = const Value.absent(),
                Value<String?> jsonOptions = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServicesTableCompanion(
                serviceId: serviceId,
                providerId: providerId,
                categoryId: categoryId,
                title: title,
                description: description,
                price: price,
                unitType: unitType,
                baseUnit: baseUnit,
                images: images,
                createdAt: createdAt,
                status: status,
                deleted: deleted,
                averageRating: averageRating,
                totalReviews: totalReviews,
                categoryName: categoryName,
                providerName: providerName,
                jsonOptions: jsonOptions,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String serviceId,
                Value<String?> providerId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<String?> unitType = const Value.absent(),
                Value<int?> baseUnit = const Value.absent(),
                Value<String?> images = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<bool?> deleted = const Value.absent(),
                Value<double> averageRating = const Value.absent(),
                Value<int> totalReviews = const Value.absent(),
                Value<String?> categoryName = const Value.absent(),
                Value<String?> providerName = const Value.absent(),
                Value<String?> jsonOptions = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServicesTableCompanion.insert(
                serviceId: serviceId,
                providerId: providerId,
                categoryId: categoryId,
                title: title,
                description: description,
                price: price,
                unitType: unitType,
                baseUnit: baseUnit,
                images: images,
                createdAt: createdAt,
                status: status,
                deleted: deleted,
                averageRating: averageRating,
                totalReviews: totalReviews,
                categoryName: categoryName,
                providerName: providerName,
                jsonOptions: jsonOptions,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ServicesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServicesTableTable,
      ServicesTableData,
      $$ServicesTableTableFilterComposer,
      $$ServicesTableTableOrderingComposer,
      $$ServicesTableTableAnnotationComposer,
      $$ServicesTableTableCreateCompanionBuilder,
      $$ServicesTableTableUpdateCompanionBuilder,
      (
        ServicesTableData,
        BaseReferences<_$AppDatabase, $ServicesTableTable, ServicesTableData>,
      ),
      ServicesTableData,
      PrefetchHooks Function()
    >;
typedef $$AuthsTableTableCreateCompanionBuilder =
    AuthsTableCompanion Function({
      Value<String> id,
      Value<String?> token,
      Value<String?> role,
      Value<String?> accountId,
      Value<DateTime?> savedAt,
      Value<int> rowid,
    });
typedef $$AuthsTableTableUpdateCompanionBuilder =
    AuthsTableCompanion Function({
      Value<String> id,
      Value<String?> token,
      Value<String?> role,
      Value<String?> accountId,
      Value<DateTime?> savedAt,
      Value<int> rowid,
    });

class $$AuthsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AuthsTableTable> {
  $$AuthsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuthsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AuthsTableTable> {
  $$AuthsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuthsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuthsTableTable> {
  $$AuthsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);
}

class $$AuthsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuthsTableTable,
          AuthsTableData,
          $$AuthsTableTableFilterComposer,
          $$AuthsTableTableOrderingComposer,
          $$AuthsTableTableAnnotationComposer,
          $$AuthsTableTableCreateCompanionBuilder,
          $$AuthsTableTableUpdateCompanionBuilder,
          (
            AuthsTableData,
            BaseReferences<_$AppDatabase, $AuthsTableTable, AuthsTableData>,
          ),
          AuthsTableData,
          PrefetchHooks Function()
        > {
  $$AuthsTableTableTableManager(_$AppDatabase db, $AuthsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuthsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuthsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuthsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> token = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<DateTime?> savedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuthsTableCompanion(
                id: id,
                token: token,
                role: role,
                accountId: accountId,
                savedAt: savedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> token = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<DateTime?> savedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuthsTableCompanion.insert(
                id: id,
                token: token,
                role: role,
                accountId: accountId,
                savedAt: savedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuthsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuthsTableTable,
      AuthsTableData,
      $$AuthsTableTableFilterComposer,
      $$AuthsTableTableOrderingComposer,
      $$AuthsTableTableAnnotationComposer,
      $$AuthsTableTableCreateCompanionBuilder,
      $$AuthsTableTableUpdateCompanionBuilder,
      (
        AuthsTableData,
        BaseReferences<_$AppDatabase, $AuthsTableTable, AuthsTableData>,
      ),
      AuthsTableData,
      PrefetchHooks Function()
    >;
typedef $$ProfileTableTableCreateCompanionBuilder =
    ProfileTableCompanion Function({
      required String userId,
      required String accountId,
      required String accountName,
      required String email,
      required String role,
      Value<String?> fullName,
      Value<String?> phoneNumber,
      Value<String?> images,
      Value<String?> address,
      Value<int> rowid,
    });
typedef $$ProfileTableTableUpdateCompanionBuilder =
    ProfileTableCompanion Function({
      Value<String> userId,
      Value<String> accountId,
      Value<String> accountName,
      Value<String> email,
      Value<String> role,
      Value<String?> fullName,
      Value<String?> phoneNumber,
      Value<String?> images,
      Value<String?> address,
      Value<int> rowid,
    });

class $$ProfileTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProfileTableTable> {
  $$ProfileTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountName => $composableBuilder(
    column: $table.accountName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get images => $composableBuilder(
    column: $table.images,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfileTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfileTableTable> {
  $$ProfileTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountName => $composableBuilder(
    column: $table.accountName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get images => $composableBuilder(
    column: $table.images,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfileTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfileTableTable> {
  $$ProfileTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get accountName => $composableBuilder(
    column: $table.accountName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get images =>
      $composableBuilder(column: $table.images, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);
}

class $$ProfileTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfileTableTable,
          ProfileTableData,
          $$ProfileTableTableFilterComposer,
          $$ProfileTableTableOrderingComposer,
          $$ProfileTableTableAnnotationComposer,
          $$ProfileTableTableCreateCompanionBuilder,
          $$ProfileTableTableUpdateCompanionBuilder,
          (
            ProfileTableData,
            BaseReferences<_$AppDatabase, $ProfileTableTable, ProfileTableData>,
          ),
          ProfileTableData,
          PrefetchHooks Function()
        > {
  $$ProfileTableTableTableManager(_$AppDatabase db, $ProfileTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfileTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> accountName = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> fullName = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<String?> images = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileTableCompanion(
                userId: userId,
                accountId: accountId,
                accountName: accountName,
                email: email,
                role: role,
                fullName: fullName,
                phoneNumber: phoneNumber,
                images: images,
                address: address,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String accountId,
                required String accountName,
                required String email,
                required String role,
                Value<String?> fullName = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<String?> images = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileTableCompanion.insert(
                userId: userId,
                accountId: accountId,
                accountName: accountName,
                email: email,
                role: role,
                fullName: fullName,
                phoneNumber: phoneNumber,
                images: images,
                address: address,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfileTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfileTableTable,
      ProfileTableData,
      $$ProfileTableTableFilterComposer,
      $$ProfileTableTableOrderingComposer,
      $$ProfileTableTableAnnotationComposer,
      $$ProfileTableTableCreateCompanionBuilder,
      $$ProfileTableTableUpdateCompanionBuilder,
      (
        ProfileTableData,
        BaseReferences<_$AppDatabase, $ProfileTableTable, ProfileTableData>,
      ),
      ProfileTableData,
      PrefetchHooks Function()
    >;
typedef $$UserAddressTableTableCreateCompanionBuilder =
    UserAddressTableCompanion Function({
      required String addressId,
      required String provinceName,
      required String districtName,
      required String wardName,
      required String streetAddress,
      Value<String?> recipientName,
      Value<String?> recipientPhone,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<DateTime?> createdAt,
      required String fullAddress,
      Value<int> rowid,
    });
typedef $$UserAddressTableTableUpdateCompanionBuilder =
    UserAddressTableCompanion Function({
      Value<String> addressId,
      Value<String> provinceName,
      Value<String> districtName,
      Value<String> wardName,
      Value<String> streetAddress,
      Value<String?> recipientName,
      Value<String?> recipientPhone,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<DateTime?> createdAt,
      Value<String> fullAddress,
      Value<int> rowid,
    });

class $$UserAddressTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserAddressTableTable> {
  $$UserAddressTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get addressId => $composableBuilder(
    column: $table.addressId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provinceName => $composableBuilder(
    column: $table.provinceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get districtName => $composableBuilder(
    column: $table.districtName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wardName => $composableBuilder(
    column: $table.wardName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get streetAddress => $composableBuilder(
    column: $table.streetAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipientName => $composableBuilder(
    column: $table.recipientName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipientPhone => $composableBuilder(
    column: $table.recipientPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullAddress => $composableBuilder(
    column: $table.fullAddress,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserAddressTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserAddressTableTable> {
  $$UserAddressTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get addressId => $composableBuilder(
    column: $table.addressId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provinceName => $composableBuilder(
    column: $table.provinceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get districtName => $composableBuilder(
    column: $table.districtName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wardName => $composableBuilder(
    column: $table.wardName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get streetAddress => $composableBuilder(
    column: $table.streetAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipientName => $composableBuilder(
    column: $table.recipientName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipientPhone => $composableBuilder(
    column: $table.recipientPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullAddress => $composableBuilder(
    column: $table.fullAddress,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserAddressTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserAddressTableTable> {
  $$UserAddressTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get addressId =>
      $composableBuilder(column: $table.addressId, builder: (column) => column);

  GeneratedColumn<String> get provinceName => $composableBuilder(
    column: $table.provinceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get districtName => $composableBuilder(
    column: $table.districtName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get wardName =>
      $composableBuilder(column: $table.wardName, builder: (column) => column);

  GeneratedColumn<String> get streetAddress => $composableBuilder(
    column: $table.streetAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recipientName => $composableBuilder(
    column: $table.recipientName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recipientPhone => $composableBuilder(
    column: $table.recipientPhone,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get fullAddress => $composableBuilder(
    column: $table.fullAddress,
    builder: (column) => column,
  );
}

class $$UserAddressTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserAddressTableTable,
          UserAddressTableData,
          $$UserAddressTableTableFilterComposer,
          $$UserAddressTableTableOrderingComposer,
          $$UserAddressTableTableAnnotationComposer,
          $$UserAddressTableTableCreateCompanionBuilder,
          $$UserAddressTableTableUpdateCompanionBuilder,
          (
            UserAddressTableData,
            BaseReferences<
              _$AppDatabase,
              $UserAddressTableTable,
              UserAddressTableData
            >,
          ),
          UserAddressTableData,
          PrefetchHooks Function()
        > {
  $$UserAddressTableTableTableManager(
    _$AppDatabase db,
    $UserAddressTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserAddressTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserAddressTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserAddressTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> addressId = const Value.absent(),
                Value<String> provinceName = const Value.absent(),
                Value<String> districtName = const Value.absent(),
                Value<String> wardName = const Value.absent(),
                Value<String> streetAddress = const Value.absent(),
                Value<String?> recipientName = const Value.absent(),
                Value<String?> recipientPhone = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<String> fullAddress = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserAddressTableCompanion(
                addressId: addressId,
                provinceName: provinceName,
                districtName: districtName,
                wardName: wardName,
                streetAddress: streetAddress,
                recipientName: recipientName,
                recipientPhone: recipientPhone,
                latitude: latitude,
                longitude: longitude,
                createdAt: createdAt,
                fullAddress: fullAddress,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String addressId,
                required String provinceName,
                required String districtName,
                required String wardName,
                required String streetAddress,
                Value<String?> recipientName = const Value.absent(),
                Value<String?> recipientPhone = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                required String fullAddress,
                Value<int> rowid = const Value.absent(),
              }) => UserAddressTableCompanion.insert(
                addressId: addressId,
                provinceName: provinceName,
                districtName: districtName,
                wardName: wardName,
                streetAddress: streetAddress,
                recipientName: recipientName,
                recipientPhone: recipientPhone,
                latitude: latitude,
                longitude: longitude,
                createdAt: createdAt,
                fullAddress: fullAddress,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserAddressTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserAddressTableTable,
      UserAddressTableData,
      $$UserAddressTableTableFilterComposer,
      $$UserAddressTableTableOrderingComposer,
      $$UserAddressTableTableAnnotationComposer,
      $$UserAddressTableTableCreateCompanionBuilder,
      $$UserAddressTableTableUpdateCompanionBuilder,
      (
        UserAddressTableData,
        BaseReferences<
          _$AppDatabase,
          $UserAddressTableTable,
          UserAddressTableData
        >,
      ),
      UserAddressTableData,
      PrefetchHooks Function()
    >;
typedef $$CartTableTableCreateCompanionBuilder =
    CartTableCompanion Function({
      required String cartItemId,
      required String cartId,
      required String serviceId,
      required String createdAt,
      required String serviceName,
      required double servicePrice,
      required String serviceImages,
      required String providerId,
      required String providerName,
      required String providerImages,
      Value<String?> optionsJson,
      Value<int> quantity,
      Value<int> rowid,
    });
typedef $$CartTableTableUpdateCompanionBuilder =
    CartTableCompanion Function({
      Value<String> cartItemId,
      Value<String> cartId,
      Value<String> serviceId,
      Value<String> createdAt,
      Value<String> serviceName,
      Value<double> servicePrice,
      Value<String> serviceImages,
      Value<String> providerId,
      Value<String> providerName,
      Value<String> providerImages,
      Value<String?> optionsJson,
      Value<int> quantity,
      Value<int> rowid,
    });

class $$CartTableTableFilterComposer
    extends Composer<_$AppDatabase, $CartTableTable> {
  $$CartTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cartItemId => $composableBuilder(
    column: $table.cartItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cartId => $composableBuilder(
    column: $table.cartId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceId => $composableBuilder(
    column: $table.serviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceName => $composableBuilder(
    column: $table.serviceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get servicePrice => $composableBuilder(
    column: $table.servicePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceImages => $composableBuilder(
    column: $table.serviceImages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerName => $composableBuilder(
    column: $table.providerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerImages => $composableBuilder(
    column: $table.providerImages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CartTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CartTableTable> {
  $$CartTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cartItemId => $composableBuilder(
    column: $table.cartItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cartId => $composableBuilder(
    column: $table.cartId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceId => $composableBuilder(
    column: $table.serviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceName => $composableBuilder(
    column: $table.serviceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get servicePrice => $composableBuilder(
    column: $table.servicePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceImages => $composableBuilder(
    column: $table.serviceImages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerName => $composableBuilder(
    column: $table.providerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerImages => $composableBuilder(
    column: $table.providerImages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CartTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CartTableTable> {
  $$CartTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cartItemId => $composableBuilder(
    column: $table.cartItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cartId =>
      $composableBuilder(column: $table.cartId, builder: (column) => column);

  GeneratedColumn<String> get serviceId =>
      $composableBuilder(column: $table.serviceId, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get serviceName => $composableBuilder(
    column: $table.serviceName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get servicePrice => $composableBuilder(
    column: $table.servicePrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serviceImages => $composableBuilder(
    column: $table.serviceImages,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerName => $composableBuilder(
    column: $table.providerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerImages => $composableBuilder(
    column: $table.providerImages,
    builder: (column) => column,
  );

  GeneratedColumn<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);
}

class $$CartTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CartTableTable,
          CartTableData,
          $$CartTableTableFilterComposer,
          $$CartTableTableOrderingComposer,
          $$CartTableTableAnnotationComposer,
          $$CartTableTableCreateCompanionBuilder,
          $$CartTableTableUpdateCompanionBuilder,
          (
            CartTableData,
            BaseReferences<_$AppDatabase, $CartTableTable, CartTableData>,
          ),
          CartTableData,
          PrefetchHooks Function()
        > {
  $$CartTableTableTableManager(_$AppDatabase db, $CartTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CartTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CartTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CartTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cartItemId = const Value.absent(),
                Value<String> cartId = const Value.absent(),
                Value<String> serviceId = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> serviceName = const Value.absent(),
                Value<double> servicePrice = const Value.absent(),
                Value<String> serviceImages = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> providerName = const Value.absent(),
                Value<String> providerImages = const Value.absent(),
                Value<String?> optionsJson = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CartTableCompanion(
                cartItemId: cartItemId,
                cartId: cartId,
                serviceId: serviceId,
                createdAt: createdAt,
                serviceName: serviceName,
                servicePrice: servicePrice,
                serviceImages: serviceImages,
                providerId: providerId,
                providerName: providerName,
                providerImages: providerImages,
                optionsJson: optionsJson,
                quantity: quantity,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cartItemId,
                required String cartId,
                required String serviceId,
                required String createdAt,
                required String serviceName,
                required double servicePrice,
                required String serviceImages,
                required String providerId,
                required String providerName,
                required String providerImages,
                Value<String?> optionsJson = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CartTableCompanion.insert(
                cartItemId: cartItemId,
                cartId: cartId,
                serviceId: serviceId,
                createdAt: createdAt,
                serviceName: serviceName,
                servicePrice: servicePrice,
                serviceImages: serviceImages,
                providerId: providerId,
                providerName: providerName,
                providerImages: providerImages,
                optionsJson: optionsJson,
                quantity: quantity,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CartTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CartTableTable,
      CartTableData,
      $$CartTableTableFilterComposer,
      $$CartTableTableOrderingComposer,
      $$CartTableTableAnnotationComposer,
      $$CartTableTableCreateCompanionBuilder,
      $$CartTableTableUpdateCompanionBuilder,
      (
        CartTableData,
        BaseReferences<_$AppDatabase, $CartTableTable, CartTableData>,
      ),
      CartTableData,
      PrefetchHooks Function()
    >;
typedef $$BookingHistoryTableTableCreateCompanionBuilder =
    BookingHistoryTableCompanion Function({
      required String bookingId,
      required String json,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$BookingHistoryTableTableUpdateCompanionBuilder =
    BookingHistoryTableCompanion Function({
      Value<String> bookingId,
      Value<String> json,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$BookingHistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $BookingHistoryTableTable> {
  $$BookingHistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bookingId => $composableBuilder(
    column: $table.bookingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookingHistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BookingHistoryTableTable> {
  $$BookingHistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bookingId => $composableBuilder(
    column: $table.bookingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookingHistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookingHistoryTableTable> {
  $$BookingHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bookingId =>
      $composableBuilder(column: $table.bookingId, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BookingHistoryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookingHistoryTableTable,
          BookingHistoryTableData,
          $$BookingHistoryTableTableFilterComposer,
          $$BookingHistoryTableTableOrderingComposer,
          $$BookingHistoryTableTableAnnotationComposer,
          $$BookingHistoryTableTableCreateCompanionBuilder,
          $$BookingHistoryTableTableUpdateCompanionBuilder,
          (
            BookingHistoryTableData,
            BaseReferences<
              _$AppDatabase,
              $BookingHistoryTableTable,
              BookingHistoryTableData
            >,
          ),
          BookingHistoryTableData,
          PrefetchHooks Function()
        > {
  $$BookingHistoryTableTableTableManager(
    _$AppDatabase db,
    $BookingHistoryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookingHistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookingHistoryTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BookingHistoryTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> bookingId = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookingHistoryTableCompanion(
                bookingId: bookingId,
                json: json,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bookingId,
                required String json,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BookingHistoryTableCompanion.insert(
                bookingId: bookingId,
                json: json,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookingHistoryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookingHistoryTableTable,
      BookingHistoryTableData,
      $$BookingHistoryTableTableFilterComposer,
      $$BookingHistoryTableTableOrderingComposer,
      $$BookingHistoryTableTableAnnotationComposer,
      $$BookingHistoryTableTableCreateCompanionBuilder,
      $$BookingHistoryTableTableUpdateCompanionBuilder,
      (
        BookingHistoryTableData,
        BaseReferences<
          _$AppDatabase,
          $BookingHistoryTableTable,
          BookingHistoryTableData
        >,
      ),
      BookingHistoryTableData,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableTableCreateCompanionBuilder =
    AppSettingsTableCompanion Function({
      Value<String> id,
      Value<String> themeMode,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableTableUpdateCompanionBuilder =
    AppSettingsTableCompanion Function({
      Value<String> id,
      Value<String> themeMode,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTableTable,
          AppSettingsTableData,
          $$AppSettingsTableTableFilterComposer,
          $$AppSettingsTableTableOrderingComposer,
          $$AppSettingsTableTableAnnotationComposer,
          $$AppSettingsTableTableCreateCompanionBuilder,
          $$AppSettingsTableTableUpdateCompanionBuilder,
          (
            AppSettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $AppSettingsTableTable,
              AppSettingsTableData
            >,
          ),
          AppSettingsTableData,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableTableManager(
    _$AppDatabase db,
    $AppSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsTableCompanion(
                id: id,
                themeMode: themeMode,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsTableCompanion.insert(
                id: id,
                themeMode: themeMode,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTableTable,
      AppSettingsTableData,
      $$AppSettingsTableTableFilterComposer,
      $$AppSettingsTableTableOrderingComposer,
      $$AppSettingsTableTableAnnotationComposer,
      $$AppSettingsTableTableCreateCompanionBuilder,
      $$AppSettingsTableTableUpdateCompanionBuilder,
      (
        AppSettingsTableData,
        BaseReferences<
          _$AppDatabase,
          $AppSettingsTableTable,
          AppSettingsTableData
        >,
      ),
      AppSettingsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ServicesTableTableTableManager get servicesTable =>
      $$ServicesTableTableTableManager(_db, _db.servicesTable);
  $$AuthsTableTableTableManager get authsTable =>
      $$AuthsTableTableTableManager(_db, _db.authsTable);
  $$ProfileTableTableTableManager get profileTable =>
      $$ProfileTableTableTableManager(_db, _db.profileTable);
  $$UserAddressTableTableTableManager get userAddressTable =>
      $$UserAddressTableTableTableManager(_db, _db.userAddressTable);
  $$CartTableTableTableManager get cartTable =>
      $$CartTableTableTableManager(_db, _db.cartTable);
  $$BookingHistoryTableTableTableManager get bookingHistoryTable =>
      $$BookingHistoryTableTableTableManager(_db, _db.bookingHistoryTable);
  $$AppSettingsTableTableTableManager get appSettingsTable =>
      $$AppSettingsTableTableTableManager(_db, _db.appSettingsTable);
}
