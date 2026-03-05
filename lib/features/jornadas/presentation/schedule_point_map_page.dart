import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../core/maps/mapbox_map_helpers.dart';
import '../../../core/models/day_detail.dart';

class SchedulePointMapPage extends StatefulWidget {
  const SchedulePointMapPage({
    super.key,
    required this.title,
    required this.colorHex,
    required this.event,
    required this.initialSelectedTime,
    required this.minSelectableTime,
    required this.maxSelectableTime,
  });

  final String title;
  final String colorHex;
  final DayProcessionEvent event;
  final DateTime initialSelectedTime;
  final DateTime minSelectableTime;
  final DateTime maxSelectableTime;

  @override
  State<SchedulePointMapPage> createState() => _SchedulePointMapPageState();
}

class _SchedulePointMapPageState extends State<SchedulePointMapPage> {
  MapboxMap? _map;
  PolylineAnnotationManager? _polylineManager;
  CircleAnnotationManager? _circleManager;
  Offset? _calloutOffset;
  late DateTime _selectedTime;

  SchedulePoint? get _currentPoint =>
      _pointForMoment(widget.event.schedulePoints, _selectedTime);

  String get _currentPointName => _currentPoint?.name ?? 'Templo';

  List<MapPoint> get _routeMapPoints => widget.event.routePoints
      .where((point) => point.hasLocation)
      .map(
        (point) =>
            MapPoint(latitude: point.latitude!, longitude: point.longitude!),
      )
      .toList(growable: false);

  List<MapPoint> get _focusPoints {
    final point = _currentPoint;
    if (point?.hasLocation == true) {
      return [
        ..._routeMapPoints,
        MapPoint(latitude: point!.latitude!, longitude: point.longitude!),
      ];
    }

    return _routeMapPoints;
  }

  @override
  void initState() {
    super.initState();
    _selectedTime = _clampToRange(
      widget.initialSelectedTime,
      min: widget.minSelectableTime,
      max: widget.maxSelectableTime,
    );
  }

  Future<void> _centerOnCurrentPoint() async {
    final map = _map;
    if (map == null) {
      return;
    }

    final point = _currentPoint;
    if (point?.hasLocation == true) {
      await map.easeTo(
        CameraOptions(
          center: Point(
            coordinates: Position(point!.longitude!, point.latitude!),
          ),
          zoom: 16,
        ),
        MapAnimationOptions(duration: 700),
      );
      return;
    }

    await easeToPoints(map, _focusPoints, fallbackZoom: 15);
  }

  Future<void> _centerOnRoute() async {
    final map = _map;
    if (map == null) {
      return;
    }

    await easeToPoints(map, _routeMapPoints, fallbackZoom: 15);
  }

  Future<void> _syncAnnotations() async {
    final polylineManager = _polylineManager;
    final circleManager = _circleManager;
    if (polylineManager == null || circleManager == null) {
      return;
    }

    await polylineManager.deleteAll();
    await circleManager.deleteAll();

    final accent = _parseColor(widget.colorHex) ?? const Color(0xFF8B1E3F);

    if (_routeMapPoints.length >= 2) {
      await polylineManager.create(
        PolylineAnnotationOptions(
          geometry: LineString(
            coordinates: _routeMapPoints
                .map((point) => point.toPoint().coordinates)
                .toList(growable: false),
          ),
          lineColor: accent.toARGB32(),
          lineWidth: 5,
        ),
      );
    }

    final currentPoint = _currentPoint;
    if (currentPoint?.hasLocation == true) {
      await circleManager.create(
        CircleAnnotationOptions(
          geometry: MapPoint(
            latitude: currentPoint!.latitude!,
            longitude: currentPoint.longitude!,
          ).toPoint(),
          circleColor: const Color(0xFF8B1E3F).toARGB32(),
          circleRadius: 7,
          circleStrokeColor: Colors.white.toARGB32(),
          circleStrokeWidth: 2,
        ),
      );
    }
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _map = mapboxMap;
    _polylineManager = await mapboxMap.annotations
        .createPolylineAnnotationManager();
    _circleManager = await mapboxMap.annotations
        .createCircleAnnotationManager();
    await _syncAnnotations();
    await _refreshCalloutPosition();
  }

