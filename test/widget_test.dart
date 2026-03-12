import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:larevira_app_v2/core/models/day_index_item.dart';
import 'package:larevira_app_v2/core/routing/app_routes.dart';
import 'package:larevira_app_v2/features/home/presentation/home_shell.dart';

void main() {
  testWidgets('go helpers navigate across named tab routes', (
    WidgetTester tester,
  ) async {
    final router = _buildTestRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Screen: Hoy'), findsOneWidget);

    await tester.tap(find.byKey(const Key('go-more')));
    await tester.pumpAndSettle();

    expect(find.text('Screen: Mas'), findsOneWidget);

    await tester.tap(find.byKey(const Key('go-jornadas')));
    await tester.pumpAndSettle();

    expect(find.text('Screen: Jornadas'), findsOneWidget);
  });

  testWidgets('push helper opens the named day detail route', (
    WidgetTester tester,
  ) async {
    final router = _buildTestRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open-day-detail')));
    await tester.pumpAndSettle();

    expect(find.text('Detail slug: domingo-ramos'), findsOneWidget);
    expect(find.text('Detail item: Domingo de Ramos'), findsOneWidget);
  });

  testWidgets('stateful shell keeps each tab stack when switching branches', (
    WidgetTester tester,
  ) async {
    final router = _buildShellTestRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Screen: Jornadas'), findsOneWidget);

    await tester.tap(find.byKey(const Key('open-shell-detail')));
    await tester.pumpAndSettle();

    expect(find.text('Shell detail slug: domingo-ramos'), findsOneWidget);

    await tester.tap(find.text('Más'));
    await tester.pumpAndSettle();

    expect(find.text('Screen: Mas shell'), findsOneWidget);

    await tester.tap(find.text('Jornadas'));
    await tester.pumpAndSettle();

    expect(find.text('Shell detail slug: domingo-ramos'), findsOneWidget);
  });
}

GoRouter _buildTestRouter() {
  return GoRouter(
    initialLocation: AppRoutes.hoy,
    routes: [
      GoRoute(
        name: AppRoutes.hoyName,
        path: AppRoutes.hoy,
        builder: (context, state) => const _TabScreen(label: 'Hoy'),
      ),
      GoRoute(
        name: AppRoutes.jornadasName,
        path: AppRoutes.jornadas,
        builder: (context, state) => const _TabScreen(label: 'Jornadas'),
        routes: [
          GoRoute(
            name: AppRoutes.dayDetailName,
            path: 'day/:slug',
            builder: (context, state) {
              final item = state.extra as DayIndexItem?;
              final slug = state.pathParameters['slug'] ?? '';

              return _DetailScreen(
                slug: slug,
                itemName: item?.name ?? 'missing',
              );
            },
          ),
        ],
      ),
      GoRoute(
        name: AppRoutes.planningName,
        path: AppRoutes.planning,
        builder: (context, state) => const _TabScreen(label: 'Planning'),
      ),
      GoRoute(
        name: AppRoutes.moreName,
        path: AppRoutes.more,
        builder: (context, state) => const _TabScreen(label: 'Mas'),
      ),
    ],
  );
}

GoRouter _buildShellTestRouter() {
  return GoRouter(
    initialLocation: AppRoutes.jornadas,
    routes: [
      StatefulShellRoute(
        builder: (context, state, navigationShell) {
          return navigationShell;
        },
        navigatorContainerBuilder: (context, navigationShell, children) {
          return HomeShell(
            navigationShell: navigationShell,
            analytics: null,
            children: children,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.hoyName,
                path: AppRoutes.hoy,
                builder: (context, state) =>
                    const _ShellTabScreen(label: 'Hoy shell'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.jornadasName,
                path: AppRoutes.jornadas,
                builder: (context, state) => const _ShellJornadasScreen(),
                routes: [
                  GoRoute(
                    name: AppRoutes.dayDetailName,
                    path: 'day/:slug',
                    builder: (context, state) {
                      final slug = state.pathParameters['slug'] ?? '';

                      return _ShellDetailScreen(slug: slug);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.planningName,
                path: AppRoutes.planning,
                builder: (context, state) =>
                    const _ShellTabScreen(label: 'Planning shell'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.moreName,
                path: AppRoutes.more,
                builder: (context, state) =>
                    const _ShellTabScreen(label: 'Mas shell'),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _TabScreen extends StatelessWidget {
  const _TabScreen({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Screen: $label'),
          TextButton(
            key: const Key('go-more'),
            onPressed: context.goToMore,
            child: const Text('More'),
          ),
          TextButton(
            key: const Key('go-jornadas'),
            onPressed: context.goToJornadas,
            child: const Text('Jornadas'),
          ),
          TextButton(
            key: const Key('open-day-detail'),
            onPressed: () {
              context.pushDayDetail(
                const DayIndexItem(
                  slug: 'domingo-ramos',
                  name: 'Domingo de Ramos',
                  startsAt: null,
                  liturgicalDate: null,
                  processionEventsCount: 8,
                ),
              );
            },
            child: const Text('Detail'),
          ),
        ],
      ),
    );
  }
}

class _DetailScreen extends StatelessWidget {
  const _DetailScreen({
    required this.slug,
    required this.itemName,
  });

  final String slug;
  final String itemName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Detail slug: $slug'),
          Text('Detail item: $itemName'),
        ],
      ),
    );
  }
}

class _ShellTabScreen extends StatelessWidget {
  const _ShellTabScreen({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Screen: $label'),
      ),
    );
  }
}

class _ShellJornadasScreen extends StatelessWidget {
  const _ShellJornadasScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Screen: Jornadas'),
          TextButton(
            key: const Key('open-shell-detail'),
            onPressed: () {
              context.pushDayDetail(
                const DayIndexItem(
                  slug: 'domingo-ramos',
                  name: 'Domingo de Ramos',
                  startsAt: null,
                  liturgicalDate: null,
                  processionEventsCount: 8,
                ),
              );
            },
            child: const Text('Open shell detail'),
          ),
        ],
      ),
    );
  }
}

class _ShellDetailScreen extends StatelessWidget {
  const _ShellDetailScreen({required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Shell detail slug: $slug'),
      ),
    );
  }
}
