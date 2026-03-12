import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../config/debug_flags.dart';
import '../models/day_detail.dart';
import '../models/day_index_item.dart';

part 'app_database.g.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

class HttpCacheEntries extends Table {
  TextColumn get key => text()();
  TextColumn get payload => text()();
  DateTimeColumn get savedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class Days extends Table {
  TextColumn get citySlug => text()();
  IntColumn get yearValue => integer()();
  TextColumn get mode => text()();
  TextColumn get slug => text()();
  TextColumn get name => text()();
  DateTimeColumn get startsAt => dateTime().nullable()();
  DateTimeColumn get liturgicalDate => dateTime().nullable()();
  IntColumn get processionEventsCount => integer()();
  TextColumn get weatherIconCode => text().nullable()();
  TextColumn get weatherConditionLabel => text().nullable()();
  RealColumn get weatherTempMinC => real().nullable()();
  RealColumn get weatherTempMaxC => real().nullable()();
  TextColumn get weatherHourlyJson => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {citySlug, yearValue, mode, slug};
}

class DayDetailEntries extends Table {
  TextColumn get citySlug => text()();
  IntColumn get yearValue => integer()();
  TextColumn get mode => text()();
  TextColumn get daySlug => text()();
  TextColumn get name => text()();
  TextColumn get officialRouteArgb => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {citySlug, yearValue, mode, daySlug};
}

class DayProcessionEventEntries extends Table {
  TextColumn get citySlug => text()();
  IntColumn get yearValue => integer()();
  TextColumn get mode => text()();
  TextColumn get daySlug => text()();
  IntColumn get position => integer()();
  TextColumn get status => text()();
  TextColumn get officialNote => text()();
  IntColumn get passDurationMinutes => integer().nullable()();
  IntColumn get stepsCount => integer().nullable()();
  IntColumn get distanceMeters => integer().nullable()();
  IntColumn get brothersCount => integer().nullable()();
  IntColumn get nazarenesCount => integer().nullable()();
  TextColumn get brotherhoodName => text()();
  TextColumn get brotherhoodSlug => text()();
  TextColumn get brotherhoodColorHex => text()();
  TextColumn get brotherhoodHistory => text().nullable()();
  TextColumn get brotherhoodHeaderImageUrl => text().nullable()();
  TextColumn get brotherhoodDressCode => text().nullable()();
  TextColumn get brotherhoodFiguresJson => text().nullable()();
  TextColumn get brotherhoodPasosJson => text().nullable()();
  TextColumn get brotherhoodShieldImageUrl => text().nullable()();
  TextColumn get routeArgb => text().nullable()();
  TextColumn get routeKml => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {
    citySlug,
    yearValue,
    mode,
    daySlug,
    position,
  };
}

class DaySchedulePointEntries extends Table {
  TextColumn get citySlug => text()();
  IntColumn get yearValue => integer()();
  TextColumn get mode => text()();
  TextColumn get daySlug => text()();
  IntColumn get eventPosition => integer()();
  IntColumn get pointPosition => integer()();
  TextColumn get name => text()();
  DateTimeColumn get plannedAt => dateTime().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {
    citySlug,
    yearValue,
    mode,
    daySlug,
    eventPosition,
    pointPosition,
  };
}

class DayRoutePointEntries extends Table {
  TextColumn get citySlug => text()();
  IntColumn get yearValue => integer()();
  TextColumn get mode => text()();
  TextColumn get daySlug => text()();
  IntColumn get eventPosition => integer()();
  IntColumn get pointPosition => integer()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {
    citySlug,
    yearValue,
    mode,
    daySlug,
    eventPosition,
    pointPosition,
  };
}

class DayOfficialRoutePointEntries extends Table {
  TextColumn get citySlug => text()();
  IntColumn get yearValue => integer()();
  TextColumn get mode => text()();
  TextColumn get daySlug => text()();
  IntColumn get pointPosition => integer()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {
    citySlug,
    yearValue,
    mode,
    daySlug,
    pointPosition,
  };
}

class SyncStatusEntries extends Table {
  TextColumn get citySlug => text()();
  IntColumn get yearValue => integer()();
  TextColumn get mode => text()();
  DateTimeColumn get lastSyncedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {citySlug, yearValue, mode};
}

class AppSettingsEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    HttpCacheEntries,
    Days,
    DayDetailEntries,
    DayProcessionEventEntries,
    DaySchedulePointEntries,
    DayRoutePointEntries,
    DayOfficialRoutePointEntries,
    SyncStatusEntries,
    AppSettingsEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 15;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(days);
        await m.createTable(dayDetailEntries);
        await m.createTable(dayProcessionEventEntries);
      }
      if (from < 3) {
        await m.createTable(syncStatusEntries);
      }
      if (from < 4) {
        await m.createTable(appSettingsEntries);
      }
      if (from < 5) {
        await m.createTable(daySchedulePointEntries);
      }
      if (from < 6) {
        await m.createTable(dayRoutePointEntries);
      }
      if (from < 7) {
        await m.addColumn(dayDetailEntries, dayDetailEntries.officialRouteArgb);
        await m.createTable(dayOfficialRoutePointEntries);
      }
      if (from < 8) {
        await m.addColumn(
          dayProcessionEventEntries,
          dayProcessionEventEntries.routeArgb,
        );
      }
      if (from < 9) {
        await m.addColumn(
          dayProcessionEventEntries,
          dayProcessionEventEntries.brothersCount,
        );
        await m.addColumn(
          dayProcessionEventEntries,
          dayProcessionEventEntries.nazarenesCount,
        );
      }
      if (from < 10) {
        await m.addColumn(
          dayProcessionEventEntries,
          dayProcessionEventEntries.stepsCount,
        );
        await m.addColumn(
          dayProcessionEventEntries,
          dayProcessionEventEntries.distanceMeters,
        );
        await m.addColumn(
          dayProcessionEventEntries,
          dayProcessionEventEntries.brotherhoodShieldImageUrl,
        );
      }
      if (from < 11) {
        await m.addColumn(
          dayProcessionEventEntries,
          dayProcessionEventEntries.brotherhoodHistory,
        );
      }
      if (from < 12) {
        await m.addColumn(
          dayProcessionEventEntries,
          dayProcessionEventEntries.brotherhoodDressCode,
        );
        await m.addColumn(
          dayProcessionEventEntries,
          dayProcessionEventEntries.brotherhoodFiguresJson,
        );
        await m.addColumn(
          dayProcessionEventEntries,
          dayProcessionEventEntries.brotherhoodPasosJson,
        );
      }
      if (from < 13) {
        await m.addColumn(
          dayProcessionEventEntries,
          dayProcessionEventEntries.brotherhoodHeaderImageUrl,
        );
      }
      if (from < 14) {
        await m.addColumn(
          dayProcessionEventEntries,
          dayProcessionEventEntries.routeKml,
        );
      }
      if (from < 15) {
        await m.addColumn(days, days.liturgicalDate);
        await m.addColumn(days, days.weatherIconCode);
        await m.addColumn(days, days.weatherConditionLabel);
        await m.addColumn(days, days.weatherTempMinC);
        await m.addColumn(days, days.weatherTempMaxC);
        await m.addColumn(days, days.weatherHourlyJson);
      }
    },
  );

  Future<void> saveHttpCache({required String key, required String payload}) {
    return into(httpCacheEntries).insertOnConflictUpdate(
      HttpCacheEntriesCompanion(
        key: Value(key),
        payload: Value(payload),
        savedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<String?> readHttpCache(String key) async {
    final row = await (select(
      httpCacheEntries,
    )..where((tbl) => tbl.key.equals(key))).getSingleOrNull();
    return row?.payload;
  }

  Future<void> clearHttpCache() {
    return delete(httpCacheEntries).go();
  }

  Future<void> replaceDays({
    required String city,
    required int year,
    required String modeValue,
    required List<DayIndexItem> items,
  }) async {
    await transaction(() async {
      await (delete(days)..where(
            (tbl) =>
                tbl.citySlug.equals(city) &
                tbl.yearValue.equals(year) &
                tbl.mode.equals(modeValue),
          ))
          .go();

      await batch((batch) {
        batch.insertAll(
          days,
          items
              .map(
                (item) => DaysCompanion.insert(
                  citySlug: city,
                  yearValue: year,
                  mode: modeValue,
                  slug: item.slug,
                  name: item.name,
                  startsAt: Value(item.startsAt),
                  liturgicalDate: Value(item.liturgicalDate),
                  processionEventsCount: item.processionEventsCount,
                  weatherIconCode: Value(item.weather?.iconCode),
                  weatherConditionLabel: Value(item.weather?.conditionLabel),
                  weatherTempMinC: Value(item.weather?.tempMinC),
                  weatherTempMaxC: Value(item.weather?.tempMaxC),
                  weatherHourlyJson: Value(_encodeWeatherHourly(item.weather)),
                ),
              )
              .toList(growable: false),
        );
      });
    });
  }

  Future<List<DayIndexItem>> getDays({
    required String city,
    required int year,
    required String modeValue,
  }) async {
    final rows =
        await (select(days)
              ..where(
                (tbl) =>
                    tbl.citySlug.equals(city) &
                    tbl.yearValue.equals(year) &
                    tbl.mode.equals(modeValue),
              )
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.startsAt)]))
            .get();

    return rows
        .map(
          (row) => DayIndexItem(
            slug: row.slug,
            name: row.name,
            startsAt: row.startsAt,
            liturgicalDate: row.liturgicalDate,
            processionEventsCount: row.processionEventsCount,
            weather: DayWeatherSummary(
              iconCode: row.weatherIconCode,
              conditionLabel: row.weatherConditionLabel,
              tempMinC: row.weatherTempMinC,
              tempMaxC: row.weatherTempMaxC,
              hourly: _decodeWeatherHourly(row.weatherHourlyJson),
            ),
          ),
        )
        .toList(growable: false);
  }

  Future<int> applyDayWeatherUpdates({
    required String city,
    required int year,
    required String modeValue,
    required Map<String, DayWeatherSummary> weatherBySlug,
  }) async {
    if (weatherBySlug.isEmpty) {
      return 0;
    }

    var updatedRows = 0;

    await transaction(() async {
      for (final entry in weatherBySlug.entries) {
        final slug = entry.key.trim();
        if (slug.isEmpty) {
          continue;
        }

        final weather = entry.value;
        final affected = await (update(days)..where(
              (tbl) =>
                  tbl.citySlug.equals(city) &
                  tbl.yearValue.equals(year) &
                  tbl.mode.equals(modeValue) &
                  tbl.slug.equals(slug),
            ))
            .write(
              DaysCompanion(
                weatherIconCode: Value(weather.iconCode),
                weatherConditionLabel: Value(weather.conditionLabel),
                weatherTempMinC: Value(weather.tempMinC),
                weatherTempMaxC: Value(weather.tempMaxC),
                weatherHourlyJson: Value(_encodeWeatherHourly(weather)),
              ),
            );

        if (affected > 0) {
          updatedRows += affected;
        }
      }
    });

    return updatedRows;
  }

  Future<void> saveDayDetail({
    required String city,
    required int year,
    required String modeValue,
    required String daySlugValue,
    required DayDetail detail,
  }) async {
    await transaction(() async {
      await (delete(dayDetailEntries)..where(
            (tbl) =>
                tbl.citySlug.equals(city) &
                tbl.yearValue.equals(year) &
                tbl.mode.equals(modeValue) &
                tbl.daySlug.equals(daySlugValue),
          ))
          .go();

      await (delete(dayProcessionEventEntries)..where(
            (tbl) =>
                tbl.citySlug.equals(city) &
                tbl.yearValue.equals(year) &
                tbl.mode.equals(modeValue) &
                tbl.daySlug.equals(daySlugValue),
          ))
          .go();

      await (delete(daySchedulePointEntries)..where(
            (tbl) =>
                tbl.citySlug.equals(city) &
                tbl.yearValue.equals(year) &
                tbl.mode.equals(modeValue) &
                tbl.daySlug.equals(daySlugValue),
          ))
          .go();

      await (delete(dayRoutePointEntries)..where(
            (tbl) =>
                tbl.citySlug.equals(city) &
                tbl.yearValue.equals(year) &
                tbl.mode.equals(modeValue) &
                tbl.daySlug.equals(daySlugValue),
          ))
          .go();

      await (delete(dayOfficialRoutePointEntries)..where(
            (tbl) =>
                tbl.citySlug.equals(city) &
                tbl.yearValue.equals(year) &
                tbl.mode.equals(modeValue) &
                tbl.daySlug.equals(daySlugValue),
          ))
          .go();

      await into(dayDetailEntries).insert(
        DayDetailEntriesCompanion.insert(
          citySlug: city,
          yearValue: year,
          mode: modeValue,
          daySlug: daySlugValue,
          name: detail.name,
          officialRouteArgb: Value(detail.officialRouteArgb),
        ),
      );

      await batch((batch) {
        batch.insertAll(
          dayProcessionEventEntries,
          detail.processionEvents
              .asMap()
              .entries
              .map(
                (entry) => DayProcessionEventEntriesCompanion.insert(
                  citySlug: city,
                  yearValue: year,
                  mode: modeValue,
                  daySlug: daySlugValue,
                  position: entry.key,
                  status: entry.value.status,
                  officialNote: entry.value.officialNote,
                  passDurationMinutes: Value(entry.value.passDurationMinutes),
                  stepsCount: Value(entry.value.stepsCount),
                  distanceMeters: Value(entry.value.distanceMeters),
                  brothersCount: Value(entry.value.brothersCount),
                  nazarenesCount: Value(entry.value.nazarenesCount),
                  brotherhoodName: entry.value.brotherhoodName,
                  brotherhoodSlug: entry.value.brotherhoodSlug,
                  brotherhoodColorHex: entry.value.brotherhoodColorHex,
                  brotherhoodHistory: Value(entry.value.brotherhoodHistory),
                  brotherhoodHeaderImageUrl: Value(
                    entry.value.brotherhoodHeaderImageUrl,
                  ),
                  brotherhoodDressCode: Value(entry.value.brotherhoodDressCode),
                  brotherhoodFiguresJson: Value(
                    _encodeBrotherhoodFigures(entry.value.brotherhoodFigures),
                  ),
                  brotherhoodPasosJson: Value(
                    _encodeBrotherhoodPasos(entry.value.brotherhoodPasos),
                  ),
                  brotherhoodShieldImageUrl: Value(
                    entry.value.brotherhoodShieldImageUrl,
                  ),
                  routeArgb: Value(entry.value.routeArgb),
                  routeKml: Value(entry.value.routeKml),
                ),
              )
              .toList(growable: false),
        );

        batch.insertAll(
          daySchedulePointEntries,
          detail.processionEvents
              .asMap()
              .entries
              .expand(
                (eventEntry) => eventEntry.value.schedulePoints
                    .asMap()
                    .entries
                    .map((pointEntry) {
                      _debugSchedulePointDb(
                        stage: 'save',
                        pointName: pointEntry.value.name,
                        plannedAt: pointEntry.value.plannedAt,
                      );

                      return DaySchedulePointEntriesCompanion.insert(
                        citySlug: city,
                        yearValue: year,
                        mode: modeValue,
                        daySlug: daySlugValue,
                        eventPosition: eventEntry.key,
                        pointPosition: pointEntry.key,
                        name: pointEntry.value.name,
                        plannedAt: Value(pointEntry.value.plannedAt),
                        latitude: Value(pointEntry.value.latitude),
                        longitude: Value(pointEntry.value.longitude),
                      );
                    }),
              )
              .toList(growable: false),
        );

        batch.insertAll(
          dayRoutePointEntries,
          detail.processionEvents
              .asMap()
              .entries
              .expand(
                (eventEntry) =>
                    eventEntry.value.routePoints.asMap().entries.map(
                      (pointEntry) => DayRoutePointEntriesCompanion.insert(
                        citySlug: city,
                        yearValue: year,
                        mode: modeValue,
                        daySlug: daySlugValue,
                        eventPosition: eventEntry.key,
                        pointPosition: pointEntry.key,
                        latitude: Value(pointEntry.value.latitude),
                        longitude: Value(pointEntry.value.longitude),
                      ),
                    ),
              )
              .toList(growable: false),
        );

        batch.insertAll(
          dayOfficialRoutePointEntries,
          detail.officialRoutePoints
              .asMap()
              .entries
              .map(
                (pointEntry) => DayOfficialRoutePointEntriesCompanion.insert(
                  citySlug: city,
                  yearValue: year,
                  mode: modeValue,
                  daySlug: daySlugValue,
                  pointPosition: pointEntry.key,
                  latitude: Value(pointEntry.value.latitude),
                  longitude: Value(pointEntry.value.longitude),
                ),
              )
              .toList(growable: false),
        );
      });
    });
  }

  Future<void> deleteDayDetail({
    required String city,
    required int year,
    required String modeValue,
    required String daySlugValue,
  }) async {
    await transaction(() async {
      await (delete(dayDetailEntries)..where(
            (tbl) =>
                tbl.citySlug.equals(city) &
                tbl.yearValue.equals(year) &
                tbl.mode.equals(modeValue) &
                tbl.daySlug.equals(daySlugValue),
          ))
          .go();

      await (delete(dayProcessionEventEntries)..where(
            (tbl) =>
                tbl.citySlug.equals(city) &
                tbl.yearValue.equals(year) &
                tbl.mode.equals(modeValue) &
                tbl.daySlug.equals(daySlugValue),
          ))
          .go();

      await (delete(daySchedulePointEntries)..where(
            (tbl) =>
                tbl.citySlug.equals(city) &
                tbl.yearValue.equals(year) &
                tbl.mode.equals(modeValue) &
                tbl.daySlug.equals(daySlugValue),
          ))
          .go();

      await (delete(dayRoutePointEntries)..where(
            (tbl) =>
                tbl.citySlug.equals(city) &
                tbl.yearValue.equals(year) &
                tbl.mode.equals(modeValue) &
                tbl.daySlug.equals(daySlugValue),
          ))
          .go();

      await (delete(dayOfficialRoutePointEntries)..where(
            (tbl) =>
                tbl.citySlug.equals(city) &
                tbl.yearValue.equals(year) &
                tbl.mode.equals(modeValue) &
                tbl.daySlug.equals(daySlugValue),
          ))
          .go();
    });
  }

  Future<DayDetail?> getDayDetail({
    required String city,
    required int year,
    required String modeValue,
    required String daySlugValue,
  }) async {
    final header =
        await (select(dayDetailEntries)..where(
              (tbl) =>
                  tbl.citySlug.equals(city) &
                  tbl.yearValue.equals(year) &
                  tbl.mode.equals(modeValue) &
                  tbl.daySlug.equals(daySlugValue),
            ))
            .getSingleOrNull();

    if (header == null) {
      return null;
    }

    final rows =
        await (select(dayProcessionEventEntries)
              ..where(
                (tbl) =>
                    tbl.citySlug.equals(city) &
                    tbl.yearValue.equals(year) &
                    tbl.mode.equals(modeValue) &
                    tbl.daySlug.equals(daySlugValue),
              )
              ..orderBy([(tbl) => OrderingTerm(expression: tbl.position)]))
            .get();

    final scheduleRows =
        await (select(daySchedulePointEntries)
              ..where(
                (tbl) =>
                    tbl.citySlug.equals(city) &
                    tbl.yearValue.equals(year) &
                    tbl.mode.equals(modeValue) &
                    tbl.daySlug.equals(daySlugValue),
              )
              ..orderBy([
                (tbl) => OrderingTerm(expression: tbl.eventPosition),
                (tbl) => OrderingTerm(expression: tbl.pointPosition),
              ]))
            .get();

    final routeRows =
        await (select(dayRoutePointEntries)
              ..where(
                (tbl) =>
                    tbl.citySlug.equals(city) &
                    tbl.yearValue.equals(year) &
                    tbl.mode.equals(modeValue) &
                    tbl.daySlug.equals(daySlugValue),
              )
              ..orderBy([
                (tbl) => OrderingTerm(expression: tbl.eventPosition),
                (tbl) => OrderingTerm(expression: tbl.pointPosition),
              ]))
            .get();

    final officialRouteRows =
        await (select(dayOfficialRoutePointEntries)
              ..where(
                (tbl) =>
                    tbl.citySlug.equals(city) &
                    tbl.yearValue.equals(year) &
                    tbl.mode.equals(modeValue) &
                    tbl.daySlug.equals(daySlugValue),
              )
              ..orderBy([(tbl) => OrderingTerm(expression: tbl.pointPosition)]))
            .get();

    final scheduleByEvent = <int, List<SchedulePoint>>{};
    for (final row in scheduleRows) {
      final resolvedPlannedAt = _asWallClock(row.plannedAt);
      _debugSchedulePointDb(
        stage: 'load',
        pointName: row.name,
        plannedAt: resolvedPlannedAt,
      );

      scheduleByEvent
          .putIfAbsent(row.eventPosition, () => <SchedulePoint>[])
          .add(
            SchedulePoint(
              name: row.name,
              plannedAt: resolvedPlannedAt,
              latitude: row.latitude,
              longitude: row.longitude,
            ),
          );
    }

    final routeByEvent = <int, List<RoutePoint>>{};
    for (final row in routeRows) {
      routeByEvent
          .putIfAbsent(row.eventPosition, () => <RoutePoint>[])
          .add(RoutePoint(latitude: row.latitude, longitude: row.longitude));
    }

    final officialRoutePoints = officialRouteRows
        .map(
          (row) => RoutePoint(latitude: row.latitude, longitude: row.longitude),
        )
        .where((point) => point.hasLocation)
        .toList(growable: false);

    return DayDetail(
      slug: header.daySlug,
      name: header.name,
      mode: header.mode,
      officialRouteArgb: header.officialRouteArgb,
      officialRoutePoints: officialRoutePoints,
      processionEvents: rows
          .map(
            (row) => DayProcessionEvent(
              status: row.status,
              officialNote: row.officialNote,
              passDurationMinutes: row.passDurationMinutes,
              stepsCount: row.stepsCount,
              distanceMeters: row.distanceMeters,
              brothersCount: row.brothersCount,
              nazarenesCount: row.nazarenesCount,
              brotherhoodName: row.brotherhoodName,
              brotherhoodSlug: row.brotherhoodSlug,
              brotherhoodColorHex: row.brotherhoodColorHex,
              brotherhoodHistory: row.brotherhoodHistory,
              brotherhoodHeaderImageUrl: row.brotherhoodHeaderImageUrl,
              brotherhoodDressCode: row.brotherhoodDressCode,
              brotherhoodFigures: _decodeBrotherhoodFigures(
                row.brotherhoodFiguresJson,
              ),
              brotherhoodPasos: _decodeBrotherhoodPasos(
                row.brotherhoodPasosJson,
              ),
              brotherhoodShieldImageUrl: row.brotherhoodShieldImageUrl,
              routeArgb: row.routeArgb,
              routeKml: row.routeKml,
              schedulePoints:
                  scheduleByEvent[row.position] ?? const <SchedulePoint>[],
              routePoints: routeByEvent[row.position] ?? const <RoutePoint>[],
            ),
          )
          .toList(growable: false),
    );
  }

  Future<void> saveLastSuccessfulSync({
    required String city,
    required int year,
    required String modeValue,
    required DateTime syncedAt,
  }) {
    return into(syncStatusEntries).insertOnConflictUpdate(
      SyncStatusEntriesCompanion(
        citySlug: Value(city),
        yearValue: Value(year),
        mode: Value(modeValue),
        lastSyncedAt: Value(syncedAt),
      ),
    );
  }

  Future<DateTime?> getLastSuccessfulSync({
    required String city,
    required int year,
    required String modeValue,
  }) async {
    final row =
        await (select(syncStatusEntries)..where(
              (tbl) =>
                  tbl.citySlug.equals(city) &
                  tbl.yearValue.equals(year) &
                  tbl.mode.equals(modeValue),
            ))
            .getSingleOrNull();
    return row?.lastSyncedAt;
  }

  Future<void> saveSetting({required String key, required String value}) {
    return into(appSettingsEntries).insertOnConflictUpdate(
      AppSettingsEntriesCompanion(key: Value(key), value: Value(value)),
    );
  }

  Future<String?> readSetting(String key) async {
    final row = await (select(
      appSettingsEntries,
    )..where((tbl) => tbl.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> saveSyncResourceVersion({
    required String city,
    required int year,
    required String modeValue,
    required String resource,
    required String version,
  }) {
    return saveSetting(
      key: _syncResourceVersionKey(
        city: city,
        year: year,
        modeValue: modeValue,
        resource: resource,
      ),
      value: version,
    );
  }

  Future<String?> readSyncResourceVersion({
    required String city,
    required int year,
    required String modeValue,
    required String resource,
  }) {
    return readSetting(
      _syncResourceVersionKey(
        city: city,
        year: year,
        modeValue: modeValue,
        resource: resource,
      ),
    );
  }

  String _syncResourceVersionKey({
    required String city,
    required int year,
    required String modeValue,
    required String resource,
  }) {
    return 'sync_resource_version_v1:$city:$year:$modeValue:$resource';
  }
}

String? _encodeBrotherhoodFigures(List<BrotherhoodFigureInfo> values) {
  if (values.isEmpty) {
    return null;
  }
  final encoded = values
      .map((item) => <String, dynamic>{
            'name': item.name,
            'description': item.description,
          })
      .toList(growable: false);
  return jsonEncode(encoded);
}

String? _encodeBrotherhoodPasos(List<BrotherhoodPasoInfo> values) {
  if (values.isEmpty) {
    return null;
  }
  final encoded = values
      .map((item) => <String, dynamic>{
            'name': item.name,
            'description': item.description,
          })
      .toList(growable: false);
  return jsonEncode(encoded);
}

List<BrotherhoodFigureInfo> _decodeBrotherhoodFigures(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return const [];
  }
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map((entry) => BrotherhoodFigureInfo(
              name: (entry['name'] ?? '').toString().trim(),
              description: (entry['description'] as String?)?.trim(),
            ))
        .where((item) => item.name.isNotEmpty)
        .toList(growable: false);
  } catch (_) {
    return const [];
  }
}

