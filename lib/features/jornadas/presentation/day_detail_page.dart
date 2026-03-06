import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../core/config/app_instance_controller.dart';
import '../../../core/config/debug_flags.dart';
import '../../../core/maps/mapbox_map_helpers.dart';
import '../../../core/models/day_detail.dart';
import '../../../core/models/day_index_item.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_page_surfaces.dart';
import '../../../core/time/test_clock_controller.dart';
import '../../../core/widgets/adaptive_app_bar_title.dart';
import '../../../core/widgets/sliver_scroll_state_mixin.dart';
import '../application/day_detail_controller.dart';
import '../application/edition_official_route_provider.dart';
import 'schedule_point_map_page.dart';

class DayDetailPage extends ConsumerStatefulWidget {
  const DayDetailPage({super.key, required this.slug, this.item});

  final String slug;
  final DayIndexItem? item;

  @override
  ConsumerState<DayDetailPage> createState() => _DayDetailPageState();
}

class _DayDetailPageState extends ConsumerState<DayDetailPage>
    with SliverScrollStateMixin<DayDetailPage> {
  static const _tabletShortestSide = 600.0;
  int _currentSection = 0;
  _ScheduleViewMode _scheduleViewMode = _ScheduleViewMode.cards;
  DateTime? _selectedScheduleTime;
  String? _selectedBrotherhoodSlug;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final appInstance = ref.watch(appInstanceProvider);
    final effectiveSlug = widget.item?.slug ?? widget.slug;
    final detailAsync = ref.watch(dayDetailProvider(effectiveSlug));
    final editionOfficialRoute = ref
        .watch(editionOfficialRouteProvider)
        .asData
        ?.value;
    final testClock = ref.watch(testClockProvider);
    final detail = detailAsync.asData?.value;
    final pageTitle = widget.item?.name ?? detail?.name ?? 'Jornada';
    final appBarBackground = AppPageSurfaces.sliverAppBarBackground(brightness);
    final isTablet =
        MediaQuery.sizeOf(context).shortestSide >= _tabletShortestSide;
    final scheduleEntries = detail == null
        ? const <_ScheduledEventEntry>[]
        : _buildScheduleEntries(
            detail.processionEvents,
            dayStartsAt: widget.item?.startsAt,
          );
    final effectiveSelectedScheduleTime = _resolveSelectedScheduleTime(
      scheduleEntries,
      _selectedScheduleTime,
      referenceTime: testClock.enabled ? testClock.currentTime : DateTime.now(),
    );
    final hasFloatingHourSelectorSlot =
        (_currentSection == 0 || _currentSection == 1) &&
        scheduleEntries.isNotEmpty;
    final showsFloatingHourSelector = hasFloatingHourSelectorSlot;
    final lockParentScrollForBrotherhoodSplit =
        isTablet && _currentSection == 2;
    final sectionPadding = _currentSection == 1
        ? EdgeInsets.zero
        : EdgeInsets.fromLTRB(
            16,
            8,
            16,
            hasFloatingHourSelectorSlot ? 126 : 24,
          );

    final content = DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppPageSurfaces.jornadasBackground(brightness),
      ),
      child: NotificationListener<ScrollNotification>(
        onNotification: handleRootScrollNotification,
        child: Stack(
          children: [
            CustomScrollView(
              physics: lockParentScrollForBrotherhoodSplit
                  ? const NeverScrollableScrollPhysics()
                  : null,
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: hasScrolled
                      ? appBarBackground
                      : Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  scrolledUnderElevation: 0,
                  forceMaterialTransparency: !hasScrolled,
                  title: AdaptiveAppBarTitle(pageTitle),
                  actions: const [SizedBox(width: kToolbarHeight)],
                ),
                SliverPadding(
                  padding: sectionPadding,
                  sliver: SliverList.list(
                    children: [
                      detailAsync.when(
                        data: (detail) => TweenAnimationBuilder<double>(
                          key: ValueKey(_currentSection),
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 140),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Opacity(opacity: value, child: child);
                          },
                          child: _SectionContent(
                            currentSection: _currentSection,
                            detail: _applyEditionOfficialRoute(
                              detail,
                              editionOfficialRoute,
                            ),
                            baseApiUrl: appInstance.baseApiUrl,
                            selectedBrotherhoodSlug: _selectedBrotherhoodSlug,
                            scheduleEntries: scheduleEntries,
                            scheduleViewMode: _scheduleViewMode,
                            selectedScheduleTime: effectiveSelectedScheduleTime,
                            useBottomNavigation: !isTablet,
                            onSelectedScheduleTimeChanged: (value) {
                              setState(() {
                                _selectedScheduleTime =
                                    _clampScheduleTimeToEntries(
                                      scheduleEntries,
                                      value,
                                    );
                              });
                            },
                            onSectionRequested: (index) {
                              setState(() {
                                _currentSection = index;
                              });
                            },
                            onBrotherhoodSelected: (slug) {
                              setState(() {
                                _selectedBrotherhoodSlug = slug;
                              });
                            },
                            onScheduleViewModeChanged: (value) {
                              setState(() {
                                _scheduleViewMode = value;
                              });
                            },
                          ),
                        ),
                        loading: () => const _LoadingState(),
                        error: (error, stackTrace) => _ErrorState(
                          message: error.toString(),
                          onRetry: () =>
                              ref.invalidate(dayDetailProvider(effectiveSlug)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasFloatingHourSelectorSlot)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: SafeArea(
                  top: false,
                  child: _FloatingTimeSelector(
                    selectedTime: effectiveSelectedScheduleTime!,
                    visible: showsFloatingHourSelector,
                    onChanged: (value) {
                      setState(() {
                        _selectedScheduleTime = _clampScheduleTimeToEntries(
                          scheduleEntries,
                          value,
                        );
                      });
                    },
                    onResetToNow: () {
                      final now = testClock.enabled
                          ? testClock.currentTime
                          : DateTime.now();
                      setState(() {
                        _selectedScheduleTime = _clampScheduleTimeToEntries(
                          scheduleEntries,
                          _roundToNearestQuarterHour(
                            _anchorReferenceTimeToScheduleDay(
                              scheduleEntries,
                              now,
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return Scaffold(
      bottomNavigationBar: isTablet
          ? null
          : NavigationBar(
              selectedIndex: _currentSection,
              onDestinationSelected: (index) {
                setState(() {
                  _currentSection = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.schedule_outlined),
                  selectedIcon: Icon(Icons.schedule_rounded),
                  label: 'Horario',
                ),
                NavigationDestination(
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map_rounded),
                  label: 'Mapa',
                ),
                NavigationDestination(
                  icon: Icon(Icons.groups_outlined),
                  selectedIcon: Icon(Icons.groups_rounded),
                  label: 'Hermandades',
                ),
                NavigationDestination(
                  icon: Icon(Icons.route_outlined),
                  selectedIcon: Icon(Icons.route_rounded),
                  label: 'Plan',
                ),
              ],
            ),
      body: isTablet
          ? SafeArea(
              child: Row(
                children: [
                  NavigationRail(
                    selectedIndex: _currentSection,
                    onDestinationSelected: (index) {
                      setState(() {
                        _currentSection = index;
                      });
                    },
                    labelType: NavigationRailLabelType.all,
                    groupAlignment: -1,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.schedule_outlined),
                        selectedIcon: Icon(Icons.schedule_rounded),
                        label: Text('Horario'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.map_outlined),
                        selectedIcon: Icon(Icons.map_rounded),
                        label: Text('Mapa'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.groups_outlined),
                        selectedIcon: Icon(Icons.groups_rounded),
                        label: Text('Hermandades'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.route_outlined),
                        selectedIcon: Icon(Icons.route_rounded),
                        label: Text('Plan'),
                      ),
                    ],
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.4,
                    ),
                  ),
                  Expanded(child: content),
                ],
              ),
            )
          : content,
    );
  }
}

class _SectionContent extends StatelessWidget {
  const _SectionContent({
    required this.currentSection,
    required this.detail,
    required this.baseApiUrl,
    required this.selectedBrotherhoodSlug,
    required this.scheduleEntries,
    required this.scheduleViewMode,
    required this.selectedScheduleTime,
    required this.useBottomNavigation,
    required this.onSelectedScheduleTimeChanged,
    required this.onSectionRequested,
    required this.onBrotherhoodSelected,
    required this.onScheduleViewModeChanged,
  });

  final int currentSection;
  final DayDetail detail;
  final String baseApiUrl;
  final String? selectedBrotherhoodSlug;
  final List<_ScheduledEventEntry> scheduleEntries;
  final _ScheduleViewMode scheduleViewMode;
  final DateTime? selectedScheduleTime;
  final bool useBottomNavigation;
  final ValueChanged<DateTime> onSelectedScheduleTimeChanged;
  final ValueChanged<int> onSectionRequested;
  final ValueChanged<String> onBrotherhoodSelected;
  final ValueChanged<_ScheduleViewMode> onScheduleViewModeChanged;

  @override
  Widget build(BuildContext context) {
    switch (currentSection) {
      case 0:
        return _ScheduleSection(
          entries: scheduleEntries,
          viewMode: scheduleViewMode,
          selectedTime: selectedScheduleTime,
          onSelectedTimeChanged: onSelectedScheduleTimeChanged,
          onViewModeChanged: onScheduleViewModeChanged,
        );
      case 1:
        return _MapSection(
          detail: detail,
          entries: scheduleEntries,
          selectedTime: selectedScheduleTime,
          useBottomNavigation: useBottomNavigation,
        );
      case 2:
        return _BrotherhoodsSection(
          detail: detail,
          baseApiUrl: baseApiUrl,
          selectedBrotherhoodSlug: selectedBrotherhoodSlug,
          onSectionRequested: onSectionRequested,
          onBrotherhoodSelected: onBrotherhoodSelected,
        );
      case 3:
        return _PlanSection(detail: detail);
      default:
        return _BrotherhoodsSection(
          detail: detail,
          baseApiUrl: baseApiUrl,
          selectedBrotherhoodSlug: selectedBrotherhoodSlug,
          onSectionRequested: onSectionRequested,
          onBrotherhoodSelected: onBrotherhoodSelected,
        );
    }
  }
}

enum _ScheduleViewMode { cards, table }

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection({
    required this.entries,
    required this.viewMode,
    required this.selectedTime,
    required this.onSelectedTimeChanged,
    required this.onViewModeChanged,
  });

  final List<_ScheduledEventEntry> entries;
  final _ScheduleViewMode viewMode;
  final DateTime? selectedTime;
  final ValueChanged<DateTime> onSelectedTimeChanged;
  final ValueChanged<_ScheduleViewMode> onViewModeChanged;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const _InfoCard(
        title: 'Sin horario disponible',
        message:
            'Todavía no hay tramos horarios sincronizados para esta jornada.',
      );
    }

    final visibleEntries = selectedTime == null
        ? entries
        : _entriesForMoment(entries, selectedTime!);
    final allSlots = _scheduleSlotsFor(entries);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: SegmentedButton<_ScheduleViewMode>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: _ScheduleViewMode.cards,
                icon: Icon(Icons.view_agenda_outlined),
                label: Text('Cards'),
              ),
              ButtonSegment(
                value: _ScheduleViewMode.table,
                icon: Icon(Icons.table_chart_outlined),
                label: Text('Tabla'),
              ),
            ],
            selected: {viewMode},
            onSelectionChanged: (selection) {
              onViewModeChanged(selection.first);
            },
          ),
        ),
        const SizedBox(height: 12),
        if (viewMode == _ScheduleViewMode.cards)
          _ScheduleCardsView(
            entries: visibleEntries,
            selectedTime: selectedTime!,
            minSelectableTime: _scheduleMinTime(entries),
            maxSelectableTime: _scheduleMaxTime(entries),
            onSelectedTimeChanged: onSelectedTimeChanged,
          )
        else
          _ScheduleTableView(
            entries: entries,
            allSlots: allSlots,
            selectedTime: selectedTime,
          ),
      ],
    );
  }
}

