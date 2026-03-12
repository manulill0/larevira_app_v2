import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics_providers.dart';
import '../../../core/analytics/app_analytics.dart';
import '../../../core/config/app_instance_controller.dart';
import '../../../core/config/debug_flags.dart';
import '../../../core/local/app_database.dart';
import '../../../core/media/private_image_cache.dart';
import '../../../core/models/day_detail.dart';
import '../../../core/models/day_index_item.dart';
import '../../../core/models/sync_changes.dart';
import '../../../core/models/sync_manifest.dart';
import '../../../core/network/larevira_api_client.dart';
import '../../jornadas/application/day_detail_controller.dart';
import '../../jornadas/application/jornadas_controller.dart';

final syncControllerProvider = NotifierProvider<SyncController, SyncState>(
  SyncController.new,
);

class SyncState {
  const SyncState({
    required this.isSyncing,
    required this.hasAttemptedInitialSync,
    required this.isInitialSyncComplete,
    this.lastSyncedAt,
    this.message,
  });

  final bool isSyncing;
  final bool hasAttemptedInitialSync;
  final bool isInitialSyncComplete;
  final DateTime? lastSyncedAt;
  final String? message;

  SyncState copyWith({
    bool? isSyncing,
    bool? hasAttemptedInitialSync,
    bool? isInitialSyncComplete,
    DateTime? lastSyncedAt,
    String? message,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      hasAttemptedInitialSync:
          hasAttemptedInitialSync ?? this.hasAttemptedInitialSync,
      isInitialSyncComplete:
          isInitialSyncComplete ?? this.isInitialSyncComplete,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      message: message,
    );
  }
}

class SyncController extends Notifier<SyncState> {
  static const _liveWeatherMinInterval = Duration(minutes: 5);
  bool _isWeatherSyncing = false;

  @override
  SyncState build() {
    final appInstance = ref.watch(appInstanceProvider);
    final year = ref.watch(editionYearProvider);
    _restorePersistedState(city: appInstance.citySlug, year: year);

    return const SyncState(
      isSyncing: false,
      hasAttemptedInitialSync: false,
      isInitialSyncComplete: false,
    );
  }

  Future<void> syncOnAppLaunch() async {
    if (state.hasAttemptedInitialSync || state.isSyncing) {
      return;
    }

    state = state.copyWith(hasAttemptedInitialSync: true);
    await _runSync(isInitialLaunch: true, forceRefresh: false);
  }

  Future<void> syncManually() async {
    if (state.isSyncing) {
      return;
    }

    await _runSync(isInitialLaunch: false, forceRefresh: true);
  }

  Future<void> syncLiveWeather({bool force = false}) async {
    if (state.isSyncing || _isWeatherSyncing) {
      return;
    }

    final appInstance = ref.read(appInstanceProvider);
    final year = ref.read(editionYearProvider);
    final apiClient = ref.read(lareviraApiClientProvider);
    final appDatabase = ref.read(appDatabaseProvider);
    const mode = 'all';

    _isWeatherSyncing = true;
    try {
      if (!force) {
        final lastSyncedAt = await _readLastLiveWeatherSync(
          appDatabase: appDatabase,
          citySlug: appInstance.citySlug,
          year: year,
          mode: mode,
        );
        if (lastSyncedAt != null &&
            DateTime.now().difference(lastSyncedAt) < _liveWeatherMinInterval) {
          return;
        }
      }

      final response = await apiClient.fetchScoped(
        appInstance.citySlug,
        year,
        '/day-weather',
      );

      final payload = response.data;
      if (payload is! Map<String, dynamic>) {
        return;
      }

      final rawItems = payload['data'];
      if (rawItems is! List<dynamic>) {
        return;
      }

      final weatherBySlug = <String, DayWeatherSummary>{};
      for (final rawItem in rawItems) {
        if (rawItem is! Map<String, dynamic>) {
          continue;
        }
        final slug = (rawItem['slug'] ?? '').toString().trim();
        if (slug.isEmpty) {
          continue;
        }
        final weatherJson = rawItem['day_weather'];
        final weather = weatherJson is Map<String, dynamic>
            ? DayWeatherSummary.fromJson(weatherJson)
            : const DayWeatherSummary();
        weatherBySlug[slug] = weather;
      }

      if (weatherBySlug.isEmpty) {
        return;
      }

      final updatedRows = await appDatabase.applyDayWeatherUpdates(
        city: appInstance.citySlug,
        year: year,
        modeValue: mode,
        weatherBySlug: weatherBySlug,
      );

      await _saveLastLiveWeatherSync(
        appDatabase: appDatabase,
        citySlug: appInstance.citySlug,
        year: year,
        mode: mode,
      );

      if (updatedRows > 0) {
        ref.invalidate(jornadasProvider);
      }
    } catch (_) {
      // Silent by design: this is a lightweight live refresh.
    } finally {
      _isWeatherSyncing = false;
    }
  }

