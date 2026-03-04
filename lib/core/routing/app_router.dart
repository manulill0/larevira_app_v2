import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../analytics/analytics_providers.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/hoy/presentation/hoy_page.dart';
import '../../features/jornadas/presentation/brotherhood_detail_page.dart';
import '../../features/jornadas/presentation/day_detail_page.dart';
import '../../features/jornadas/presentation/jornadas_page.dart';
import '../../features/more/presentation/more_page.dart';
import '../../features/planning/presentation/planning_page.dart';
import '../../features/sync/application/sync_controller.dart';
import '../../features/sync/presentation/app_startup_gate.dart';
import '../models/day_index_item.dart';
import 'app_routes.dart';

String defaultHomeRedirect() => AppRoutes.defaultHome;

String? resolveAppRedirect({
  required SyncState syncState,
  required String path,
}) {
  final isStartupRoute = path == AppRoutes.startup;

  if (!syncState.isInitialSyncComplete && !isStartupRoute) {
    return AppRoutes.startup;
  }

  if (syncState.isInitialSyncComplete && isStartupRoute) {
    return AppRoutes.defaultHome;
  }

  return null;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _RouterRefreshListenable(ref);
  final analytics = ref.read(appAnalyticsProvider);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    initialLocation: AppRoutes.root,
    refreshListenable: refreshListenable,
    observers: analytics == null
        ? const <NavigatorObserver>[]
        : <NavigatorObserver>[analytics.observer],
    redirect: (context, state) {
      final syncState = ref.read(syncControllerProvider);
      return resolveAppRedirect(
        syncState: syncState,
        path: state.uri.path,
      );
    },
    routes: [
      GoRoute(
        name: AppRoutes.rootName,
        path: AppRoutes.root,
        redirect: (context, state) => defaultHomeRedirect(),
      ),
      GoRoute(
        name: AppRoutes.startupName,
        path: AppRoutes.startup,
        builder: (context, state) => const AppStartupGate(),
      ),
      GoRoute(
        name: AppRoutes.dayDetailName,
        path: AppRoutes.dayDetail(':slug'),
        builder: (context, state) {
          final item =
              state.extra is DayIndexItem ? state.extra! as DayIndexItem : null;

          return DayDetailPage(
            slug: state.pathParameters['slug'] ?? '',
            item: item,
          );
        },
      ),
      GoRoute(
        name: AppRoutes.brotherhoodDetailName,
        path: AppRoutes.brotherhoodDetail(':slug'),
        builder: (context, state) {
          final routeData = state.extra is BrotherhoodDetailRouteData
              ? state.extra! as BrotherhoodDetailRouteData
              : null;

          return BrotherhoodDetailPage(
            slug: state.pathParameters['slug'] ?? '',
            event: routeData?.event,
            dayName: routeData?.dayName,
          );
        },
      ),
      StatefulShellRoute(
        builder: (context, state, navigationShell) {
          return navigationShell;
        },
        navigatorContainerBuilder: (context, navigationShell, children) {
          return HomeShell(
            navigationShell: navigationShell,
            analytics: analytics,
            children: children,
          );
        },
        branches: [
          StatefulShellBranch(
            preload: true,
            routes: [
              GoRoute(
                name: AppRoutes.hoyName,
                path: AppRoutes.hoy,
                builder: (context, state) => const HoyPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            preload: true,
            routes: [
              GoRoute(
                name: AppRoutes.jornadasName,
                path: AppRoutes.jornadas,
                builder: (context, state) => const JornadasPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            preload: true,
            routes: [
              GoRoute(
                name: AppRoutes.planningName,
                path: AppRoutes.planning,
                builder: (context, state) => const PlanningPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            preload: true,
            routes: [
              GoRoute(
                name: AppRoutes.moreName,
                path: AppRoutes.more,
                builder: (context, state) => const MorePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _RouterRefreshListenable extends ChangeNotifier {
  _RouterRefreshListenable(Ref ref) {
    _subscription = ref.listen<SyncState>(
      syncControllerProvider,
      (previous, next) => notifyListeners(),
    );
  }

  late final ProviderSubscription<SyncState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
