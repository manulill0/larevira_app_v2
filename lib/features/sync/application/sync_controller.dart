import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_instance_controller.dart';
import '../../../core/local/app_database.dart';
import '../../../core/models/day_detail.dart';
import '../../../core/models/day_index_item.dart';
import '../../../core/models/sync_manifest.dart';
import '../../../core/network/larevira_api_client.dart';
import '../../jornadas/application/day_detail_controller.dart';
import '../../jornadas/application/jornadas_controller.dart';

final syncControllerProvider =
    NotifierProvider<SyncController, SyncState>(SyncController.new);

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
  @override
  SyncState build() {
    final appInstance = ref.watch(appInstanceProvider);
    final year = ref.watch(editionYearProvider);
    _restorePersistedState(
      city: appInstance.citySlug,
      year: year,
    );

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

  Future<void> _runSync({
    required bool isInitialLaunch,
    required bool forceRefresh,
  }) async {
    final appInstance = ref.read(appInstanceProvider);
    final year = ref.read(editionYearProvider);
    final apiClient = ref.read(lareviraApiClientProvider);
    final appDatabase = ref.read(appDatabaseProvider);
    const mode = 'all';
    const resourceKey = 'days';
    final localDays = await appDatabase.getDays(
      city: appInstance.citySlug,
      year: year,
      modeValue: mode,
    );
    final hasLocalDays = localDays.isNotEmpty;

    state = state.copyWith(
      isSyncing: true,
      message: null,
    );

    try {
      final manifest = await _fetchSyncManifest(
        apiClient: apiClient,
        citySlug: appInstance.citySlug,
        year: year,
      );
      final manifestResource = manifest?.resource(resourceKey);
      final localVersion = await appDatabase.readSyncResourceVersion(
        city: appInstance.citySlug,
        year: year,
        modeValue: mode,
        resource: resourceKey,
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
        return;
      }

      final daysResponse = await apiClient.fetchScoped(
        appInstance.citySlug,
        year,
        '/days',
        queryParameters: const {'mode': mode},
      );

      final daysPayload = daysResponse.data;
      if (daysPayload is! Map<String, dynamic>) {
        throw StateError('Respuesta de jornadas invalida.');
      }

      final rawList =
          (daysPayload['data'] as List<dynamic>? ?? const <dynamic>[]);
      final days = rawList
          .whereType<Map<String, dynamic>>()
          .map(DayIndexItem.fromJson)
          .toList(growable: false);

      await appDatabase.replaceDays(
        city: appInstance.citySlug,
        year: year,
        modeValue: mode,
        items: days,
      );

      var syncedDetails = 0;
      var detailFailures = 0;

      for (final item in days) {
        try {
          final detailResponse = await apiClient.fetchScoped(
            appInstance.citySlug,
            year,
            '/days/${item.slug}',
            queryParameters: const {'mode': mode},
          );

          final detailPayload = detailResponse.data;
          if (detailPayload is! Map<String, dynamic>) {
            detailFailures += 1;
            continue;
          }

          final detailData =
              (detailPayload['data'] as Map<String, dynamic>? ?? const {});
          final detail = DayDetail.fromJson(detailData);

          await appDatabase.saveDayDetail(
            city: appInstance.citySlug,
            year: year,
            modeValue: mode,
            daySlugValue: item.slug,
            detail: detail,
          );
          syncedDetails += 1;
        } catch (_) {
          detailFailures += 1;
        }
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

      state = state.copyWith(
        isSyncing: false,
        isInitialSyncComplete: isInitialLaunch
            ? true
            : state.isInitialSyncComplete,
        lastSyncedAt: syncedAt,
        message: detailFailures == 0
            ? 'OK: ${days.length} jornadas y $syncedDetails detalles sincronizados.'
            : 'OK: ${days.length} jornadas sincronizadas. '
                '$syncedDetails detalles actualizados y $detailFailures pendientes.',
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
    }
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
  }) async {
    try {
      final response = await apiClient.fetchScoped(
        citySlug,
        year,
        '/sync-manifest',
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

    state = state.copyWith(lastSyncedAt: persisted);
  }
}