class _ScheduleCardsView extends StatelessWidget {
  const _ScheduleCardsView({
    required this.entries,
    required this.selectedTime,
    required this.minSelectableTime,
    required this.maxSelectableTime,
    required this.onSelectedTimeChanged,
  });

  final List<_ScheduledEventEntry> entries;
  final DateTime selectedTime;
  final DateTime minSelectableTime;
  final DateTime maxSelectableTime;
  final ValueChanged<DateTime> onSelectedTimeChanged;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const _InfoCard(
        title: 'Sin pasos en esta hora',
        message: 'Prueba otra hora desde el selector inferior.',
      );
    }

    return Column(
      children: [
        for (final entry in entries) ...[
          _ScheduleCard(
            entry: entry,
            selectedTime: selectedTime,
            minSelectableTime: minSelectableTime,
            maxSelectableTime: maxSelectableTime,
            onSelectedTimeChanged: onSelectedTimeChanged,
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ScheduleTableView extends StatefulWidget {
  const _ScheduleTableView({
    required this.entries,
    required this.allSlots,
    required this.selectedTime,
  });

  final List<_ScheduledEventEntry> entries;
  final List<DateTime> allSlots;
  final DateTime? selectedTime;

  @override
  State<_ScheduleTableView> createState() => _ScheduleTableViewState();
}

class _ScheduleTableViewState extends State<_ScheduleTableView> {
  static const _cellWidth = 110.0;
  final ScrollController _horizontalController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _moveToSelectedSlot(animated: false);
    });
  }

  @override
  void didUpdateWidget(covariant _ScheduleTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTime != oldWidget.selectedTime ||
        widget.allSlots.length != oldWidget.allSlots.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _moveToSelectedSlot(
          animated: widget.selectedTime != oldWidget.selectedTime,
        );
      });
    }
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  void _moveToSelectedSlot({required bool animated}) {
    if (!_horizontalController.hasClients || widget.selectedTime == null) {
      return;
    }

    final selectedSlot = _slotStartFor(widget.selectedTime!);
    final slotIndex = widget.allSlots.indexWhere(
      (slot) => _isSameSlot(slot, selectedSlot),
    );
    if (slotIndex < 0) {
      return;
    }

    final targetOffset = slotIndex * _cellWidth;
    final clampedOffset = targetOffset.clamp(
      0.0,
      _horizontalController.position.maxScrollExtent,
    );
    if (animated) {
      _horizontalController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    _horizontalController.jumpTo(clampedOffset);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final groupedEntries = _groupEntriesByBrotherhood(
      widget.entries,
    ).values.toList(growable: false);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Builder(
          builder: (context) {
            final baseStyle =
                theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 14);
            final textDirection = Directionality.of(context);
            double maxNameWidth = 0;
            for (final brotherhoodEntries in groupedEntries) {
              final painter = TextPainter(
                text: TextSpan(
                  text: brotherhoodEntries.first.event.brotherhoodName,
                  style: baseStyle,
                ),
                textDirection: textDirection,
                maxLines: 1,
              )..layout();
              if (painter.width > maxNameWidth) {
                maxNameWidth = painter.width;
              }
            }

            final leftWidth = maxNameWidth + 32;
            const headerHeight = 44.0;
            const rowHeight = 54.0;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: leftWidth,
                  child: Column(
                    children: [
                      Container(
                        height: headerHeight,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Hermandad',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      for (final brotherhoodEntries in groupedEntries)
                        Container(
                          height: rowHeight,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            brotherhoodEntries.first.event.brotherhoodName,
                            style: baseStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _horizontalController,
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            for (final slot in widget.allSlots)
                              Container(
                                width: _cellWidth,
                                height: headerHeight,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                color:
                                    widget.selectedTime != null &&
                                        _isSameSlot(
                                          slot,
                                          _slotStartFor(widget.selectedTime!),
                                        )
                                    ? colorScheme.primary.withValues(
                                        alpha: 0.08,
                                      )
                                    : null,
                                child: Text(
                                  _formatSlotLabel(slot),
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color:
                                        widget.selectedTime != null &&
                                            _isSameSlot(
                                              slot,
                                              _slotStartFor(
                                                widget.selectedTime!,
                                              ),
                                            )
                                        ? colorScheme.primary
                                        : null,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Divider(height: 1),
                        for (final brotherhoodEntries in groupedEntries)
                          Row(
                            children: [
                              for (final slot in widget.allSlots)
                                Builder(
                                  builder: (context) {
                                    final entry = _findEntryForSlot(
                                      brotherhoodEntries,
                                      slot,
                                    );
                                    final pointName = entry == null
                                        ? '-'
                                        : entry.pointName.trim().isEmpty
                                        ? 'Punto'
                                        : entry.pointName.trim();
                                    final accent =
                                        _parseColor(
                                          brotherhoodEntries
                                              .first
                                              .event
                                              .brotherhoodColorHex,
                                        ) ??
                                        colorScheme.primary;
                                    final isSelected =
                                        widget.selectedTime != null &&
                                        _isSameSlot(
                                          slot,
                                          _slotStartFor(widget.selectedTime!),
                                        );

                                    return Container(
                                      width: _cellWidth,
                                      height: rowHeight,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: pointName == '-'
                                            ? null
                                            : isSelected
                                            ? accent.withValues(alpha: 0.10)
                                            : null,
                                        border: pointName == '-' || !isSelected
                                            ? null
                                            : Border.all(
                                                color: accent.withValues(
                                                  alpha: 0.35,
                                                ),
                                              ),
                                      ),
                                      child: Text(
                                        pointName,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: pointName == '-'
                                            ? theme.textTheme.bodyMedium
                                            : theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MapSection extends StatefulWidget {
  const _MapSection({
    required this.detail,
    required this.entries,
    required this.selectedTime,
    required this.useBottomNavigation,
  });

  final DayDetail detail;
  final List<_ScheduledEventEntry> entries;
  final DateTime? selectedTime;
  final bool useBottomNavigation;

  @override
  State<_MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends State<_MapSection> {
  MapboxMap? _map;
  PolylineAnnotationManager? _brotherhoodRouteManager;
  CircleAnnotationManager? _markerManager;
  int _syncGeneration = 0;
  bool _showLegend = false;
  static const Color _officialCourseFallbackColor = Color(0xFFFFA500);

  List<MapPoint> _routeMapPoints(DayProcessionEvent event) {
    return event.routePoints
        .where((point) => point.hasLocation)
        .map(
          (point) =>
              MapPoint(latitude: point.latitude!, longitude: point.longitude!),
        )
        .toList(growable: false);
  }

  bool _isEventVisibleAt(DayProcessionEvent event, DateTime selectedTime) {
    final timedSchedule =
        event.schedulePoints
            .where((point) => point.hasLocation && point.plannedAt != null)
            .toList(growable: false)
          ..sort((a, b) => a.plannedAt!.compareTo(b.plannedAt!));

    if (timedSchedule.isEmpty) {
      return true;
    }

    final startsAt = timedSchedule.first.plannedAt!;
    final endsAt = timedSchedule.last.plannedAt!.add(
      Duration(minutes: (event.passDurationMinutes ?? 0).clamp(0, 240)),
    );

    return !selectedTime.isBefore(startsAt) && !selectedTime.isAfter(endsAt);
  }

  List<_VisibleRoute> _visibleRoutes(DateTime selectedTime) {
    return widget.detail.processionEvents
        .where((event) => _isEventVisibleAt(event, selectedTime))
        .map(
          (event) => _VisibleRoute(
            color:
                _parseColor(event.brotherhoodColorHex) ??
                Theme.of(context).colorScheme.primary,
            points: _routeMapPoints(event),
          ),
        )
        .where((route) => route.points.length >= 2)
        .toList(growable: false);
  }

  _VisibleRoute? _officialCourseRoute() {
    final points = widget.detail.officialRoutePoints
        .where((point) => point.hasLocation)
        .map(
          (point) =>
              MapPoint(latitude: point.latitude!, longitude: point.longitude!),
        )
        .toList(growable: false);
    if (points.length < 2) {
      return null;
    }

    return _VisibleRoute(
      color:
          (_parseArgbColor(widget.detail.officialRouteArgb) ??
                  _officialCourseFallbackColor)
              .withValues(alpha: 0.9),
      points: points,
    );
  }

  List<_ActiveTrack> _activeTracksFor(DateTime selectedTime) {
    final result = <_ActiveTrack>[];

    for (final event in widget.detail.processionEvents) {
      if (!_isEventVisibleAt(event, selectedTime)) {
        continue;
      }

      final route = _routeMapPoints(event);
      if (route.length < 2) {
        continue;
      }

      final timedSchedule =
          event.schedulePoints
              .where((point) => point.hasLocation && point.plannedAt != null)
              .toList(growable: false)
            ..sort((a, b) => a.plannedAt!.compareTo(b.plannedAt!));
      if (timedSchedule.isEmpty) {
        continue;
      }

      final timedRoutePoints = <_TimedRoutePoint>[];
      var searchFrom = 0;
      for (final point in timedSchedule) {
        final routeIndex = _nearestRouteIndexFrom(
          route,
          MapPoint(latitude: point.latitude!, longitude: point.longitude!),
          searchFrom,
        );
        searchFrom = routeIndex;
        timedRoutePoints.add(
          _TimedRoutePoint(
            time: point.plannedAt!,
            routeIndex: routeIndex.toDouble(),
          ),
        );
      }

      final headIndex = _routeIndexAtTime(timedRoutePoints, selectedTime);
      if (headIndex == null) {
        continue;
      }

      final passMinutes = (event.passDurationMinutes ?? 0).clamp(0, 240);
      final routeEnd = timedRoutePoints.last.time;
      if (passMinutes > 0 &&
          selectedTime.isAfter(routeEnd.add(Duration(minutes: passMinutes)))) {
        continue;
      }

      final tailTime = selectedTime.subtract(Duration(minutes: passMinutes));
      final tailIndex = passMinutes <= 0
          ? headIndex
          : (_routeIndexAtTime(timedRoutePoints, tailTime) ??
                timedRoutePoints.first.routeIndex);

      final segment = _sliceRoute(route, tailIndex, headIndex);
      if (segment.length < 2) {
        continue;
      }

      result.add(
        _ActiveTrack(
          color:
              _parseColor(event.brotherhoodColorHex) ??
              Theme.of(context).colorScheme.primary,
          points: segment,
          head: _pointAtIndex(route, headIndex),
        ),
      );
    }

    return result;
  }

  List<MapPoint> get _currentMarkerMapPoints {
    final selectedTime = widget.selectedTime;
    if (selectedTime == null) {
      return const [];
    }
    return _activeTracksFor(
      selectedTime,
    ).map((track) => track.head).toList(growable: false);
  }

  List<MapPoint> get _focusPoints {
    final selectedTime = widget.selectedTime;
    if (selectedTime == null) {
      return const [];
    }

    final activeTracks = _activeTracksFor(selectedTime);
    final activePoints = activeTracks.expand((track) => track.points).toList();
    if (activePoints.isNotEmpty) {
      return activePoints;
    }

    final visibleRoutes = _visibleRoutes(selectedTime);
    final visiblePoints = visibleRoutes
        .expand((route) => route.points)
        .toList();
    final officialRoute = _officialCourseRoute();
    final fallback = [...visiblePoints, ...?officialRoute?.points];
    if (fallback.isNotEmpty) {
      return fallback;
    }

    return _allRoutePoints();
  }

  List<MapPoint> _allRoutePoints() {
    return widget.detail.processionEvents
        .expand((event) => event.routePoints)
        .where((point) => point.hasLocation)
        .map(
          (point) =>
              MapPoint(latitude: point.latitude!, longitude: point.longitude!),
        )
        .toList(growable: false);
  }

  List<_RouteLegendItem> get _legendItems {
    final items = <_RouteLegendItem>[];
    final officialRoute = _officialCourseRoute();
    if (officialRoute != null) {
      items.add(
        _RouteLegendItem(label: 'Carrera oficial', color: officialRoute.color),
      );
    }
    for (final event in widget.detail.processionEvents) {
      items.add(
        _RouteLegendItem(
          label: event.brotherhoodName,
          color:
              _parseColor(event.brotherhoodColorHex) ??
              Theme.of(context).colorScheme.primary,
        ),
      );
    }
    return items;
  }

  Future<void> _syncAnnotations() async {
    final syncGeneration = ++_syncGeneration;
    final brotherhoodRouteManager = _brotherhoodRouteManager;
    final markerManager = _markerManager;
    final selectedTime = widget.selectedTime;
    if (brotherhoodRouteManager == null ||
        markerManager == null ||
        selectedTime == null) {
      return;
    }

    try {
      await brotherhoodRouteManager.deleteAll();
      await markerManager.deleteAll();
      if (!mounted || syncGeneration != _syncGeneration) {
        return;
      }

      final visibleRoutes = _visibleRoutes(selectedTime);
      final officialRoute = _officialCourseRoute();
      final activeTracks = _activeTracksFor(selectedTime);

      for (final route in visibleRoutes) {
        await brotherhoodRouteManager.create(
          PolylineAnnotationOptions(
            geometry: LineString(
              coordinates: route.points
                  .map((point) => point.toPoint().coordinates)
                  .toList(growable: false),
            ),
            lineColor: route.color.withValues(alpha: 0.16).toARGB32(),
            lineWidth: 3,
          ),
        );
      }

      if (officialRoute != null) {
        await brotherhoodRouteManager.create(
          PolylineAnnotationOptions(
            geometry: LineString(
              coordinates: officialRoute.points
                  .map((point) => point.toPoint().coordinates)
                  .toList(growable: false),
            ),
            lineColor: officialRoute.color.withValues(alpha: 0.62).toARGB32(),
            lineWidth: 9,
          ),
        );
      }

      for (final track in activeTracks) {
        await brotherhoodRouteManager.create(
          PolylineAnnotationOptions(
            geometry: LineString(
              coordinates: track.points
                  .map((point) => point.toPoint().coordinates)
                  .toList(growable: false),
            ),
            lineColor: track.color.toARGB32(),
            lineWidth: 5,
          ),
        );
        await markerManager.create(
          CircleAnnotationOptions(
            geometry: track.head.toPoint(),
            circleColor: track.color.toARGB32(),
            circleRadius: 9,
            circleStrokeColor: Colors.white.toARGB32(),
            circleStrokeWidth: 2,
          ),
        );
      }
    } on PlatformException catch (error) {
      if (kDebugMode) {
        debugPrint('[day-map] annotation channel disconnected: $error');
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[day-map] annotation sync failed: $error');
      }
    }
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    try {
      _map = mapboxMap;
      _brotherhoodRouteManager = await mapboxMap.annotations
          .createPolylineAnnotationManager();
      _markerManager = await mapboxMap.annotations
          .createCircleAnnotationManager();
      if (!mounted) {
        return;
      }
      await _syncAnnotations();
    } on PlatformException catch (error) {
      if (kDebugMode) {
        debugPrint('[day-map] map creation failed: $error');
      }
    }
  }

  Future<void> _centerOnAll() async {
    await easeToPoints(_map, _focusPoints, fallbackZoom: 13.8);
  }

  Future<void> _centerOnCurrentPoints() async {
    final current = _currentMarkerMapPoints;
    if (current.isNotEmpty) {
      await easeToPoints(_map, current, fallbackZoom: 15.2);
      return;
    }

    await _centerOnAll();
  }

  @override
  void didUpdateWidget(covariant _MapSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.detail != widget.detail ||
        oldWidget.selectedTime != widget.selectedTime) {
      _syncAnnotations();
    }
  }

  @override
  void dispose() {
    _syncGeneration++;
    _brotherhoodRouteManager = null;
    _markerManager = null;
    _map = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTime = widget.selectedTime;
    if (selectedTime == null) {
      return const _InfoCard(
        title: 'Sin horario disponible',
        message: 'No hay horas disponibles para representar puntos en el mapa.',
      );
    }

    final activeTracks = _activeTracksFor(selectedTime);
    final hasGeometry = _focusPoints.isNotEmpty;

    if (kMapboxAccessToken.isEmpty) {
      return const _InfoCard(
        title: 'Mapa no configurado',
        message:
            'Falta MAPBOX_ACCESS_TOKEN. Ejecuta la app con --dart-define=MAPBOX_ACCESS_TOKEN=tu_token.',
      );
    }

    final media = MediaQuery.sizeOf(context);
    final insets = MediaQuery.paddingOf(context);
    final mapHeight =
        (media.height -
                insets.top -
                insets.bottom -
                kToolbarHeight -
                (widget.useBottomNavigation ? kBottomNavigationBarHeight : 0))
            .clamp(360.0, 1200.0);

    return SizedBox(
      height: mapHeight,
      child: Stack(
        children: [
          if (hasGeometry)
            MapWidget(
              key: const ValueKey('day-detail-map'),
              styleUri: mapboxStyleUriForBrightness(
                Theme.of(context).brightness,
              ),
              gestureRecognizers: kMapGestureRecognizers,
              cameraOptions: cameraForPoints(_focusPoints, fallbackZoom: 13.8),
              onMapCreated: _onMapCreated,
            )
          else
            const _InfoCard(
              title: 'Sin geometria de itinerarios',
              message: 'No hay coordenadas sincronizadas para esta jornada.',
            ),
          Positioned(
            left: 12,
            top: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () {
                    setState(() {
                      _showLegend = !_showLegend;
                    });
                  },
                  icon: Icon(
                    _showLegend
                        ? Icons.visibility_off_outlined
                        : Icons.palette_outlined,
                  ),
                  label: Text(
                    _showLegend ? 'Ocultar leyenda' : 'Mostrar leyenda',
                  ),
                ),
                if (_showLegend) ...[
                  const SizedBox(height: 8),
                  Builder(
                    builder: (context) {
                      final legendItems = _legendItems;
                      return Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 220),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (
                                    var i = 0;
                                    i < legendItems.length;
                                    i++
                                  ) ...[
                                    _RouteLegendChip(item: legendItems[i]),
                                    if (i < legendItems.length - 1)
                                      const SizedBox(height: 6),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'day-map-fit-all',
                  onPressed: _centerOnAll,
                  child: const Icon(Icons.center_focus_strong),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'day-map-fit-live',
                  onPressed: _centerOnCurrentPoints,
                  child: const Icon(Icons.my_location_rounded),
                ),
              ],
            ),
          ),
          if (activeTracks.isEmpty)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'No hay ninguna procesión en la calle.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  int _nearestRouteIndexFrom(
    List<MapPoint> route,
    MapPoint target,
    int startIndex,
  ) {
    var bestIndex = startIndex;
    var bestDistance = double.infinity;
    for (var i = startIndex; i < route.length; i++) {
      final latDiff = route[i].latitude - target.latitude;
      final lngDiff = route[i].longitude - target.longitude;
      final sqDistance = (latDiff * latDiff) + (lngDiff * lngDiff);
      if (sqDistance < bestDistance) {
        bestDistance = sqDistance;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  double? _routeIndexAtTime(List<_TimedRoutePoint> points, DateTime at) {
    if (points.isEmpty) {
      return null;
    }
    if (at.isBefore(points.first.time)) {
      return null;
    }
    if (!at.isBefore(points.last.time)) {
      return points.last.routeIndex.toDouble();
    }

    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      if (at.isBefore(a.time) || at.isAfter(b.time)) {
        continue;
      }

      final totalMs = b.time.difference(a.time).inMilliseconds;
      if (totalMs <= 0) {
        return b.routeIndex.toDouble();
      }
      final partMs = at.difference(a.time).inMilliseconds.clamp(0, totalMs);
      final ratio = partMs / totalMs;
      return a.routeIndex + ((b.routeIndex - a.routeIndex) * ratio);
    }

    return points.last.routeIndex.toDouble();
  }

  MapPoint _pointAtIndex(List<MapPoint> route, double index) {
    final lastIndex = route.length - 1;
    if (lastIndex <= 0) {
      return route.first;
    }

    final clamped = index.clamp(0, lastIndex.toDouble());
    final low = clamped.floor();
    final high = clamped.ceil();
    if (low == high) {
      return route[low];
    }

    final ratio = clamped - low;
    final start = route[low];
    final end = route[high];
    return MapPoint(
      latitude: start.latitude + ((end.latitude - start.latitude) * ratio),
      longitude: start.longitude + ((end.longitude - start.longitude) * ratio),
    );
  }

  List<MapPoint> _sliceRoute(List<MapPoint> route, double from, double to) {
    if (route.isEmpty) {
      return const [];
    }

    var start = from;
    var end = to;
    if (end < start) {
      final temp = start;
      start = end;
      end = temp;
    }

    final startPoint = _pointAtIndex(route, start);
    final endPoint = _pointAtIndex(route, end);
    final startFloor = start.floor();
    final endCeil = end.ceil();

    final points = <MapPoint>[startPoint];
    for (var i = startFloor + 1; i < endCeil; i++) {
      if (i >= 0 && i < route.length) {
        points.add(route[i]);
      }
    }
    points.add(endPoint);
    return points;
  }
}

class _RouteLegendItem {
  const _RouteLegendItem({required this.label, required this.color});

  final String label;
  final Color color;
}

class _RouteLegendChip extends StatelessWidget {
  const _RouteLegendChip({required this.item});

  final _RouteLegendItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 4,
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          item.label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _VisibleRoute {
  const _VisibleRoute({required this.color, required this.points});

  final Color color;
  final List<MapPoint> points;
}

class _ActiveTrack {
  const _ActiveTrack({
    required this.color,
    required this.points,
    required this.head,
  });

  final Color color;
  final List<MapPoint> points;
  final MapPoint head;
}

class _TimedRoutePoint {
  const _TimedRoutePoint({required this.time, required this.routeIndex});

  final DateTime time;
  final double routeIndex;
}

class _BrotherhoodsSection extends StatelessWidget {
  const _BrotherhoodsSection({
    required this.detail,
    required this.baseApiUrl,
    required this.selectedBrotherhoodSlug,
    required this.onSectionRequested,
    required this.onBrotherhoodSelected,
  });

  final DayDetail detail;
  final String baseApiUrl;
  final String? selectedBrotherhoodSlug;
  final ValueChanged<int> onSectionRequested;
  final ValueChanged<String> onBrotherhoodSelected;

  @override
  Widget build(BuildContext context) {
    final detail = this.detail;
    if (detail.processionEvents.isEmpty) {
      return const _InfoCard(
        title: 'Sin hermandades',
        message: 'No hay eventos devueltos para esta jornada.',
      );
    }

    final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    if (!isTablet) {
      return Column(
        children: [
          for (final event in detail.processionEvents) ...[
            _ProcessionEventCard(
              event: event,
              onTap: () async {
                onBrotherhoodSelected(event.brotherhoodSlug);
                final result = await context.pushBrotherhoodDetail<Object?>(
                  event,
                  dayName: detail.name,
                );
                if (result == null) {
                  return;
                }
                if (result is BrotherhoodDetailReturnData) {
                  onBrotherhoodSelected(result.brotherhoodSlug);
                  onSectionRequested(result.sectionIndex);
                  return;
                }
                if (result is int) {
                  onSectionRequested(result);
                }
              },
            ),
            const SizedBox(height: 12),
          ],
        ],
      );
    }

    final selectedSlug =
        selectedBrotherhoodSlug ??
        detail.processionEvents.first.brotherhoodSlug;
    final selectedEvent = detail.processionEvents.firstWhere(
      (event) => event.brotherhoodSlug == selectedSlug,
      orElse: () => detail.processionEvents.first,
    );
    final media = MediaQuery.sizeOf(context);
    final insets = MediaQuery.paddingOf(context);
    final isLandscape = media.width > media.height;
    final bottomAllowance = isLandscape ? 56.0 : 24.0;
    final panelHeight =
        (media.height -
                insets.top -
                insets.bottom -
                kToolbarHeight -
                bottomAllowance)
            .clamp(320.0, media.height);

    return SizedBox(
      height: panelHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListView.separated(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: detail.processionEvents.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final event = detail.processionEvents[index];
                  return _ProcessionEventCard(
                    event: event,
                    isSelected:
                        event.brotherhoodSlug == selectedEvent.brotherhoodSlug,
                    showOfficialNote: false,
                    onTap: () {
                      onBrotherhoodSelected(event.brotherhoodSlug);
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 8,
            child: _BrotherhoodDetailPanel(
              event: selectedEvent,
              dayName: detail.name,
              baseApiUrl: baseApiUrl,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrotherhoodDetailPanel extends StatelessWidget {
  const _BrotherhoodDetailPanel({
    required this.event,
    required this.dayName,
    required this.baseApiUrl,
  });

  final DayProcessionEvent event;
  final String dayName;
  final String baseApiUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent =
        _parseColor(event.brotherhoodColorHex) ?? colorScheme.primary;
    final headerLabel = (event.brotherhoodShortName?.trim().isNotEmpty ?? false)
        ? event.brotherhoodShortName!.trim()
        : event.brotherhoodName;
    final headerImageUrl = _resolvePanelImageUrl(
      event.brotherhoodHeaderImageUrl,
      baseApiUrl,
    );
    final shieldImageUrl = _resolvePanelImageUrl(
      event.brotherhoodShieldImageUrl,
      baseApiUrl,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            SizedBox(
              height: 170,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _BrotherhoodPanelHeaderBackground(
                    imageUrl: headerImageUrl,
                    accent: accent,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.12),
                          Colors.black.withValues(alpha: 0.58),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 12,
                    child: Row(
                      children: [
                        _BrotherhoodPanelShieldAvatar(
                          imageUrl: shieldImageUrl,
                          accent: accent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            headerLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: colorScheme.surface,
              child: const TabBar(
                tabs: [
                  Tab(text: 'Información'),
                  Tab(text: 'Itinerario'),
                  Tab(text: 'Mapa'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Text(
                          event.brotherhoodName,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _BrotherhoodPanelStatCard(
                              label: 'Duración',
                              value: event.passDurationMinutes == null
                                  ? '--'
                                  : '${event.passDurationMinutes} min',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _BrotherhoodPanelStatCard(
                              label: 'Hermanos',
                              value: event.brothersCount == null
                                  ? '--'
                                  : '${event.brothersCount}',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _BrotherhoodPanelStatCard(
                              label: 'Nazarenos',
                              value: event.nazarenesCount == null
                                  ? '--'
                                  : '${event.nazarenesCount}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(title: 'Estado', message: _statusLabel(event)),
                      const SizedBox(height: 12),
                      _InfoCard(
                        title: 'Identificador',
                        message: event.brotherhoodSlug.isEmpty
                            ? 'Sin slug disponible'
                            : event.brotherhoodSlug,
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        title: 'Color',
                        message: event.brotherhoodColorHex.isEmpty
                            ? 'Sin color definido'
                            : event.brotherhoodColorHex.toUpperCase(),
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(title: 'Jornada', message: dayName),
                      const SizedBox(height: 12),
                      _InfoCard(
                        title: 'Nota oficial',
                        message: event.officialNote.isEmpty
                            ? 'No hay nota oficial para esta hermandad en la jornada.'
                            : event.officialNote,
                      ),
                    ],
                  ),
                  _BrotherhoodPanelItineraryTab(event: event),
                  _BrotherhoodPanelMapTab(event: event),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrotherhoodPanelHeaderBackground extends StatelessWidget {
  const _BrotherhoodPanelHeaderBackground({
    required this.imageUrl,
    required this.accent,
  });

  final String? imageUrl;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    if (hasImage) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent.withValues(alpha: 0.8),
                  accent.withValues(alpha: 0.35),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          );
        },
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.8),
            accent.withValues(alpha: 0.35),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class _BrotherhoodPanelItineraryTab extends StatelessWidget {
  const _BrotherhoodPanelItineraryTab({required this.event});

  final DayProcessionEvent event;

  @override
  Widget build(BuildContext context) {
    final points = event.schedulePoints;
    if (points.isEmpty) {
      return ListView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: const [
          _InfoCard(
            title: 'Itinerario no disponible',
            message: 'No hay puntos de itinerario en esta jornada.',
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: points.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final point = points[index];
        return _InfoCard(
          title: '${index + 1}. ${point.name}',
          message: point.plannedAt == null
              ? 'Hora no disponible'
              : 'Hora prevista: ${_formatTimeLabel(point.plannedAt!)}',
        );
      },
    );
  }
}

class _BrotherhoodPanelShieldAvatar extends StatelessWidget {
  const _BrotherhoodPanelShieldAvatar({
    required this.imageUrl,
    required this.accent,
  });

  final String? imageUrl;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.75),
          width: 1.2,
        ),
        color: accent.withValues(alpha: 0.25),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.shield_rounded,
                color: Colors.white,
                size: 18,
              ),
            )
          : const Icon(Icons.shield_rounded, color: Colors.white, size: 18),
    );
  }
}

class _BrotherhoodPanelMapTab extends StatelessWidget {
  const _BrotherhoodPanelMapTab({required this.event});

  final DayProcessionEvent event;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: const [
        _InfoCard(
          title: 'Mapa',
          message: 'Vista de mapa específica de hermandad en preparación.',
        ),
      ],
    );
  }
}

class _BrotherhoodPanelStatCard extends StatelessWidget {
  const _BrotherhoodPanelStatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

String? _resolvePanelImageUrl(String? raw, String baseApiUrl) {
  if (raw == null || raw.trim().isEmpty) {
    return null;
  }
  final value = raw.trim();
  final uri = Uri.tryParse(value);
  if (uri != null && uri.hasScheme) {
    return value;
  }

  final base = Uri.tryParse(baseApiUrl);
  if (base == null) {
    return value;
  }

  final origin = Uri(
    scheme: base.scheme,
    host: base.host,
    port: base.hasPort ? base.port : null,
  );
  return origin.resolve(value).toString();
}

class _PlanSection extends StatelessWidget {
  const _PlanSection({required this.detail});

  final DayDetail detail;

  @override
  Widget build(BuildContext context) {
    return _PlaceholderSection(
      child: _InfoCard(
        title: 'Plan en construcción',
        message:
            'Desde aquí podrás seleccionar hermandades y construir tu recorrido para ${detail.name}.',
      ),
    );
  }
}

class _PlaceholderSection extends StatelessWidget {
  const _PlaceholderSection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.entry,
    required this.selectedTime,
    required this.minSelectableTime,
    required this.maxSelectableTime,
    required this.onSelectedTimeChanged,
  });

  final _ScheduledEventEntry entry;
  final DateTime selectedTime;
  final DateTime minSelectableTime;
  final DateTime maxSelectableTime;
  final ValueChanged<DateTime> onSelectedTimeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent =
        _parseColor(entry.event.brotherhoodColorHex) ?? colorScheme.primary;
    final statusChips = _statusChipsFor(entry.event.status);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? colorScheme.outlineVariant.withValues(alpha: 0.22)
              : AppColors.accentRose.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.0 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: entry.schedulePoint?.hasLocation == true
              ? () async {
                  final updatedTime = await Navigator.of(context)
                      .push<DateTime>(
                        MaterialPageRoute<DateTime>(
                          builder: (context) => SchedulePointMapPage(
                            title: entry.event.brotherhoodName,
                            colorHex: entry.event.brotherhoodColorHex,
                            event: entry.event,
                            initialSelectedTime: selectedTime,
                            minSelectableTime: minSelectableTime,
                            maxSelectableTime: maxSelectableTime,
                          ),
                        ),
                      );
                  if (updatedTime != null) {
                    onSelectedTimeChanged(updatedTime);
                  }
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 52,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.event.brotherhoodName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (statusChips.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                for (final chip in statusChips)
                                  _EventStatusChip(
                                    label: chip.label,
                                    foreground: chip.foreground,
                                    background: chip.background,
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        entry.pointName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EventStatusChip extends StatelessWidget {
  const _EventStatusChip({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}

class _FloatingTimeSelector extends StatelessWidget {
  const _FloatingTimeSelector({
    required this.selectedTime,
    required this.visible,
    required this.onChanged,
    required this.onResetToNow,
  });

  final DateTime selectedTime;
  final bool visible;
  final ValueChanged<DateTime> onChanged;
  final VoidCallback onResetToNow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return IgnorePointer(
      ignoring: !visible,
      child: Opacity(
        opacity: visible ? 1 : 0,
        child: Material(
          elevation: 8,
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width - 32,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Hora seleccionada',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTimeLabel(selectedTime),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _TimeShiftButton(
                        icon: Icons.fast_rewind_rounded,
                        onPressed: () => onChanged(
                          selectedTime.subtract(const Duration(minutes: 60)),
                        ),
                      ),
                      _TimeShiftButton(
                        icon: Icons.keyboard_double_arrow_left_rounded,
                        onPressed: () => onChanged(
                          selectedTime.subtract(const Duration(minutes: 30)),
                        ),
                      ),
                      _TimeShiftButton(
                        icon: Icons.chevron_left_rounded,
                        onPressed: () => onChanged(
                          selectedTime.subtract(const Duration(minutes: 15)),
                        ),
                      ),
                      SizedBox(
                        height: 38,
                        child: OutlinedButton(
                          onPressed: onResetToNow,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(color: colorScheme.outline),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          child: const Text('Ahora'),
                        ),
                      ),
                      _TimeShiftButton(
                        icon: Icons.chevron_right_rounded,
                        onPressed: () => onChanged(
                          selectedTime.add(const Duration(minutes: 15)),
                        ),
                      ),
                      _TimeShiftButton(
                        icon: Icons.keyboard_double_arrow_right_rounded,
                        onPressed: () => onChanged(
                          selectedTime.add(const Duration(minutes: 30)),
                        ),
                      ),
                      _TimeShiftButton(
                        icon: Icons.fast_forward_rounded,
                        onPressed: () => onChanged(
                          selectedTime.add(const Duration(minutes: 60)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeShiftButton extends StatelessWidget {
  const _TimeShiftButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(message),
          ],
        ),
      ),
    );
  }
}

class _ProcessionEventCard extends StatelessWidget {
  const _ProcessionEventCard({
    required this.event,
    this.onTap,
    this.isSelected = false,
    this.showOfficialNote = true,
  });

  final DayProcessionEvent event;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool showOfficialNote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent =
        _parseColor(event.brotherhoodColorHex) ?? colorScheme.primary;
    final selectedBackground = accent.withValues(alpha: isDark ? 0.18 : 0.12);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected
            ? selectedBackground
            : (isDark ? colorScheme.surface : AppColors.lightCard),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? accent.withValues(alpha: 0.36)
              : isDark
              ? colorScheme.outlineVariant.withValues(alpha: 0.22)
              : AppColors.accentRose.withValues(alpha: 0.08),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 6,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        event.brotherhoodName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _statusLabel(event),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (showOfficialNote &&
                          event.officialNote.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          event.officialNote,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No se pudo cargar el detalle',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SelectableText(message),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduledEventEntry {
  const _ScheduledEventEntry({
    required this.event,
    required this.pointName,
    required this.scheduledAt,
    required this.schedulePoint,
  });

  final DayProcessionEvent event;
  final String pointName;
  final DateTime scheduledAt;
  final SchedulePoint? schedulePoint;
}

String _statusLabel(DayProcessionEvent event) {
  final pass = event.passDurationMinutes;
  if (pass != null) {
    return '${event.status} · $pass min';
  }
  return event.status;
}

List<_ScheduledEventEntry> _buildScheduleEntries(
  List<DayProcessionEvent> events, {
  required DateTime? dayStartsAt,
}) {
  final anchor = _resolveScheduleAnchor(dayStartsAt);
  var fallbackCurrent = anchor;
  final entries = <_ScheduledEventEntry>[];

  for (final event in events) {
    final timedPoints =
        event.schedulePoints
            .where((point) => point.plannedAt != null)
            .toList(growable: false)
          ..sort((a, b) => a.plannedAt!.compareTo(b.plannedAt!));

    if (timedPoints.isNotEmpty) {
      for (final point in timedPoints) {
        _debugScheduleEntry(
          eventName: event.brotherhoodName,
          pointName: point.name,
          scheduledAt: point.plannedAt,
        );
        entries.add(
          _ScheduledEventEntry(
            event: event,
            pointName: point.name,
            scheduledAt: point.plannedAt!,
            schedulePoint: point,
          ),
        );
      }
      continue;
    }

    entries.add(
      _ScheduledEventEntry(
        event: event,
        pointName: 'Horario estimado',
        scheduledAt: fallbackCurrent,
        schedulePoint: null,
      ),
    );
    final durationMinutes = (event.passDurationMinutes ?? 30).clamp(15, 180);
    fallbackCurrent = fallbackCurrent.add(Duration(minutes: durationMinutes));
  }

  entries.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  return entries;
}

void _debugScheduleEntry({
  required String eventName,
  required String pointName,
  required DateTime? scheduledAt,
}) {
  if (!kDebugMode || !scheduleDebugLogsEnabled) {
    return;
  }

  debugPrint(
    '[schedule_entry] $eventName | $pointName | ${scheduledAt?.toIso8601String()}',
  );
}

Map<String, List<_ScheduledEventEntry>> _groupEntriesByBrotherhood(
  List<_ScheduledEventEntry> entries,
) {
  final grouped = <String, List<_ScheduledEventEntry>>{};

  for (final entry in entries) {
    final key = entry.event.brotherhoodSlug;
    grouped.putIfAbsent(key, () => <_ScheduledEventEntry>[]).add(entry);
  }

  for (final value in grouped.values) {
    value.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  return grouped;
}

List<_ScheduledEventEntry> _entriesForMoment(
  List<_ScheduledEventEntry> entries,
  DateTime selectedTime,
) {
  final visible = <_ScheduledEventEntry>[];
  final grouped = _groupEntriesByBrotherhood(entries);

  for (final brotherhoodEntries in grouped.values) {
    _ScheduledEventEntry? chosen;
    final first = brotherhoodEntries.first;
    final last = brotherhoodEntries.last;

    for (final entry in brotherhoodEntries) {
      if (!entry.scheduledAt.isAfter(selectedTime)) {
        chosen = entry;
      } else {
        break;
      }
    }

    if (chosen == null) {
      visible.add(
        _ScheduledEventEntry(
          event: first.event,
          pointName: 'Templo',
          scheduledAt: selectedTime,
          schedulePoint: first.schedulePoint,
        ),
      );
      continue;
    }

    if (selectedTime.isAfter(last.scheduledAt)) {
      visible.add(
        _ScheduledEventEntry(
          event: last.event,
          pointName: 'Templo',
          scheduledAt: selectedTime,
          schedulePoint: last.schedulePoint,
        ),
      );
      continue;
    }

    visible.add(chosen);
  }

  visible.sort((a, b) {
    final statusPriority = _scheduleCardStatusPriority(
      a.event.status,
    ).compareTo(_scheduleCardStatusPriority(b.event.status));
    if (statusPriority != 0) {
      return statusPriority;
    }
    final campanaCompare = _campanaSortTime(
      grouped[a.event.brotherhoodSlug]!,
    ).compareTo(_campanaSortTime(grouped[b.event.brotherhoodSlug]!));
    if (campanaCompare != 0) {
      return campanaCompare;
    }
    return a.event.brotherhoodName.compareTo(b.event.brotherhoodName);
  });
  return visible;
}

int _scheduleCardStatusPriority(String status) {
  if (_isCancelledStatus(status)) {
    return 1;
  }
  return 0;
}

List<_StatusChipData> _statusChipsFor(String status) {
  final chips = <_StatusChipData>[];
  if (_isDelayedStatus(status)) {
    chips.add(
      const _StatusChipData(
        label: 'Retrasada',
        foreground: Color(0xFF9A3412),
        background: Color(0xFFFFEDD5),
      ),
    );
  }
  if (_isCancelledStatus(status)) {
    chips.add(
      const _StatusChipData(
        label: 'Cancelada',
        foreground: Color(0xFF991B1B),
        background: Color(0xFFFEE2E2),
      ),
    );
  }
  return chips;
}

bool _isDelayedStatus(String status) {
  final normalized = _normalizeStatus(status);
  return normalized.contains('retrasad') ||
      normalized.contains('delay') ||
      normalized.contains('late');
}

bool _isCancelledStatus(String status) {
  final normalized = _normalizeStatus(status);
  return normalized.contains('cancelad') ||
      normalized.contains('cancelled') ||
      normalized.contains('canceled');
}

String _normalizeStatus(String status) {
  return status
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u');
}

class _StatusChipData {
  const _StatusChipData({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;
}

List<DateTime> _scheduleSlotsFor(List<_ScheduledEventEntry> entries) {
  if (entries.isEmpty) {
    return const [];
  }

  final first = _slotStartFor(entries.first.scheduledAt);
  final last = _slotStartFor(entries.last.scheduledAt);
  final slots = <DateTime>[];
  var cursor = first;

  while (!cursor.isAfter(last)) {
    slots.add(cursor);
    cursor = cursor.add(const Duration(minutes: 30));
  }

  return slots;
}

DateTime? _resolveSelectedScheduleTime(
  List<_ScheduledEventEntry> entries,
  DateTime? selected, {
  required DateTime referenceTime,
}) {
  if (entries.isEmpty) {
    return null;
  }

  if (selected != null) {
    return selected;
  }

  return _roundToNearestQuarterHour(
    _anchorReferenceTimeToScheduleDay(entries, referenceTime),
  );
}

DateTime _resolveScheduleAnchor(DateTime? dayStartsAt) {
  if (dayStartsAt != null) {
    final hasExplicitTime = dayStartsAt.hour != 0 || dayStartsAt.minute != 0;
    return DateTime(
      dayStartsAt.year,
      dayStartsAt.month,
      dayStartsAt.day,
      hasExplicitTime ? dayStartsAt.hour : 16,
      hasExplicitTime ? dayStartsAt.minute : 0,
    );
  }

  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, 16);
}

bool _isSameSlot(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day &&
      left.hour == right.hour &&
      left.minute == right.minute;
}

DateTime _slotStartFor(DateTime value) {
  final flooredMinute = value.minute < 30 ? 0 : 30;
  return DateTime(
    value.year,
    value.month,
    value.day,
    value.hour,
    flooredMinute,
  );
}

_ScheduledEventEntry? _findEntryForSlot(
  List<_ScheduledEventEntry> entries,
  DateTime slot,
) {
  _ScheduledEventEntry? match;

  for (final entry in entries) {
    if (_isSameSlot(_slotStartFor(entry.scheduledAt), slot)) {
      match = entry;
    }
  }

  return match;
}

DateTime _campanaSortTime(List<_ScheduledEventEntry> entries) {
  for (final entry in entries) {
    if (entry.pointName.toLowerCase().contains('campana')) {
      return entry.scheduledAt;
    }
  }

  return entries.first.scheduledAt;
}

DateTime _anchorReferenceTimeToScheduleDay(
  List<_ScheduledEventEntry> entries,
  DateTime referenceTime,
) {
  final first = entries.first.scheduledAt;
  return DateTime(
    first.year,
    first.month,
    first.day,
    referenceTime.hour,
    referenceTime.minute,
  );
}

DateTime _roundToNearestQuarterHour(DateTime value) {
  final totalMinutes = value.hour * 60 + value.minute;
  final roundedMinutes = ((totalMinutes + 7) ~/ 15) * 15;
  final normalizedMinutes = roundedMinutes % (24 * 60);
  final dayOffset = roundedMinutes ~/ (24 * 60);

  return DateTime(
    value.year,
    value.month,
    value.day + dayOffset,
    normalizedMinutes ~/ 60,
    normalizedMinutes % 60,
  );
}

String _formatTimeLabel(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _formatSlotLabel(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

DateTime _clampScheduleTimeToEntries(
  List<_ScheduledEventEntry> entries,
  DateTime value,
) {
  if (entries.isEmpty) {
    return value;
  }

  final minTime = _scheduleMinTime(entries);
  final maxTime = _scheduleMaxTime(entries);

  if (value.isBefore(minTime)) {
    return minTime;
  }
  if (value.isAfter(maxTime)) {
    return maxTime;
  }

  return value;
}

DateTime _scheduleMinTime(List<_ScheduledEventEntry> entries) {
  return entries.first.scheduledAt.subtract(const Duration(hours: 2));
}

DateTime _scheduleMaxTime(List<_ScheduledEventEntry> entries) {
  return entries.last.scheduledAt.add(const Duration(hours: 2));
}

DayDetail _applyEditionOfficialRoute(
  DayDetail detail,
  EditionOfficialRoute? editionOfficialRoute,
) {
  if (editionOfficialRoute == null || !editionOfficialRoute.hasGeometry) {
    return detail;
  }

  return detail.copyWith(
    officialRouteArgb: editionOfficialRoute.argb ?? detail.officialRouteArgb,
    officialRoutePoints: editionOfficialRoute.points,
  );
}

Color? _parseColor(String raw) {
  final value = raw.trim();
  if (!value.startsWith('#')) {
    return null;
  }

  final hex = value.substring(1);
  if (hex.length != 6) {
    return null;
  }

  final parsed = int.tryParse(hex, radix: 16);
  if (parsed == null) {
    return null;
  }

  return Color(0xFF000000 | parsed);
}

Color? _parseArgbColor(String? raw) {
  if (raw == null) {
    return null;
  }

  final value = raw.trim();
  if (value.isEmpty) {
    return null;
  }

  if (value.startsWith('#')) {
    final hex = value.substring(1);
    if (hex.length == 8) {
      final parsed = int.tryParse(hex, radix: 16);
      if (parsed != null) {
        return Color(parsed);
      }
    }
    if (hex.length == 6) {
      final parsed = int.tryParse(hex, radix: 16);
      if (parsed != null) {
        return Color(0xFF000000 | parsed);
      }
    }
  }

  if (value.startsWith('0x') || value.startsWith('0X')) {
    final parsed = int.tryParse(value.substring(2), radix: 16);
    if (parsed != null) {
      return Color(parsed);
    }
  }

  final decimalParsed = int.tryParse(value);
  if (decimalParsed != null && decimalParsed >= 0) {
    return Color(decimalParsed & 0xFFFFFFFF);
  }

  final tuple = value.split(',');
  if (tuple.length == 4) {
    final channels = tuple
        .map((part) => int.tryParse(part.trim()))
        .toList(growable: false);
    if (channels.every((channel) => channel != null)) {
      final a = channels[0]!.clamp(0, 255);
      final r = channels[1]!.clamp(0, 255);
      final g = channels[2]!.clamp(0, 255);
      final b = channels[3]!.clamp(0, 255);
      return Color.fromARGB(a, r, g, b);
    }
  }

  return null;
}