  Future<void> _refreshCalloutPosition() async {
    final map = _map;
    final currentPoint = _currentPoint;
    if (map == null || currentPoint?.hasLocation != true || !mounted) {
      if (_calloutOffset != null) {
        setState(() {
          _calloutOffset = null;
        });
      }
      return;
    }

    try {
      final pixel = await map.pixelForCoordinate(
        Point(
          coordinates: Position(
            currentPoint!.longitude!,
            currentPoint.latitude!,
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _calloutOffset = Offset(pixel.x.toDouble(), pixel.y.toDouble());
      });
    } catch (_) {
      // Ignore temporary projection failures while the map is still settling.
    }
  }

  Future<void> _updateSelectedTime(DateTime value) async {
    setState(() {
      _selectedTime = _clampToRange(
        value,
        min: widget.minSelectableTime,
        max: widget.maxSelectableTime,
      );
    });
    await _syncAnnotations();
    await _refreshCalloutPosition();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final plannedAt = _currentPoint?.plannedAt;
    final pointTime = plannedAt == null
        ? null
        : '${plannedAt.hour.toString().padLeft(2, '0')}:${plannedAt.minute.toString().padLeft(2, '0')}';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(_selectedTime);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(_selectedTime),
          ),
        ),
        floatingActionButtonAnimator: FloatingActionButtonAnimator.noAnimation,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _FloatingTimeSelector(
          selectedTime: _selectedTime,
          onChanged: _updateSelectedTime,
          onResetToNow: () {
            _updateSelectedTime(
              _clampToRange(
                _roundToNearestQuarterHour(
                  DateTime(
                    _selectedTime.year,
                    _selectedTime.month,
                    _selectedTime.day,
                    DateTime.now().hour,
                    DateTime.now().minute,
                  ),
                ),
                min: widget.minSelectableTime,
                max: widget.maxSelectableTime,
              ),
            );
          },
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                if (kMapboxAccessToken.isEmpty)
                  Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Falta MAPBOX_ACCESS_TOKEN. Ejecuta la app con --dart-define=MAPBOX_ACCESS_TOKEN=tu_token.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  )
                else
                  MapWidget(
                    key: const ValueKey('schedule-point-map'),
                    styleUri: mapboxStyleUriForBrightness(
                      Theme.of(context).brightness,
                    ),
                    gestureRecognizers: kMapGestureRecognizers,
                    cameraOptions: cameraForPoints(
                      _focusPoints,
                      fallbackZoom: 15,
                    ),
                    onCameraChangeListener: (_) {
                      _refreshCalloutPosition();
                    },
                    onMapCreated: _onMapCreated,
                  ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton.small(
                          heroTag: 'schedule-map-fit-point',
                          onPressed: _centerOnCurrentPoint,
                          child: const Icon(Icons.my_location_rounded),
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton.small(
                          heroTag: 'schedule-map-fit-route',
                          onPressed: _centerOnRoute,
                          child: const Icon(Icons.route_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_calloutOffset != null)
                  Builder(
                    builder: (context) {
                      final maxCardWidth = constraints.maxWidth - 24;
                      final label = pointTime == null
                          ? _currentPointName
                          : '$pointTime · $_currentPointName';
                      final textStyle = Theme.of(context).textTheme.titleSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                          );
                      final textPainter = TextPainter(
                        text: TextSpan(text: label, style: textStyle),
                        textDirection: Directionality.of(context),
                        maxLines: 1,
                      )..layout(maxWidth: maxCardWidth - 24);
                      final cardWidth = math.min(
                        textPainter.width + 24,
                        maxCardWidth,
                      );
                      const cardHeight = 72.0;
                      const arrowSize = 8.0;
                      const verticalGap = -16.0;
                      final left = math.max(
                        12.0,
                        math.min(
                          _calloutOffset!.dx - (cardWidth / 2),
                          constraints.maxWidth - cardWidth - 12,
                        ),
                      );
                      final preferredAboveTop =
                          _calloutOffset!.dy -
                          cardHeight -
                          arrowSize -
                          verticalGap;
                      final canShowAbove = preferredAboveTop >= 12;
                      final top = math.max(
                        12.0,
                        math.min(
                          canShowAbove
                              ? preferredAboveTop
                              : _calloutOffset!.dy + verticalGap,
                          constraints.maxHeight - cardHeight - arrowSize - 126,
                        ),
                      );

                      return Positioned(
                        left: left,
                        top: top,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!canShowAbove)
                              Icon(
                                Icons.arrow_drop_up_rounded,
                                size: arrowSize,
                                color: Theme.of(context).cardColor,
                              ),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: cardWidth,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [Text(label, style: textStyle)],
                                  ),
                                ),
                              ),
                            ),
                            if (canShowAbove)
                              Icon(
                                Icons.arrow_drop_down_rounded,
                                size: arrowSize,
                                color: Theme.of(context).cardColor,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

SchedulePoint? _pointForMoment(
  List<SchedulePoint> points,
  DateTime selectedTime,
) {
  final timedPoints = points.where((point) => point.plannedAt != null).toList()
    ..sort((a, b) => a.plannedAt!.compareTo(b.plannedAt!));

  if (timedPoints.isEmpty) {
    return null;
  }

  if (selectedTime.isBefore(timedPoints.first.plannedAt!)) {
    return timedPoints.first;
  }

  if (selectedTime.isAfter(timedPoints.last.plannedAt!)) {
    return timedPoints.last;
  }

  SchedulePoint? chosen;
  for (final point in timedPoints) {
    if (!point.plannedAt!.isAfter(selectedTime)) {
      chosen = point;
    } else {
      break;
    }
  }

  return chosen;
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

class _FloatingTimeSelector extends StatelessWidget {
  const _FloatingTimeSelector({
    required this.selectedTime,
    required this.onChanged,
    required this.onResetToNow,
  });

  final DateTime selectedTime;
  final ValueChanged<DateTime> onChanged;
  final VoidCallback onResetToNow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
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

String _formatTimeLabel(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

DateTime _clampToRange(
  DateTime value, {
  required DateTime min,
  required DateTime max,
}) {
  if (value.isBefore(min)) {
    return min;
  }
  if (value.isAfter(max)) {
    return max;
  }
  return value;
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
