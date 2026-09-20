// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ReportsTable extends Reports with TableInfo<$ReportsTable, Report> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transcriptionMeta = const VerificationMeta(
    'transcription',
  );
  @override
  late final GeneratedColumn<String> transcription = GeneratedColumn<String>(
    'transcription',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _riskLevelMeta = const VerificationMeta(
    'riskLevel',
  );
  @override
  late final GeneratedColumn<String> riskLevel = GeneratedColumn<String>(
    'risk_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _a2uiBlueprintMeta = const VerificationMeta(
    'a2uiBlueprint',
  );
  @override
  late final GeneratedColumn<String> a2uiBlueprint = GeneratedColumn<String>(
    'a2ui_blueprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    timestamp,
    latitude,
    longitude,
    transcription,
    riskLevel,
    a2uiBlueprint,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<Report> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('transcription')) {
      context.handle(
        _transcriptionMeta,
        transcription.isAcceptableOrUnknown(
          data['transcription']!,
          _transcriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transcriptionMeta);
    }
    if (data.containsKey('risk_level')) {
      context.handle(
        _riskLevelMeta,
        riskLevel.isAcceptableOrUnknown(data['risk_level']!, _riskLevelMeta),
      );
    } else if (isInserting) {
      context.missing(_riskLevelMeta);
    }
    if (data.containsKey('a2ui_blueprint')) {
      context.handle(
        _a2uiBlueprintMeta,
        a2uiBlueprint.isAcceptableOrUnknown(
          data['a2ui_blueprint']!,
          _a2uiBlueprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_a2uiBlueprintMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Report map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Report(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      transcription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcription'],
      )!,
      riskLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}risk_level'],
      )!,
      a2uiBlueprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}a2ui_blueprint'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $ReportsTable createAlias(String alias) {
    return $ReportsTable(attachedDatabase, alias);
  }
}