  Future<void> _runSync({
    required bool isInitialLaunch,
    required bool forceRefresh,
  }) async {
    final appInstance = ref.read(appInstanceProvider);
    final year = ref.read(editionYearProvider);
    final apiClient = ref.read(lareviraApiClientProvider);
    final appDatabase = ref.read(appDatabaseProvider);
    final AppAnalytics? analytics = ref.read(appAnalyticsProvider);
    const mode = 'all';
    const resourceKey = 'days';
    final metrics = _SyncMetrics(exposeInMessage: syncMetricsMessageEnabled);
    final startedAt = DateTime.now();
    var localDays = const <DayIndexItem>[];
    var hasLocalDays = false;

    state = state.copyWith(isSyncing: true, message: null);

    try {
      localDays = await appDatabase.getDays(
        city: appInstance.citySlug,
        year: year,
        modeValue: mode,
      );
      hasLocalDays = localDays.isNotEmpty;

      final manifest = await _fetchSyncManifest(
        apiClient: apiClient,
        citySlug: appInstance.citySlug,
        year: year,
        metrics: metrics,
      );
      final manifestResource = manifest?.resource(resourceKey);
      final localVersion = await appDatabase.readSyncResourceVersion(
        city: appInstance.citySlug,
        year: year,
        modeValue: mode,
        resource: resourceKey,
      );
      final persistedLastSync = await appDatabase.getLastSuccessfulSync(
        city: appInstance.citySlug,
        year: year,
        modeValue: mode,
      );

      final needsDetailRepair = hasLocalDays
          ? await _hasMissingMapData(
              appDatabase: appDatabase,
              citySlug: appInstance.citySlug,
              year: year,
              mode: mode,
              items: localDays,
            )
          : false;

      if (!forceRefresh &&
          _shouldSkipDaysSync(
            hasLocalDays: hasLocalDays,
            localVersion: localVersion,
            remoteResource: manifestResource,
          ) &&
          !needsDetailRepair) {
        final skippedAt = DateTime.now();
        await appDatabase.saveLastSuccessfulSync(
          city: appInstance.citySlug,
          year: year,
          modeValue: mode,
          syncedAt: skippedAt,
        );

        state = state.copyWith(
          isSyncing: false,
          isInitialSyncComplete: isInitialLaunch
              ? true
              : state.isInitialSyncComplete,
          lastSyncedAt: skippedAt,
          message: 'Sin cambios en jornadas. Se mantienen los datos locales.',
        );
        _trackSyncAnalytics(
          analytics: analytics,
          startedAt: startedAt,
          result: 'manifest_skip',
          planType: 'none',
          forceRefresh: forceRefresh,
          hasLocalDays: hasLocalDays,
          syncedDaysCount: localDays.length,
          syncedDetailsCount: 0,
          detailFailures: 0,
          metrics: metrics,
        );
        return;
      }

      final syncPlan = await _resolveSyncPlan(
        apiClient: apiClient,
        citySlug: appInstance.citySlug,
        year: year,
        since: persistedLastSync,
        hasLocalDays: hasLocalDays,
        forceRefresh: forceRefresh,
        needsDetailRepair: needsDetailRepair,
        metrics: metrics,
      );

      if (syncPlan.type == _SyncType.noop) {
        final syncedAt = DateTime.now();
        await appDatabase.saveLastSuccessfulSync(
          city: appInstance.citySlug,
          year: year,
          modeValue: mode,
          syncedAt: syncedAt,
        );
        if (manifestResource != null && manifestResource.version.isNotEmpty) {
          await appDatabase.saveSyncResourceVersion(
            city: appInstance.citySlug,
            year: year,
            modeValue: mode,
            resource: resourceKey,
            version: manifestResource.version,
          );
        }

        state = state.copyWith(
          isSyncing: false,
          isInitialSyncComplete: isInitialLaunch
              ? true
              : state.isInitialSyncComplete,
          lastSyncedAt: syncedAt,
          message:
              'Sin cambios relevantes desde la última sincronización incremental.'
              '${metrics.messageSuffix}',
        );
        _trackSyncAnalytics(
          analytics: analytics,
          startedAt: startedAt,
          result: 'incremental_noop',
          planType: _planLabel(syncPlan.type),
          forceRefresh: forceRefresh,
          hasLocalDays: hasLocalDays,
          syncedDaysCount: 0,
          syncedDetailsCount: 0,
          detailFailures: 0,
          metrics: metrics,
        );
        return;
      }

      final days = await _fetchDayIndex(
        apiClient: apiClient,
        citySlug: appInstance.citySlug,
        year: year,
        mode: mode,
        metrics: metrics,
      );

      await appDatabase.replaceDays(
        city: appInstance.citySlug,
        year: year,
        modeValue: mode,
        items: days,
      );

      final slugsToSync = _slugsForPlan(plan: syncPlan, dayIndex: days);

      var syncedDetails = 0;
      var detailFailures = 0;

      if (slugsToSync.isNotEmpty) {
        final detailResult = await _syncDayDetails(
          apiClient: apiClient,
          appDatabase: appDatabase,
          citySlug: appInstance.citySlug,
          year: year,
          mode: mode,
          slugs: slugsToSync,
          metrics: metrics,
        );
        syncedDetails = detailResult.synced;
        detailFailures = detailResult.failures;
      }

      ref.invalidate(jornadasProvider);
      ref.invalidate(dayDetailProvider);

      final syncedAt = DateTime.now();
      await appDatabase.saveLastSuccessfulSync(
        city: appInstance.citySlug,
        year: year,
        modeValue: mode,
        syncedAt: syncedAt,
      );
      if (detailFailures == 0 &&
          manifestResource != null &&
          manifestResource.version.isNotEmpty) {
        await appDatabase.saveSyncResourceVersion(
          city: appInstance.citySlug,
          year: year,
          modeValue: mode,
          resource: resourceKey,
          version: manifestResource.version,
        );
      }

      if (forceRefresh) {
        await _prefetchBrotherhoodImagesFromLocal(
          appDatabase: appDatabase,
          citySlug: appInstance.citySlug,
          year: year,
          mode: mode,
        );
      }

      state = state.copyWith(
        isSyncing: false,
        isInitialSyncComplete: isInitialLaunch
            ? true
            : state.isInitialSyncComplete,
        lastSyncedAt: syncedAt,
        message: detailFailures == 0
            ? 'OK: ${days.length} jornadas y $syncedDetails detalles sincronizados.'
                  '${metrics.messageSuffix}'
            : 'OK: ${days.length} jornadas sincronizadas. '
                  '$syncedDetails detalles actualizados y $detailFailures pendientes.'
                  '${metrics.messageSuffix}',
      );
      _trackSyncAnalytics(
        analytics: analytics,
        startedAt: startedAt,
        result: detailFailures == 0 ? 'success' : 'partial_success',
        planType: _planLabel(syncPlan.type),
        forceRefresh: forceRefresh,
        hasLocalDays: hasLocalDays,
        syncedDaysCount: days.length,
        syncedDetailsCount: syncedDetails,
        detailFailures: detailFailures,
        metrics: metrics,
      );
    } catch (error) {
      state = state.copyWith(
        isSyncing: false,
        isInitialSyncComplete: isInitialLaunch
            ? true
            : state.isInitialSyncComplete,
        message: _buildSyncErrorMessage(
          error,
          hasLocalDays: hasLocalDays,
          isInitialLaunch: isInitialLaunch,
        ),
      );
      _trackSyncAnalytics(
        analytics: analytics,
        startedAt: startedAt,
        result: 'failure',
        planType: 'unknown',
        forceRefresh: forceRefresh,
        hasLocalDays: hasLocalDays,
        syncedDaysCount: 0,
        syncedDetailsCount: 0,
        detailFailures: 0,
        metrics: metrics,
        error: error.toString(),
      );
    }
  }