List<BrotherhoodPasoInfo> _decodeBrotherhoodPasos(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return const [];
  }
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map((entry) => BrotherhoodPasoInfo(
              name: (entry['name'] ?? '').toString().trim(),
              description: (entry['description'] as String?)?.trim(),
            ))
        .where((item) => item.name.isNotEmpty)
        .toList(growable: false);
  } catch (_) {
    return const [];
  }
}

String? _encodeWeatherHourly(DayWeatherSummary? weather) {
  if (weather == null || weather.hourly.isEmpty) {
    return null;
  }

  final encoded = weather.hourly
      .map(
        (entry) => <String, dynamic>{
          'hour_label': entry.hourLabel,
          'icon_code': entry.iconCode,
          'condition_label': entry.conditionLabel,
          'temperature_c': entry.temperatureC,
          'precipitation_probability': entry.precipitationProbability,
        },
      )
      .toList(growable: false);

  return jsonEncode(encoded);
}

List<DayWeatherHourlyPoint> _decodeWeatherHourly(String? raw) {
  if (raw == null || raw.isEmpty) {
    return const <DayWeatherHourlyPoint>[];
  }

  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List<dynamic>) {
      return const <DayWeatherHourlyPoint>[];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(DayWeatherHourlyPoint.fromJson)
        .where((entry) => entry.hourLabel.isNotEmpty)
        .toList(growable: false);
  } catch (_) {
    return const <DayWeatherHourlyPoint>[];
  }
}

DateTime? _asWallClock(DateTime? value) {
  if (value == null) {
    return null;
  }

  return DateTime(
    value.year,
    value.month,
    value.day,
    value.hour,
    value.minute,
    value.second,
    value.millisecond,
    value.microsecond,
  );
}

void _debugSchedulePointDb({
  required String stage,
  required String pointName,
  required DateTime? plannedAt,
}) {
  if (!kDebugMode || !scheduleDebugLogsEnabled) {
    return;
  }

  debugPrint(
    '[schedule_point:$stage-db] $pointName | ${plannedAt?.toIso8601String()}',
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'larevira.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