class Report extends DataClass implements Insertable<Report> {
  final int id;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String transcription;
  final String riskLevel;
  final String a2uiBlueprint;
  final bool synced;
  const Report({
    required this.id,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.transcription,
    required this.riskLevel,
    required this.a2uiBlueprint,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['transcription'] = Variable<String>(transcription);
    map['risk_level'] = Variable<String>(riskLevel);
    map['a2ui_blueprint'] = Variable<String>(a2uiBlueprint);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  ReportsCompanion toCompanion(bool nullToAbsent) {
    return ReportsCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      latitude: Value(latitude),
      longitude: Value(longitude),
      transcription: Value(transcription),
      riskLevel: Value(riskLevel),
      a2uiBlueprint: Value(a2uiBlueprint),
      synced: Value(synced),
    );
  }

  factory Report.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Report(
      id: serializer.fromJson<int>(json['id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      transcription: serializer.fromJson<String>(json['transcription']),
      riskLevel: serializer.fromJson<String>(json['riskLevel']),
      a2uiBlueprint: serializer.fromJson<String>(json['a2uiBlueprint']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'transcription': serializer.toJson<String>(transcription),
      'riskLevel': serializer.toJson<String>(riskLevel),
      'a2uiBlueprint': serializer.toJson<String>(a2uiBlueprint),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  Report copyWith({
    int? id,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    String? transcription,
    String? riskLevel,
    String? a2uiBlueprint,
    bool? synced,
  }) => Report(
    id: id ?? this.id,
    timestamp: timestamp ?? this.timestamp,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    transcription: transcription ?? this.transcription,
    riskLevel: riskLevel ?? this.riskLevel,
    a2uiBlueprint: a2uiBlueprint ?? this.a2uiBlueprint,
    synced: synced ?? this.synced,
  );
  Report copyWithCompanion(ReportsCompanion data) {
    return Report(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      transcription: data.transcription.present
          ? data.transcription.value
          : this.transcription,
      riskLevel: data.riskLevel.present ? data.riskLevel.value : this.riskLevel,
      a2uiBlueprint: data.a2uiBlueprint.present
          ? data.a2uiBlueprint.value
          : this.a2uiBlueprint,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Report(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('transcription: $transcription, ')
          ..write('riskLevel: $riskLevel, ')
          ..write('a2uiBlueprint: $a2uiBlueprint, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    timestamp,
    latitude,
    longitude,
    transcription,
    riskLevel,
    a2uiBlueprint,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Report &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.transcription == this.transcription &&
          other.riskLevel == this.riskLevel &&
          other.a2uiBlueprint == this.a2uiBlueprint &&
          other.synced == this.synced);
}

class ReportsCompanion extends UpdateCompanion<Report> {
  final Value<int> id;
  final Value<DateTime> timestamp;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> transcription;
  final Value<String> riskLevel;
  final Value<String> a2uiBlueprint;
  final Value<bool> synced;
  const ReportsCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.transcription = const Value.absent(),
    this.riskLevel = const Value.absent(),
    this.a2uiBlueprint = const Value.absent(),
    this.synced = const Value.absent(),
  });
  ReportsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime timestamp,
    required double latitude,
    required double longitude,
    required String transcription,
    required String riskLevel,
    required String a2uiBlueprint,
    this.synced = const Value.absent(),
  }) : timestamp = Value(timestamp),
       latitude = Value(latitude),
       longitude = Value(longitude),
       transcription = Value(transcription),
       riskLevel = Value(riskLevel),
       a2uiBlueprint = Value(a2uiBlueprint);
  static Insertable<Report> custom({
    Expression<int>? id,
    Expression<DateTime>? timestamp,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? transcription,
    Expression<String>? riskLevel,
    Expression<String>? a2uiBlueprint,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (transcription != null) 'transcription': transcription,
      if (riskLevel != null) 'risk_level': riskLevel,
      if (a2uiBlueprint != null) 'a2ui_blueprint': a2uiBlueprint,
      if (synced != null) 'synced': synced,
    });
  }

  ReportsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? timestamp,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String>? transcription,
    Value<String>? riskLevel,
    Value<String>? a2uiBlueprint,
    Value<bool>? synced,
  }) {
    return ReportsCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      transcription: transcription ?? this.transcription,
      riskLevel: riskLevel ?? this.riskLevel,
      a2uiBlueprint: a2uiBlueprint ?? this.a2uiBlueprint,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (transcription.present) {
      map['transcription'] = Variable<String>(transcription.value);
    }
    if (riskLevel.present) {
      map['risk_level'] = Variable<String>(riskLevel.value);
    }
    if (a2uiBlueprint.present) {
      map['a2ui_blueprint'] = Variable<String>(a2uiBlueprint.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReportsCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('transcription: $transcription, ')
          ..write('riskLevel: $riskLevel, ')
          ..write('a2uiBlueprint: $a2uiBlueprint, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $ConflictDataTable extends ConflictData
    with TableInfo<$ConflictDataTable, ConflictDataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConflictDataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatalitiesMeta = const VerificationMeta(
    'fatalities',
  );
  @override
  late final GeneratedColumn<int> fatalities = GeneratedColumn<int>(
    'fatalities',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _locationNameMeta = const VerificationMeta(
    'locationName',
  );
  @override
  late final GeneratedColumn<String> locationName = GeneratedColumn<String>(
    'location_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    latitude,
    longitude,
    type,
    severity,
    fatalities,
    locationName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conflict_data';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConflictDataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('fatalities')) {
      context.handle(
        _fatalitiesMeta,
        fatalities.isAcceptableOrUnknown(data['fatalities']!, _fatalitiesMeta),
      );
    }
    if (data.containsKey('location_name')) {
      context.handle(
        _locationNameMeta,
        locationName.isAcceptableOrUnknown(
          data['location_name']!,
          _locationNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_locationNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConflictDataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConflictDataData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      fatalities: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fatalities'],
      )!,
      locationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_name'],
      )!,
    );
  }

  @override
  $ConflictDataTable createAlias(String alias) {
    return $ConflictDataTable(attachedDatabase, alias);
  }
}

class ConflictDataData extends DataClass
    implements Insertable<ConflictDataData> {
  final int id;
  final DateTime date;
  final double latitude;
  final double longitude;
  final String type;
  final String severity;
  final int fatalities;
  final String locationName;
  const ConflictDataData({
    required this.id,
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.severity,
    required this.fatalities,
    required this.locationName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['type'] = Variable<String>(type);
    map['severity'] = Variable<String>(severity);
    map['fatalities'] = Variable<int>(fatalities);
    map['location_name'] = Variable<String>(locationName);
    return map;
  }

  ConflictDataCompanion toCompanion(bool nullToAbsent) {
    return ConflictDataCompanion(
      id: Value(id),
      date: Value(date),
      latitude: Value(latitude),
      longitude: Value(longitude),
      type: Value(type),
      severity: Value(severity),
      fatalities: Value(fatalities),
      locationName: Value(locationName),
    );
  }

  factory ConflictDataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConflictDataData(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      type: serializer.fromJson<String>(json['type']),
      severity: serializer.fromJson<String>(json['severity']),
      fatalities: serializer.fromJson<int>(json['fatalities']),
      locationName: serializer.fromJson<String>(json['locationName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'type': serializer.toJson<String>(type),
      'severity': serializer.toJson<String>(severity),
      'fatalities': serializer.toJson<int>(fatalities),
      'locationName': serializer.toJson<String>(locationName),
    };
  }

  ConflictDataData copyWith({
    int? id,
    DateTime? date,
    double? latitude,
    double? longitude,
    String? type,
    String? severity,
    int? fatalities,
    String? locationName,
  }) => ConflictDataData(
    id: id ?? this.id,
    date: date ?? this.date,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    type: type ?? this.type,
    severity: severity ?? this.severity,
    fatalities: fatalities ?? this.fatalities,
    locationName: locationName ?? this.locationName,
  );
  ConflictDataData copyWithCompanion(ConflictDataCompanion data) {
    return ConflictDataData(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      type: data.type.present ? data.type.value : this.type,
      severity: data.severity.present ? data.severity.value : this.severity,
      fatalities: data.fatalities.present
          ? data.fatalities.value
          : this.fatalities,
      locationName: data.locationName.present
          ? data.locationName.value
          : this.locationName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConflictDataData(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('type: $type, ')
          ..write('severity: $severity, ')
          ..write('fatalities: $fatalities, ')
          ..write('locationName: $locationName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    latitude,
    longitude,
    type,
    severity,
    fatalities,
    locationName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConflictDataData &&
          other.id == this.id &&
          other.date == this.date &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.type == this.type &&
          other.severity == this.severity &&
          other.fatalities == this.fatalities &&
          other.locationName == this.locationName);
}

class ConflictDataCompanion extends UpdateCompanion<ConflictDataData> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> type;
  final Value<String> severity;
  final Value<int> fatalities;
  final Value<String> locationName;
  const ConflictDataCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.type = const Value.absent(),
    this.severity = const Value.absent(),
    this.fatalities = const Value.absent(),
    this.locationName = const Value.absent(),
  });
  ConflictDataCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required double latitude,
    required double longitude,
    required String type,
    required String severity,
    this.fatalities = const Value.absent(),
    required String locationName,
  }) : date = Value(date),
       latitude = Value(latitude),
       longitude = Value(longitude),
       type = Value(type),
       severity = Value(severity),
       locationName = Value(locationName);
  static Insertable<ConflictDataData> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? type,
    Expression<String>? severity,
    Expression<int>? fatalities,
    Expression<String>? locationName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (type != null) 'type': type,
      if (severity != null) 'severity': severity,
      if (fatalities != null) 'fatalities': fatalities,
      if (locationName != null) 'location_name': locationName,
    });
  }

  ConflictDataCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String>? type,
    Value<String>? severity,
    Value<int>? fatalities,
    Value<String>? locationName,
  }) {
    return ConflictDataCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      fatalities: fatalities ?? this.fatalities,
      locationName: locationName ?? this.locationName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (fatalities.present) {
      map['fatalities'] = Variable<int>(fatalities.value);
    }
    if (locationName.present) {
      map['location_name'] = Variable<String>(locationName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConflictDataCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('type: $type, ')
          ..write('severity: $severity, ')
          ..write('fatalities: $fatalities, ')
          ..write('locationName: $locationName')
          ..write(')'))
        .toString();
  }
}

class $CacheTable extends Cache with TableInfo<$CacheTable, CacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, timestamp, expiresAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<CacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  CacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
    );
  }

  @override
  $CacheTable createAlias(String alias) {
    return $CacheTable(attachedDatabase, alias);
  }
}