  String _planLabel(_SyncType type) {
    switch (type) {
      case _SyncType.noop:
        return 'noop';
      case _SyncType.partial:
        return 'partial';
      case _SyncType.full:
        return 'full';
    }
  }

  String _liveWeatherSyncKey({
    required String citySlug,
    required int year,
    required String mode,
  }) {
    return 'live_weather_last_sync_v1:$citySlug:$year:$mode';
  }

  Future<DateTime?> _readLastLiveWeatherSync({
    required AppDatabase appDatabase,
    required String citySlug,
    required int year,
    required String mode,
  }) async {
    final raw = await appDatabase.readSetting(
      _liveWeatherSyncKey(citySlug: citySlug, year: year, mode: mode),
    );
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  Future<void> _saveLastLiveWeatherSync({
    required AppDatabase appDatabase,
    required String citySlug,
    required int year,
    required String mode,
  }) {
    return appDatabase.saveSetting(
      key: _liveWeatherSyncKey(citySlug: citySlug, year: year, mode: mode),
      value: DateTime.now().toIso8601String(),
    );
  }

  void _trackSyncAnalytics({
    required AppAnalytics? analytics,
    required DateTime startedAt,
    required String result,
    required String planType,
    required bool forceRefresh,
    required bool hasLocalDays,
    required int syncedDaysCount,
    required int syncedDetailsCount,
    required int detailFailures,
    required _SyncMetrics metrics,
    String? error,
  }) {
    if (analytics == null) {
      return;
    }

    final elapsedMs = DateTime.now().difference(startedAt).inMilliseconds;
    final parameters = <String, Object>{
      'result': result,
      'plan': planType,
      'force_refresh': forceRefresh ? 1 : 0,
      'had_local_days': hasLocalDays ? 1 : 0,
      'days_synced': syncedDaysCount,
      'details_synced': syncedDetailsCount,
      'detail_failures': detailFailures,
      'retries': metrics.retryAttempts,
      'batch_splits': metrics.batchSplits,
      'batches': metrics.batchesFetched,
      'fallbacks': metrics.singleFallbacks,
      'invalidated_slugs': metrics.invalidatedSlugs,
      'duration_ms': elapsedMs,
    };
    if (error != null && error.isNotEmpty) {
      parameters['error'] = error.length > 100
          ? error.substring(0, 100)
          : error;
    }

    analytics.track('sync_run', parameters: parameters);
  }

  Future<_SyncPlan> _resolveSyncPlan({
    required LareviraApiClient apiClient,
    required String citySlug,
    required int year,
    required DateTime? since,
    required bool hasLocalDays,
    required bool forceRefresh,
    required bool needsDetailRepair,
    required _SyncMetrics metrics,
  }) async {
    if (forceRefresh || !hasLocalDays || needsDetailRepair || since == null) {
      return const _SyncPlan.full();
    }

    final changes = await _fetchSyncChanges(
      apiClient: apiClient,
      citySlug: citySlug,
      year: year,
      since: since,
      metrics: metrics,
    );

    if (changes == null) {
      return const _SyncPlan.full();
    }

    if (_requiresFullRefresh(changes)) {
      return const _SyncPlan.full();
    }

    if (changes.days.changedSlugs.isEmpty) {
      return const _SyncPlan.noop();
    }

    return _SyncPlan.partial(changes.days.changedSlugs);
  }

  bool _requiresFullRefresh(SyncChanges changes) {
    if (changes.days.fullResyncRequired ||
        changes.brotherhoods.fullResyncRequired ||
        changes.processionEvents.fullResyncRequired ||
        changes.itineraries.fullResyncRequired) {
      return true;
    }

    if (changes.processionEvents.changedEventIds.isNotEmpty ||
        changes.itineraries.changedEventIds.isNotEmpty) {
      return true;
    }

    return false;
  }

  List<String> _slugsForPlan({
    required _SyncPlan plan,
    required List<DayIndexItem> dayIndex,
  }) {
    final all = dayIndex
        .map((item) => item.slug.trim())
        .where((value) => value.isNotEmpty)
        .toSet();

    switch (plan.type) {
      case _SyncType.noop:
        return const [];
      case _SyncType.full:
        return all.toList(growable: false);
      case _SyncType.partial:
        final changed = plan.changedSlugs.toSet();
        final selected = <String>[];
        for (final slug in changed) {
          if (all.contains(slug)) {
            selected.add(slug);
          }
        }
        return selected;
    }
  }

  Future<_DetailSyncResult> _syncDayDetails({
    required LareviraApiClient apiClient,
    required AppDatabase appDatabase,
    required String citySlug,
    required int year,
    required String mode,
    required List<String> slugs,
    required _SyncMetrics metrics,
  }) async {
    var synced = 0;
    var failures = 0;

    final queue = <List<String>>[
      for (final batch in _chunk(slugs, size: 80)) batch,
    ];

    while (queue.isNotEmpty) {
      final batch = queue.removeAt(0);
      _DayBatchResult batchResult;

      try {
        batchResult = await _fetchDayDetailsBatch(
          apiClient: apiClient,
          citySlug: citySlug,
          year: year,
          mode: mode,
          slugs: batch,
          metrics: metrics,
        );
        metrics.batchesFetched += 1;
      } on DioException catch (error) {
        if (_shouldSplitBatch(error, batch.length)) {
          final splitIndex = batch.length ~/ 2;
          queue.insert(0, batch.sublist(splitIndex));
          queue.insert(0, batch.sublist(0, splitIndex));
          metrics.batchSplits += 1;
          continue;
        }

        for (final slug in batch) {
          metrics.singleFallbacks += 1;
          final singleDetail = await _fetchSingleDayDetail(
            apiClient: apiClient,
            citySlug: citySlug,
            year: year,
            mode: mode,
            slug: slug,
            metrics: metrics,
          );
          if (singleDetail == null) {
            failures += 1;
            continue;
          }

          await appDatabase.saveDayDetail(
            city: citySlug,
            year: year,
            modeValue: mode,
            daySlugValue: slug,
            detail: singleDetail,
          );
          synced += 1;
        }
        continue;
      }

      final returnedBySlug = <String, DayDetail>{};
      for (final detail in batchResult.details) {
        final slug = detail.slug.trim();
        if (slug.isEmpty) {
          continue;
        }

        returnedBySlug[slug] = detail;
      }

      final missingSlugs = batchResult.missingSlugs.toSet();
      if (batchResult.missingEventIds.isNotEmpty) {
        // We don't have day mapping for event IDs locally, so force fallback
        // resolution slug-by-slug for this chunk.
        missingSlugs.addAll(batch);
      }

      for (final slug in batch) {
        final fromBatch = returnedBySlug[slug];
        if (fromBatch != null && !missingSlugs.contains(slug)) {
          await appDatabase.saveDayDetail(
            city: citySlug,
            year: year,
            modeValue: mode,
            daySlugValue: slug,
            detail: fromBatch,
          );
          synced += 1;
          continue;
        }

        if (missingSlugs.contains(slug)) {
          await appDatabase.deleteDayDetail(
            city: citySlug,
            year: year,
            modeValue: mode,
            daySlugValue: slug,
          );
          metrics.invalidatedSlugs += 1;
        }

        metrics.singleFallbacks += 1;
        final singleDetail = await _fetchSingleDayDetail(
          apiClient: apiClient,
          citySlug: citySlug,
          year: year,
          mode: mode,
          slug: slug,
          metrics: metrics,
        );

        if (singleDetail == null) {
          failures += 1;
          continue;
        }

        await appDatabase.saveDayDetail(
          city: citySlug,
          year: year,
          modeValue: mode,
          daySlugValue: slug,
          detail: singleDetail,
        );
        synced += 1;
      }
    }

    return _DetailSyncResult(synced: synced, failures: failures);
  }

  bool _shouldSplitBatch(DioException error, int batchSize) {
    if (batchSize <= 1) {
      return false;
    }

    final statusCode = error.response?.statusCode;
    if (statusCode == 413) {
      return true;
    }

    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout;
  }

  Future<_DayBatchResult> _fetchDayDetailsBatch({
    required LareviraApiClient apiClient,
    required String citySlug,
    required int year,
    required String mode,
    required List<String> slugs,
    required _SyncMetrics metrics,
  }) async {
    if (slugs.isEmpty) {
      return const _DayBatchResult.empty();
    }

    final response = await _retryRequest(() {
      return apiClient.fetchScoped(
        citySlug,
        year,
        '/days-batch',
        queryParameters: {'mode': mode, 'slugs': slugs.join(',')},
      );
    }, metrics: metrics);

    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      return const _DayBatchResult.empty();
    }

    final data = payload['data'];
    final details = <DayDetail>[];
    final missingSlugs = <String>{};
    final missingEventIds = <int>{};

    _collectMissingKeys(payload['meta'], missingSlugs, missingEventIds);

    if (data is List<dynamic>) {
      for (final item in data) {
        if (item is! Map<String, dynamic>) {
          continue;
        }
        details.add(DayDetail.fromJson(item));
      }
      final enrichedDetails = await _enrichDayDetailsWithBrotherhoodData(
        apiClient: apiClient,
        citySlug: citySlug,
        year: year,
        details: details,
        metrics: metrics,
      );
      return _DayBatchResult(
        details: enrichedDetails,
        missingSlugs: missingSlugs.toList(growable: false),
        missingEventIds: missingEventIds.toList(growable: false),
      );
    }

    if (data is Map<String, dynamic>) {
      _collectMissingKeys(data['meta'], missingSlugs, missingEventIds);

      if (data['items'] is List<dynamic>) {
        final items = data['items'] as List<dynamic>;
        for (final item in items) {
          if (item is! Map<String, dynamic>) {
            continue;
          }
          details.add(DayDetail.fromJson(item));
        }
        final enrichedDetails = await _enrichDayDetailsWithBrotherhoodData(
          apiClient: apiClient,
          citySlug: citySlug,
          year: year,
          details: details,
          metrics: metrics,
        );
        return _DayBatchResult(
          details: enrichedDetails,
          missingSlugs: missingSlugs.toList(growable: false),
          missingEventIds: missingEventIds.toList(growable: false),
        );
      }

      for (final entry in data.entries) {
        if (entry.key == 'meta') {
          continue;
        }
        if (entry.value is! Map<String, dynamic>) {
          continue;
        }

        final item = <String, dynamic>{
          ...(entry.value as Map<String, dynamic>),
        };
        if ((item['slug'] ?? '').toString().trim().isEmpty) {
          item['slug'] = entry.key;
        }
        details.add(DayDetail.fromJson(item));
      }
    }

    final enrichedDetails = await _enrichDayDetailsWithBrotherhoodData(
      apiClient: apiClient,
      citySlug: citySlug,
      year: year,
      details: details,
      metrics: metrics,
    );

    return _DayBatchResult(
      details: enrichedDetails,
      missingSlugs: missingSlugs.toList(growable: false),
      missingEventIds: missingEventIds.toList(growable: false),
    );
  }

