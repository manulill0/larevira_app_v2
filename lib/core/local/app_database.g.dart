// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $HttpCacheEntriesTable extends HttpCacheEntries
    with TableInfo<$HttpCacheEntriesTable, HttpCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HttpCacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, payload, savedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'http_cache_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<HttpCacheEntry> instance, {
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
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  HttpCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HttpCacheEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
    );
  }

  @override
  $HttpCacheEntriesTable createAlias(String alias) {
    return $HttpCacheEntriesTable(attachedDatabase, alias);
  }
}

class HttpCacheEntry extends DataClass implements Insertable<HttpCacheEntry> {
  final String key;
  final String payload;
  final DateTime savedAt;
  const HttpCacheEntry({
    required this.key,
    required this.payload,
    required this.savedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['payload'] = Variable<String>(payload);
    map['saved_at'] = Variable<DateTime>(savedAt);
    return map;
  }

  HttpCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return HttpCacheEntriesCompanion(
      key: Value(key),
      payload: Value(payload),
      savedAt: Value(savedAt),
    );
  }

  factory HttpCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HttpCacheEntry(
      key: serializer.fromJson<String>(json['key']),
      payload: serializer.fromJson<String>(json['payload']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'payload': serializer.toJson<String>(payload),
      'savedAt': serializer.toJson<DateTime>(savedAt),
    };
  }