class CacheData extends DataClass implements Insertable<CacheData> {
  final String key;
  final String value;
  final DateTime timestamp;
  final DateTime expiresAt;
  const CacheData({
    required this.key,
    required this.value,
    required this.timestamp,
    required this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    return map;
  }

  CacheCompanion toCompanion(bool nullToAbsent) {
    return CacheCompanion(
      key: Value(key),
      value: Value(value),
      timestamp: Value(timestamp),
      expiresAt: Value(expiresAt),
    );
  }

  factory CacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
    };
  }

  CacheData copyWith({
    String? key,
    String? value,
    DateTime? timestamp,
    DateTime? expiresAt,
  }) => CacheData(
    key: key ?? this.key,
    value: value ?? this.value,
    timestamp: timestamp ?? this.timestamp,
    expiresAt: expiresAt ?? this.expiresAt,
  );
  CacheData copyWithCompanion(CacheCompanion data) {
    return CacheData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheData(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('timestamp: $timestamp, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, timestamp, expiresAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheData &&
          other.key == this.key &&
          other.value == this.value &&
          other.timestamp == this.timestamp &&
          other.expiresAt == this.expiresAt);
}

class CacheCompanion extends UpdateCompanion<CacheData> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> timestamp;
  final Value<DateTime> expiresAt;
  final Value<int> rowid;
  const CacheCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheCompanion.insert({
    required String key,
    required String value,
    required DateTime timestamp,
    required DateTime expiresAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       timestamp = Value(timestamp),
       expiresAt = Value(expiresAt);
  static Insertable<CacheData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? timestamp,
    Expression<DateTime>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (timestamp != null) 'timestamp': timestamp,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? timestamp,
    Value<DateTime>? expiresAt,
    Value<int>? rowid,
  }) {
    return CacheCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      timestamp: timestamp ?? this.timestamp,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('timestamp: $timestamp, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ReportsTable reports = $ReportsTable(this);
  late final $ConflictDataTable conflictData = $ConflictDataTable(this);
  late final $CacheTable cache = $CacheTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    reports,
    conflictData,
    cache,
  ];
}

typedef $$ReportsTableCreateCompanionBuilder = ReportsCompanion Function({
  Value<int> id,
  required DateTime timestamp,
  required double latitude,
  required double longitude,
  required String transcription,
  required String riskLevel,
  required String a2uiBlueprint,
  Value<bool> synced,
});
typedef $$ReportsTableUpdateCompanionBuilder = ReportsCompanion Function({
  Value<int> id,
  Value<DateTime> timestamp,
  Value<double> latitude,
  Value<double> longitude,
  Value<String> transcription,
  Value<String> riskLevel,
  Value<String> a2uiBlueprint,
  Value<bool> synced,
});

class $$ReportsTableFilterComposer
    extends Composer<_$AppDatabase, $ReportsTable> {
  $$ReportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
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

  ColumnFilters<String> get transcription => $composableBuilder(
    column: $table.transcription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get riskLevel => $composableBuilder(
    column: $table.riskLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get a2uiBlueprint => $composableBuilder(
    column: $table.a2uiBlueprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReportsTable> {
  $$ReportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
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

  ColumnOrderings<String> get transcription => $composableBuilder(
    column: $table.transcription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get riskLevel => $composableBuilder(
    column: $table.riskLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get a2uiBlueprint => $composableBuilder(
    column: $table.a2uiBlueprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReportsTable> {
  $$ReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get transcription => $composableBuilder(
    column: $table.transcription,
    builder: (column) => column,
  );

  GeneratedColumn<String> get riskLevel =>
      $composableBuilder(column: $table.riskLevel, builder: (column) => column);

  GeneratedColumn<String> get a2uiBlueprint => $composableBuilder(
    column: $table.a2uiBlueprint,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$ReportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReportsTable,
          Report,
          $$ReportsTableFilterComposer,
          $$ReportsTableOrderingComposer,
          $$ReportsTableAnnotationComposer,
          $$ReportsTableCreateCompanionBuilder,
          $$ReportsTableUpdateCompanionBuilder,
          (Report, BaseReferences<_$AppDatabase, $ReportsTable, Report>),
          Report,
          PrefetchHooks Function()
        > {
  $$ReportsTableTableManager(_$AppDatabase db, $ReportsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String> transcription = const Value.absent(),
                Value<String> riskLevel = const Value.absent(),
                Value<String> a2uiBlueprint = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => ReportsCompanion(
                id: id,
                timestamp: timestamp,
                latitude: latitude,
                longitude: longitude,
                transcription: transcription,
                riskLevel: riskLevel,
                a2uiBlueprint: a2uiBlueprint,
                synced: synced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime timestamp,
                required double latitude,
                required double longitude,
                required String transcription,
                required String riskLevel,
                required String a2uiBlueprint,
                Value<bool> synced = const Value.absent(),
              }) => ReportsCompanion.insert(
                id: id,
                timestamp: timestamp,
                latitude: latitude,
                longitude: longitude,
                transcription: transcription,
                riskLevel: riskLevel,
                a2uiBlueprint: a2uiBlueprint,
                synced: synced,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReportsTable, Report>(table),
                  BaseReferences<_$AppDatabase, $ReportsTable, Report>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReportsTable,
      Report,
      $$ReportsTableFilterComposer,
      $$ReportsTableOrderingComposer,
      $$ReportsTableAnnotationComposer,
      $$ReportsTableCreateCompanionBuilder,
      $$ReportsTableUpdateCompanionBuilder,
      (Report, BaseReferences<_$AppDatabase, $ReportsTable, Report>),
      Report,
      PrefetchHooks Function()
    >;
typedef $$ConflictDataTableCreateCompanionBuilder =
    ConflictDataCompanion Function({
      Value<int> id,
      required DateTime date,
      required double latitude,
      required double longitude,
      required String type,
      required String severity,
      Value<int> fatalities,
      required String locationName,
    });
typedef $$ConflictDataTableUpdateCompanionBuilder =
    ConflictDataCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<double> latitude,
      Value<double> longitude,
      Value<String> type,
      Value<String> severity,
      Value<int> fatalities,
      Value<String> locationName,
    });

class $$ConflictDataTableFilterComposer
    extends Composer<_$AppDatabase, $ConflictDataTable> {
  $$ConflictDataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fatalities => $composableBuilder(
    column: $table.fatalities,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConflictDataTableOrderingComposer
    extends Composer<_$AppDatabase, $ConflictDataTable> {
  $$ConflictDataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fatalities => $composableBuilder(
    column: $table.fatalities,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConflictDataTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConflictDataTable> {
  $$ConflictDataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<int> get fatalities => $composableBuilder(
    column: $table.fatalities,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => column,
  );
}

class $$ConflictDataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConflictDataTable,
          ConflictDataData,
          $$ConflictDataTableFilterComposer,
          $$ConflictDataTableOrderingComposer,
          $$ConflictDataTableAnnotationComposer,
          $$ConflictDataTableCreateCompanionBuilder,
          $$ConflictDataTableUpdateCompanionBuilder,
          (
            ConflictDataData,
            BaseReferences<_$AppDatabase, $ConflictDataTable, ConflictDataData>,
          ),
          ConflictDataData,
          PrefetchHooks Function()
        > {
  $$ConflictDataTableTableManager(_$AppDatabase db, $ConflictDataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConflictDataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConflictDataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConflictDataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<int> fatalities = const Value.absent(),
                Value<String> locationName = const Value.absent(),
              }) => ConflictDataCompanion(
                id: id,
                date: date,
                latitude: latitude,
                longitude: longitude,
                type: type,
                severity: severity,
                fatalities: fatalities,
                locationName: locationName,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required double latitude,
                required double longitude,
                required String type,
                required String severity,
                Value<int> fatalities = const Value.absent(),
                required String locationName,
              }) => ConflictDataCompanion.insert(
                id: id,
                date: date,
                latitude: latitude,
                longitude: longitude,
                type: type,
                severity: severity,
                fatalities: fatalities,
                locationName: locationName,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConflictDataTable, ConflictDataData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ConflictDataTable,
                    ConflictDataData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConflictDataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConflictDataTable,
      ConflictDataData,
      $$ConflictDataTableFilterComposer,
      $$ConflictDataTableOrderingComposer,
      $$ConflictDataTableAnnotationComposer,
      $$ConflictDataTableCreateCompanionBuilder,
      $$ConflictDataTableUpdateCompanionBuilder,
      (
        ConflictDataData,
        BaseReferences<_$AppDatabase, $ConflictDataTable, ConflictDataData>,
      ),
      ConflictDataData,
      PrefetchHooks Function()
    >;
typedef $$CacheTableCreateCompanionBuilder = CacheCompanion Function({
  required String key,
  required String value,
  required DateTime timestamp,
  required DateTime expiresAt,
  Value<int> rowid,
});
typedef $$CacheTableUpdateCompanionBuilder = CacheCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<DateTime> timestamp,
  Value<DateTime> expiresAt,
  Value<int> rowid,
});

class $$CacheTableFilterComposer extends Composer<_$AppDatabase, $CacheTable> {
  $$CacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CacheTableOrderingComposer
    extends Composer<_$AppDatabase, $CacheTable> {
  $$CacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $CacheTable> {
  $$CacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$CacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CacheTable,
          CacheData,
          $$CacheTableFilterComposer,
          $$CacheTableOrderingComposer,
          $$CacheTableAnnotationComposer,
          $$CacheTableCreateCompanionBuilder,
          $$CacheTableUpdateCompanionBuilder,
          (CacheData, BaseReferences<_$AppDatabase, $CacheTable, CacheData>),
          CacheData,
          PrefetchHooks Function()
        > {
  $$CacheTableTableManager(_$AppDatabase db, $CacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheCompanion(
                key: key,
                value: value,
                timestamp: timestamp,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime timestamp,
                required DateTime expiresAt,
                Value<int> rowid = const Value.absent(),
              }) => CacheCompanion.insert(
                key: key,
                value: value,
                timestamp: timestamp,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CacheTable, CacheData>(table),
                  BaseReferences<_$AppDatabase, $CacheTable, CacheData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CacheTable,
      CacheData,
      $$CacheTableFilterComposer,
      $$CacheTableOrderingComposer,
      $$CacheTableAnnotationComposer,
      $$CacheTableCreateCompanionBuilder,
      $$CacheTableUpdateCompanionBuilder,
      (CacheData, BaseReferences<_$AppDatabase, $CacheTable, CacheData>),
      CacheData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ReportsTableTableManager get reports =>
      $$ReportsTableTableManager(_db, _db.reports);
  $$ConflictDataTableTableManager get conflictData =>
      $$ConflictDataTableTableManager(_db, _db.conflictData);
  $$CacheTableTableManager get cache =>
      $$CacheTableTableManager(_db, _db.cache);
}