  void _collectMissingKeys(
    Object? rawMeta,
    Set<String> missingSlugs,
    Set<int> missingEventIds,
  ) {
    if (rawMeta is! Map<String, dynamic>) {
      return;
    }

    final rawSlugs = (rawMeta['missing_slugs'] as List<dynamic>? ?? const []);
    for (final value in rawSlugs) {
      final slug = value.toString().trim();
      if (slug.isNotEmpty) {
        missingSlugs.add(slug);
      }
    }

    final rawIds = (rawMeta['missing_ids'] as List<dynamic>? ?? const []);
    for (final value in rawIds) {
      if (value is num) {
        missingEventIds.add(value.toInt());
      }
    }
  }

  Future<DayDetail?> _fetchSingleDayDetail({
    required LareviraApiClient apiClient,
    required String citySlug,
    required int year,
    required String mode,
    required String slug,
    required _SyncMetrics metrics,
  }) async {
    try {
      final response = await _retryRequest(() {
        return apiClient.fetchScoped(
          citySlug,
          year,
          '/days/$slug',
          queryParameters: {'mode': mode},
        );
      }, metrics: metrics);

      final payload = response.data;
      if (payload is! Map<String, dynamic>) {
        return null;
      }

      final data = (payload['data'] as Map<String, dynamic>? ?? const {});
      final detail = DayDetail.fromJson(data);
      final enriched = await _enrichDayDetailsWithBrotherhoodData(
        apiClient: apiClient,
        citySlug: citySlug,
        year: year,
        details: [detail],
        metrics: metrics,
      );
      if (enriched.isEmpty) {
        return detail;
      }
      return enriched.first;
    } catch (_) {
      return null;
    }
  }

