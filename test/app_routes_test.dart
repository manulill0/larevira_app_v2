import 'package:flutter_test/flutter_test.dart';

import 'package:larevira_app_v2/core/routing/app_router.dart';
import 'package:larevira_app_v2/core/routing/app_routes.dart';
import 'package:larevira_app_v2/features/sync/application/sync_controller.dart';

void main() {
  const syncingState = SyncState(
    isSyncing: true,
    hasAttemptedInitialSync: true,
    isInitialSyncComplete: false,
  );
  const syncedState = SyncState(
    isSyncing: false,
    hasAttemptedInitialSync: true,
    isInitialSyncComplete: true,
  );

  group('router redirects', () {
    test('sends non-startup routes to startup until initial sync completes', () {
      expect(
        resolveAppRedirect(
          syncState: syncingState,
          path: AppRoutes.hoy,
        ),
        AppRoutes.startup,
      );

      expect(
        resolveAppRedirect(
          syncState: syncingState,
          path: AppRoutes.root,
        ),
        AppRoutes.startup,
      );
    });

    test('allows startup while syncing', () {
      expect(
        resolveAppRedirect(
          syncState: syncingState,
          path: AppRoutes.startup,
        ),
        isNull,
      );
    });

    test('sends startup to default home after initial sync', () {
      expect(
        resolveAppRedirect(
          syncState: syncedState,
          path: AppRoutes.startup,
        ),
        AppRoutes.defaultHome,
      );
    });

    test('allows app routes after initial sync', () {
      expect(
        resolveAppRedirect(
          syncState: syncedState,
          path: AppRoutes.jornadas,
        ),
        isNull,
      );
    });

    test('root redirect uses the configured default home', () {
      expect(defaultHomeRedirect(), AppRoutes.defaultHome);
    });
  });

  group('route metadata', () {
    test('tabs expose stable branch indexes', () {
      expect(AppTab.hoy.branchIndex, 0);
      expect(AppTab.jornadas.branchIndex, 1);
      expect(AppTab.planning.branchIndex, 2);
      expect(AppTab.more.branchIndex, 3);
    });

    test('tabs expose stable route names', () {
      expect(AppTab.hoy.routeName, AppRoutes.hoyName);
      expect(AppTab.jornadas.routeName, AppRoutes.jornadasName);
      expect(AppTab.planning.routeName, AppRoutes.planningName);
      expect(AppTab.more.routeName, AppRoutes.moreName);
    });

    test('day detail path is built from the jornadas branch', () {
      expect(
        AppRoutes.dayDetail('domingo-ramos'),
        '/jornadas/day/domingo-ramos',
      );
    });
  });
}
