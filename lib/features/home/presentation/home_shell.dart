import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/app_analytics.dart';
import '../../../core/routing/app_routes.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.navigationShell,
    required this.children,
    required this.analytics,
  });

  final StatefulNavigationShell navigationShell;
  final List<Widget> children;
  final AppAnalytics? analytics;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _tabletShortestSide = 600.0;
  static const _screenNames = <String>['today', 'days', 'planning', 'more'];

  @override
  void initState() {
    super.initState();
    _trackCurrentScreen();
  }

  @override
  void didUpdateWidget(covariant HomeShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationShell.currentIndex !=
        widget.navigationShell.currentIndex) {
      _trackCurrentScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final backgroundTop = isDark
        ? colorScheme.surface
        : colorScheme.surface.withValues(alpha: 0.96);
    final backgroundBottom = isDark
        ? colorScheme.surfaceContainerLowest
        : colorScheme.secondary.withValues(alpha: 0.08);
    final navigationBackground =
        theme.navigationBarTheme.backgroundColor ?? colorScheme.surface;
    final railIndicatorColor = isDark
        ? colorScheme.primary.withValues(alpha: 0.18)
        : colorScheme.secondary.withValues(alpha: 0.78);

    return LayoutBuilder(
      builder: (context, constraints) {
        final useTabletLayout =
            MediaQuery.sizeOf(context).shortestSide >= _tabletShortestSide;

        return Scaffold(
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [backgroundTop, backgroundBottom],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: useTabletLayout
                ? SafeArea(
                    child: Row(
                      children: [
                        ColoredBox(
                          color: navigationBackground.withValues(
                            alpha: isDark ? 0.72 : 0.9,
                          ),
                          child: NavigationRail(
                            selectedIndex: widget.navigationShell.currentIndex,
                            onDestinationSelected: _selectTab,
                            labelType: NavigationRailLabelType.all,
                            useIndicator: true,
                            indicatorColor: railIndicatorColor,
                            groupAlignment: -1,
                            destinations: const [
                              NavigationRailDestination(
                                icon: Icon(Icons.wb_sunny_outlined),
                                selectedIcon: Icon(Icons.wb_sunny_rounded),
                                label: Text('Hoy'),
                              ),
                              NavigationRailDestination(
                                icon: Icon(Icons.calendar_view_week_outlined),
                                selectedIcon: Icon(
                                  Icons.calendar_view_week_rounded,
                                ),
                                label: Text('Jornadas'),
                              ),
                              NavigationRailDestination(
                                icon: Icon(Icons.route_outlined),
                                selectedIcon: Icon(Icons.route_rounded),
                                label: Text('Mi Planning'),
                              ),
                              NavigationRailDestination(
                                icon: Icon(Icons.more_horiz_outlined),
                                selectedIcon: Icon(Icons.more_horiz_rounded),
                                label: Text('Más'),
                              ),
                            ],
                          ),
                        ),
                        VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.4,
                          ),
                        ),
                        Expanded(
                          child: _AnimatedBranchContainer(
                            currentIndex: widget.navigationShell.currentIndex,
                            children: widget.children,
                          ),
                        ),
                      ],
                    ),
                  )
                : _AnimatedBranchContainer(
                    currentIndex: widget.navigationShell.currentIndex,
                    children: widget.children,
                  ),
          ),
          bottomNavigationBar: useTabletLayout
              ? null
              : DecoratedBox(
                  decoration: BoxDecoration(color: navigationBackground),
                  child: NavigationBar(
                    selectedIndex: widget.navigationShell.currentIndex,
                    onDestinationSelected: _selectTab,
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.wb_sunny_outlined),
                        selectedIcon: Icon(Icons.wb_sunny_rounded),
                        label: 'Hoy',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.calendar_view_week_outlined),
                        selectedIcon: Icon(Icons.calendar_view_week_rounded),
                        label: 'Jornadas',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.route_outlined),
                        selectedIcon: Icon(Icons.route_rounded),
                        label: 'Mi Planning',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.more_horiz_outlined),
                        selectedIcon: Icon(Icons.more_horiz_rounded),
                        label: 'Más',
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  void _selectTab(int index) {
    if (index == widget.navigationShell.currentIndex) {
      return;
    }

    final tab = AppTab.values[index];
    widget.navigationShell.goBranch(tab.branchIndex, initialLocation: false);
    widget.analytics?.track(
      'tab_selected',
      parameters: <String, Object>{'tab': _screenNames[index]},
    );
  }

  void _trackCurrentScreen() {
    final analytics = widget.analytics;
    if (analytics == null) {
      return;
    }
    analytics.trackScreen(_screenNames[widget.navigationShell.currentIndex]);
  }
}

class _AnimatedBranchContainer extends StatelessWidget {
  const _AnimatedBranchContainer({
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var index = 0; index < children.length; index++)
          Offstage(
            offstage: index != currentIndex,
            child: TickerMode(
              enabled: index == currentIndex,
              child: index == currentIndex
                  ? TweenAnimationBuilder<double>(
                      key: ValueKey('branch-$currentIndex'),
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 140),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(opacity: value, child: child);
                      },
                      child: children[index],
                    )
                  : children[index],
            ),
          ),
      ],
    );
  }
}