  Future<List<DayDetail>> _enrichDayDetailsWithBrotherhoodData({
    required LareviraApiClient apiClient,
    required String citySlug,
    required int year,
    required List<DayDetail> details,
    required _SyncMetrics metrics,
  }) async {
    if (details.isEmpty) {
      return details;
    }

    final slugs = <String>{
      for (final detail in details)
        for (final event in detail.processionEvents)
          if (event.brotherhoodSlug.trim().isNotEmpty) event.brotherhoodSlug,
    }.toList(growable: false);

    if (slugs.isEmpty) {
      return details;
    }

    try {
      final summaries = await _fetchBrotherhoodBatchSummaries(
        apiClient: apiClient,
        citySlug: citySlug,
        year: year,
        slugs: slugs,
        metrics: metrics,
      );
      if (summaries.isEmpty) {
        return details;
      }

      return details
          .map((detail) => _applyBrotherhoodSummaries(detail, summaries))
          .toList(growable: false);
    } catch (_) {
      return details;
    }
  }

  Future<Map<String, _BrotherhoodSummary>> _fetchBrotherhoodBatchSummaries({
    required LareviraApiClient apiClient,
    required String citySlug,
    required int year,
    required List<String> slugs,
    required _SyncMetrics metrics,
  }) async {
    if (slugs.isEmpty) {
      return const {};
    }

    final response = await _retryRequest(() {
      return apiClient.fetchScoped(
        citySlug,
        year,
        '/brotherhoods-batch',
        queryParameters: {'slugs': slugs.join(',')},
      );
    }, metrics: metrics);

    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      return const {};
    }

