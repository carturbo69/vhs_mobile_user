// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_database.dart';

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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ServicesTableTable servicesTable = $ServicesTableTable(this);
  late final $AuthsTableTable authsTable = $AuthsTableTable(this);
  late final ServicesDao servicesDao = ServicesDao(this as AppDatabase);
  late final AuthDao authDao = AuthDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    servicesTable,
    authsTable,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ServicesTableTableTableManager get servicesTable =>
      $$ServicesTableTableTableManager(_db, _db.servicesTable);
  $$AuthsTableTableTableManager get authsTable =>
      $$AuthsTableTableTableManager(_db, _db.authsTable);
}