  HttpCacheEntry copyWith({String? key, String? payload, DateTime? savedAt}) =>
      HttpCacheEntry(
        key: key ?? this.key,
        payload: payload ?? this.payload,
        savedAt: savedAt ?? this.savedAt,
      );
  HttpCacheEntry copyWithCompanion(HttpCacheEntriesCompanion data) {
    return HttpCacheEntry(
      key: data.key.present ? data.key.value : this.key,
      payload: data.payload.present ? data.payload.value : this.payload,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HttpCacheEntry(')
          ..write('key: $key, ')
          ..write('payload: $payload, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, payload, savedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HttpCacheEntry &&
          other.key == this.key &&
          other.payload == this.payload &&
          other.savedAt == this.savedAt);
}

class HttpCacheEntriesCompanion extends UpdateCompanion<HttpCacheEntry> {
  final Value<String> key;
  final Value<String> payload;
  final Value<DateTime> savedAt;
  final Value<int> rowid;
  const HttpCacheEntriesCompanion({
    this.key = const Value.absent(),
    this.payload = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HttpCacheEntriesCompanion.insert({
    required String key,
    required String payload,
    required DateTime savedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       payload = Value(payload),
       savedAt = Value(savedAt);
  static Insertable<HttpCacheEntry> custom({
    Expression<String>? key,
    Expression<String>? payload,
    Expression<DateTime>? savedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (payload != null) 'payload': payload,
      if (savedAt != null) 'saved_at': savedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HttpCacheEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? payload,
    Value<DateTime>? savedAt,
    Value<int>? rowid,
  }) {
    return HttpCacheEntriesCompanion(
      key: key ?? this.key,
      payload: payload ?? this.payload,
      savedAt: savedAt ?? this.savedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
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
    return (StringBuffer('HttpCacheEntriesCompanion(')
          ..write('key: $key, ')
          ..write('payload: $payload, ')
          ..write('savedAt: $savedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DaysTable extends Days with TableInfo<$DaysTable, Day> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _citySlugMeta = const VerificationMeta(
    'citySlug',
  );
  @override
  late final GeneratedColumn<String> citySlug = GeneratedColumn<String>(
    'city_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearValueMeta = const VerificationMeta(
    'yearValue',
  );
  @override
  late final GeneratedColumn<int> yearValue = GeneratedColumn<int>(
    'year_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startsAtMeta = const VerificationMeta(
    'startsAt',
  );
  @override
  late final GeneratedColumn<DateTime> startsAt = GeneratedColumn<DateTime>(
    'starts_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _liturgicalDateMeta = const VerificationMeta(
    'liturgicalDate',
  );
  @override
  late final GeneratedColumn<DateTime> liturgicalDate =
      GeneratedColumn<DateTime>(
        'liturgical_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _processionEventsCountMeta =
      const VerificationMeta('processionEventsCount');
  @override
  late final GeneratedColumn<int> processionEventsCount = GeneratedColumn<int>(
    'procession_events_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weatherIconCodeMeta = const VerificationMeta(
    'weatherIconCode',
  );
  @override
  late final GeneratedColumn<String> weatherIconCode = GeneratedColumn<String>(
    'weather_icon_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weatherConditionLabelMeta =
      const VerificationMeta('weatherConditionLabel');
  @override
  late final GeneratedColumn<String> weatherConditionLabel =
      GeneratedColumn<String>(
        'weather_condition_label',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _weatherTempMinCMeta = const VerificationMeta(
    'weatherTempMinC',
  );
  @override
  late final GeneratedColumn<double> weatherTempMinC = GeneratedColumn<double>(
    'weather_temp_min_c',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weatherTempMaxCMeta = const VerificationMeta(
    'weatherTempMaxC',
  );
  @override
  late final GeneratedColumn<double> weatherTempMaxC = GeneratedColumn<double>(
    'weather_temp_max_c',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weatherHourlyJsonMeta = const VerificationMeta(
    'weatherHourlyJson',
  );
  @override
  late final GeneratedColumn<String> weatherHourlyJson =
      GeneratedColumn<String>(
        'weather_hourly_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    citySlug,
    yearValue,
    mode,
    slug,
    name,
    startsAt,
    liturgicalDate,
    processionEventsCount,
    weatherIconCode,
    weatherConditionLabel,
    weatherTempMinC,
    weatherTempMaxC,
    weatherHourlyJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'days';
  @override
  VerificationContext validateIntegrity(
    Insertable<Day> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('city_slug')) {
      context.handle(
        _citySlugMeta,
        citySlug.isAcceptableOrUnknown(data['city_slug']!, _citySlugMeta),
      );
    } else if (isInserting) {
      context.missing(_citySlugMeta);
    }
    if (data.containsKey('year_value')) {
      context.handle(
        _yearValueMeta,
        yearValue.isAcceptableOrUnknown(data['year_value']!, _yearValueMeta),
      );
    } else if (isInserting) {
      context.missing(_yearValueMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
      );
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('starts_at')) {
      context.handle(
        _startsAtMeta,
        startsAt.isAcceptableOrUnknown(data['starts_at']!, _startsAtMeta),
      );
    }
    if (data.containsKey('liturgical_date')) {
      context.handle(
        _liturgicalDateMeta,
        liturgicalDate.isAcceptableOrUnknown(
          data['liturgical_date']!,
          _liturgicalDateMeta,
        ),
      );
    }
    if (data.containsKey('procession_events_count')) {
      context.handle(
        _processionEventsCountMeta,
        processionEventsCount.isAcceptableOrUnknown(
          data['procession_events_count']!,
          _processionEventsCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_processionEventsCountMeta);
    }
    if (data.containsKey('weather_icon_code')) {
      context.handle(
        _weatherIconCodeMeta,
        weatherIconCode.isAcceptableOrUnknown(
          data['weather_icon_code']!,
          _weatherIconCodeMeta,
        ),
      );
    }
    if (data.containsKey('weather_condition_label')) {
      context.handle(
        _weatherConditionLabelMeta,
        weatherConditionLabel.isAcceptableOrUnknown(
          data['weather_condition_label']!,
          _weatherConditionLabelMeta,
        ),
      );
    }
    if (data.containsKey('weather_temp_min_c')) {
      context.handle(
        _weatherTempMinCMeta,
        weatherTempMinC.isAcceptableOrUnknown(
          data['weather_temp_min_c']!,
          _weatherTempMinCMeta,
        ),
      );
    }
    if (data.containsKey('weather_temp_max_c')) {
      context.handle(
        _weatherTempMaxCMeta,
        weatherTempMaxC.isAcceptableOrUnknown(
          data['weather_temp_max_c']!,
          _weatherTempMaxCMeta,
        ),
      );
    }
    if (data.containsKey('weather_hourly_json')) {
      context.handle(
        _weatherHourlyJsonMeta,
        weatherHourlyJson.isAcceptableOrUnknown(
          data['weather_hourly_json']!,
          _weatherHourlyJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {citySlug, yearValue, mode, slug};
  @override
  Day map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Day(
      citySlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city_slug'],
      )!,
      yearValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_value'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      slug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slug'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      startsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}starts_at'],
      ),
      liturgicalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}liturgical_date'],
      ),
      processionEventsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}procession_events_count'],
      )!,
      weatherIconCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weather_icon_code'],
      ),
      weatherConditionLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weather_condition_label'],
      ),
      weatherTempMinC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weather_temp_min_c'],
      ),
      weatherTempMaxC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weather_temp_max_c'],
      ),
      weatherHourlyJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weather_hourly_json'],
      ),
    );
  }

  @override
  $DaysTable createAlias(String alias) {
    return $DaysTable(attachedDatabase, alias);
  }
}

class Day extends DataClass implements Insertable<Day> {
  final String citySlug;
  final int yearValue;
  final String mode;
  final String slug;
  final String name;
  final DateTime? startsAt;
  final DateTime? liturgicalDate;
  final int processionEventsCount;
  final String? weatherIconCode;
  final String? weatherConditionLabel;
  final double? weatherTempMinC;
  final double? weatherTempMaxC;
  final String? weatherHourlyJson;
  const Day({
    required this.citySlug,
    required this.yearValue,
    required this.mode,
    required this.slug,
    required this.name,
    this.startsAt,
    this.liturgicalDate,
    required this.processionEventsCount,
    this.weatherIconCode,
    this.weatherConditionLabel,
    this.weatherTempMinC,
    this.weatherTempMaxC,
    this.weatherHourlyJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['city_slug'] = Variable<String>(citySlug);
    map['year_value'] = Variable<int>(yearValue);
    map['mode'] = Variable<String>(mode);
    map['slug'] = Variable<String>(slug);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || startsAt != null) {
      map['starts_at'] = Variable<DateTime>(startsAt);
    }
    if (!nullToAbsent || liturgicalDate != null) {
      map['liturgical_date'] = Variable<DateTime>(liturgicalDate);
    }
    map['procession_events_count'] = Variable<int>(processionEventsCount);
    if (!nullToAbsent || weatherIconCode != null) {
      map['weather_icon_code'] = Variable<String>(weatherIconCode);
    }
    if (!nullToAbsent || weatherConditionLabel != null) {
      map['weather_condition_label'] = Variable<String>(weatherConditionLabel);
    }
    if (!nullToAbsent || weatherTempMinC != null) {
      map['weather_temp_min_c'] = Variable<double>(weatherTempMinC);
    }
    if (!nullToAbsent || weatherTempMaxC != null) {
      map['weather_temp_max_c'] = Variable<double>(weatherTempMaxC);
    }
    if (!nullToAbsent || weatherHourlyJson != null) {
      map['weather_hourly_json'] = Variable<String>(weatherHourlyJson);
    }
    return map;
  }

  DaysCompanion toCompanion(bool nullToAbsent) {
    return DaysCompanion(
      citySlug: Value(citySlug),
      yearValue: Value(yearValue),
      mode: Value(mode),
      slug: Value(slug),
      name: Value(name),
      startsAt: startsAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startsAt),
      liturgicalDate: liturgicalDate == null && nullToAbsent
          ? const Value.absent()
          : Value(liturgicalDate),
      processionEventsCount: Value(processionEventsCount),
      weatherIconCode: weatherIconCode == null && nullToAbsent
          ? const Value.absent()
          : Value(weatherIconCode),
      weatherConditionLabel: weatherConditionLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(weatherConditionLabel),
      weatherTempMinC: weatherTempMinC == null && nullToAbsent
          ? const Value.absent()
          : Value(weatherTempMinC),
      weatherTempMaxC: weatherTempMaxC == null && nullToAbsent
          ? const Value.absent()
          : Value(weatherTempMaxC),
      weatherHourlyJson: weatherHourlyJson == null && nullToAbsent
          ? const Value.absent()
          : Value(weatherHourlyJson),
    );
  }

  factory Day.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Day(
      citySlug: serializer.fromJson<String>(json['citySlug']),
      yearValue: serializer.fromJson<int>(json['yearValue']),
      mode: serializer.fromJson<String>(json['mode']),
      slug: serializer.fromJson<String>(json['slug']),
      name: serializer.fromJson<String>(json['name']),
      startsAt: serializer.fromJson<DateTime?>(json['startsAt']),
      liturgicalDate: serializer.fromJson<DateTime?>(json['liturgicalDate']),
      processionEventsCount: serializer.fromJson<int>(
        json['processionEventsCount'],
      ),
      weatherIconCode: serializer.fromJson<String?>(json['weatherIconCode']),
      weatherConditionLabel: serializer.fromJson<String?>(
        json['weatherConditionLabel'],
      ),
      weatherTempMinC: serializer.fromJson<double?>(json['weatherTempMinC']),
      weatherTempMaxC: serializer.fromJson<double?>(json['weatherTempMaxC']),
      weatherHourlyJson: serializer.fromJson<String?>(
        json['weatherHourlyJson'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'citySlug': serializer.toJson<String>(citySlug),
      'yearValue': serializer.toJson<int>(yearValue),
      'mode': serializer.toJson<String>(mode),
      'slug': serializer.toJson<String>(slug),
      'name': serializer.toJson<String>(name),
      'startsAt': serializer.toJson<DateTime?>(startsAt),
      'liturgicalDate': serializer.toJson<DateTime?>(liturgicalDate),
      'processionEventsCount': serializer.toJson<int>(processionEventsCount),
      'weatherIconCode': serializer.toJson<String?>(weatherIconCode),
      'weatherConditionLabel': serializer.toJson<String?>(
        weatherConditionLabel,
      ),
      'weatherTempMinC': serializer.toJson<double?>(weatherTempMinC),
      'weatherTempMaxC': serializer.toJson<double?>(weatherTempMaxC),
      'weatherHourlyJson': serializer.toJson<String?>(weatherHourlyJson),
    };
  }

  Day copyWith({
    String? citySlug,
    int? yearValue,
    String? mode,
    String? slug,
    String? name,
    Value<DateTime?> startsAt = const Value.absent(),
    Value<DateTime?> liturgicalDate = const Value.absent(),
    int? processionEventsCount,
    Value<String?> weatherIconCode = const Value.absent(),
    Value<String?> weatherConditionLabel = const Value.absent(),
    Value<double?> weatherTempMinC = const Value.absent(),
    Value<double?> weatherTempMaxC = const Value.absent(),
    Value<String?> weatherHourlyJson = const Value.absent(),
  }) => Day(
    citySlug: citySlug ?? this.citySlug,
    yearValue: yearValue ?? this.yearValue,
    mode: mode ?? this.mode,
    slug: slug ?? this.slug,
    name: name ?? this.name,
    startsAt: startsAt.present ? startsAt.value : this.startsAt,
    liturgicalDate: liturgicalDate.present
        ? liturgicalDate.value
        : this.liturgicalDate,
    processionEventsCount: processionEventsCount ?? this.processionEventsCount,
    weatherIconCode: weatherIconCode.present
        ? weatherIconCode.value
        : this.weatherIconCode,
    weatherConditionLabel: weatherConditionLabel.present
        ? weatherConditionLabel.value
        : this.weatherConditionLabel,
    weatherTempMinC: weatherTempMinC.present
        ? weatherTempMinC.value
        : this.weatherTempMinC,
    weatherTempMaxC: weatherTempMaxC.present
        ? weatherTempMaxC.value
        : this.weatherTempMaxC,
    weatherHourlyJson: weatherHourlyJson.present
        ? weatherHourlyJson.value
        : this.weatherHourlyJson,
  );
  Day copyWithCompanion(DaysCompanion data) {
    return Day(
      citySlug: data.citySlug.present ? data.citySlug.value : this.citySlug,
      yearValue: data.yearValue.present ? data.yearValue.value : this.yearValue,
      mode: data.mode.present ? data.mode.value : this.mode,
      slug: data.slug.present ? data.slug.value : this.slug,
      name: data.name.present ? data.name.value : this.name,
      startsAt: data.startsAt.present ? data.startsAt.value : this.startsAt,
      liturgicalDate: data.liturgicalDate.present
          ? data.liturgicalDate.value
          : this.liturgicalDate,
      processionEventsCount: data.processionEventsCount.present
          ? data.processionEventsCount.value
          : this.processionEventsCount,
      weatherIconCode: data.weatherIconCode.present
          ? data.weatherIconCode.value
          : this.weatherIconCode,
      weatherConditionLabel: data.weatherConditionLabel.present
          ? data.weatherConditionLabel.value
          : this.weatherConditionLabel,
      weatherTempMinC: data.weatherTempMinC.present
          ? data.weatherTempMinC.value
          : this.weatherTempMinC,
      weatherTempMaxC: data.weatherTempMaxC.present
          ? data.weatherTempMaxC.value
          : this.weatherTempMaxC,
      weatherHourlyJson: data.weatherHourlyJson.present
          ? data.weatherHourlyJson.value
          : this.weatherHourlyJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Day(')
          ..write('citySlug: $citySlug, ')
          ..write('yearValue: $yearValue, ')
          ..write('mode: $mode, ')
          ..write('slug: $slug, ')
          ..write('name: $name, ')
          ..write('startsAt: $startsAt, ')
          ..write('liturgicalDate: $liturgicalDate, ')
          ..write('processionEventsCount: $processionEventsCount, ')
          ..write('weatherIconCode: $weatherIconCode, ')
          ..write('weatherConditionLabel: $weatherConditionLabel, ')
          ..write('weatherTempMinC: $weatherTempMinC, ')
          ..write('weatherTempMaxC: $weatherTempMaxC, ')
          ..write('weatherHourlyJson: $weatherHourlyJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    citySlug,
    yearValue,
    mode,
    slug,
    name,
    startsAt,
    liturgicalDate,
    processionEventsCount,
    weatherIconCode,
    weatherConditionLabel,
    weatherTempMinC,
    weatherTempMaxC,
    weatherHourlyJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Day &&
          other.citySlug == this.citySlug &&
          other.yearValue == this.yearValue &&
          other.mode == this.mode &&
          other.slug == this.slug &&
          other.name == this.name &&
          other.startsAt == this.startsAt &&
          other.liturgicalDate == this.liturgicalDate &&
          other.processionEventsCount == this.processionEventsCount &&
          other.weatherIconCode == this.weatherIconCode &&
          other.weatherConditionLabel == this.weatherConditionLabel &&
          other.weatherTempMinC == this.weatherTempMinC &&
          other.weatherTempMaxC == this.weatherTempMaxC &&
          other.weatherHourlyJson == this.weatherHourlyJson);
}

class DaysCompanion extends UpdateCompanion<Day> {
  final Value<String> citySlug;
  final Value<int> yearValue;
  final Value<String> mode;
  final Value<String> slug;
  final Value<String> name;
  final Value<DateTime?> startsAt;
  final Value<DateTime?> liturgicalDate;
  final Value<int> processionEventsCount;
  final Value<String?> weatherIconCode;
  final Value<String?> weatherConditionLabel;
  final Value<double?> weatherTempMinC;
  final Value<double?> weatherTempMaxC;
  final Value<String?> weatherHourlyJson;
  final Value<int> rowid;
  const DaysCompanion({
    this.citySlug = const Value.absent(),
    this.yearValue = const Value.absent(),
    this.mode = const Value.absent(),
    this.slug = const Value.absent(),
    this.name = const Value.absent(),
    this.startsAt = const Value.absent(),
    this.liturgicalDate = const Value.absent(),
    this.processionEventsCount = const Value.absent(),
    this.weatherIconCode = const Value.absent(),
    this.weatherConditionLabel = const Value.absent(),
    this.weatherTempMinC = const Value.absent(),
    this.weatherTempMaxC = const Value.absent(),
    this.weatherHourlyJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DaysCompanion.insert({
    required String citySlug,
    required int yearValue,
    required String mode,
    required String slug,
    required String name,
    this.startsAt = const Value.absent(),
    this.liturgicalDate = const Value.absent(),
    required int processionEventsCount,
    this.weatherIconCode = const Value.absent(),
    this.weatherConditionLabel = const Value.absent(),
    this.weatherTempMinC = const Value.absent(),
    this.weatherTempMaxC = const Value.absent(),
    this.weatherHourlyJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : citySlug = Value(citySlug),
       yearValue = Value(yearValue),
       mode = Value(mode),
       slug = Value(slug),
       name = Value(name),
       processionEventsCount = Value(processionEventsCount);
  static Insertable<Day> custom({
    Expression<String>? citySlug,
    Expression<int>? yearValue,
    Expression<String>? mode,
    Expression<String>? slug,
    Expression<String>? name,
    Expression<DateTime>? startsAt,
    Expression<DateTime>? liturgicalDate,
    Expression<int>? processionEventsCount,
    Expression<String>? weatherIconCode,
    Expression<String>? weatherConditionLabel,
    Expression<double>? weatherTempMinC,
    Expression<double>? weatherTempMaxC,
    Expression<String>? weatherHourlyJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (citySlug != null) 'city_slug': citySlug,
      if (yearValue != null) 'year_value': yearValue,
      if (mode != null) 'mode': mode,
      if (slug != null) 'slug': slug,
      if (name != null) 'name': name,
      if (startsAt != null) 'starts_at': startsAt,
      if (liturgicalDate != null) 'liturgical_date': liturgicalDate,
      if (processionEventsCount != null)
        'procession_events_count': processionEventsCount,
      if (weatherIconCode != null) 'weather_icon_code': weatherIconCode,
      if (weatherConditionLabel != null)
        'weather_condition_label': weatherConditionLabel,
      if (weatherTempMinC != null) 'weather_temp_min_c': weatherTempMinC,
      if (weatherTempMaxC != null) 'weather_temp_max_c': weatherTempMaxC,
      if (weatherHourlyJson != null) 'weather_hourly_json': weatherHourlyJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DaysCompanion copyWith({
    Value<String>? citySlug,
    Value<int>? yearValue,
    Value<String>? mode,
    Value<String>? slug,
    Value<String>? name,
    Value<DateTime?>? startsAt,
    Value<DateTime?>? liturgicalDate,
    Value<int>? processionEventsCount,
    Value<String?>? weatherIconCode,
    Value<String?>? weatherConditionLabel,
    Value<double?>? weatherTempMinC,
    Value<double?>? weatherTempMaxC,
    Value<String?>? weatherHourlyJson,
    Value<int>? rowid,
  }) {
    return DaysCompanion(
      citySlug: citySlug ?? this.citySlug,
      yearValue: yearValue ?? this.yearValue,
      mode: mode ?? this.mode,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      startsAt: startsAt ?? this.startsAt,
      liturgicalDate: liturgicalDate ?? this.liturgicalDate,
      processionEventsCount:
          processionEventsCount ?? this.processionEventsCount,
      weatherIconCode: weatherIconCode ?? this.weatherIconCode,
      weatherConditionLabel:
          weatherConditionLabel ?? this.weatherConditionLabel,
      weatherTempMinC: weatherTempMinC ?? this.weatherTempMinC,
      weatherTempMaxC: weatherTempMaxC ?? this.weatherTempMaxC,
      weatherHourlyJson: weatherHourlyJson ?? this.weatherHourlyJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (citySlug.present) {
      map['city_slug'] = Variable<String>(citySlug.value);
    }
    if (yearValue.present) {
      map['year_value'] = Variable<int>(yearValue.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (startsAt.present) {
      map['starts_at'] = Variable<DateTime>(startsAt.value);
    }
    if (liturgicalDate.present) {
      map['liturgical_date'] = Variable<DateTime>(liturgicalDate.value);
    }
    if (processionEventsCount.present) {
      map['procession_events_count'] = Variable<int>(
        processionEventsCount.value,
      );
    }
    if (weatherIconCode.present) {
      map['weather_icon_code'] = Variable<String>(weatherIconCode.value);
    }
    if (weatherConditionLabel.present) {
      map['weather_condition_label'] = Variable<String>(
        weatherConditionLabel.value,
      );
    }
    if (weatherTempMinC.present) {
      map['weather_temp_min_c'] = Variable<double>(weatherTempMinC.value);
    }
    if (weatherTempMaxC.present) {
      map['weather_temp_max_c'] = Variable<double>(weatherTempMaxC.value);
    }
    if (weatherHourlyJson.present) {
      map['weather_hourly_json'] = Variable<String>(weatherHourlyJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DaysCompanion(')
          ..write('citySlug: $citySlug, ')
          ..write('yearValue: $yearValue, ')
          ..write('mode: $mode, ')
          ..write('slug: $slug, ')
          ..write('name: $name, ')
          ..write('startsAt: $startsAt, ')
          ..write('liturgicalDate: $liturgicalDate, ')
          ..write('processionEventsCount: $processionEventsCount, ')
          ..write('weatherIconCode: $weatherIconCode, ')
          ..write('weatherConditionLabel: $weatherConditionLabel, ')
          ..write('weatherTempMinC: $weatherTempMinC, ')
          ..write('weatherTempMaxC: $weatherTempMaxC, ')
          ..write('weatherHourlyJson: $weatherHourlyJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DayDetailEntriesTable extends DayDetailEntries
    with TableInfo<$DayDetailEntriesTable, DayDetailEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayDetailEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _citySlugMeta = const VerificationMeta(
    'citySlug',
  );
  @override
  late final GeneratedColumn<String> citySlug = GeneratedColumn<String>(
    'city_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearValueMeta = const VerificationMeta(
    'yearValue',
  );
  @override
  late final GeneratedColumn<int> yearValue = GeneratedColumn<int>(
    'year_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daySlugMeta = const VerificationMeta(
    'daySlug',
  );
  @override
  late final GeneratedColumn<String> daySlug = GeneratedColumn<String>(
    'day_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _officialRouteArgbMeta = const VerificationMeta(
    'officialRouteArgb',
  );
  @override
  late final GeneratedColumn<String> officialRouteArgb =
      GeneratedColumn<String>(
        'official_route_argb',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    citySlug,
    yearValue,
    mode,
    daySlug,
    name,
    officialRouteArgb,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_detail_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayDetailEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('city_slug')) {
      context.handle(
        _citySlugMeta,
        citySlug.isAcceptableOrUnknown(data['city_slug']!, _citySlugMeta),
      );
    } else if (isInserting) {
      context.missing(_citySlugMeta);
    }
    if (data.containsKey('year_value')) {
      context.handle(
        _yearValueMeta,
        yearValue.isAcceptableOrUnknown(data['year_value']!, _yearValueMeta),
      );
    } else if (isInserting) {
      context.missing(_yearValueMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('day_slug')) {
      context.handle(
        _daySlugMeta,
        daySlug.isAcceptableOrUnknown(data['day_slug']!, _daySlugMeta),
      );
    } else if (isInserting) {
      context.missing(_daySlugMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('official_route_argb')) {
      context.handle(
        _officialRouteArgbMeta,
        officialRouteArgb.isAcceptableOrUnknown(
          data['official_route_argb']!,
          _officialRouteArgbMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {citySlug, yearValue, mode, daySlug};
  @override
  DayDetailEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayDetailEntry(
      citySlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city_slug'],
      )!,
      yearValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_value'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      daySlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_slug'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      officialRouteArgb: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}official_route_argb'],
      ),
    );
  }

  @override
  $DayDetailEntriesTable createAlias(String alias) {
    return $DayDetailEntriesTable(attachedDatabase, alias);
  }
}

class DayDetailEntry extends DataClass implements Insertable<DayDetailEntry> {
  final String citySlug;
  final int yearValue;
  final String mode;
  final String daySlug;
  final String name;
  final String? officialRouteArgb;
  const DayDetailEntry({
    required this.citySlug,
    required this.yearValue,
    required this.mode,
    required this.daySlug,
    required this.name,
    this.officialRouteArgb,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['city_slug'] = Variable<String>(citySlug);
    map['year_value'] = Variable<int>(yearValue);
    map['mode'] = Variable<String>(mode);
    map['day_slug'] = Variable<String>(daySlug);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || officialRouteArgb != null) {
      map['official_route_argb'] = Variable<String>(officialRouteArgb);
    }
    return map;
  }

  DayDetailEntriesCompanion toCompanion(bool nullToAbsent) {
    return DayDetailEntriesCompanion(
      citySlug: Value(citySlug),
      yearValue: Value(yearValue),
      mode: Value(mode),
      daySlug: Value(daySlug),
      name: Value(name),
      officialRouteArgb: officialRouteArgb == null && nullToAbsent
          ? const Value.absent()
          : Value(officialRouteArgb),
    );
  }

  factory DayDetailEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayDetailEntry(
      citySlug: serializer.fromJson<String>(json['citySlug']),
      yearValue: serializer.fromJson<int>(json['yearValue']),
      mode: serializer.fromJson<String>(json['mode']),
      daySlug: serializer.fromJson<String>(json['daySlug']),
      name: serializer.fromJson<String>(json['name']),
      officialRouteArgb: serializer.fromJson<String?>(
        json['officialRouteArgb'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'citySlug': serializer.toJson<String>(citySlug),
      'yearValue': serializer.toJson<int>(yearValue),
      'mode': serializer.toJson<String>(mode),
      'daySlug': serializer.toJson<String>(daySlug),
      'name': serializer.toJson<String>(name),
      'officialRouteArgb': serializer.toJson<String?>(officialRouteArgb),
    };
  }

  DayDetailEntry copyWith({
    String? citySlug,
    int? yearValue,
    String? mode,
    String? daySlug,
    String? name,
    Value<String?> officialRouteArgb = const Value.absent(),
  }) => DayDetailEntry(
    citySlug: citySlug ?? this.citySlug,
    yearValue: yearValue ?? this.yearValue,
    mode: mode ?? this.mode,
    daySlug: daySlug ?? this.daySlug,
    name: name ?? this.name,
    officialRouteArgb: officialRouteArgb.present
        ? officialRouteArgb.value
        : this.officialRouteArgb,
  );
  DayDetailEntry copyWithCompanion(DayDetailEntriesCompanion data) {
    return DayDetailEntry(
      citySlug: data.citySlug.present ? data.citySlug.value : this.citySlug,
      yearValue: data.yearValue.present ? data.yearValue.value : this.yearValue,
      mode: data.mode.present ? data.mode.value : this.mode,
      daySlug: data.daySlug.present ? data.daySlug.value : this.daySlug,
      name: data.name.present ? data.name.value : this.name,
      officialRouteArgb: data.officialRouteArgb.present
          ? data.officialRouteArgb.value
          : this.officialRouteArgb,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayDetailEntry(')
          ..write('citySlug: $citySlug, ')
          ..write('yearValue: $yearValue, ')
          ..write('mode: $mode, ')
          ..write('daySlug: $daySlug, ')
          ..write('name: $name, ')
          ..write('officialRouteArgb: $officialRouteArgb')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(citySlug, yearValue, mode, daySlug, name, officialRouteArgb);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayDetailEntry &&
          other.citySlug == this.citySlug &&
          other.yearValue == this.yearValue &&
          other.mode == this.mode &&
          other.daySlug == this.daySlug &&
          other.name == this.name &&
          other.officialRouteArgb == this.officialRouteArgb);
}

class DayDetailEntriesCompanion extends UpdateCompanion<DayDetailEntry> {
  final Value<String> citySlug;
  final Value<int> yearValue;
  final Value<String> mode;
  final Value<String> daySlug;
  final Value<String> name;
  final Value<String?> officialRouteArgb;
  final Value<int> rowid;
  const DayDetailEntriesCompanion({
    this.citySlug = const Value.absent(),
    this.yearValue = const Value.absent(),
    this.mode = const Value.absent(),
    this.daySlug = const Value.absent(),
    this.name = const Value.absent(),
    this.officialRouteArgb = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayDetailEntriesCompanion.insert({
    required String citySlug,
    required int yearValue,
    required String mode,
    required String daySlug,
    required String name,
    this.officialRouteArgb = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : citySlug = Value(citySlug),
       yearValue = Value(yearValue),
       mode = Value(mode),
       daySlug = Value(daySlug),
       name = Value(name);
  static Insertable<DayDetailEntry> custom({
    Expression<String>? citySlug,
    Expression<int>? yearValue,
    Expression<String>? mode,
    Expression<String>? daySlug,
    Expression<String>? name,
    Expression<String>? officialRouteArgb,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (citySlug != null) 'city_slug': citySlug,
      if (yearValue != null) 'year_value': yearValue,
      if (mode != null) 'mode': mode,
      if (daySlug != null) 'day_slug': daySlug,
      if (name != null) 'name': name,
      if (officialRouteArgb != null) 'official_route_argb': officialRouteArgb,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayDetailEntriesCompanion copyWith({
    Value<String>? citySlug,
    Value<int>? yearValue,
    Value<String>? mode,
    Value<String>? daySlug,
    Value<String>? name,
    Value<String?>? officialRouteArgb,
    Value<int>? rowid,
  }) {
    return DayDetailEntriesCompanion(
      citySlug: citySlug ?? this.citySlug,
      yearValue: yearValue ?? this.yearValue,
      mode: mode ?? this.mode,
      daySlug: daySlug ?? this.daySlug,
      name: name ?? this.name,
      officialRouteArgb: officialRouteArgb ?? this.officialRouteArgb,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (citySlug.present) {
      map['city_slug'] = Variable<String>(citySlug.value);
    }
    if (yearValue.present) {
      map['year_value'] = Variable<int>(yearValue.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (daySlug.present) {
      map['day_slug'] = Variable<String>(daySlug.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (officialRouteArgb.present) {
      map['official_route_argb'] = Variable<String>(officialRouteArgb.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayDetailEntriesCompanion(')
          ..write('citySlug: $citySlug, ')
          ..write('yearValue: $yearValue, ')
          ..write('mode: $mode, ')
          ..write('daySlug: $daySlug, ')
          ..write('name: $name, ')
          ..write('officialRouteArgb: $officialRouteArgb, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DayProcessionEventEntriesTable extends DayProcessionEventEntries
    with TableInfo<$DayProcessionEventEntriesTable, DayProcessionEventEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayProcessionEventEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _citySlugMeta = const VerificationMeta(
    'citySlug',
  );
  @override
  late final GeneratedColumn<String> citySlug = GeneratedColumn<String>(
    'city_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearValueMeta = const VerificationMeta(
    'yearValue',
  );
  @override
  late final GeneratedColumn<int> yearValue = GeneratedColumn<int>(
    'year_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daySlugMeta = const VerificationMeta(
    'daySlug',
  );
  @override
  late final GeneratedColumn<String> daySlug = GeneratedColumn<String>(
    'day_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _officialNoteMeta = const VerificationMeta(
    'officialNote',
  );
  @override
  late final GeneratedColumn<String> officialNote = GeneratedColumn<String>(
    'official_note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passDurationMinutesMeta =
      const VerificationMeta('passDurationMinutes');
  @override
  late final GeneratedColumn<int> passDurationMinutes = GeneratedColumn<int>(
    'pass_duration_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stepsCountMeta = const VerificationMeta(
    'stepsCount',
  );
  @override
  late final GeneratedColumn<int> stepsCount = GeneratedColumn<int>(
    'steps_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<int> distanceMeters = GeneratedColumn<int>(
    'distance_meters',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _brothersCountMeta = const VerificationMeta(
    'brothersCount',
  );
  @override
  late final GeneratedColumn<int> brothersCount = GeneratedColumn<int>(
    'brothers_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nazarenesCountMeta = const VerificationMeta(
    'nazarenesCount',
  );
  @override
  late final GeneratedColumn<int> nazarenesCount = GeneratedColumn<int>(
    'nazarenes_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _brotherhoodNameMeta = const VerificationMeta(
    'brotherhoodName',
  );
  @override
  late final GeneratedColumn<String> brotherhoodName = GeneratedColumn<String>(
    'brotherhood_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brotherhoodSlugMeta = const VerificationMeta(
    'brotherhoodSlug',
  );
  @override
  late final GeneratedColumn<String> brotherhoodSlug = GeneratedColumn<String>(
    'brotherhood_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brotherhoodColorHexMeta =
      const VerificationMeta('brotherhoodColorHex');
  @override
  late final GeneratedColumn<String> brotherhoodColorHex =
      GeneratedColumn<String>(
        'brotherhood_color_hex',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _brotherhoodHistoryMeta =
      const VerificationMeta('brotherhoodHistory');
  @override
  late final GeneratedColumn<String> brotherhoodHistory =
      GeneratedColumn<String>(
        'brotherhood_history',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _brotherhoodHeaderImageUrlMeta =
      const VerificationMeta('brotherhoodHeaderImageUrl');
  @override
  late final GeneratedColumn<String> brotherhoodHeaderImageUrl =
      GeneratedColumn<String>(
        'brotherhood_header_image_url',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _brotherhoodDressCodeMeta =
      const VerificationMeta('brotherhoodDressCode');
  @override
  late final GeneratedColumn<String> brotherhoodDressCode =
      GeneratedColumn<String>(
        'brotherhood_dress_code',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _brotherhoodFiguresJsonMeta =
      const VerificationMeta('brotherhoodFiguresJson');
  @override
  late final GeneratedColumn<String> brotherhoodFiguresJson =
      GeneratedColumn<String>(
        'brotherhood_figures_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _brotherhoodPasosJsonMeta =
      const VerificationMeta('brotherhoodPasosJson');
  @override
  late final GeneratedColumn<String> brotherhoodPasosJson =
      GeneratedColumn<String>(
        'brotherhood_pasos_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _brotherhoodShieldImageUrlMeta =
      const VerificationMeta('brotherhoodShieldImageUrl');
  @override
  late final GeneratedColumn<String> brotherhoodShieldImageUrl =
      GeneratedColumn<String>(
        'brotherhood_shield_image_url',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _routeArgbMeta = const VerificationMeta(
    'routeArgb',
  );
  @override
  late final GeneratedColumn<String> routeArgb = GeneratedColumn<String>(
    'route_argb',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _routeKmlMeta = const VerificationMeta(
    'routeKml',
  );
  @override
  late final GeneratedColumn<String> routeKml = GeneratedColumn<String>(
    'route_kml',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    citySlug,
    yearValue,
    mode,
    daySlug,
    position,
    status,
    officialNote,
    passDurationMinutes,
    stepsCount,
    distanceMeters,
    brothersCount,
    nazarenesCount,
    brotherhoodName,
    brotherhoodSlug,
    brotherhoodColorHex,
    brotherhoodHistory,
    brotherhoodHeaderImageUrl,
    brotherhoodDressCode,
    brotherhoodFiguresJson,
    brotherhoodPasosJson,
    brotherhoodShieldImageUrl,
    routeArgb,
    routeKml,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_procession_event_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayProcessionEventEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('city_slug')) {
      context.handle(
        _citySlugMeta,
        citySlug.isAcceptableOrUnknown(data['city_slug']!, _citySlugMeta),
      );
    } else if (isInserting) {
      context.missing(_citySlugMeta);
    }
    if (data.containsKey('year_value')) {
      context.handle(
        _yearValueMeta,
        yearValue.isAcceptableOrUnknown(data['year_value']!, _yearValueMeta),
      );
    } else if (isInserting) {
      context.missing(_yearValueMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('day_slug')) {
      context.handle(
        _daySlugMeta,
        daySlug.isAcceptableOrUnknown(data['day_slug']!, _daySlugMeta),
      );
    } else if (isInserting) {
      context.missing(_daySlugMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('official_note')) {
      context.handle(
        _officialNoteMeta,
        officialNote.isAcceptableOrUnknown(
          data['official_note']!,
          _officialNoteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_officialNoteMeta);
    }
    if (data.containsKey('pass_duration_minutes')) {
      context.handle(
        _passDurationMinutesMeta,
        passDurationMinutes.isAcceptableOrUnknown(
          data['pass_duration_minutes']!,
          _passDurationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('steps_count')) {
      context.handle(
        _stepsCountMeta,
        stepsCount.isAcceptableOrUnknown(data['steps_count']!, _stepsCountMeta),
      );
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('brothers_count')) {
      context.handle(
        _brothersCountMeta,
        brothersCount.isAcceptableOrUnknown(
          data['brothers_count']!,
          _brothersCountMeta,
        ),
      );
    }
    if (data.containsKey('nazarenes_count')) {
      context.handle(
        _nazarenesCountMeta,
        nazarenesCount.isAcceptableOrUnknown(
          data['nazarenes_count']!,
          _nazarenesCountMeta,
        ),
      );
    }
    if (data.containsKey('brotherhood_name')) {
      context.handle(
        _brotherhoodNameMeta,
        brotherhoodName.isAcceptableOrUnknown(
          data['brotherhood_name']!,
          _brotherhoodNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_brotherhoodNameMeta);
    }
    if (data.containsKey('brotherhood_slug')) {
      context.handle(
        _brotherhoodSlugMeta,
        brotherhoodSlug.isAcceptableOrUnknown(
          data['brotherhood_slug']!,
          _brotherhoodSlugMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_brotherhoodSlugMeta);
    }
    if (data.containsKey('brotherhood_color_hex')) {
      context.handle(
        _brotherhoodColorHexMeta,
        brotherhoodColorHex.isAcceptableOrUnknown(
          data['brotherhood_color_hex']!,
          _brotherhoodColorHexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_brotherhoodColorHexMeta);
    }
    if (data.containsKey('brotherhood_history')) {
      context.handle(
        _brotherhoodHistoryMeta,
        brotherhoodHistory.isAcceptableOrUnknown(
          data['brotherhood_history']!,
          _brotherhoodHistoryMeta,
        ),
      );
    }
    if (data.containsKey('brotherhood_header_image_url')) {
      context.handle(
        _brotherhoodHeaderImageUrlMeta,
        brotherhoodHeaderImageUrl.isAcceptableOrUnknown(
          data['brotherhood_header_image_url']!,
          _brotherhoodHeaderImageUrlMeta,
        ),
      );
    }
    if (data.containsKey('brotherhood_dress_code')) {
      context.handle(
        _brotherhoodDressCodeMeta,
        brotherhoodDressCode.isAcceptableOrUnknown(
          data['brotherhood_dress_code']!,
          _brotherhoodDressCodeMeta,
        ),
      );
    }
    if (data.containsKey('brotherhood_figures_json')) {
      context.handle(
        _brotherhoodFiguresJsonMeta,
        brotherhoodFiguresJson.isAcceptableOrUnknown(
          data['brotherhood_figures_json']!,
          _brotherhoodFiguresJsonMeta,
        ),
      );
    }
    if (data.containsKey('brotherhood_pasos_json')) {
      context.handle(
        _brotherhoodPasosJsonMeta,
        brotherhoodPasosJson.isAcceptableOrUnknown(
          data['brotherhood_pasos_json']!,
          _brotherhoodPasosJsonMeta,
        ),
      );
    }
    if (data.containsKey('brotherhood_shield_image_url')) {
      context.handle(
        _brotherhoodShieldImageUrlMeta,
        brotherhoodShieldImageUrl.isAcceptableOrUnknown(
          data['brotherhood_shield_image_url']!,
          _brotherhoodShieldImageUrlMeta,
        ),
      );
    }
    if (data.containsKey('route_argb')) {
      context.handle(
        _routeArgbMeta,
        routeArgb.isAcceptableOrUnknown(data['route_argb']!, _routeArgbMeta),
      );
    }
    if (data.containsKey('route_kml')) {
      context.handle(
        _routeKmlMeta,
        routeKml.isAcceptableOrUnknown(data['route_kml']!, _routeKmlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    citySlug,
    yearValue,
    mode,
    daySlug,
    position,
  };
  @override
  DayProcessionEventEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayProcessionEventEntry(
      citySlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city_slug'],
      )!,
      yearValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_value'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      daySlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_slug'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      officialNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}official_note'],
      )!,
      passDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pass_duration_minutes'],
      ),
      stepsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}steps_count'],
      ),
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distance_meters'],
      ),
      brothersCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}brothers_count'],
      ),
      nazarenesCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nazarenes_count'],
      ),
      brotherhoodName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brotherhood_name'],
      )!,
      brotherhoodSlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brotherhood_slug'],
      )!,
      brotherhoodColorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brotherhood_color_hex'],
      )!,
      brotherhoodHistory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brotherhood_history'],
      ),
      brotherhoodHeaderImageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brotherhood_header_image_url'],
      ),
      brotherhoodDressCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brotherhood_dress_code'],
      ),
      brotherhoodFiguresJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brotherhood_figures_json'],
      ),
      brotherhoodPasosJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brotherhood_pasos_json'],
      ),
      brotherhoodShieldImageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brotherhood_shield_image_url'],
      ),
      routeArgb: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_argb'],
      ),
      routeKml: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_kml'],
      ),
    );
  }

  @override
  $DayProcessionEventEntriesTable createAlias(String alias) {
    return $DayProcessionEventEntriesTable(attachedDatabase, alias);
  }
}

class DayProcessionEventEntry extends DataClass
    implements Insertable<DayProcessionEventEntry> {
  final String citySlug;
  final int yearValue;
  final String mode;
  final String daySlug;
  final int position;
  final String status;
  final String officialNote;
  final int? passDurationMinutes;
  final int? stepsCount;
  final int? distanceMeters;
  final int? brothersCount;
  final int? nazarenesCount;
  final String brotherhoodName;
  final String brotherhoodSlug;
  final String brotherhoodColorHex;
  final String? brotherhoodHistory;
  final String? brotherhoodHeaderImageUrl;
  final String? brotherhoodDressCode;
  final String? brotherhoodFiguresJson;
  final String? brotherhoodPasosJson;
  final String? brotherhoodShieldImageUrl;
  final String? routeArgb;
  final String? routeKml;
  const DayProcessionEventEntry({
    required this.citySlug,
    required this.yearValue,
    required this.mode,
    required this.daySlug,
    required this.position,
    required this.status,
    required this.officialNote,
    this.passDurationMinutes,
    this.stepsCount,
    this.distanceMeters,
    this.brothersCount,
    this.nazarenesCount,
    required this.brotherhoodName,
    required this.brotherhoodSlug,
    required this.brotherhoodColorHex,
    this.brotherhoodHistory,
    this.brotherhoodHeaderImageUrl,
    this.brotherhoodDressCode,
    this.brotherhoodFiguresJson,
    this.brotherhoodPasosJson,
    this.brotherhoodShieldImageUrl,
    this.routeArgb,
    this.routeKml,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['city_slug'] = Variable<String>(citySlug);
    map['year_value'] = Variable<int>(yearValue);
    map['mode'] = Variable<String>(mode);
    map['day_slug'] = Variable<String>(daySlug);
    map['position'] = Variable<int>(position);
    map['status'] = Variable<String>(status);
    map['official_note'] = Variable<String>(officialNote);
    if (!nullToAbsent || passDurationMinutes != null) {
      map['pass_duration_minutes'] = Variable<int>(passDurationMinutes);
    }
    if (!nullToAbsent || stepsCount != null) {
      map['steps_count'] = Variable<int>(stepsCount);
    }
    if (!nullToAbsent || distanceMeters != null) {
      map['distance_meters'] = Variable<int>(distanceMeters);
    }
    if (!nullToAbsent || brothersCount != null) {
      map['brothers_count'] = Variable<int>(brothersCount);
    }
    if (!nullToAbsent || nazarenesCount != null) {
      map['nazarenes_count'] = Variable<int>(nazarenesCount);
    }
    map['brotherhood_name'] = Variable<String>(brotherhoodName);
    map['brotherhood_slug'] = Variable<String>(brotherhoodSlug);
    map['brotherhood_color_hex'] = Variable<String>(brotherhoodColorHex);
    if (!nullToAbsent || brotherhoodHistory != null) {
      map['brotherhood_history'] = Variable<String>(brotherhoodHistory);
    }
    if (!nullToAbsent || brotherhoodHeaderImageUrl != null) {
      map['brotherhood_header_image_url'] = Variable<String>(
        brotherhoodHeaderImageUrl,
      );
    }
    if (!nullToAbsent || brotherhoodDressCode != null) {
      map['brotherhood_dress_code'] = Variable<String>(brotherhoodDressCode);
    }
    if (!nullToAbsent || brotherhoodFiguresJson != null) {
      map['brotherhood_figures_json'] = Variable<String>(
        brotherhoodFiguresJson,
      );
    }
    if (!nullToAbsent || brotherhoodPasosJson != null) {
      map['brotherhood_pasos_json'] = Variable<String>(brotherhoodPasosJson);
    }
    if (!nullToAbsent || brotherhoodShieldImageUrl != null) {
      map['brotherhood_shield_image_url'] = Variable<String>(
        brotherhoodShieldImageUrl,
      );
    }
    if (!nullToAbsent || routeArgb != null) {
      map['route_argb'] = Variable<String>(routeArgb);
    }
    if (!nullToAbsent || routeKml != null) {
      map['route_kml'] = Variable<String>(routeKml);
    }
    return map;
  }

  DayProcessionEventEntriesCompanion toCompanion(bool nullToAbsent) {
    return DayProcessionEventEntriesCompanion(
      citySlug: Value(citySlug),
      yearValue: Value(yearValue),
      mode: Value(mode),
      daySlug: Value(daySlug),
      position: Value(position),
      status: Value(status),
      officialNote: Value(officialNote),
      passDurationMinutes: passDurationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(passDurationMinutes),
      stepsCount: stepsCount == null && nullToAbsent
          ? const Value.absent()
          : Value(stepsCount),
      distanceMeters: distanceMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceMeters),
      brothersCount: brothersCount == null && nullToAbsent
          ? const Value.absent()
          : Value(brothersCount),
      nazarenesCount: nazarenesCount == null && nullToAbsent
          ? const Value.absent()
          : Value(nazarenesCount),
      brotherhoodName: Value(brotherhoodName),
      brotherhoodSlug: Value(brotherhoodSlug),
      brotherhoodColorHex: Value(brotherhoodColorHex),
      brotherhoodHistory: brotherhoodHistory == null && nullToAbsent
          ? const Value.absent()
          : Value(brotherhoodHistory),
      brotherhoodHeaderImageUrl:
          brotherhoodHeaderImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(brotherhoodHeaderImageUrl),
      brotherhoodDressCode: brotherhoodDressCode == null && nullToAbsent
          ? const Value.absent()
          : Value(brotherhoodDressCode),
      brotherhoodFiguresJson: brotherhoodFiguresJson == null && nullToAbsent
          ? const Value.absent()
          : Value(brotherhoodFiguresJson),
      brotherhoodPasosJson: brotherhoodPasosJson == null && nullToAbsent
          ? const Value.absent()
          : Value(brotherhoodPasosJson),
      brotherhoodShieldImageUrl:
          brotherhoodShieldImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(brotherhoodShieldImageUrl),
      routeArgb: routeArgb == null && nullToAbsent
          ? const Value.absent()
          : Value(routeArgb),
      routeKml: routeKml == null && nullToAbsent
          ? const Value.absent()
          : Value(routeKml),
    );
  }

  factory DayProcessionEventEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayProcessionEventEntry(
      citySlug: serializer.fromJson<String>(json['citySlug']),
      yearValue: serializer.fromJson<int>(json['yearValue']),
      mode: serializer.fromJson<String>(json['mode']),
      daySlug: serializer.fromJson<String>(json['daySlug']),
      position: serializer.fromJson<int>(json['position']),
      status: serializer.fromJson<String>(json['status']),
      officialNote: serializer.fromJson<String>(json['officialNote']),
      passDurationMinutes: serializer.fromJson<int?>(
        json['passDurationMinutes'],
      ),
      stepsCount: serializer.fromJson<int?>(json['stepsCount']),
      distanceMeters: serializer.fromJson<int?>(json['distanceMeters']),
      brothersCount: serializer.fromJson<int?>(json['brothersCount']),
      nazarenesCount: serializer.fromJson<int?>(json['nazarenesCount']),
      brotherhoodName: serializer.fromJson<String>(json['brotherhoodName']),
      brotherhoodSlug: serializer.fromJson<String>(json['brotherhoodSlug']),
      brotherhoodColorHex: serializer.fromJson<String>(
        json['brotherhoodColorHex'],
      ),
      brotherhoodHistory: serializer.fromJson<String?>(
        json['brotherhoodHistory'],
      ),
      brotherhoodHeaderImageUrl: serializer.fromJson<String?>(
        json['brotherhoodHeaderImageUrl'],
      ),
      brotherhoodDressCode: serializer.fromJson<String?>(
        json['brotherhoodDressCode'],
      ),
      brotherhoodFiguresJson: serializer.fromJson<String?>(
        json['brotherhoodFiguresJson'],
      ),
      brotherhoodPasosJson: serializer.fromJson<String?>(
        json['brotherhoodPasosJson'],
      ),
      brotherhoodShieldImageUrl: serializer.fromJson<String?>(
        json['brotherhoodShieldImageUrl'],
      ),
      routeArgb: serializer.fromJson<String?>(json['routeArgb']),
      routeKml: serializer.fromJson<String?>(json['routeKml']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'citySlug': serializer.toJson<String>(citySlug),
      'yearValue': serializer.toJson<int>(yearValue),
      'mode': serializer.toJson<String>(mode),
      'daySlug': serializer.toJson<String>(daySlug),
      'position': serializer.toJson<int>(position),
      'status': serializer.toJson<String>(status),
      'officialNote': serializer.toJson<String>(officialNote),
      'passDurationMinutes': serializer.toJson<int?>(passDurationMinutes),
      'stepsCount': serializer.toJson<int?>(stepsCount),
      'distanceMeters': serializer.toJson<int?>(distanceMeters),
      'brothersCount': serializer.toJson<int?>(brothersCount),
      'nazarenesCount': serializer.toJson<int?>(nazarenesCount),
      'brotherhoodName': serializer.toJson<String>(brotherhoodName),
      'brotherhoodSlug': serializer.toJson<String>(brotherhoodSlug),
      'brotherhoodColorHex': serializer.toJson<String>(brotherhoodColorHex),
      'brotherhoodHistory': serializer.toJson<String?>(brotherhoodHistory),
      'brotherhoodHeaderImageUrl': serializer.toJson<String?>(
        brotherhoodHeaderImageUrl,
      ),
      'brotherhoodDressCode': serializer.toJson<String?>(brotherhoodDressCode),
      'brotherhoodFiguresJson': serializer.toJson<String?>(
        brotherhoodFiguresJson,
      ),
      'brotherhoodPasosJson': serializer.toJson<String?>(brotherhoodPasosJson),
      'brotherhoodShieldImageUrl': serializer.toJson<String?>(
        brotherhoodShieldImageUrl,
      ),
      'routeArgb': serializer.toJson<String?>(routeArgb),
      'routeKml': serializer.toJson<String?>(routeKml),
    };
  }

  DayProcessionEventEntry copyWith({
    String? citySlug,
    int? yearValue,
    String? mode,
    String? daySlug,
    int? position,
    String? status,
    String? officialNote,
    Value<int?> passDurationMinutes = const Value.absent(),
    Value<int?> stepsCount = const Value.absent(),
    Value<int?> distanceMeters = const Value.absent(),
    Value<int?> brothersCount = const Value.absent(),
    Value<int?> nazarenesCount = const Value.absent(),
    String? brotherhoodName,
    String? brotherhoodSlug,
    String? brotherhoodColorHex,
    Value<String?> brotherhoodHistory = const Value.absent(),
    Value<String?> brotherhoodHeaderImageUrl = const Value.absent(),
    Value<String?> brotherhoodDressCode = const Value.absent(),
    Value<String?> brotherhoodFiguresJson = const Value.absent(),
    Value<String?> brotherhoodPasosJson = const Value.absent(),
    Value<String?> brotherhoodShieldImageUrl = const Value.absent(),
    Value<String?> routeArgb = const Value.absent(),
    Value<String?> routeKml = const Value.absent(),
  }) => DayProcessionEventEntry(
    citySlug: citySlug ?? this.citySlug,
    yearValue: yearValue ?? this.yearValue,
    mode: mode ?? this.mode,
    daySlug: daySlug ?? this.daySlug,
    position: position ?? this.position,
    status: status ?? this.status,
    officialNote: officialNote ?? this.officialNote,
    passDurationMinutes: passDurationMinutes.present
        ? passDurationMinutes.value
        : this.passDurationMinutes,
    stepsCount: stepsCount.present ? stepsCount.value : this.stepsCount,
    distanceMeters: distanceMeters.present
        ? distanceMeters.value
        : this.distanceMeters,
    brothersCount: brothersCount.present
        ? brothersCount.value
        : this.brothersCount,
    nazarenesCount: nazarenesCount.present
        ? nazarenesCount.value
        : this.nazarenesCount,
    brotherhoodName: brotherhoodName ?? this.brotherhoodName,
    brotherhoodSlug: brotherhoodSlug ?? this.brotherhoodSlug,
    brotherhoodColorHex: brotherhoodColorHex ?? this.brotherhoodColorHex,
    brotherhoodHistory: brotherhoodHistory.present
        ? brotherhoodHistory.value
        : this.brotherhoodHistory,
    brotherhoodHeaderImageUrl: brotherhoodHeaderImageUrl.present
        ? brotherhoodHeaderImageUrl.value
        : this.brotherhoodHeaderImageUrl,
    brotherhoodDressCode: brotherhoodDressCode.present
        ? brotherhoodDressCode.value
        : this.brotherhoodDressCode,
    brotherhoodFiguresJson: brotherhoodFiguresJson.present
        ? brotherhoodFiguresJson.value
        : this.brotherhoodFiguresJson,
    brotherhoodPasosJson: brotherhoodPasosJson.present
        ? brotherhoodPasosJson.value
        : this.brotherhoodPasosJson,
    brotherhoodShieldImageUrl: brotherhoodShieldImageUrl.present
        ? brotherhoodShieldImageUrl.value
        : this.brotherhoodShieldImageUrl,
    routeArgb: routeArgb.present ? routeArgb.value : this.routeArgb,
    routeKml: routeKml.present ? routeKml.value : this.routeKml,
  );
  DayProcessionEventEntry copyWithCompanion(
    DayProcessionEventEntriesCompanion data,
  ) {
    return DayProcessionEventEntry(
      citySlug: data.citySlug.present ? data.citySlug.value : this.citySlug,
      yearValue: data.yearValue.present ? data.yearValue.value : this.yearValue,
      mode: data.mode.present ? data.mode.value : this.mode,
      daySlug: data.daySlug.present ? data.daySlug.value : this.daySlug,
      position: data.position.present ? data.position.value : this.position,
      status: data.status.present ? data.status.value : this.status,
      officialNote: data.officialNote.present
          ? data.officialNote.value
          : this.officialNote,
      passDurationMinutes: data.passDurationMinutes.present
          ? data.passDurationMinutes.value
          : this.passDurationMinutes,
      stepsCount: data.stepsCount.present
          ? data.stepsCount.value
          : this.stepsCount,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      brothersCount: data.brothersCount.present
          ? data.brothersCount.value
          : this.brothersCount,
      nazarenesCount: data.nazarenesCount.present
          ? data.nazarenesCount.value
          : this.nazarenesCount,
      brotherhoodName: data.brotherhoodName.present
          ? data.brotherhoodName.value
          : this.brotherhoodName,
      brotherhoodSlug: data.brotherhoodSlug.present
          ? data.brotherhoodSlug.value
          : this.brotherhoodSlug,
      brotherhoodColorHex: data.brotherhoodColorHex.present
          ? data.brotherhoodColorHex.value
          : this.brotherhoodColorHex,
      brotherhoodHistory: data.brotherhoodHistory.present
          ? data.brotherhoodHistory.value
          : this.brotherhoodHistory,
      brotherhoodHeaderImageUrl: data.brotherhoodHeaderImageUrl.present
          ? data.brotherhoodHeaderImageUrl.value
          : this.brotherhoodHeaderImageUrl,
      brotherhoodDressCode: data.brotherhoodDressCode.present
          ? data.brotherhoodDressCode.value
          : this.brotherhoodDressCode,
      brotherhoodFiguresJson: data.brotherhoodFiguresJson.present
          ? data.brotherhoodFiguresJson.value
          : this.brotherhoodFiguresJson,
      brotherhoodPasosJson: data.brotherhoodPasosJson.present
          ? data.brotherhoodPasosJson.value
          : this.brotherhoodPasosJson,
      brotherhoodShieldImageUrl: data.brotherhoodShieldImageUrl.present
          ? data.brotherhoodShieldImageUrl.value
          : this.brotherhoodShieldImageUrl,
      routeArgb: data.routeArgb.present ? data.routeArgb.value : this.routeArgb,
      routeKml: data.routeKml.present ? data.routeKml.value : this.routeKml,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayProcessionEventEntry(')
          ..write('citySlug: $citySlug, ')
          ..write('yearValue: $yearValue, ')
          ..write('mode: $mode, ')
          ..write('daySlug: $daySlug, ')
          ..write('position: $position, ')
          ..write('status: $status, ')
          ..write('officialNote: $officialNote, ')
          ..write('passDurationMinutes: $passDurationMinutes, ')
          ..write('stepsCount: $stepsCount, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('brothersCount: $brothersCount, ')
          ..write('nazarenesCount: $nazarenesCount, ')
          ..write('brotherhoodName: $brotherhoodName, ')
          ..write('brotherhoodSlug: $brotherhoodSlug, ')
          ..write('brotherhoodColorHex: $brotherhoodColorHex, ')
          ..write('brotherhoodHistory: $brotherhoodHistory, ')
          ..write('brotherhoodHeaderImageUrl: $brotherhoodHeaderImageUrl, ')
          ..write('brotherhoodDressCode: $brotherhoodDressCode, ')
          ..write('brotherhoodFiguresJson: $brotherhoodFiguresJson, ')
          ..write('brotherhoodPasosJson: $brotherhoodPasosJson, ')
          ..write('brotherhoodShieldImageUrl: $brotherhoodShieldImageUrl, ')
          ..write('routeArgb: $routeArgb, ')
          ..write('routeKml: $routeKml')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    citySlug,
    yearValue,
    mode,
    daySlug,
    position,
    status,
    officialNote,
    passDurationMinutes,
    stepsCount,
    distanceMeters,
    brothersCount,
    nazarenesCount,
    brotherhoodName,
    brotherhoodSlug,
    brotherhoodColorHex,
    brotherhoodHistory,
    brotherhoodHeaderImageUrl,
    brotherhoodDressCode,
    brotherhoodFiguresJson,
    brotherhoodPasosJson,
    brotherhoodShieldImageUrl,
    routeArgb,
    routeKml,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayProcessionEventEntry &&
          other.citySlug == this.citySlug &&
          other.yearValue == this.yearValue &&
          other.mode == this.mode &&
          other.daySlug == this.daySlug &&
          other.position == this.position &&
          other.status == this.status &&
          other.officialNote == this.officialNote &&
          other.passDurationMinutes == this.passDurationMinutes &&
          other.stepsCount == this.stepsCount &&
          other.distanceMeters == this.distanceMeters &&
          other.brothersCount == this.brothersCount &&
          other.nazarenesCount == this.nazarenesCount &&
          other.brotherhoodName == this.brotherhoodName &&
          other.brotherhoodSlug == this.brotherhoodSlug &&
          other.brotherhoodColorHex == this.brotherhoodColorHex &&
          other.brotherhoodHistory == this.brotherhoodHistory &&
          other.brotherhoodHeaderImageUrl == this.brotherhoodHeaderImageUrl &&
          other.brotherhoodDressCode == this.brotherhoodDressCode &&
          other.brotherhoodFiguresJson == this.brotherhoodFiguresJson &&
          other.brotherhoodPasosJson == this.brotherhoodPasosJson &&
          other.brotherhoodShieldImageUrl == this.brotherhoodShieldImageUrl &&
          other.routeArgb == this.routeArgb &&
          other.routeKml == this.routeKml);
}

class DayProcessionEventEntriesCompanion
    extends UpdateCompanion<DayProcessionEventEntry> {
  final Value<String> citySlug;
  final Value<int> yearValue;
  final Value<String> mode;
  final Value<String> daySlug;
  final Value<int> position;
  final Value<String> status;
  final Value<String> officialNote;
  final Value<int?> passDurationMinutes;
  final Value<int?> stepsCount;
  final Value<int?> distanceMeters;
  final Value<int?> brothersCount;
  final Value<int?> nazarenesCount;
  final Value<String> brotherhoodName;
  final Value<String> brotherhoodSlug;
  final Value<String> brotherhoodColorHex;
  final Value<String?> brotherhoodHistory;
  final Value<String?> brotherhoodHeaderImageUrl;
  final Value<String?> brotherhoodDressCode;
  final Value<String?> brotherhoodFiguresJson;
  final Value<String?> brotherhoodPasosJson;
  final Value<String?> brotherhoodShieldImageUrl;
  final Value<String?> routeArgb;
  final Value<String?> routeKml;
  final Value<int> rowid;
  const DayProcessionEventEntriesCompanion({
    this.citySlug = const Value.absent(),
    this.yearValue = const Value.absent(),
    this.mode = const Value.absent(),
    this.daySlug = const Value.absent(),
    this.position = const Value.absent(),
    this.status = const Value.absent(),
    this.officialNote = const Value.absent(),
    this.passDurationMinutes = const Value.absent(),
    this.stepsCount = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.brothersCount = const Value.absent(),
    this.nazarenesCount = const Value.absent(),
    this.brotherhoodName = const Value.absent(),
    this.brotherhoodSlug = const Value.absent(),
    this.brotherhoodColorHex = const Value.absent(),
    this.brotherhoodHistory = const Value.absent(),
    this.brotherhoodHeaderImageUrl = const Value.absent(),
    this.brotherhoodDressCode = const Value.absent(),
    this.brotherhoodFiguresJson = const Value.absent(),
    this.brotherhoodPasosJson = const Value.absent(),
    this.brotherhoodShieldImageUrl = const Value.absent(),
    this.routeArgb = const Value.absent(),
    this.routeKml = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayProcessionEventEntriesCompanion.insert({
    required String citySlug,
    required int yearValue,
    required String mode,
    required String daySlug,
    required int position,
    required String status,
    required String officialNote,
    this.passDurationMinutes = const Value.absent(),
    this.stepsCount = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.brothersCount = const Value.absent(),
    this.nazarenesCount = const Value.absent(),
    required String brotherhoodName,
    required String brotherhoodSlug,
    required String brotherhoodColorHex,
    this.brotherhoodHistory = const Value.absent(),
    this.brotherhoodHeaderImageUrl = const Value.absent(),
    this.brotherhoodDressCode = const Value.absent(),
    this.brotherhoodFiguresJson = const Value.absent(),
    this.brotherhoodPasosJson = const Value.absent(),
    this.brotherhoodShieldImageUrl = const Value.absent(),
    this.routeArgb = const Value.absent(),
    this.routeKml = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : citySlug = Value(citySlug),
       yearValue = Value(yearValue),
       mode = Value(mode),
       daySlug = Value(daySlug),
       position = Value(position),
       status = Value(status),
       officialNote = Value(officialNote),
       brotherhoodName = Value(brotherhoodName),
       brotherhoodSlug = Value(brotherhoodSlug),
       brotherhoodColorHex = Value(brotherhoodColorHex);
  static Insertable<DayProcessionEventEntry> custom({
    Expression<String>? citySlug,
    Expression<int>? yearValue,
    Expression<String>? mode,
    Expression<String>? daySlug,
    Expression<int>? position,
    Expression<String>? status,
    Expression<String>? officialNote,
    Expression<int>? passDurationMinutes,
    Expression<int>? stepsCount,
    Expression<int>? distanceMeters,
    Expression<int>? brothersCount,
    Expression<int>? nazarenesCount,
    Expression<String>? brotherhoodName,
    Expression<String>? brotherhoodSlug,
    Expression<String>? brotherhoodColorHex,
    Expression<String>? brotherhoodHistory,
    Expression<String>? brotherhoodHeaderImageUrl,
    Expression<String>? brotherhoodDressCode,
    Expression<String>? brotherhoodFiguresJson,
    Expression<String>? brotherhoodPasosJson,
    Expression<String>? brotherhoodShieldImageUrl,
    Expression<String>? routeArgb,
    Expression<String>? routeKml,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (citySlug != null) 'city_slug': citySlug,
      if (yearValue != null) 'year_value': yearValue,
      if (mode != null) 'mode': mode,
      if (daySlug != null) 'day_slug': daySlug,
      if (position != null) 'position': position,
      if (status != null) 'status': status,
      if (officialNote != null) 'official_note': officialNote,
      if (passDurationMinutes != null)
        'pass_duration_minutes': passDurationMinutes,
      if (stepsCount != null) 'steps_count': stepsCount,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (brothersCount != null) 'brothers_count': brothersCount,
      if (nazarenesCount != null) 'nazarenes_count': nazarenesCount,
      if (brotherhoodName != null) 'brotherhood_name': brotherhoodName,
      if (brotherhoodSlug != null) 'brotherhood_slug': brotherhoodSlug,
      if (brotherhoodColorHex != null)
        'brotherhood_color_hex': brotherhoodColorHex,
      if (brotherhoodHistory != null) 'brotherhood_history': brotherhoodHistory,
      if (brotherhoodHeaderImageUrl != null)
        'brotherhood_header_image_url': brotherhoodHeaderImageUrl,
      if (brotherhoodDressCode != null)
        'brotherhood_dress_code': brotherhoodDressCode,
      if (brotherhoodFiguresJson != null)
        'brotherhood_figures_json': brotherhoodFiguresJson,
      if (brotherhoodPasosJson != null)
        'brotherhood_pasos_json': brotherhoodPasosJson,
      if (brotherhoodShieldImageUrl != null)
        'brotherhood_shield_image_url': brotherhoodShieldImageUrl,
      if (routeArgb != null) 'route_argb': routeArgb,
      if (routeKml != null) 'route_kml': routeKml,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayProcessionEventEntriesCompanion copyWith({
    Value<String>? citySlug,
    Value<int>? yearValue,
    Value<String>? mode,
    Value<String>? daySlug,
    Value<int>? position,
    Value<String>? status,
    Value<String>? officialNote,
    Value<int?>? passDurationMinutes,
    Value<int?>? stepsCount,
    Value<int?>? distanceMeters,
    Value<int?>? brothersCount,
    Value<int?>? nazarenesCount,
    Value<String>? brotherhoodName,
    Value<String>? brotherhoodSlug,
    Value<String>? brotherhoodColorHex,
    Value<String?>? brotherhoodHistory,
    Value<String?>? brotherhoodHeaderImageUrl,
    Value<String?>? brotherhoodDressCode,
    Value<String?>? brotherhoodFiguresJson,
    Value<String?>? brotherhoodPasosJson,
    Value<String?>? brotherhoodShieldImageUrl,
    Value<String?>? routeArgb,
    Value<String?>? routeKml,
    Value<int>? rowid,
  }) {
    return DayProcessionEventEntriesCompanion(
      citySlug: citySlug ?? this.citySlug,
      yearValue: yearValue ?? this.yearValue,
      mode: mode ?? this.mode,
      daySlug: daySlug ?? this.daySlug,
      position: position ?? this.position,
      status: status ?? this.status,
      officialNote: officialNote ?? this.officialNote,
      passDurationMinutes: passDurationMinutes ?? this.passDurationMinutes,
      stepsCount: stepsCount ?? this.stepsCount,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      brothersCount: brothersCount ?? this.brothersCount,
      nazarenesCount: nazarenesCount ?? this.nazarenesCount,
      brotherhoodName: brotherhoodName ?? this.brotherhoodName,
      brotherhoodSlug: brotherhoodSlug ?? this.brotherhoodSlug,
      brotherhoodColorHex: brotherhoodColorHex ?? this.brotherhoodColorHex,
      brotherhoodHistory: brotherhoodHistory ?? this.brotherhoodHistory,
      brotherhoodHeaderImageUrl:
          brotherhoodHeaderImageUrl ?? this.brotherhoodHeaderImageUrl,
      brotherhoodDressCode: brotherhoodDressCode ?? this.brotherhoodDressCode,
      brotherhoodFiguresJson:
          brotherhoodFiguresJson ?? this.brotherhoodFiguresJson,
      brotherhoodPasosJson: brotherhoodPasosJson ?? this.brotherhoodPasosJson,
      brotherhoodShieldImageUrl:
          brotherhoodShieldImageUrl ?? this.brotherhoodShieldImageUrl,
      routeArgb: routeArgb ?? this.routeArgb,
      routeKml: routeKml ?? this.routeKml,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (citySlug.present) {
      map['city_slug'] = Variable<String>(citySlug.value);
    }
    if (yearValue.present) {
      map['year_value'] = Variable<int>(yearValue.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (daySlug.present) {
      map['day_slug'] = Variable<String>(daySlug.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (officialNote.present) {
      map['official_note'] = Variable<String>(officialNote.value);
    }
    if (passDurationMinutes.present) {
      map['pass_duration_minutes'] = Variable<int>(passDurationMinutes.value);
    }
    if (stepsCount.present) {
      map['steps_count'] = Variable<int>(stepsCount.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<int>(distanceMeters.value);
    }
    if (brothersCount.present) {
      map['brothers_count'] = Variable<int>(brothersCount.value);
    }
    if (nazarenesCount.present) {
      map['nazarenes_count'] = Variable<int>(nazarenesCount.value);
    }
    if (brotherhoodName.present) {
      map['brotherhood_name'] = Variable<String>(brotherhoodName.value);
    }
    if (brotherhoodSlug.present) {
      map['brotherhood_slug'] = Variable<String>(brotherhoodSlug.value);
    }
    if (brotherhoodColorHex.present) {
      map['brotherhood_color_hex'] = Variable<String>(
        brotherhoodColorHex.value,
      );
    }
    if (brotherhoodHistory.present) {
      map['brotherhood_history'] = Variable<String>(brotherhoodHistory.value);
    }
    if (brotherhoodHeaderImageUrl.present) {
      map['brotherhood_header_image_url'] = Variable<String>(
        brotherhoodHeaderImageUrl.value,
      );
    }
    if (brotherhoodDressCode.present) {
      map['brotherhood_dress_code'] = Variable<String>(
        brotherhoodDressCode.value,
      );
    }
    if (brotherhoodFiguresJson.present) {
      map['brotherhood_figures_json'] = Variable<String>(
        brotherhoodFiguresJson.value,
      );
    }
    if (brotherhoodPasosJson.present) {
      map['brotherhood_pasos_json'] = Variable<String>(
        brotherhoodPasosJson.value,
      );
    }
    if (brotherhoodShieldImageUrl.present) {
      map['brotherhood_shield_image_url'] = Variable<String>(
        brotherhoodShieldImageUrl.value,
      );
    }
    if (routeArgb.present) {
      map['route_argb'] = Variable<String>(routeArgb.value);
    }
    if (routeKml.present) {
      map['route_kml'] = Variable<String>(routeKml.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayProcessionEventEntriesCompanion(')
          ..write('citySlug: $citySlug, ')
          ..write('yearValue: $yearValue, ')
          ..write('mode: $mode, ')
          ..write('daySlug: $daySlug, ')
          ..write('position: $position, ')
          ..write('status: $status, ')
          ..write('officialNote: $officialNote, ')
          ..write('passDurationMinutes: $passDurationMinutes, ')
          ..write('stepsCount: $stepsCount, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('brothersCount: $brothersCount, ')
          ..write('nazarenesCount: $nazarenesCount, ')
          ..write('brotherhoodName: $brotherhoodName, ')
          ..write('brotherhoodSlug: $brotherhoodSlug, ')
          ..write('brotherhoodColorHex: $brotherhoodColorHex, ')
          ..write('brotherhoodHistory: $brotherhoodHistory, ')
          ..write('brotherhoodHeaderImageUrl: $brotherhoodHeaderImageUrl, ')
          ..write('brotherhoodDressCode: $brotherhoodDressCode, ')
          ..write('brotherhoodFiguresJson: $brotherhoodFiguresJson, ')
          ..write('brotherhoodPasosJson: $brotherhoodPasosJson, ')
          ..write('brotherhoodShieldImageUrl: $brotherhoodShieldImageUrl, ')
          ..write('routeArgb: $routeArgb, ')
          ..write('routeKml: $routeKml, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DaySchedulePointEntriesTable extends DaySchedulePointEntries
    with TableInfo<$DaySchedulePointEntriesTable, DaySchedulePointEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DaySchedulePointEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _citySlugMeta = const VerificationMeta(
    'citySlug',
  );
  @override
  late final GeneratedColumn<String> citySlug = GeneratedColumn<String>(
    'city_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearValueMeta = const VerificationMeta(
    'yearValue',
  );
  @override
  late final GeneratedColumn<int> yearValue = GeneratedColumn<int>(
    'year_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daySlugMeta = const VerificationMeta(
    'daySlug',
  );
  @override
  late final GeneratedColumn<String> daySlug = GeneratedColumn<String>(
    'day_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventPositionMeta = const VerificationMeta(
    'eventPosition',
  );
  @override
  late final GeneratedColumn<int> eventPosition = GeneratedColumn<int>(
    'event_position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pointPositionMeta = const VerificationMeta(
    'pointPosition',
  );
  @override
  late final GeneratedColumn<int> pointPosition = GeneratedColumn<int>(
    'point_position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedAtMeta = const VerificationMeta(
    'plannedAt',
  );
  @override
  late final GeneratedColumn<DateTime> plannedAt = GeneratedColumn<DateTime>(
    'planned_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
  @override
  List<GeneratedColumn> get $columns => [
    citySlug,
    yearValue,
    mode,
    daySlug,
    eventPosition,
    pointPosition,
    name,
    plannedAt,
    latitude,
    longitude,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_schedule_point_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DaySchedulePointEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('city_slug')) {
      context.handle(
        _citySlugMeta,
        citySlug.isAcceptableOrUnknown(data['city_slug']!, _citySlugMeta),
      );
    } else if (isInserting) {
      context.missing(_citySlugMeta);
    }
    if (data.containsKey('year_value')) {
      context.handle(
        _yearValueMeta,
        yearValue.isAcceptableOrUnknown(data['year_value']!, _yearValueMeta),
      );
    } else if (isInserting) {
      context.missing(_yearValueMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('day_slug')) {
      context.handle(
        _daySlugMeta,
        daySlug.isAcceptableOrUnknown(data['day_slug']!, _daySlugMeta),
      );
    } else if (isInserting) {
      context.missing(_daySlugMeta);
    }
    if (data.containsKey('event_position')) {
      context.handle(
        _eventPositionMeta,
        eventPosition.isAcceptableOrUnknown(
          data['event_position']!,
          _eventPositionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eventPositionMeta);
    }
    if (data.containsKey('point_position')) {
      context.handle(
        _pointPositionMeta,
        pointPosition.isAcceptableOrUnknown(
          data['point_position']!,
          _pointPositionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pointPositionMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('planned_at')) {
      context.handle(
        _plannedAtMeta,
        plannedAt.isAcceptableOrUnknown(data['planned_at']!, _plannedAtMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    citySlug,
    yearValue,
    mode,
    daySlug,
    eventPosition,
    pointPosition,
  };
  @override
  DaySchedulePointEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DaySchedulePointEntry(
      citySlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city_slug'],
      )!,
      yearValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_value'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      daySlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_slug'],
      )!,
      eventPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_position'],
      )!,
      pointPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}point_position'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      plannedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}planned_at'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
    );
  }

  @override
  $DaySchedulePointEntriesTable createAlias(String alias) {
    return $DaySchedulePointEntriesTable(attachedDatabase, alias);
  }
}

class DaySchedulePointEntry extends DataClass
    implements Insertable<DaySchedulePointEntry> {
  final String citySlug;
  final int yearValue;
  final String mode;
  final String daySlug;
  final int eventPosition;
  final int pointPosition;
  final String name;
  final DateTime? plannedAt;
  final double? latitude;
  final double? longitude;
  const DaySchedulePointEntry({
    required this.citySlug,
    required this.yearValue,
    required this.mode,
    required this.daySlug,
    required this.eventPosition,
    required this.pointPosition,
    required this.name,
    this.plannedAt,
    this.latitude,
    this.longitude,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['city_slug'] = Variable<String>(citySlug);
    map['year_value'] = Variable<int>(yearValue);
    map['mode'] = Variable<String>(mode);
    map['day_slug'] = Variable<String>(daySlug);
    map['event_position'] = Variable<int>(eventPosition);
    map['point_position'] = Variable<int>(pointPosition);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || plannedAt != null) {
      map['planned_at'] = Variable<DateTime>(plannedAt);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    return map;
  }

  DaySchedulePointEntriesCompanion toCompanion(bool nullToAbsent) {
    return DaySchedulePointEntriesCompanion(
      citySlug: Value(citySlug),
      yearValue: Value(yearValue),
      mode: Value(mode),
      daySlug: Value(daySlug),
      eventPosition: Value(eventPosition),
      pointPosition: Value(pointPosition),
      name: Value(name),
      plannedAt: plannedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedAt),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
    );
  }

  factory DaySchedulePointEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DaySchedulePointEntry(
      citySlug: serializer.fromJson<String>(json['citySlug']),
      yearValue: serializer.fromJson<int>(json['yearValue']),
      mode: serializer.fromJson<String>(json['mode']),
      daySlug: serializer.fromJson<String>(json['daySlug']),
      eventPosition: serializer.fromJson<int>(json['eventPosition']),
      pointPosition: serializer.fromJson<int>(json['pointPosition']),
      name: serializer.fromJson<String>(json['name']),
      plannedAt: serializer.fromJson<DateTime?>(json['plannedAt']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'citySlug': serializer.toJson<String>(citySlug),
      'yearValue': serializer.toJson<int>(yearValue),
      'mode': serializer.toJson<String>(mode),
      'daySlug': serializer.toJson<String>(daySlug),
      'eventPosition': serializer.toJson<int>(eventPosition),
      'pointPosition': serializer.toJson<int>(pointPosition),
      'name': serializer.toJson<String>(name),
      'plannedAt': serializer.toJson<DateTime?>(plannedAt),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
    };
  }

  DaySchedulePointEntry copyWith({
    String? citySlug,
    int? yearValue,
    String? mode,
    String? daySlug,
    int? eventPosition,
    int? pointPosition,
    String? name,
    Value<DateTime?> plannedAt = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
  }) => DaySchedulePointEntry(
    citySlug: citySlug ?? this.citySlug,
    yearValue: yearValue ?? this.yearValue,
    mode: mode ?? this.mode,
    daySlug: daySlug ?? this.daySlug,
    eventPosition: eventPosition ?? this.eventPosition,
    pointPosition: pointPosition ?? this.pointPosition,
    name: name ?? this.name,
    plannedAt: plannedAt.present ? plannedAt.value : this.plannedAt,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
  );
  DaySchedulePointEntry copyWithCompanion(
    DaySchedulePointEntriesCompanion data,
  ) {
    return DaySchedulePointEntry(
      citySlug: data.citySlug.present ? data.citySlug.value : this.citySlug,
      yearValue: data.yearValue.present ? data.yearValue.value : this.yearValue,
      mode: data.mode.present ? data.mode.value : this.mode,
      daySlug: data.daySlug.present ? data.daySlug.value : this.daySlug,
      eventPosition: data.eventPosition.present
          ? data.eventPosition.value
          : this.eventPosition,
      pointPosition: data.pointPosition.present
          ? data.pointPosition.value
          : this.pointPosition,
      name: data.name.present ? data.name.value : this.name,
      plannedAt: data.plannedAt.present ? data.plannedAt.value : this.plannedAt,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DaySchedulePointEntry(')
          ..write('citySlug: $citySlug, ')
          ..write('yearValue: $yearValue, ')
          ..write('mode: $mode, ')
          ..write('daySlug: $daySlug, ')
          ..write('eventPosition: $eventPosition, ')
          ..write('pointPosition: $pointPosition, ')
          ..write('name: $name, ')
          ..write('plannedAt: $plannedAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    citySlug,
    yearValue,
    mode,
    daySlug,
    eventPosition,
    pointPosition,
    name,
    plannedAt,
    latitude,
    longitude,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DaySchedulePointEntry &&
          other.citySlug == this.citySlug &&
          other.yearValue == this.yearValue &&
          other.mode == this.mode &&
          other.daySlug == this.daySlug &&
          other.eventPosition == this.eventPosition &&
          other.pointPosition == this.pointPosition &&
          other.name == this.name &&
          other.plannedAt == this.plannedAt &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude);
}

class DaySchedulePointEntriesCompanion
    extends UpdateCompanion<DaySchedulePointEntry> {
  final Value<String> citySlug;
  final Value<int> yearValue;
  final Value<String> mode;
  final Value<String> daySlug;
  final Value<int> eventPosition;
  final Value<int> pointPosition;
  final Value<String> name;
  final Value<DateTime?> plannedAt;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<int> rowid;
  const DaySchedulePointEntriesCompanion({
    this.citySlug = const Value.absent(),
    this.yearValue = const Value.absent(),
    this.mode = const Value.absent(),
    this.daySlug = const Value.absent(),
    this.eventPosition = const Value.absent(),
    this.pointPosition = const Value.absent(),
    this.name = const Value.absent(),
    this.plannedAt = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DaySchedulePointEntriesCompanion.insert({
    required String citySlug,
    required int yearValue,
    required String mode,
    required String daySlug,
    required int eventPosition,
    required int pointPosition,
    required String name,
    this.plannedAt = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : citySlug = Value(citySlug),
       yearValue = Value(yearValue),
       mode = Value(mode),
       daySlug = Value(daySlug),
       eventPosition = Value(eventPosition),
       pointPosition = Value(pointPosition),
       name = Value(name);
  static Insertable<DaySchedulePointEntry> custom({
    Expression<String>? citySlug,
    Expression<int>? yearValue,
    Expression<String>? mode,
    Expression<String>? daySlug,
    Expression<int>? eventPosition,
    Expression<int>? pointPosition,
    Expression<String>? name,
    Expression<DateTime>? plannedAt,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (citySlug != null) 'city_slug': citySlug,
      if (yearValue != null) 'year_value': yearValue,
      if (mode != null) 'mode': mode,
      if (daySlug != null) 'day_slug': daySlug,
      if (eventPosition != null) 'event_position': eventPosition,
      if (pointPosition != null) 'point_position': pointPosition,
      if (name != null) 'name': name,
      if (plannedAt != null) 'planned_at': plannedAt,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DaySchedulePointEntriesCompanion copyWith({
    Value<String>? citySlug,
    Value<int>? yearValue,
    Value<String>? mode,
    Value<String>? daySlug,
    Value<int>? eventPosition,
    Value<int>? pointPosition,
    Value<String>? name,
    Value<DateTime?>? plannedAt,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<int>? rowid,
  }) {
    return DaySchedulePointEntriesCompanion(
      citySlug: citySlug ?? this.citySlug,
      yearValue: yearValue ?? this.yearValue,
      mode: mode ?? this.mode,
      daySlug: daySlug ?? this.daySlug,
      eventPosition: eventPosition ?? this.eventPosition,
      pointPosition: pointPosition ?? this.pointPosition,
      name: name ?? this.name,
      plannedAt: plannedAt ?? this.plannedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (citySlug.present) {
      map['city_slug'] = Variable<String>(citySlug.value);
    }
    if (yearValue.present) {
      map['year_value'] = Variable<int>(yearValue.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (daySlug.present) {
      map['day_slug'] = Variable<String>(daySlug.value);
    }
    if (eventPosition.present) {
      map['event_position'] = Variable<int>(eventPosition.value);
    }
    if (pointPosition.present) {
      map['point_position'] = Variable<int>(pointPosition.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (plannedAt.present) {
      map['planned_at'] = Variable<DateTime>(plannedAt.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DaySchedulePointEntriesCompanion(')
          ..write('citySlug: $citySlug, ')
          ..write('yearValue: $yearValue, ')
          ..write('mode: $mode, ')
          ..write('daySlug: $daySlug, ')
          ..write('eventPosition: $eventPosition, ')
          ..write('pointPosition: $pointPosition, ')
          ..write('name: $name, ')
          ..write('plannedAt: $plannedAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DayRoutePointEntriesTable extends DayRoutePointEntries
    with TableInfo<$DayRoutePointEntriesTable, DayRoutePointEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayRoutePointEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _citySlugMeta = const VerificationMeta(
    'citySlug',
  );
  @override
  late final GeneratedColumn<String> citySlug = GeneratedColumn<String>(
    'city_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearValueMeta = const VerificationMeta(
    'yearValue',
  );
  @override
  late final GeneratedColumn<int> yearValue = GeneratedColumn<int>(
    'year_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daySlugMeta = const VerificationMeta(
    'daySlug',
  );
  @override
  late final GeneratedColumn<String> daySlug = GeneratedColumn<String>(
    'day_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventPositionMeta = const VerificationMeta(
    'eventPosition',
  );
  @override
  late final GeneratedColumn<int> eventPosition = GeneratedColumn<int>(
    'event_position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pointPositionMeta = const VerificationMeta(
    'pointPosition',
  );
  @override
  late final GeneratedColumn<int> pointPosition = GeneratedColumn<int>(
    'point_position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    citySlug,
    yearValue,
    mode,
    daySlug,
    eventPosition,
    pointPosition,
    latitude,
    longitude,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_route_point_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayRoutePointEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('city_slug')) {
      context.handle(
        _citySlugMeta,
        citySlug.isAcceptableOrUnknown(data['city_slug']!, _citySlugMeta),
      );
    } else if (isInserting) {
      context.missing(_citySlugMeta);
    }
    if (data.containsKey('year_value')) {
      context.handle(
        _yearValueMeta,
        yearValue.isAcceptableOrUnknown(data['year_value']!, _yearValueMeta),
      );
    } else if (isInserting) {
      context.missing(_yearValueMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('day_slug')) {
      context.handle(
        _daySlugMeta,
        daySlug.isAcceptableOrUnknown(data['day_slug']!, _daySlugMeta),
      );
    } else if (isInserting) {
      context.missing(_daySlugMeta);
    }
    if (data.containsKey('event_position')) {
      context.handle(
        _eventPositionMeta,
        eventPosition.isAcceptableOrUnknown(
          data['event_position']!,
          _eventPositionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eventPositionMeta);
    }
    if (data.containsKey('point_position')) {
      context.handle(
        _pointPositionMeta,
        pointPosition.isAcceptableOrUnknown(
          data['point_position']!,
          _pointPositionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pointPositionMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    citySlug,
    yearValue,
    mode,
    daySlug,
    eventPosition,
    pointPosition,
  };
  @override
  DayRoutePointEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayRoutePointEntry(
      citySlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city_slug'],
      )!,
      yearValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_value'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      daySlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_slug'],
      )!,
      eventPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_position'],
      )!,
      pointPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}point_position'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
    );
  }

  @override
  $DayRoutePointEntriesTable createAlias(String alias) {
    return $DayRoutePointEntriesTable(attachedDatabase, alias);
  }
}

class DayRoutePointEntry extends DataClass
    implements Insertable<DayRoutePointEntry> {
  final String citySlug;
  final int yearValue;
  final String mode;
  final String daySlug;
  final int eventPosition;
  final int pointPosition;
  final double? latitude;
  final double? longitude;
  const DayRoutePointEntry({
    required this.citySlug,
    required this.yearValue,
    required this.mode,
    required this.daySlug,
    required this.eventPosition,
    required this.pointPosition,
    this.latitude,
    this.longitude,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['city_slug'] = Variable<String>(citySlug);
    map['year_value'] = Variable<int>(yearValue);
    map['mode'] = Variable<String>(mode);
    map['day_slug'] = Variable<String>(daySlug);
    map['event_position'] = Variable<int>(eventPosition);
    map['point_position'] = Variable<int>(pointPosition);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    return map;
  }

  DayRoutePointEntriesCompanion toCompanion(bool nullToAbsent) {
    return DayRoutePointEntriesCompanion(
      citySlug: Value(citySlug),
      yearValue: Value(yearValue),
      mode: Value(mode),
      daySlug: Value(daySlug),
      eventPosition: Value(eventPosition),
      pointPosition: Value(pointPosition),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
    );
  }

  factory DayRoutePointEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayRoutePointEntry(
      citySlug: serializer.fromJson<String>(json['citySlug']),
      yearValue: serializer.fromJson<int>(json['yearValue']),
      mode: serializer.fromJson<String>(json['mode']),
      daySlug: serializer.fromJson<String>(json['daySlug']),
      eventPosition: serializer.fromJson<int>(json['eventPosition']),
      pointPosition: serializer.fromJson<int>(json['pointPosition']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'citySlug': serializer.toJson<String>(citySlug),
      'yearValue': serializer.toJson<int>(yearValue),
      'mode': serializer.toJson<String>(mode),
      'daySlug': serializer.toJson<String>(daySlug),
      'eventPosition': serializer.toJson<int>(eventPosition),
      'pointPosition': serializer.toJson<int>(pointPosition),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
    };
  }

  DayRoutePointEntry copyWith({
    String? citySlug,
    int? yearValue,
    String? mode,
    String? daySlug,
    int? eventPosition,
    int? pointPosition,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
  }) => DayRoutePointEntry(
    citySlug: citySlug ?? this.citySlug,
    yearValue: yearValue ?? this.yearValue,
    mode: mode ?? this.mode,
    daySlug: daySlug ?? this.daySlug,
    eventPosition: eventPosition ?? this.eventPosition,
    pointPosition: pointPosition ?? this.pointPosition,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
  );
  DayRoutePointEntry copyWithCompanion(DayRoutePointEntriesCompanion data) {
    return DayRoutePointEntry(
      citySlug: data.citySlug.present ? data.citySlug.value : this.citySlug,
      yearValue: data.yearValue.present ? data.yearValue.value : this.yearValue,
      mode: data.mode.present ? data.mode.value : this.mode,
      daySlug: data.daySlug.present ? data.daySlug.value : this.daySlug,
      eventPosition: data.eventPosition.present
          ? data.eventPosition.value
          : this.eventPosition,
      pointPosition: data.pointPosition.present
          ? data.pointPosition.value
          : this.pointPosition,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayRoutePointEntry(')
          ..write('citySlug: $citySlug, ')
          ..write('yearValue: $yearValue, ')
          ..write('mode: $mode, ')
          ..write('daySlug: $daySlug, ')
          ..write('eventPosition: $eventPosition, ')
          ..write('pointPosition: $pointPosition, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    citySlug,
    yearValue,
    mode,
    daySlug,
    eventPosition,
    pointPosition,
    latitude,
    longitude,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayRoutePointEntry &&
          other.citySlug == this.citySlug &&
          other.yearValue == this.yearValue &&
          other.mode == this.mode &&
          other.daySlug == this.daySlug &&
          other.eventPosition == this.eventPosition &&
          other.pointPosition == this.pointPosition &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude);
}

class DayRoutePointEntriesCompanion
    extends UpdateCompanion<DayRoutePointEntry> {
  final Value<String> citySlug;
  final Value<int> yearValue;
  final Value<String> mode;
  final Value<String> daySlug;
  final Value<int> eventPosition;
  final Value<int> pointPosition;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<int> rowid;
  const DayRoutePointEntriesCompanion({
    this.citySlug = const Value.absent(),
    this.yearValue = const Value.absent(),
    this.mode = const Value.absent(),
    this.daySlug = const Value.absent(),
    this.eventPosition = const Value.absent(),
    this.pointPosition = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayRoutePointEntriesCompanion.insert({
    required String citySlug,
    required int yearValue,
    required String mode,
    required String daySlug,
    required int eventPosition,
    required int pointPosition,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : citySlug = Value(citySlug),
       yearValue = Value(yearValue),
       mode = Value(mode),
       daySlug = Value(daySlug),
       eventPosition = Value(eventPosition),
       pointPosition = Value(pointPosition);
  static Insertable<DayRoutePointEntry> custom({
    Expression<String>? citySlug,
    Expression<int>? yearValue,
    Expression<String>? mode,
    Expression<String>? daySlug,
    Expression<int>? eventPosition,
    Expression<int>? pointPosition,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (citySlug != null) 'city_slug': citySlug,
      if (yearValue != null) 'year_value': yearValue,
      if (mode != null) 'mode': mode,
      if (daySlug != null) 'day_slug': daySlug,
      if (eventPosition != null) 'event_position': eventPosition,
      if (pointPosition != null) 'point_position': pointPosition,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayRoutePointEntriesCompanion copyWith({
    Value<String>? citySlug,
    Value<int>? yearValue,
    Value<String>? mode,
    Value<String>? daySlug,
    Value<int>? eventPosition,
    Value<int>? pointPosition,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<int>? rowid,
  }) {
    return DayRoutePointEntriesCompanion(
      citySlug: citySlug ?? this.citySlug,
      yearValue: yearValue ?? this.yearValue,
      mode: mode ?? this.mode,
      daySlug: daySlug ?? this.daySlug,
      eventPosition: eventPosition ?? this.eventPosition,
      pointPosition: pointPosition ?? this.pointPosition,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (citySlug.present) {
      map['city_slug'] = Variable<String>(citySlug.value);
    }
    if (yearValue.present) {
      map['year_value'] = Variable<int>(yearValue.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (daySlug.present) {
      map['day_slug'] = Variable<String>(daySlug.value);
    }
    if (eventPosition.present) {
      map['event_position'] = Variable<int>(eventPosition.value);
    }
    if (pointPosition.present) {
      map['point_position'] = Variable<int>(pointPosition.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayRoutePointEntriesCompanion(')
          ..write('citySlug: $citySlug, ')
          ..write('yearValue: $yearValue, ')
          ..write('mode: $mode, ')
          ..write('daySlug: $daySlug, ')
          ..write('eventPosition: $eventPosition, ')
          ..write('pointPosition: $pointPosition, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DayOfficialRoutePointEntriesTable extends DayOfficialRoutePointEntries
    with
        TableInfo<
          $DayOfficialRoutePointEntriesTable,
          DayOfficialRoutePointEntry
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayOfficialRoutePointEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _citySlugMeta = const VerificationMeta(
    'citySlug',
  );
  @override
  late final GeneratedColumn<String> citySlug = GeneratedColumn<String>(
    'city_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearValueMeta = const VerificationMeta(
    'yearValue',
  );
  @override
  late final GeneratedColumn<int> yearValue = GeneratedColumn<int>(
    'year_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daySlugMeta = const VerificationMeta(
    'daySlug',
  );
  @override
  late final GeneratedColumn<String> daySlug = GeneratedColumn<String>(
    'day_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pointPositionMeta = const VerificationMeta(
    'pointPosition',
  );
  @override
  late final GeneratedColumn<int> pointPosition = GeneratedColumn<int>(
    'point_position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    citySlug,
    yearValue,
    mode,
    daySlug,
    pointPosition,
    latitude,
    longitude,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_official_route_point_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayOfficialRoutePointEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('city_slug')) {
      context.handle(
        _citySlugMeta,
        citySlug.isAcceptableOrUnknown(data['city_slug']!, _citySlugMeta),
      );
    } else if (isInserting) {
      context.missing(_citySlugMeta);
    }
    if (data.containsKey('year_value')) {
      context.handle(
        _yearValueMeta,
        yearValue.isAcceptableOrUnknown(data['year_value']!, _yearValueMeta),
      );
    } else if (isInserting) {
      context.missing(_yearValueMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('day_slug')) {
      context.handle(
        _daySlugMeta,
        daySlug.isAcceptableOrUnknown(data['day_slug']!, _daySlugMeta),
      );
    } else if (isInserting) {
      context.missing(_daySlugMeta);
    }
    if (data.containsKey('point_position')) {
      context.handle(
        _pointPositionMeta,
        pointPosition.isAcceptableOrUnknown(
          data['point_position']!,
          _pointPositionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pointPositionMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    citySlug,
    yearValue,
    mode,
    daySlug,
    pointPosition,
  };
  @override
  DayOfficialRoutePointEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayOfficialRoutePointEntry(
      citySlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city_slug'],
      )!,
      yearValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_value'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      daySlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_slug'],
      )!,
      pointPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}point_position'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
    );
  }

  @override
  $DayOfficialRoutePointEntriesTable createAlias(String alias) {
    return $DayOfficialRoutePointEntriesTable(attachedDatabase, alias);
  }
}

class DayOfficialRoutePointEntry extends DataClass
    implements Insertable<DayOfficialRoutePointEntry> {
  final String citySlug;
  final int yearValue;
  final String mode;
  final String daySlug;
  final int pointPosition;
  final double? latitude;
  final double? longitude;
  const DayOfficialRoutePointEntry({
    required this.citySlug,
    required this.yearValue,
    required this.mode,
    required this.daySlug,
    required this.pointPosition,
    this.latitude,
    this.longitude,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['city_slug'] = Variable<String>(citySlug);
    map['year_value'] = Variable<int>(yearValue);
    map['mode'] = Variable<String>(mode);
    map['day_slug'] = Variable<String>(daySlug);
    map['point_position'] = Variable<int>(pointPosition);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    return map;
  }

  DayOfficialRoutePointEntriesCompanion toCompanion(bool nullToAbsent) {
    return DayOfficialRoutePointEntriesCompanion(
      citySlug: Value(citySlug),
      yearValue: Value(yearValue),
      mode: Value(mode),
      daySlug: Value(daySlug),
      pointPosition: Value(pointPosition),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
    );
  }

  factory DayOfficialRoutePointEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayOfficialRoutePointEntry(
      citySlug: serializer.fromJson<String>(json['citySlug']),
      yearValue: serializer.fromJson<int>(json['yearValue']),
      mode: serializer.fromJson<String>(json['mode']),
      daySlug: serializer.fromJson<String>(json['daySlug']),
      pointPosition: serializer.fromJson<int>(json['pointPosition']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'citySlug': serializer.toJson<String>(citySlug),
      'yearValue': serializer.toJson<int>(yearValue),
      'mode': serializer.toJson<String>(mode),
      'daySlug': serializer.toJson<String>(daySlug),
      'pointPosition': serializer.toJson<int>(pointPosition),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
    };
  }

  DayOfficialRoutePointEntry copyWith({
    String? citySlug,
    int? yearValue,
    String? mode,
    String? daySlug,
    int? pointPosition,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
  }) => DayOfficialRoutePointEntry(
    citySlug: citySlug ?? this.citySlug,
    yearValue: yearValue ?? this.yearValue,
    mode: mode ?? this.mode,
    daySlug: daySlug ?? this.daySlug,
    pointPosition: pointPosition ?? this.pointPosition,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
  );
  DayOfficialRoutePointEntry copyWithCompanion(
    DayOfficialRoutePointEntriesCompanion data,
  ) {
    return DayOfficialRoutePointEntry(
      citySlug: data.citySlug.present ? data.citySlug.value : this.citySlug,
      yearValue: data.yearValue.present ? data.yearValue.value : this.yearValue,
      mode: data.mode.present ? data.mode.value : this.mode,
      daySlug: data.daySlug.present ? data.daySlug.value : this.daySlug,
      pointPosition: data.pointPosition.present
          ? data.pointPosition.value
          : this.pointPosition,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayOfficialRoutePointEntry(')
          ..write('citySlug: $citySlug, ')
          ..write('yearValue: $yearValue, ')
          ..write('mode: $mode, ')
          ..write('daySlug: $daySlug, ')
          ..write('pointPosition: $pointPosition, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    citySlug,
    yearValue,
    mode,
    daySlug,
    pointPosition,
    latitude,
    longitude,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayOfficialRoutePointEntry &&
          other.citySlug == this.citySlug &&
          other.yearValue == this.yearValue &&
          other.mode == this.mode &&
          other.daySlug == this.daySlug &&
          other.pointPosition == this.pointPosition &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude);
}

class DayOfficialRoutePointEntriesCompanion
    extends UpdateCompanion<DayOfficialRoutePointEntry> {
  final Value<String> citySlug;
  final Value<int> yearValue;
  final Value<String> mode;
  final Value<String> daySlug;
  final Value<int> pointPosition;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<int> rowid;
  const DayOfficialRoutePointEntriesCompanion({
    this.citySlug = const Value.absent(),
    this.yearValue = const Value.absent(),
    this.mode = const Value.absent(),
    this.daySlug = const Value.absent(),
    this.pointPosition = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayOfficialRoutePointEntriesCompanion.insert({
    required String citySlug,
    required int yearValue,
    required String mode,
    required String daySlug,
    required int pointPosition,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : citySlug = Value(citySlug),
       yearValue = Value(yearValue),
       mode = Value(mode),
       daySlug = Value(daySlug),
       pointPosition = Value(pointPosition);
  static Insertable<DayOfficialRoutePointEntry> custom({
    Expression<String>? citySlug,
    Expression<int>? yearValue,
    Expression<String>? mode,
    Expression<String>? daySlug,
    Expression<int>? pointPosition,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (citySlug != null) 'city_slug': citySlug,
      if (yearValue != null) 'year_value': yearValue,
      if (mode != null) 'mode': mode,
      if (daySlug != null) 'day_slug': daySlug,
      if (pointPosition != null) 'point_position': pointPosition,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayOfficialRoutePointEntriesCompanion copyWith({
    Value<String>? citySlug,
    Value<int>? yearValue,
    Value<String>? mode,
    Value<String>? daySlug,
    Value<int>? pointPosition,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<int>? rowid,
  }) {
    return DayOfficialRoutePointEntriesCompanion(
      citySlug: citySlug ?? this.citySlug,
      yearValue: yearValue ?? this.yearValue,
      mode: mode ?? this.mode,
      daySlug: daySlug ?? this.daySlug,
      pointPosition: pointPosition ?? this.pointPosition,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (citySlug.present) {
      map['city_slug'] = Variable<String>(citySlug.value);
    }
    if (yearValue.present) {
      map['year_value'] = Variable<int>(yearValue.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (daySlug.present) {
      map['day_slug'] = Variable<String>(daySlug.value);
    }
    if (pointPosition.present) {
      map['point_position'] = Variable<int>(pointPosition.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayOfficialRoutePointEntriesCompanion(')
          ..write('citySlug: $citySlug, ')
          ..write('yearValue: $yearValue, ')
          ..write('mode: $mode, ')
          ..write('daySlug: $daySlug, ')
          ..write('pointPosition: $pointPosition, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStatusEntriesTable extends SyncStatusEntries
    with TableInfo<$SyncStatusEntriesTable, SyncStatusEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStatusEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _citySlugMeta = const VerificationMeta(
    'citySlug',
  );
  @override
  late final GeneratedColumn<String> citySlug = GeneratedColumn<String>(
    'city_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearValueMeta = const VerificationMeta(
    'yearValue',
  );
  @override
  late final GeneratedColumn<int> yearValue = GeneratedColumn<int>(
    'year_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    citySlug,
    yearValue,
    mode,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_status_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStatusEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('city_slug')) {
      context.handle(
        _citySlugMeta,
        citySlug.isAcceptableOrUnknown(data['city_slug']!, _citySlugMeta),
      );
    } else if (isInserting) {
      context.missing(_citySlugMeta);
    }
    if (data.containsKey('year_value')) {
      context.handle(
        _yearValueMeta,
        yearValue.isAcceptableOrUnknown(data['year_value']!, _yearValueMeta),
      );
    } else if (isInserting) {
      context.missing(_yearValueMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSyncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {citySlug, yearValue, mode};
  @override
  SyncStatusEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStatusEntry(
      citySlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city_slug'],
      )!,
      yearValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_value'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      )!,
    );
  }

  @override
  $SyncStatusEntriesTable createAlias(String alias) {
    return $SyncStatusEntriesTable(attachedDatabase, alias);
  }
}

class SyncStatusEntry extends DataClass implements Insertable<SyncStatusEntry> {
  final String citySlug;
  final int yearValue;
  final String mode;
  final DateTime lastSyncedAt;
  const SyncStatusEntry({
    required this.citySlug,
    required this.yearValue,
    required this.mode,
    required this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['city_slug'] = Variable<String>(citySlug);
    map['year_value'] = Variable<int>(yearValue);
    map['mode'] = Variable<String>(mode);
    map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    return map;
  }

  SyncStatusEntriesCompanion toCompanion(bool nullToAbsent) {
    return SyncStatusEntriesCompanion(
      citySlug: Value(citySlug),
      yearValue: Value(yearValue),
      mode: Value(mode),
      lastSyncedAt: Value(lastSyncedAt),
    );
  }

  factory SyncStatusEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStatusEntry(
      citySlug: serializer.fromJson<String>(json['citySlug']),
      yearValue: serializer.fromJson<int>(json['yearValue']),
      mode: serializer.fromJson<String>(json['mode']),
      lastSyncedAt: serializer.fromJson<DateTime>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'citySlug': serializer.toJson<String>(citySlug),
      'yearValue': serializer.toJson<int>(yearValue),
      'mode': serializer.toJson<String>(mode),
      'lastSyncedAt': serializer.toJson<DateTime>(lastSyncedAt),
    };
  }

  SyncStatusEntry copyWith({
    String? citySlug,
    int? yearValue,
    String? mode,
    DateTime? lastSyncedAt,
  }) => SyncStatusEntry(
    citySlug: citySlug ?? this.citySlug,
    yearValue: yearValue ?? this.yearValue,
    mode: mode ?? this.mode,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
  );
  SyncStatusEntry copyWithCompanion(SyncStatusEntriesCompanion data) {
    return SyncStatusEntry(
      citySlug: data.citySlug.present ? data.citySlug.value : this.citySlug,
      yearValue: data.yearValue.present ? data.yearValue.value : this.yearValue,
      mode: data.mode.present ? data.mode.value : this.mode,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStatusEntry(')
          ..write('citySlug: $citySlug, ')
          ..write('yearValue: $yearValue, ')
          ..write('mode: $mode, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(citySlug, yearValue, mode, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStatusEntry &&
          other.citySlug == this.citySlug &&
          other.yearValue == this.yearValue &&
          other.mode == this.mode &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class SyncStatusEntriesCompanion extends UpdateCompanion<SyncStatusEntry> {
  final Value<String> citySlug;
  final Value<int> yearValue;
  final Value<String> mode;
  final Value<DateTime> lastSyncedAt;
  final Value<int> rowid;
  const SyncStatusEntriesCompanion({
    this.citySlug = const Value.absent(),
    this.yearValue = const Value.absent(),
    this.mode = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStatusEntriesCompanion.insert({
    required String citySlug,
    required int yearValue,
    required String mode,
    required DateTime lastSyncedAt,
    this.rowid = const Value.absent(),
  }) : citySlug = Value(citySlug),
       yearValue = Value(yearValue),
       mode = Value(mode),
       lastSyncedAt = Value(lastSyncedAt);
  static Insertable<SyncStatusEntry> custom({
    Expression<String>? citySlug,
    Expression<int>? yearValue,
    Expression<String>? mode,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (citySlug != null) 'city_slug': citySlug,
      if (yearValue != null) 'year_value': yearValue,
      if (mode != null) 'mode': mode,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStatusEntriesCompanion copyWith({
    Value<String>? citySlug,
    Value<int>? yearValue,
    Value<String>? mode,
    Value<DateTime>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return SyncStatusEntriesCompanion(
      citySlug: citySlug ?? this.citySlug,
      yearValue: yearValue ?? this.yearValue,
      mode: mode ?? this.mode,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (citySlug.present) {
      map['city_slug'] = Variable<String>(citySlug.value);
    }
    if (yearValue.present) {
      map['year_value'] = Variable<int>(yearValue.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStatusEntriesCompanion(')
          ..write('citySlug: $citySlug, ')
          ..write('yearValue: $yearValue, ')
          ..write('mode: $mode, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsEntriesTable extends AppSettingsEntries
    with TableInfo<$AppSettingsEntriesTable, AppSettingsEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsEntriesTable(this.attachedDatabase, [this._alias]);
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
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsEntry> instance, {
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingsEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsEntriesTable createAlias(String alias) {
    return $AppSettingsEntriesTable(attachedDatabase, alias);
  }
}

class AppSettingsEntry extends DataClass
    implements Insertable<AppSettingsEntry> {
  final String key;
  final String value;
  const AppSettingsEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsEntriesCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory AppSettingsEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSettingsEntry copyWith({String? key, String? value}) =>
      AppSettingsEntry(key: key ?? this.key, value: value ?? this.value);
  AppSettingsEntry copyWithCompanion(AppSettingsEntriesCompanion data) {
    return AppSettingsEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsEntriesCompanion extends UpdateCompanion<AppSettingsEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsEntriesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSettingsEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HttpCacheEntriesTable httpCacheEntries = $HttpCacheEntriesTable(
    this,
  );
  late final $DaysTable days = $DaysTable(this);
  late final $DayDetailEntriesTable dayDetailEntries = $DayDetailEntriesTable(
    this,
  );
  late final $DayProcessionEventEntriesTable dayProcessionEventEntries =
      $DayProcessionEventEntriesTable(this);
  late final $DaySchedulePointEntriesTable daySchedulePointEntries =
      $DaySchedulePointEntriesTable(this);
  late final $DayRoutePointEntriesTable dayRoutePointEntries =
      $DayRoutePointEntriesTable(this);
  late final $DayOfficialRoutePointEntriesTable dayOfficialRoutePointEntries =
      $DayOfficialRoutePointEntriesTable(this);
  late final $SyncStatusEntriesTable syncStatusEntries =
      $SyncStatusEntriesTable(this);
  late final $AppSettingsEntriesTable appSettingsEntries =
      $AppSettingsEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    httpCacheEntries,
    days,
    dayDetailEntries,
    dayProcessionEventEntries,
    daySchedulePointEntries,
    dayRoutePointEntries,
    dayOfficialRoutePointEntries,
    syncStatusEntries,
    appSettingsEntries,
  ];
}

typedef $$HttpCacheEntriesTableCreateCompanionBuilder =
    HttpCacheEntriesCompanion Function({
      required String key,
      required String payload,
      required DateTime savedAt,
      Value<int> rowid,
    });
typedef $$HttpCacheEntriesTableUpdateCompanionBuilder =
    HttpCacheEntriesCompanion Function({
      Value<String> key,
      Value<String> payload,
      Value<DateTime> savedAt,
      Value<int> rowid,
    });

class $$HttpCacheEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $HttpCacheEntriesTable> {
  $$HttpCacheEntriesTableFilterComposer({
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

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HttpCacheEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $HttpCacheEntriesTable> {
  $$HttpCacheEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HttpCacheEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HttpCacheEntriesTable> {
  $$HttpCacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);
}

class $$HttpCacheEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HttpCacheEntriesTable,
          HttpCacheEntry,
          $$HttpCacheEntriesTableFilterComposer,
          $$HttpCacheEntriesTableOrderingComposer,
          $$HttpCacheEntriesTableAnnotationComposer,
          $$HttpCacheEntriesTableCreateCompanionBuilder,
          $$HttpCacheEntriesTableUpdateCompanionBuilder,
          (
            HttpCacheEntry,
            BaseReferences<
              _$AppDatabase,
              $HttpCacheEntriesTable,
              HttpCacheEntry
            >,
          ),
          HttpCacheEntry,
          PrefetchHooks Function()
        > {
  $$HttpCacheEntriesTableTableManager(
    _$AppDatabase db,
    $HttpCacheEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HttpCacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HttpCacheEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HttpCacheEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HttpCacheEntriesCompanion(
                key: key,
                payload: payload,
                savedAt: savedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String payload,
                required DateTime savedAt,
                Value<int> rowid = const Value.absent(),
              }) => HttpCacheEntriesCompanion.insert(
                key: key,
                payload: payload,
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

typedef $$HttpCacheEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HttpCacheEntriesTable,
      HttpCacheEntry,
      $$HttpCacheEntriesTableFilterComposer,
      $$HttpCacheEntriesTableOrderingComposer,
      $$HttpCacheEntriesTableAnnotationComposer,
      $$HttpCacheEntriesTableCreateCompanionBuilder,
      $$HttpCacheEntriesTableUpdateCompanionBuilder,
      (
        HttpCacheEntry,
        BaseReferences<_$AppDatabase, $HttpCacheEntriesTable, HttpCacheEntry>,
      ),
      HttpCacheEntry,
      PrefetchHooks Function()
    >;
typedef $$DaysTableCreateCompanionBuilder =
    DaysCompanion Function({
      required String citySlug,
      required int yearValue,
      required String mode,
      required String slug,
      required String name,
      Value<DateTime?> startsAt,
      Value<DateTime?> liturgicalDate,
      required int processionEventsCount,
      Value<String?> weatherIconCode,
      Value<String?> weatherConditionLabel,
      Value<double?> weatherTempMinC,
      Value<double?> weatherTempMaxC,
      Value<String?> weatherHourlyJson,
      Value<int> rowid,
    });
typedef $$DaysTableUpdateCompanionBuilder =
    DaysCompanion Function({
      Value<String> citySlug,
      Value<int> yearValue,
      Value<String> mode,
      Value<String> slug,
      Value<String> name,
      Value<DateTime?> startsAt,
      Value<DateTime?> liturgicalDate,
      Value<int> processionEventsCount,
      Value<String?> weatherIconCode,
      Value<String?> weatherConditionLabel,
      Value<double?> weatherTempMinC,
      Value<double?> weatherTempMaxC,
      Value<String?> weatherHourlyJson,
      Value<int> rowid,
    });

class $$DaysTableFilterComposer extends Composer<_$AppDatabase, $DaysTable> {
  $$DaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get citySlug => $composableBuilder(
    column: $table.citySlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearValue => $composableBuilder(
    column: $table.yearValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get liturgicalDate => $composableBuilder(
    column: $table.liturgicalDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get processionEventsCount => $composableBuilder(
    column: $table.processionEventsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weatherIconCode => $composableBuilder(
    column: $table.weatherIconCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weatherConditionLabel => $composableBuilder(
    column: $table.weatherConditionLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weatherTempMinC => $composableBuilder(
    column: $table.weatherTempMinC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weatherTempMaxC => $composableBuilder(
    column: $table.weatherTempMaxC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weatherHourlyJson => $composableBuilder(
    column: $table.weatherHourlyJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DaysTableOrderingComposer extends Composer<_$AppDatabase, $DaysTable> {
  $$DaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get citySlug => $composableBuilder(
    column: $table.citySlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearValue => $composableBuilder(
    column: $table.yearValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get liturgicalDate => $composableBuilder(
    column: $table.liturgicalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get processionEventsCount => $composableBuilder(
    column: $table.processionEventsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weatherIconCode => $composableBuilder(
    column: $table.weatherIconCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weatherConditionLabel => $composableBuilder(
    column: $table.weatherConditionLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weatherTempMinC => $composableBuilder(
    column: $table.weatherTempMinC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weatherTempMaxC => $composableBuilder(
    column: $table.weatherTempMaxC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weatherHourlyJson => $composableBuilder(
    column: $table.weatherHourlyJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $DaysTable> {
  $$DaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get citySlug =>
      $composableBuilder(column: $table.citySlug, builder: (column) => column);

  GeneratedColumn<int> get yearValue =>
      $composableBuilder(column: $table.yearValue, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get startsAt =>
      $composableBuilder(column: $table.startsAt, builder: (column) => column);

  GeneratedColumn<DateTime> get liturgicalDate => $composableBuilder(
    column: $table.liturgicalDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get processionEventsCount => $composableBuilder(
    column: $table.processionEventsCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weatherIconCode => $composableBuilder(
    column: $table.weatherIconCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weatherConditionLabel => $composableBuilder(
    column: $table.weatherConditionLabel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weatherTempMinC => $composableBuilder(
    column: $table.weatherTempMinC,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weatherTempMaxC => $composableBuilder(
    column: $table.weatherTempMaxC,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weatherHourlyJson => $composableBuilder(
    column: $table.weatherHourlyJson,
    builder: (column) => column,
  );
}

class $$DaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DaysTable,
          Day,
          $$DaysTableFilterComposer,
          $$DaysTableOrderingComposer,
          $$DaysTableAnnotationComposer,
          $$DaysTableCreateCompanionBuilder,
          $$DaysTableUpdateCompanionBuilder,
          (Day, BaseReferences<_$AppDatabase, $DaysTable, Day>),
          Day,
          PrefetchHooks Function()
        > {
  $$DaysTableTableManager(_$AppDatabase db, $DaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> citySlug = const Value.absent(),
                Value<int> yearValue = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime?> startsAt = const Value.absent(),
                Value<DateTime?> liturgicalDate = const Value.absent(),
                Value<int> processionEventsCount = const Value.absent(),
                Value<String?> weatherIconCode = const Value.absent(),
                Value<String?> weatherConditionLabel = const Value.absent(),
                Value<double?> weatherTempMinC = const Value.absent(),
                Value<double?> weatherTempMaxC = const Value.absent(),
                Value<String?> weatherHourlyJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DaysCompanion(
                citySlug: citySlug,
                yearValue: yearValue,
                mode: mode,
                slug: slug,
                name: name,
                startsAt: startsAt,
                liturgicalDate: liturgicalDate,
                processionEventsCount: processionEventsCount,
                weatherIconCode: weatherIconCode,
                weatherConditionLabel: weatherConditionLabel,
                weatherTempMinC: weatherTempMinC,
                weatherTempMaxC: weatherTempMaxC,
                weatherHourlyJson: weatherHourlyJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String citySlug,
                required int yearValue,
                required String mode,
                required String slug,
                required String name,
                Value<DateTime?> startsAt = const Value.absent(),
                Value<DateTime?> liturgicalDate = const Value.absent(),
                required int processionEventsCount,
                Value<String?> weatherIconCode = const Value.absent(),
                Value<String?> weatherConditionLabel = const Value.absent(),
                Value<double?> weatherTempMinC = const Value.absent(),
                Value<double?> weatherTempMaxC = const Value.absent(),
                Value<String?> weatherHourlyJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DaysCompanion.insert(
                citySlug: citySlug,
                yearValue: yearValue,
                mode: mode,
                slug: slug,
                name: name,
                startsAt: startsAt,
                liturgicalDate: liturgicalDate,
                processionEventsCount: processionEventsCount,
                weatherIconCode: weatherIconCode,
                weatherConditionLabel: weatherConditionLabel,
                weatherTempMinC: weatherTempMinC,
                weatherTempMaxC: weatherTempMaxC,
                weatherHourlyJson: weatherHourlyJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DaysTable,
      Day,
      $$DaysTableFilterComposer,
      $$DaysTableOrderingComposer,
      $$DaysTableAnnotationComposer,
      $$DaysTableCreateCompanionBuilder,
      $$DaysTableUpdateCompanionBuilder,
      (Day, BaseReferences<_$AppDatabase, $DaysTable, Day>),
      Day,
      PrefetchHooks Function()
    >;
typedef $$DayDetailEntriesTableCreateCompanionBuilder =
    DayDetailEntriesCompanion Function({
      required String citySlug,
      required int yearValue,
      required String mode,
      required String daySlug,
      required String name,
      Value<String?> officialRouteArgb,
      Value<int> rowid,
    });
typedef $$DayDetailEntriesTableUpdateCompanionBuilder =
    DayDetailEntriesCompanion Function({
      Value<String> citySlug,
      Value<int> yearValue,
      Value<String> mode,
      Value<String> daySlug,
      Value<String> name,
      Value<String?> officialRouteArgb,
      Value<int> rowid,
    });

class $$DayDetailEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DayDetailEntriesTable> {
  $$DayDetailEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get citySlug => $composableBuilder(
    column: $table.citySlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearValue => $composableBuilder(
    column: $table.yearValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get daySlug => $composableBuilder(
    column: $table.daySlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get officialRouteArgb => $composableBuilder(
    column: $table.officialRouteArgb,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DayDetailEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DayDetailEntriesTable> {
  $$DayDetailEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get citySlug => $composableBuilder(
    column: $table.citySlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearValue => $composableBuilder(
    column: $table.yearValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get daySlug => $composableBuilder(
    column: $table.daySlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get officialRouteArgb => $composableBuilder(
    column: $table.officialRouteArgb,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayDetailEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayDetailEntriesTable> {
  $$DayDetailEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get citySlug =>
      $composableBuilder(column: $table.citySlug, builder: (column) => column);

  GeneratedColumn<int> get yearValue =>
      $composableBuilder(column: $table.yearValue, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get daySlug =>
      $composableBuilder(column: $table.daySlug, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get officialRouteArgb => $composableBuilder(
    column: $table.officialRouteArgb,
    builder: (column) => column,
  );
}

class $$DayDetailEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayDetailEntriesTable,
          DayDetailEntry,
          $$DayDetailEntriesTableFilterComposer,
          $$DayDetailEntriesTableOrderingComposer,
          $$DayDetailEntriesTableAnnotationComposer,
          $$DayDetailEntriesTableCreateCompanionBuilder,
          $$DayDetailEntriesTableUpdateCompanionBuilder,
          (
            DayDetailEntry,
            BaseReferences<
              _$AppDatabase,
              $DayDetailEntriesTable,
              DayDetailEntry
            >,
          ),
          DayDetailEntry,
          PrefetchHooks Function()
        > {
  $$DayDetailEntriesTableTableManager(
    _$AppDatabase db,
    $DayDetailEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayDetailEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayDetailEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayDetailEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> citySlug = const Value.absent(),
                Value<int> yearValue = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> daySlug = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> officialRouteArgb = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayDetailEntriesCompanion(
                citySlug: citySlug,
                yearValue: yearValue,
                mode: mode,
                daySlug: daySlug,
                name: name,
                officialRouteArgb: officialRouteArgb,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String citySlug,
                required int yearValue,
                required String mode,
                required String daySlug,
                required String name,
                Value<String?> officialRouteArgb = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayDetailEntriesCompanion.insert(
                citySlug: citySlug,
                yearValue: yearValue,
                mode: mode,
                daySlug: daySlug,
                name: name,
                officialRouteArgb: officialRouteArgb,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayDetailEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayDetailEntriesTable,
      DayDetailEntry,
      $$DayDetailEntriesTableFilterComposer,
      $$DayDetailEntriesTableOrderingComposer,
      $$DayDetailEntriesTableAnnotationComposer,
      $$DayDetailEntriesTableCreateCompanionBuilder,
      $$DayDetailEntriesTableUpdateCompanionBuilder,
      (
        DayDetailEntry,
        BaseReferences<_$AppDatabase, $DayDetailEntriesTable, DayDetailEntry>,
      ),
      DayDetailEntry,
      PrefetchHooks Function()
    >;
typedef $$DayProcessionEventEntriesTableCreateCompanionBuilder =
    DayProcessionEventEntriesCompanion Function({
      required String citySlug,
      required int yearValue,
      required String mode,
      required String daySlug,
      required int position,
      required String status,
      required String officialNote,
      Value<int?> passDurationMinutes,
      Value<int?> stepsCount,
      Value<int?> distanceMeters,
      Value<int?> brothersCount,
      Value<int?> nazarenesCount,
      required String brotherhoodName,
      required String brotherhoodSlug,
      required String brotherhoodColorHex,
      Value<String?> brotherhoodHistory,
      Value<String?> brotherhoodHeaderImageUrl,
      Value<String?> brotherhoodDressCode,
      Value<String?> brotherhoodFiguresJson,
      Value<String?> brotherhoodPasosJson,
      Value<String?> brotherhoodShieldImageUrl,
      Value<String?> routeArgb,
      Value<String?> routeKml,
      Value<int> rowid,
    });
typedef $$DayProcessionEventEntriesTableUpdateCompanionBuilder =
    DayProcessionEventEntriesCompanion Function({
      Value<String> citySlug,
      Value<int> yearValue,
      Value<String> mode,
      Value<String> daySlug,
      Value<int> position,
      Value<String> status,
      Value<String> officialNote,
      Value<int?> passDurationMinutes,
      Value<int?> stepsCount,
      Value<int?> distanceMeters,
      Value<int?> brothersCount,
      Value<int?> nazarenesCount,
      Value<String> brotherhoodName,
      Value<String> brotherhoodSlug,
      Value<String> brotherhoodColorHex,
      Value<String?> brotherhoodHistory,
      Value<String?> brotherhoodHeaderImageUrl,
      Value<String?> brotherhoodDressCode,
      Value<String?> brotherhoodFiguresJson,
      Value<String?> brotherhoodPasosJson,
      Value<String?> brotherhoodShieldImageUrl,
      Value<String?> routeArgb,
      Value<String?> routeKml,
      Value<int> rowid,
    });

class $$DayProcessionEventEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DayProcessionEventEntriesTable> {
  $$DayProcessionEventEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get citySlug => $composableBuilder(
    column: $table.citySlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearValue => $composableBuilder(
    column: $table.yearValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get daySlug => $composableBuilder(
    column: $table.daySlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get officialNote => $composableBuilder(
    column: $table.officialNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get passDurationMinutes => $composableBuilder(
    column: $table.passDurationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stepsCount => $composableBuilder(
    column: $table.stepsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get brothersCount => $composableBuilder(
    column: $table.brothersCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nazarenesCount => $composableBuilder(
    column: $table.nazarenesCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brotherhoodName => $composableBuilder(
    column: $table.brotherhoodName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brotherhoodSlug => $composableBuilder(
    column: $table.brotherhoodSlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brotherhoodColorHex => $composableBuilder(
    column: $table.brotherhoodColorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brotherhoodHistory => $composableBuilder(
    column: $table.brotherhoodHistory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brotherhoodHeaderImageUrl => $composableBuilder(
    column: $table.brotherhoodHeaderImageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brotherhoodDressCode => $composableBuilder(
    column: $table.brotherhoodDressCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brotherhoodFiguresJson => $composableBuilder(
    column: $table.brotherhoodFiguresJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brotherhoodPasosJson => $composableBuilder(
    column: $table.brotherhoodPasosJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brotherhoodShieldImageUrl => $composableBuilder(
    column: $table.brotherhoodShieldImageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routeArgb => $composableBuilder(
    column: $table.routeArgb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routeKml => $composableBuilder(
    column: $table.routeKml,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DayProcessionEventEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DayProcessionEventEntriesTable> {
  $$DayProcessionEventEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get citySlug => $composableBuilder(
    column: $table.citySlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearValue => $composableBuilder(
    column: $table.yearValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get daySlug => $composableBuilder(
    column: $table.daySlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get officialNote => $composableBuilder(
    column: $table.officialNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passDurationMinutes => $composableBuilder(
    column: $table.passDurationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stepsCount => $composableBuilder(
    column: $table.stepsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get brothersCount => $composableBuilder(
    column: $table.brothersCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nazarenesCount => $composableBuilder(
    column: $table.nazarenesCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brotherhoodName => $composableBuilder(
    column: $table.brotherhoodName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brotherhoodSlug => $composableBuilder(
    column: $table.brotherhoodSlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brotherhoodColorHex => $composableBuilder(
    column: $table.brotherhoodColorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brotherhoodHistory => $composableBuilder(
    column: $table.brotherhoodHistory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brotherhoodHeaderImageUrl => $composableBuilder(
    column: $table.brotherhoodHeaderImageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brotherhoodDressCode => $composableBuilder(
    column: $table.brotherhoodDressCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brotherhoodFiguresJson => $composableBuilder(
    column: $table.brotherhoodFiguresJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brotherhoodPasosJson => $composableBuilder(
    column: $table.brotherhoodPasosJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brotherhoodShieldImageUrl => $composableBuilder(
    column: $table.brotherhoodShieldImageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routeArgb => $composableBuilder(
    column: $table.routeArgb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routeKml => $composableBuilder(
    column: $table.routeKml,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayProcessionEventEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayProcessionEventEntriesTable> {
  $$DayProcessionEventEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get citySlug =>
      $composableBuilder(column: $table.citySlug, builder: (column) => column);

  GeneratedColumn<int> get yearValue =>
      $composableBuilder(column: $table.yearValue, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get daySlug =>
      $composableBuilder(column: $table.daySlug, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get officialNote => $composableBuilder(
    column: $table.officialNote,
    builder: (column) => column,
  );

  GeneratedColumn<int> get passDurationMinutes => $composableBuilder(
    column: $table.passDurationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stepsCount => $composableBuilder(
    column: $table.stepsCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get brothersCount => $composableBuilder(
    column: $table.brothersCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nazarenesCount => $composableBuilder(
    column: $table.nazarenesCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brotherhoodName => $composableBuilder(
    column: $table.brotherhoodName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brotherhoodSlug => $composableBuilder(
    column: $table.brotherhoodSlug,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brotherhoodColorHex => $composableBuilder(
    column: $table.brotherhoodColorHex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brotherhoodHistory => $composableBuilder(
    column: $table.brotherhoodHistory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brotherhoodHeaderImageUrl => $composableBuilder(
    column: $table.brotherhoodHeaderImageUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brotherhoodDressCode => $composableBuilder(
    column: $table.brotherhoodDressCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brotherhoodFiguresJson => $composableBuilder(
    column: $table.brotherhoodFiguresJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brotherhoodPasosJson => $composableBuilder(
    column: $table.brotherhoodPasosJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brotherhoodShieldImageUrl => $composableBuilder(
    column: $table.brotherhoodShieldImageUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get routeArgb =>
      $composableBuilder(column: $table.routeArgb, builder: (column) => column);

  GeneratedColumn<String> get routeKml =>
      $composableBuilder(column: $table.routeKml, builder: (column) => column);
}

class $$DayProcessionEventEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayProcessionEventEntriesTable,
          DayProcessionEventEntry,
          $$DayProcessionEventEntriesTableFilterComposer,
          $$DayProcessionEventEntriesTableOrderingComposer,
          $$DayProcessionEventEntriesTableAnnotationComposer,
          $$DayProcessionEventEntriesTableCreateCompanionBuilder,
          $$DayProcessionEventEntriesTableUpdateCompanionBuilder,
          (
            DayProcessionEventEntry,
            BaseReferences<
              _$AppDatabase,
              $DayProcessionEventEntriesTable,
              DayProcessionEventEntry
            >,
          ),
          DayProcessionEventEntry,
          PrefetchHooks Function()
        > {
  $$DayProcessionEventEntriesTableTableManager(
    _$AppDatabase db,
    $DayProcessionEventEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayProcessionEventEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$DayProcessionEventEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DayProcessionEventEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> citySlug = const Value.absent(),
                Value<int> yearValue = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> daySlug = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> officialNote = const Value.absent(),
                Value<int?> passDurationMinutes = const Value.absent(),
                Value<int?> stepsCount = const Value.absent(),
                Value<int?> distanceMeters = const Value.absent(),
                Value<int?> brothersCount = const Value.absent(),
                Value<int?> nazarenesCount = const Value.absent(),
                Value<String> brotherhoodName = const Value.absent(),
                Value<String> brotherhoodSlug = const Value.absent(),
                Value<String> brotherhoodColorHex = const Value.absent(),
                Value<String?> brotherhoodHistory = const Value.absent(),
                Value<String?> brotherhoodHeaderImageUrl = const Value.absent(),
                Value<String?> brotherhoodDressCode = const Value.absent(),
                Value<String?> brotherhoodFiguresJson = const Value.absent(),
                Value<String?> brotherhoodPasosJson = const Value.absent(),
                Value<String?> brotherhoodShieldImageUrl = const Value.absent(),
                Value<String?> routeArgb = const Value.absent(),
                Value<String?> routeKml = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayProcessionEventEntriesCompanion(
                citySlug: citySlug,
                yearValue: yearValue,
                mode: mode,
                daySlug: daySlug,
                position: position,
                status: status,
                officialNote: officialNote,
                passDurationMinutes: passDurationMinutes,
                stepsCount: stepsCount,
                distanceMeters: distanceMeters,
                brothersCount: brothersCount,
                nazarenesCount: nazarenesCount,
                brotherhoodName: brotherhoodName,
                brotherhoodSlug: brotherhoodSlug,
                brotherhoodColorHex: brotherhoodColorHex,
                brotherhoodHistory: brotherhoodHistory,
                brotherhoodHeaderImageUrl: brotherhoodHeaderImageUrl,
                brotherhoodDressCode: brotherhoodDressCode,
                brotherhoodFiguresJson: brotherhoodFiguresJson,
                brotherhoodPasosJson: brotherhoodPasosJson,
                brotherhoodShieldImageUrl: brotherhoodShieldImageUrl,
                routeArgb: routeArgb,
                routeKml: routeKml,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String citySlug,
                required int yearValue,
                required String mode,
                required String daySlug,
                required int position,
                required String status,
                required String officialNote,
                Value<int?> passDurationMinutes = const Value.absent(),
                Value<int?> stepsCount = const Value.absent(),
                Value<int?> distanceMeters = const Value.absent(),
                Value<int?> brothersCount = const Value.absent(),
                Value<int?> nazarenesCount = const Value.absent(),
                required String brotherhoodName,
                required String brotherhoodSlug,
                required String brotherhoodColorHex,
                Value<String?> brotherhoodHistory = const Value.absent(),
                Value<String?> brotherhoodHeaderImageUrl = const Value.absent(),
                Value<String?> brotherhoodDressCode = const Value.absent(),
                Value<String?> brotherhoodFiguresJson = const Value.absent(),
                Value<String?> brotherhoodPasosJson = const Value.absent(),
                Value<String?> brotherhoodShieldImageUrl = const Value.absent(),
                Value<String?> routeArgb = const Value.absent(),
                Value<String?> routeKml = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayProcessionEventEntriesCompanion.insert(
                citySlug: citySlug,
                yearValue: yearValue,
                mode: mode,
                daySlug: daySlug,
                position: position,
                status: status,
                officialNote: officialNote,
                passDurationMinutes: passDurationMinutes,
                stepsCount: stepsCount,
                distanceMeters: distanceMeters,
                brothersCount: brothersCount,
                nazarenesCount: nazarenesCount,
                brotherhoodName: brotherhoodName,
                brotherhoodSlug: brotherhoodSlug,
                brotherhoodColorHex: brotherhoodColorHex,
                brotherhoodHistory: brotherhoodHistory,
                brotherhoodHeaderImageUrl: brotherhoodHeaderImageUrl,
                brotherhoodDressCode: brotherhoodDressCode,
                brotherhoodFiguresJson: brotherhoodFiguresJson,
                brotherhoodPasosJson: brotherhoodPasosJson,
                brotherhoodShieldImageUrl: brotherhoodShieldImageUrl,
                routeArgb: routeArgb,
                routeKml: routeKml,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayProcessionEventEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayProcessionEventEntriesTable,
      DayProcessionEventEntry,
      $$DayProcessionEventEntriesTableFilterComposer,
      $$DayProcessionEventEntriesTableOrderingComposer,
      $$DayProcessionEventEntriesTableAnnotationComposer,
      $$DayProcessionEventEntriesTableCreateCompanionBuilder,
      $$DayProcessionEventEntriesTableUpdateCompanionBuilder,
      (
        DayProcessionEventEntry,
        BaseReferences<
          _$AppDatabase,
          $DayProcessionEventEntriesTable,
          DayProcessionEventEntry
        >,
      ),
      DayProcessionEventEntry,
      PrefetchHooks Function()
    >;
typedef $$DaySchedulePointEntriesTableCreateCompanionBuilder =
    DaySchedulePointEntriesCompanion Function({
      required String citySlug,
      required int yearValue,
      required String mode,
      required String daySlug,
      required int eventPosition,
      required int pointPosition,
      required String name,
      Value<DateTime?> plannedAt,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<int> rowid,
    });
typedef $$DaySchedulePointEntriesTableUpdateCompanionBuilder =
    DaySchedulePointEntriesCompanion Function({
      Value<String> citySlug,
      Value<int> yearValue,
      Value<String> mode,
      Value<String> daySlug,
      Value<int> eventPosition,
      Value<int> pointPosition,
      Value<String> name,
      Value<DateTime?> plannedAt,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<int> rowid,
    });

class $$DaySchedulePointEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DaySchedulePointEntriesTable> {
  $$DaySchedulePointEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get citySlug => $composableBuilder(
    column: $table.citySlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearValue => $composableBuilder(
    column: $table.yearValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get daySlug => $composableBuilder(
    column: $table.daySlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eventPosition => $composableBuilder(
    column: $table.eventPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pointPosition => $composableBuilder(
    column: $table.pointPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get plannedAt => $composableBuilder(
    column: $table.plannedAt,
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
}

class $$DaySchedulePointEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DaySchedulePointEntriesTable> {
  $$DaySchedulePointEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get citySlug => $composableBuilder(
    column: $table.citySlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearValue => $composableBuilder(
    column: $table.yearValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get daySlug => $composableBuilder(
    column: $table.daySlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eventPosition => $composableBuilder(
    column: $table.eventPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pointPosition => $composableBuilder(
    column: $table.pointPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get plannedAt => $composableBuilder(
    column: $table.plannedAt,
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
}

class $$DaySchedulePointEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DaySchedulePointEntriesTable> {
  $$DaySchedulePointEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get citySlug =>
      $composableBuilder(column: $table.citySlug, builder: (column) => column);

  GeneratedColumn<int> get yearValue =>
      $composableBuilder(column: $table.yearValue, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get daySlug =>
      $composableBuilder(column: $table.daySlug, builder: (column) => column);

  GeneratedColumn<int> get eventPosition => $composableBuilder(
    column: $table.eventPosition,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pointPosition => $composableBuilder(
    column: $table.pointPosition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get plannedAt =>
      $composableBuilder(column: $table.plannedAt, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);
}

class $$DaySchedulePointEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DaySchedulePointEntriesTable,
          DaySchedulePointEntry,
          $$DaySchedulePointEntriesTableFilterComposer,
          $$DaySchedulePointEntriesTableOrderingComposer,
          $$DaySchedulePointEntriesTableAnnotationComposer,
          $$DaySchedulePointEntriesTableCreateCompanionBuilder,
          $$DaySchedulePointEntriesTableUpdateCompanionBuilder,
          (
            DaySchedulePointEntry,
            BaseReferences<
              _$AppDatabase,
              $DaySchedulePointEntriesTable,
              DaySchedulePointEntry
            >,
          ),
          DaySchedulePointEntry,
          PrefetchHooks Function()
        > {
  $$DaySchedulePointEntriesTableTableManager(
    _$AppDatabase db,
    $DaySchedulePointEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DaySchedulePointEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$DaySchedulePointEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DaySchedulePointEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> citySlug = const Value.absent(),
                Value<int> yearValue = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> daySlug = const Value.absent(),
                Value<int> eventPosition = const Value.absent(),
                Value<int> pointPosition = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime?> plannedAt = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DaySchedulePointEntriesCompanion(
                citySlug: citySlug,
                yearValue: yearValue,
                mode: mode,
                daySlug: daySlug,
                eventPosition: eventPosition,
                pointPosition: pointPosition,
                name: name,
                plannedAt: plannedAt,
                latitude: latitude,
                longitude: longitude,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String citySlug,
                required int yearValue,
                required String mode,
                required String daySlug,
                required int eventPosition,
                required int pointPosition,
                required String name,
                Value<DateTime?> plannedAt = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DaySchedulePointEntriesCompanion.insert(
                citySlug: citySlug,
                yearValue: yearValue,
                mode: mode,
                daySlug: daySlug,
                eventPosition: eventPosition,
                pointPosition: pointPosition,
                name: name,
                plannedAt: plannedAt,
                latitude: latitude,
                longitude: longitude,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DaySchedulePointEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DaySchedulePointEntriesTable,
      DaySchedulePointEntry,
      $$DaySchedulePointEntriesTableFilterComposer,
      $$DaySchedulePointEntriesTableOrderingComposer,
      $$DaySchedulePointEntriesTableAnnotationComposer,
      $$DaySchedulePointEntriesTableCreateCompanionBuilder,
      $$DaySchedulePointEntriesTableUpdateCompanionBuilder,
      (
        DaySchedulePointEntry,
        BaseReferences<
          _$AppDatabase,
          $DaySchedulePointEntriesTable,
          DaySchedulePointEntry
        >,
      ),
      DaySchedulePointEntry,
      PrefetchHooks Function()
    >;
typedef $$DayRoutePointEntriesTableCreateCompanionBuilder =
    DayRoutePointEntriesCompanion Function({
      required String citySlug,
      required int yearValue,
      required String mode,
      required String daySlug,
      required int eventPosition,
      required int pointPosition,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<int> rowid,
    });
typedef $$DayRoutePointEntriesTableUpdateCompanionBuilder =
    DayRoutePointEntriesCompanion Function({
      Value<String> citySlug,
      Value<int> yearValue,
      Value<String> mode,
      Value<String> daySlug,
      Value<int> eventPosition,
      Value<int> pointPosition,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<int> rowid,
    });

class $$DayRoutePointEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DayRoutePointEntriesTable> {
  $$DayRoutePointEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get citySlug => $composableBuilder(
    column: $table.citySlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearValue => $composableBuilder(
    column: $table.yearValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get daySlug => $composableBuilder(
    column: $table.daySlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eventPosition => $composableBuilder(
    column: $table.eventPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pointPosition => $composableBuilder(
    column: $table.pointPosition,
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
}

class $$DayRoutePointEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DayRoutePointEntriesTable> {
  $$DayRoutePointEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get citySlug => $composableBuilder(
    column: $table.citySlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearValue => $composableBuilder(
    column: $table.yearValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get daySlug => $composableBuilder(
    column: $table.daySlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eventPosition => $composableBuilder(
    column: $table.eventPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pointPosition => $composableBuilder(
    column: $table.pointPosition,
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
}

class $$DayRoutePointEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayRoutePointEntriesTable> {
  $$DayRoutePointEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get citySlug =>
      $composableBuilder(column: $table.citySlug, builder: (column) => column);

  GeneratedColumn<int> get yearValue =>
      $composableBuilder(column: $table.yearValue, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get daySlug =>
      $composableBuilder(column: $table.daySlug, builder: (column) => column);

  GeneratedColumn<int> get eventPosition => $composableBuilder(
    column: $table.eventPosition,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pointPosition => $composableBuilder(
    column: $table.pointPosition,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);
}

class $$DayRoutePointEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayRoutePointEntriesTable,
          DayRoutePointEntry,
          $$DayRoutePointEntriesTableFilterComposer,
          $$DayRoutePointEntriesTableOrderingComposer,
          $$DayRoutePointEntriesTableAnnotationComposer,
          $$DayRoutePointEntriesTableCreateCompanionBuilder,
          $$DayRoutePointEntriesTableUpdateCompanionBuilder,
          (
            DayRoutePointEntry,
            BaseReferences<
              _$AppDatabase,
              $DayRoutePointEntriesTable,
              DayRoutePointEntry
            >,
          ),
          DayRoutePointEntry,
          PrefetchHooks Function()
        > {
  $$DayRoutePointEntriesTableTableManager(
    _$AppDatabase db,
    $DayRoutePointEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayRoutePointEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayRoutePointEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DayRoutePointEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> citySlug = const Value.absent(),
                Value<int> yearValue = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> daySlug = const Value.absent(),
                Value<int> eventPosition = const Value.absent(),
                Value<int> pointPosition = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayRoutePointEntriesCompanion(
                citySlug: citySlug,
                yearValue: yearValue,
                mode: mode,
                daySlug: daySlug,
                eventPosition: eventPosition,
                pointPosition: pointPosition,
                latitude: latitude,
                longitude: longitude,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String citySlug,
                required int yearValue,
                required String mode,
                required String daySlug,
                required int eventPosition,
                required int pointPosition,
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayRoutePointEntriesCompanion.insert(
                citySlug: citySlug,
                yearValue: yearValue,
                mode: mode,
                daySlug: daySlug,
                eventPosition: eventPosition,
                pointPosition: pointPosition,
                latitude: latitude,
                longitude: longitude,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayRoutePointEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayRoutePointEntriesTable,
      DayRoutePointEntry,
      $$DayRoutePointEntriesTableFilterComposer,
      $$DayRoutePointEntriesTableOrderingComposer,
      $$DayRoutePointEntriesTableAnnotationComposer,
      $$DayRoutePointEntriesTableCreateCompanionBuilder,
      $$DayRoutePointEntriesTableUpdateCompanionBuilder,
      (
        DayRoutePointEntry,
        BaseReferences<
          _$AppDatabase,
          $DayRoutePointEntriesTable,
          DayRoutePointEntry
        >,
      ),
      DayRoutePointEntry,
      PrefetchHooks Function()
    >;
typedef $$DayOfficialRoutePointEntriesTableCreateCompanionBuilder =
    DayOfficialRoutePointEntriesCompanion Function({
      required String citySlug,
      required int yearValue,
      required String mode,
      required String daySlug,
      required int pointPosition,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<int> rowid,
    });
typedef $$DayOfficialRoutePointEntriesTableUpdateCompanionBuilder =
    DayOfficialRoutePointEntriesCompanion Function({
      Value<String> citySlug,
      Value<int> yearValue,
      Value<String> mode,
      Value<String> daySlug,
      Value<int> pointPosition,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<int> rowid,
    });

class $$DayOfficialRoutePointEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DayOfficialRoutePointEntriesTable> {
  $$DayOfficialRoutePointEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get citySlug => $composableBuilder(
    column: $table.citySlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearValue => $composableBuilder(
    column: $table.yearValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get daySlug => $composableBuilder(
    column: $table.daySlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pointPosition => $composableBuilder(
    column: $table.pointPosition,
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
}

class $$DayOfficialRoutePointEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DayOfficialRoutePointEntriesTable> {
  $$DayOfficialRoutePointEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get citySlug => $composableBuilder(
    column: $table.citySlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearValue => $composableBuilder(
    column: $table.yearValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get daySlug => $composableBuilder(
    column: $table.daySlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pointPosition => $composableBuilder(
    column: $table.pointPosition,
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
}

class $$DayOfficialRoutePointEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayOfficialRoutePointEntriesTable> {
  $$DayOfficialRoutePointEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get citySlug =>
      $composableBuilder(column: $table.citySlug, builder: (column) => column);

  GeneratedColumn<int> get yearValue =>
      $composableBuilder(column: $table.yearValue, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get daySlug =>
      $composableBuilder(column: $table.daySlug, builder: (column) => column);

  GeneratedColumn<int> get pointPosition => $composableBuilder(
    column: $table.pointPosition,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);
}

class $$DayOfficialRoutePointEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayOfficialRoutePointEntriesTable,
          DayOfficialRoutePointEntry,
          $$DayOfficialRoutePointEntriesTableFilterComposer,
          $$DayOfficialRoutePointEntriesTableOrderingComposer,
          $$DayOfficialRoutePointEntriesTableAnnotationComposer,
          $$DayOfficialRoutePointEntriesTableCreateCompanionBuilder,
          $$DayOfficialRoutePointEntriesTableUpdateCompanionBuilder,
          (
            DayOfficialRoutePointEntry,
            BaseReferences<
              _$AppDatabase,
              $DayOfficialRoutePointEntriesTable,
              DayOfficialRoutePointEntry
            >,
          ),
          DayOfficialRoutePointEntry,
          PrefetchHooks Function()
        > {
  $$DayOfficialRoutePointEntriesTableTableManager(
    _$AppDatabase db,
    $DayOfficialRoutePointEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayOfficialRoutePointEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$DayOfficialRoutePointEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DayOfficialRoutePointEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> citySlug = const Value.absent(),
                Value<int> yearValue = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> daySlug = const Value.absent(),
                Value<int> pointPosition = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayOfficialRoutePointEntriesCompanion(
                citySlug: citySlug,
                yearValue: yearValue,
                mode: mode,
                daySlug: daySlug,
                pointPosition: pointPosition,
                latitude: latitude,
                longitude: longitude,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String citySlug,
                required int yearValue,
                required String mode,
                required String daySlug,
                required int pointPosition,
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayOfficialRoutePointEntriesCompanion.insert(
                citySlug: citySlug,
                yearValue: yearValue,
                mode: mode,
                daySlug: daySlug,
                pointPosition: pointPosition,
                latitude: latitude,
                longitude: longitude,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayOfficialRoutePointEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayOfficialRoutePointEntriesTable,
      DayOfficialRoutePointEntry,
      $$DayOfficialRoutePointEntriesTableFilterComposer,
      $$DayOfficialRoutePointEntriesTableOrderingComposer,
      $$DayOfficialRoutePointEntriesTableAnnotationComposer,
      $$DayOfficialRoutePointEntriesTableCreateCompanionBuilder,
      $$DayOfficialRoutePointEntriesTableUpdateCompanionBuilder,
      (
        DayOfficialRoutePointEntry,
        BaseReferences<
          _$AppDatabase,
          $DayOfficialRoutePointEntriesTable,
          DayOfficialRoutePointEntry
        >,
      ),
      DayOfficialRoutePointEntry,
      PrefetchHooks Function()
    >;
typedef $$SyncStatusEntriesTableCreateCompanionBuilder =
    SyncStatusEntriesCompanion Function({
      required String citySlug,
      required int yearValue,
      required String mode,
      required DateTime lastSyncedAt,
      Value<int> rowid,
    });
typedef $$SyncStatusEntriesTableUpdateCompanionBuilder =
    SyncStatusEntriesCompanion Function({
      Value<String> citySlug,
      Value<int> yearValue,
      Value<String> mode,
      Value<DateTime> lastSyncedAt,
      Value<int> rowid,
    });

class $$SyncStatusEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStatusEntriesTable> {
  $$SyncStatusEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get citySlug => $composableBuilder(
    column: $table.citySlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearValue => $composableBuilder(
    column: $table.yearValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStatusEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStatusEntriesTable> {
  $$SyncStatusEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get citySlug => $composableBuilder(
    column: $table.citySlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearValue => $composableBuilder(
    column: $table.yearValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStatusEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStatusEntriesTable> {
  $$SyncStatusEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get citySlug =>
      $composableBuilder(column: $table.citySlug, builder: (column) => column);

  GeneratedColumn<int> get yearValue =>
      $composableBuilder(column: $table.yearValue, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$SyncStatusEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStatusEntriesTable,
          SyncStatusEntry,
          $$SyncStatusEntriesTableFilterComposer,
          $$SyncStatusEntriesTableOrderingComposer,
          $$SyncStatusEntriesTableAnnotationComposer,
          $$SyncStatusEntriesTableCreateCompanionBuilder,
          $$SyncStatusEntriesTableUpdateCompanionBuilder,
          (
            SyncStatusEntry,
            BaseReferences<
              _$AppDatabase,
              $SyncStatusEntriesTable,
              SyncStatusEntry
            >,
          ),
          SyncStatusEntry,
          PrefetchHooks Function()
        > {
  $$SyncStatusEntriesTableTableManager(
    _$AppDatabase db,
    $SyncStatusEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStatusEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStatusEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStatusEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> citySlug = const Value.absent(),
                Value<int> yearValue = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<DateTime> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStatusEntriesCompanion(
                citySlug: citySlug,
                yearValue: yearValue,
                mode: mode,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String citySlug,
                required int yearValue,
                required String mode,
                required DateTime lastSyncedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncStatusEntriesCompanion.insert(
                citySlug: citySlug,
                yearValue: yearValue,
                mode: mode,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStatusEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStatusEntriesTable,
      SyncStatusEntry,
      $$SyncStatusEntriesTableFilterComposer,
      $$SyncStatusEntriesTableOrderingComposer,
      $$SyncStatusEntriesTableAnnotationComposer,
      $$SyncStatusEntriesTableCreateCompanionBuilder,
      $$SyncStatusEntriesTableUpdateCompanionBuilder,
      (
        SyncStatusEntry,
        BaseReferences<_$AppDatabase, $SyncStatusEntriesTable, SyncStatusEntry>,
      ),
      SyncStatusEntry,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsEntriesTableCreateCompanionBuilder =
    AppSettingsEntriesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsEntriesTableUpdateCompanionBuilder =
    AppSettingsEntriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsEntriesTable> {
  $$AppSettingsEntriesTableFilterComposer({
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
}

class $$AppSettingsEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsEntriesTable> {
  $$AppSettingsEntriesTableOrderingComposer({
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
}

class $$AppSettingsEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsEntriesTable> {
  $$AppSettingsEntriesTableAnnotationComposer({
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
}

class $$AppSettingsEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsEntriesTable,
          AppSettingsEntry,
          $$AppSettingsEntriesTableFilterComposer,
          $$AppSettingsEntriesTableOrderingComposer,
          $$AppSettingsEntriesTableAnnotationComposer,
          $$AppSettingsEntriesTableCreateCompanionBuilder,
          $$AppSettingsEntriesTableUpdateCompanionBuilder,
          (
            AppSettingsEntry,
            BaseReferences<
              _$AppDatabase,
              $AppSettingsEntriesTable,
              AppSettingsEntry
            >,
          ),
          AppSettingsEntry,
          PrefetchHooks Function()
        > {
  $$AppSettingsEntriesTableTableManager(
    _$AppDatabase db,
    $AppSettingsEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsEntriesCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsEntriesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsEntriesTable,
      AppSettingsEntry,
      $$AppSettingsEntriesTableFilterComposer,
      $$AppSettingsEntriesTableOrderingComposer,
      $$AppSettingsEntriesTableAnnotationComposer,
      $$AppSettingsEntriesTableCreateCompanionBuilder,
      $$AppSettingsEntriesTableUpdateCompanionBuilder,
      (
        AppSettingsEntry,
        BaseReferences<
          _$AppDatabase,
          $AppSettingsEntriesTable,
          AppSettingsEntry
        >,
      ),
      AppSettingsEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HttpCacheEntriesTableTableManager get httpCacheEntries =>
      $$HttpCacheEntriesTableTableManager(_db, _db.httpCacheEntries);
  $$DaysTableTableManager get days => $$DaysTableTableManager(_db, _db.days);
  $$DayDetailEntriesTableTableManager get dayDetailEntries =>
      $$DayDetailEntriesTableTableManager(_db, _db.dayDetailEntries);
  $$DayProcessionEventEntriesTableTableManager get dayProcessionEventEntries =>
      $$DayProcessionEventEntriesTableTableManager(
        _db,
        _db.dayProcessionEventEntries,
      );
  $$DaySchedulePointEntriesTableTableManager get daySchedulePointEntries =>
      $$DaySchedulePointEntriesTableTableManager(
        _db,
        _db.daySchedulePointEntries,
      );
  $$DayRoutePointEntriesTableTableManager get dayRoutePointEntries =>
      $$DayRoutePointEntriesTableTableManager(_db, _db.dayRoutePointEntries);
  $$DayOfficialRoutePointEntriesTableTableManager
  get dayOfficialRoutePointEntries =>
      $$DayOfficialRoutePointEntriesTableTableManager(
        _db,
        _db.dayOfficialRoutePointEntries,
      );
  $$SyncStatusEntriesTableTableManager get syncStatusEntries =>
      $$SyncStatusEntriesTableTableManager(_db, _db.syncStatusEntries);
  $$AppSettingsEntriesTableTableManager get appSettingsEntries =>
      $$AppSettingsEntriesTableTableManager(_db, _db.appSettingsEntries);
}