    final data = payload['data'];
    if (data is! List<dynamic>) {
      return const {};
    }

    final summaries = <String, _BrotherhoodSummary>{};
    for (final item in data) {
      if (item is! Map<String, dynamic>) {
        continue;
      }
      final slug = (item['slug'] ?? '').toString().trim();
      if (slug.isEmpty) {
        continue;
      }
      final shieldImageUrl = _pickString(item, const [
        'shield_image_url',
        'shield_url',
        'logo_url',
        'badge_url',
      ]);
      final headerImageUrl = _pickString(item, const [
        'header_image_url',
        'header_image',
        'cover_image_url',
        'cover_url',
      ]);
      final history = _pickString(item, const ['history', 'historia', 'about']);
      final dressCode = _pickString(item, const ['dress_code', 'dressCode']) ??
          _pickString(
            (item['metadata'] as Map<String, dynamic>? ?? const {}),
            const ['dress_code', 'dressCode'],
          );
      final figures = _extractNamedDescriptions(item['figures']);
      final pasos = _extractPasoDescriptions(item['pasos']);
      final stepsCount = _pickInt(item, const [
        'steps_count',
        'pasos_count',
        'number_of_steps',
      ]) ?? _countStepsList(item['pasos']);
      summaries[slug] = _BrotherhoodSummary(
        shieldImageUrl: shieldImageUrl,
        headerImageUrl: headerImageUrl,
        history: history,
        dressCode: dressCode,
        figures: figures,
        pasos: pasos,
        stepsCount: stepsCount,
      );
    }
    return summaries;
  }

  DayDetail _applyBrotherhoodSummaries(
    DayDetail detail,
    Map<String, _BrotherhoodSummary> summaries,
  ) {
    final events = detail.processionEvents.map((event) {
      final summary = summaries[event.brotherhoodSlug];
      if (summary == null) {
        return event;
      }
      return event.copyWith(
        stepsCount: event.stepsCount ?? summary.stepsCount,
        brotherhoodHistory: event.brotherhoodHistory ?? summary.history,
        brotherhoodHeaderImageUrl:
            event.brotherhoodHeaderImageUrl ?? summary.headerImageUrl,
        brotherhoodDressCode:
            event.brotherhoodDressCode ?? summary.dressCode,
        brotherhoodFigures: event.brotherhoodFigures.isNotEmpty
            ? event.brotherhoodFigures
            : summary.figures,
        brotherhoodPasos:
            event.brotherhoodPasos.isNotEmpty ? event.brotherhoodPasos : summary.pasos,
        brotherhoodShieldImageUrl:
            event.brotherhoodShieldImageUrl ?? summary.shieldImageUrl,
      );
    }).toList(growable: false);
    return detail.copyWith(processionEvents: events);
  }

  int? _countStepsList(Object? rawPasos) {
    if (rawPasos is! List<dynamic>) {
      return null;
    }
    return rawPasos.whereType<Map<String, dynamic>>().length;
  }

  List<BrotherhoodFigureInfo> _extractNamedDescriptions(Object? raw) {
    if (raw is! List<dynamic>) {
      return const [];
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .map(
          (entry) => BrotherhoodFigureInfo(
            name: (entry['name'] ?? '').toString().trim(),
            description: _pickString(
              entry,
              const ['description', 'text', 'content'],
            ),
          ),
        )
        .where((item) => item.name.isNotEmpty)
        .toList(growable: false);
  }

  List<BrotherhoodPasoInfo> _extractPasoDescriptions(Object? raw) {
    if (raw is! List<dynamic>) {
      return const [];
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .map(
          (entry) => BrotherhoodPasoInfo(
            name: (entry['name'] ?? '').toString().trim(),
            description: _pickString(
              entry,
              const ['description', 'text', 'content'],
            ),
          ),
        )
        .where((item) => item.name.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> _prefetchBrotherhoodImagesFromLocal({
    required AppDatabase appDatabase,
    required String citySlug,
    required int year,
    required String mode,
  }) async {
    final days = await appDatabase.getDays(
      city: citySlug,
      year: year,
      modeValue: mode,
    );
    if (days.isEmpty) {
      return;
    }

    final shieldUrls = <String>{};
    final headerUrls = <String>{};

    for (final day in days) {
      final detail = await appDatabase.getDayDetail(
        city: citySlug,
        year: year,
        modeValue: mode,
        daySlugValue: day.slug,
      );
      if (detail == null) {
        continue;
      }
      for (final event in detail.processionEvents) {
        final shield = event.brotherhoodShieldImageUrl?.trim();
        if (_isHttpUrl(shield)) {
          shieldUrls.add(shield!);
        }
        final header = event.brotherhoodHeaderImageUrl?.trim();
        if (_isHttpUrl(header)) {
          headerUrls.add(header!);
        }
      }
    }

    final tasks = <Future<void>>[
      for (final url in shieldUrls)
        PrivateImageCache.getOrFetchShield(url).then((_) {}),
      for (final url in headerUrls)
        PrivateImageCache.getOrFetchHeader(url).then((_) {}),
    ];
    if (tasks.isNotEmpty) {
      await Future.wait(tasks);
    }
  }

  bool _isHttpUrl(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    final uri = Uri.tryParse(value);
    if (uri == null) {
      return false;
    }
    return uri.hasScheme &&
        (uri.scheme.toLowerCase() == 'http' ||
            uri.scheme.toLowerCase() == 'https');
  }

  String? _pickString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  int? _pickInt(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return null;
  }

  Future<List<DayIndexItem>> _fetchDayIndex({
    required LareviraApiClient apiClient,
    required String citySlug,
    required int year,
    required String mode,
    required _SyncMetrics metrics,
  }) async {
    final daysResponse = await _retryRequest(() {
      return apiClient.fetchScoped(
        citySlug,
        year,
        '/days',
        queryParameters: {'mode': mode},
      );
    }, metrics: metrics);

    final daysPayload = daysResponse.data;
    if (daysPayload is! Map<String, dynamic>) {
      throw StateError('Respuesta de jornadas invalida.');
    }

    final rawList =
        (daysPayload['data'] as List<dynamic>? ?? const <dynamic>[]);
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(DayIndexItem.fromJson)
        .toList(growable: false);
  }

  String _buildSyncErrorMessage(
    Object error, {
    required bool hasLocalDays,
    required bool isInitialLaunch,
  }) {
    if (!hasLocalDays) {
      return 'Se necesita conexión para la primera sincronización. '
          'Abre la app con internet o sincroniza desde "Más".';
    }

    if (isInitialLaunch) {
      return 'Sin conexión o error remoto. Se mantienen los datos guardados en el dispositivo.';
    }

    return 'No se ha podido sincronizar ahora. Se mantienen los datos guardados en el dispositivo. ($error)';
  }

  Future<SyncManifest?> _fetchSyncManifest({
    required LareviraApiClient apiClient,
    required String citySlug,
    required int year,
    required _SyncMetrics metrics,
  }) async {
    try {
      final response = await _retryRequest(
        () => apiClient.fetchScoped(citySlug, year, '/sync-manifest'),
        metrics: metrics,
      );
      final payload = response.data;
      if (payload is! Map<String, dynamic>) {
        return null;
      }

      final data = (payload['data'] as Map<String, dynamic>? ?? const {});
      return SyncManifest.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<SyncChanges?> _fetchSyncChanges({
    required LareviraApiClient apiClient,
    required String citySlug,
    required int year,
    required DateTime since,
    required _SyncMetrics metrics,
  }) async {
    try {
      final response = await _retryRequest(() {
        return apiClient.fetchScoped(
          citySlug,
          year,
          '/sync-changes',
          queryParameters: {'since': since.toUtc().toIso8601String()},
        );
      }, metrics: metrics);
      final payload = response.data;
      if (payload is! Map<String, dynamic>) {
        return null;
      }

      final data = (payload['data'] as Map<String, dynamic>? ?? const {});
      return SyncChanges.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<Response<dynamic>> _retryRequest(
    Future<Response<dynamic>> Function() run, {
    required _SyncMetrics metrics,
  }) async {
    const maxAttempts = 4;
    var attempt = 0;

    while (true) {
      attempt += 1;
      try {
        return await run();
      } on DioException catch (error) {
        if (attempt >= maxAttempts || !_isRetryable(error)) {
          rethrow;
        }
        metrics.retryAttempts += 1;

        final delayMs =
            (500 * (1 << (attempt - 1))) + ((DateTime.now().microsecond % 220));
        await Future<void>.delayed(Duration(milliseconds: delayMs));
      }
    }
  }

  bool _isRetryable(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 429 || (statusCode != null && statusCode >= 500)) {
      return true;
    }

    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown;
  }

  bool _shouldSkipDaysSync({
    required bool hasLocalDays,
    required String? localVersion,
    required SyncManifestResource? remoteResource,
  }) {
    if (!hasLocalDays || localVersion == null || localVersion.isEmpty) {
      return false;
    }

    if (remoteResource == null || remoteResource.version.isEmpty) {
      return false;
    }

    return remoteResource.version == localVersion;
  }

  Future<bool> _hasMissingMapData({
    required AppDatabase appDatabase,
    required String citySlug,
    required int year,
    required String mode,
    required List<DayIndexItem> items,
  }) async {
    for (final item in items) {
      final detail = await appDatabase.getDayDetail(
        city: citySlug,
        year: year,
        modeValue: mode,
        daySlugValue: item.slug,
      );

      if (detail == null ||
          !_hasRealSchedulePoints(detail) ||
          !_hasRouteGeometry(detail)) {
        return true;
      }
    }

    return false;
  }

  bool _hasRealSchedulePoints(DayDetail detail) {
    for (final event in detail.processionEvents) {
      if (event.schedulePoints.any((point) => point.plannedAt != null)) {
        return true;
      }
    }

    return false;
  }

  bool _hasRouteGeometry(DayDetail detail) {
    for (final event in detail.processionEvents) {
      if (event.routePoints.where((point) => point.hasLocation).length >= 2) {
        return true;
      }
    }

    return false;
  }

  Future<void> _restorePersistedState({
    required String city,
    required int year,
  }) async {
    const mode = 'all';
    final appDatabase = ref.read(appDatabaseProvider);
    final persisted = await appDatabase.getLastSuccessfulSync(
      city: city,
      year: year,
      modeValue: mode,
    );

    final currentAppInstance = ref.read(appInstanceProvider);
    final currentYear = ref.read(editionYearProvider);
    if (currentAppInstance.citySlug != city || currentYear != year) {
      return;
    }

    if (persisted == null) {
      return;
    }

    state = state.copyWith(
      lastSyncedAt: persisted,
      isInitialSyncComplete: true,
    );
  }

  Iterable<List<String>> _chunk(
    List<String> values, {
    required int size,
  }) sync* {
    if (size <= 0 || values.isEmpty) {
      return;
    }

    for (var i = 0; i < values.length; i += size) {
      final end = (i + size > values.length) ? values.length : i + size;
      yield values.sublist(i, end);
    }
  }
}

class _DetailSyncResult {
  const _DetailSyncResult({required this.synced, required this.failures});

  final int synced;
  final int failures;
}

class _BrotherhoodSummary {
  const _BrotherhoodSummary({
    required this.shieldImageUrl,
    required this.headerImageUrl,
    required this.history,
    required this.dressCode,
    required this.figures,
    required this.pasos,
    required this.stepsCount,
  });

  final String? shieldImageUrl;
  final String? headerImageUrl;
  final String? history;
  final String? dressCode;
  final List<BrotherhoodFigureInfo> figures;
  final List<BrotherhoodPasoInfo> pasos;
  final int? stepsCount;
}

class _DayBatchResult {
  const _DayBatchResult({
    required this.details,
    required this.missingSlugs,
    required this.missingEventIds,
  });

  const _DayBatchResult.empty()
    : details = const <DayDetail>[],
      missingSlugs = const <String>[],
      missingEventIds = const <int>[];

  final List<DayDetail> details;
  final List<String> missingSlugs;
  final List<int> missingEventIds;
}

class _SyncMetrics {
  _SyncMetrics({required this.exposeInMessage});

  final bool exposeInMessage;
  int retryAttempts = 0;
  int batchSplits = 0;
  int batchesFetched = 0;
  int singleFallbacks = 0;
  int invalidatedSlugs = 0;

  String get messageSuffix {
    if (!exposeInMessage) {
      return '';
    }

    if (retryAttempts == 0 &&
        batchSplits == 0 &&
        batchesFetched == 0 &&
        singleFallbacks == 0 &&
        invalidatedSlugs == 0) {
      return '';
    }

    return ' [métricas: batches=$batchesFetched, retries=$retryAttempts, '
        'splits=$batchSplits, fallbacks=$singleFallbacks, '
        'invalidaciones=$invalidatedSlugs]';
  }
}

enum _SyncType { noop, partial, full }

class _SyncPlan {
  const _SyncPlan._({required this.type, required this.changedSlugs});

  const _SyncPlan.noop()
    : this._(type: _SyncType.noop, changedSlugs: const <String>[]);

  const _SyncPlan.full()
    : this._(type: _SyncType.full, changedSlugs: const <String>[]);

  _SyncPlan.partial(List<String> changedSlugs)
    : this._(type: _SyncType.partial, changedSlugs: changedSlugs);

  final _SyncType type;
  final List<String> changedSlugs;
}
