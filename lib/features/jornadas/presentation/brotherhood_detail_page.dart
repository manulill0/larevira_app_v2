import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../core/config/app_instance_controller.dart';
import '../../../core/media/private_image_cache.dart';
import '../../../core/maps/mapbox_map_helpers.dart';
import '../../../core/models/day_detail.dart';
import '../../../core/network/larevira_api_client.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_page_surfaces.dart';

final _brotherhoodVisualProvider =
    FutureProvider.family<_BrotherhoodVisualData?, String>((ref, slug) async {
      final trimmedSlug = slug.trim();
      if (trimmedSlug.isEmpty) {
        return null;
      }

      final appInstance = ref.read(appInstanceProvider);
      final year = ref.read(editionYearProvider);
      final apiClient = ref.read(lareviraApiClientProvider);

      try {
        final response = await apiClient.getScoped(
          appInstance.citySlug,
          year,
          '/brotherhoods/$trimmedSlug',
        );
        final payload = response.data;
        if (payload is! Map<String, dynamic>) {
          return null;
        }
        final data = (payload['data'] as Map<String, dynamic>? ?? const {});
        final shortName = _pickString(data, const [
          'short_name',
          'shortName',
          'name',
        ]);
        final fullName = _pickString(data, const ['full_name', 'fullName']);
        final foundationYear = _pickInt(data, const [
          'foundation_year',
          'foundationYear',
        ]);
        final history = _resolveHistoryText(data);
        final dressCode = _resolveDressCodeText(data);
        final figures = _parseFigureItems(data['figures']);
        final pasos = _parsePasoItems(data['pasos']);
        final headerImageUrl = _resolveImageUrl(
          _pickString(data, const [
            'header_image_url',
            'header_image',
            'cover_image_url',
          ]),
          appInstance.baseApiUrl,
        );
        final shieldImageUrl = _resolveImageUrl(
          _pickString(data, const [
            'shield_image_url',
            'shield_url',
            'logo_url',
          ]),
          appInstance.baseApiUrl,
        );

        return _BrotherhoodVisualData(
          shortName: shortName,
          fullName: fullName,
          foundationYear: foundationYear,
          history: history,
          dressCode: dressCode,
          figures: figures,
          pasos: pasos,
          headerImageUrl: headerImageUrl,
          shieldImageUrl: shieldImageUrl,
        );
      } catch (_) {
        return null;
      }
    });

class BrotherhoodDetailPage extends ConsumerWidget {
  const BrotherhoodDetailPage({
    super.key,
    required this.slug,
    this.event,
    this.dayName,
  });

  final String slug;
  final DayProcessionEvent? event;
  final String? dayName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final media = MediaQuery.sizeOf(context);
    final isTablet = media.shortestSide >= 600;
    final isLandscape = media.width > media.height;
    final isCompactLandscape = !isTablet && isLandscape;
    final shouldUseSplitLayout = isTablet && isLandscape;
    if (shouldUseSplitLayout && Navigator.of(context).canPop()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop(
            BrotherhoodDetailReturnData(sectionIndex: 2, brotherhoodSlug: slug),
          );
        }
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    final visualAsync = ref.watch(_brotherhoodVisualProvider(slug));
    final visual = visualAsync.asData?.value;
    final accent =
        _parseColor(event?.brotherhoodColorHex ?? '') ?? colorScheme.primary;
    final backgroundTop = isDark
        ? AppColors.backgroundDarkTop
        : AppColors.lightPage;
    final backgroundBottom = isDark
        ? AppColors.backgroundDarkBottom
        : AppColors.backgroundLightBottom;
    final title = event?.brotherhoodName ?? 'Hermandad';
    final shortName =
        (visual?.shortName != null && visual!.shortName!.trim().isNotEmpty)
        ? visual.shortName!.trim()
        : _resolveShortName(event, fallback: title);
    final expandedHeight = isCompactLandscape
        ? (media.height * 0.34).clamp(140.0, 210.0)
        : (media.height * 0.30).clamp(210.0, 360.0);
    final tabBar = TabBar(
      isScrollable: isCompactLandscape,
      tabs: const [
        Tab(text: 'Información'),
        Tab(text: 'Itinerario'),
        Tab(text: 'Mapa'),
      ],
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: theme.textTheme.labelLarge,
    );

    final content = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [backgroundTop, backgroundBottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: true,
                expandedHeight: expandedHeight,
                backgroundColor: AppPageSurfaces.sliverAppBarBackground(
                  theme.brightness,
                ),
                centerTitle: true,
                titleSpacing: 0,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  expandedTitleScale: 1,
                  titlePadding: const EdgeInsetsDirectional.only(
                    start: 16,
                    end: 16,
                    bottom: 12,
                  ),
                  title: _BrotherhoodHeaderIdentity(
                    shortName: shortName,
                    shieldImageUrl:
                        visual?.shieldImageUrl ??
                        event?.brotherhoodShieldImageUrl,
                    accent: accent,
                  ),
                  background: _BrotherhoodHeaderBackground(
                    imageUrl:
                        visual?.headerImageUrl ??
                        event?.brotherhoodHeaderImageUrl,
                    accent: accent,
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarSliverDelegate(tabBar: tabBar),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _InformationTab(
                event: event,
                visual: visual,
                accent: accent,
                isTablet: isTablet,
              ),
              _ItineraryTab(event: event),
              _MapTab(
                event: event,
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      bottomNavigationBar: isTablet
          ? null
          : NavigationBar(
              selectedIndex: 2,
              onDestinationSelected: (index) {
                if (index == 2) {
                  return;
                }
                Navigator.of(context).pop(
                  BrotherhoodDetailReturnData(
                    sectionIndex: index,
                    brotherhoodSlug: slug,
                  ),
                );
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
      body: content,
    );
  }
}

class _TabBarSliverDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarSliverDelegate({required this.tabBar});

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(color: colorScheme.surface, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _TabBarSliverDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar;
  }
}

class _InformationTab extends StatelessWidget {
  const _InformationTab({
    required this.event,
    required this.visual,
    required this.accent,
    required this.isTablet,
  });

  final DayProcessionEvent? event;
  final _BrotherhoodVisualData? visual;
  final Color accent;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final horizontal = isTablet ? 20.0 : 16.0;
    final historyMessage =
        visual?.history?.trim().isNotEmpty == true
        ? visual!.history!.trim()
        : event?.brotherhoodHistory?.trim().isNotEmpty == true
        ? event!.brotherhoodHistory!.trim()
        : 'No hay historia disponible para esta hermandad.';

    return ListView(
      padding: EdgeInsets.fromLTRB(horizontal, 10, horizontal, 24),
      children: event == null
          ? [
              const _InfoBlock(
                title: 'Detalle pendiente',
                child: Text(
                  'Todavía no hay detalle de esta hermandad para esta jornada.',
                ),
              ),
            ]
          : [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: accent.withValues(alpha: 0.18)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      visual?.fullName?.trim().isNotEmpty == true
                          ? visual!.fullName!.trim()
                          : event!.brotherhoodName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Fundación',
                      value: visual?.foundationYear?.toString() ?? '--',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'Hermanos',
                      value: _formatCount(event!.brothersCount),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'Nazarenos',
                      value: _formatCount(event!.nazarenesCount),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Historia',
                child: Text(historyMessage),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Túnicas',
                child: Text(
                  visual?.dressCode?.trim().isNotEmpty == true
                      ? visual!.dressCode!.trim()
                      : event?.brotherhoodDressCode?.trim().isNotEmpty == true
                      ? event!.brotherhoodDressCode!.trim()
                      : 'No hay información de túnicas disponible.',
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Titulares',
                child: _FigureCardsContent(
                  figures: visual?.figures ??
                      event?.brotherhoodFigures
                          .map(
                            (item) => _BrotherhoodFigureItem(
                              name: item.name,
                              description: item.description,
                            ),
                          )
                          .toList(growable: false) ??
                      const [],
                  emptyLabel: 'No hay titulares disponibles.',
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Pasos',
                child: _PasoCardsContent(
                  pasos: visual?.pasos ??
                      event?.brotherhoodPasos
                          .map(
                            (item) => _BrotherhoodPasoItem(
                              name: item.name,
                              description: item.description,
                            ),
                          )
                          .toList(growable: false) ??
                      const [],
                  emptyLabel: 'No hay pasos disponibles.',
                ),
              ),
              const SizedBox(height: 12),
              _InfoBlock(
                title: 'Color',
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(event!.brotherhoodColorHex),
                  ],
                ),
              ),
            ],
    );
  }
}

class _ItineraryTab extends StatelessWidget {
  const _ItineraryTab({required this.event});

  final DayProcessionEvent? event;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.primary;

    if (event == null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: const [
          _InfoBlock(
            title: 'Itinerario no disponible',
            child: Text('No hay datos de itinerario para esta jornada.'),
          ),
        ],
      );
    }

    final points = event!.schedulePoints;
    if (points.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: const [
          _InfoBlock(
            title: 'Itinerario no disponible',
            child: Text('No hay puntos de itinerario en esta jornada.'),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      itemCount: points.length,
      itemBuilder: (context, index) {
        final point = points[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ItineraryPointTile(
            index: index + 1,
            name: point.name,
            timeLabel: point.plannedAt == null ? '--:--' : _formatTime(point.plannedAt!),
            accent: accent,
          ),
        );
      },
    );
  }
}

class _ItineraryPointTile extends StatelessWidget {
  const _ItineraryPointTile({
    required this.index,
    required this.name,
    required this.timeLabel,
    required this.accent,
  });

  final int index;
  final String name;
  final String timeLabel;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$index',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Cinzel',
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Lora',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              timeLabel,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                fontFamily: 'Cinzel',
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.map_outlined,
              color: accent,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}

class _MapTab extends StatefulWidget {
  const _MapTab({required this.event});

  final DayProcessionEvent? event;

  @override
  State<_MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<_MapTab> {
  PolylineAnnotationManager? _polylineManager;
  PointAnnotationManager? _pointManager;
  Uint8List? _houseIconBytes;
  bool _showLegend = true;

  List<MapPoint> get _brotherhoodRoutePoints {
    final event = widget.event;
    if (event == null) {
      return const <MapPoint>[];
    }
    return event.routePoints
        .where((point) => point.hasLocation)
        .map(
          (point) => MapPoint(
            latitude: point.latitude!,
            longitude: point.longitude!,
          ),
        )
        .toList(growable: false);
  }

  List<_KmlLinePlacemark> get _kmlLinePlacemarks =>
      _parseKml(widget.event?.routeKml).lines;

  List<_KmlPointPlacemark> get _kmlPointPlacemarks =>
      _parseKml(widget.event?.routeKml).points;

  List<MapPoint> get _allPoints {
    final kmlLines = _kmlLinePlacemarks;
    if (kmlLines.isNotEmpty) {
      final points = kmlLines.expand((line) => line.points).toList(growable: false);
      if (_kmlPointPlacemarks.isNotEmpty) {
        return [
          ...points,
          ..._kmlPointPlacemarks.map((point) => point.point),
        ];
      }
      return points;
    }
    return _brotherhoodRoutePoints;
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _polylineManager = await mapboxMap.annotations
        .createPolylineAnnotationManager();
    _pointManager = await mapboxMap.annotations.createPointAnnotationManager();
    _houseIconBytes ??= await _buildHouseIconBytes(AppColors.primary);
    await _syncAnnotations();
  }

  Future<void> _syncAnnotations() async {
    final polylineManager = _polylineManager;
    final pointManager = _pointManager;
    if (polylineManager == null || pointManager == null) {
      return;
    }

    await polylineManager.deleteAll();
    await pointManager.deleteAll();

    final accent =
        _parseColor(widget.event?.brotherhoodColorHex ?? '') ?? AppColors.primary;
    final kmlLines = _kmlLinePlacemarks;
    if (kmlLines.isNotEmpty) {
      for (final line in kmlLines) {
        if (line.points.length < 2) {
          continue;
        }
        await polylineManager.create(
          PolylineAnnotationOptions(
            geometry: LineString(
              coordinates: line.points
                  .map((point) => point.toPoint().coordinates)
                  .toList(growable: false),
            ),
            lineColor: (line.color ?? accent).toARGB32(),
            lineWidth: 5.5,
          ),
        );
      }
    } else {
      final brotherhoodPoints = _brotherhoodRoutePoints;
      if (brotherhoodPoints.length >= 2) {
        await polylineManager.create(
          PolylineAnnotationOptions(
            geometry: LineString(
              coordinates: brotherhoodPoints
                  .map((point) => point.toPoint().coordinates)
                  .toList(growable: false),
            ),
            lineColor: accent.toARGB32(),
            lineWidth: 5.5,
          ),
        );
      }
    }

    final icon = _houseIconBytes ?? await _buildHouseIconBytes(AppColors.primary);
    _houseIconBytes = icon;
    for (final point in _kmlPointPlacemarks) {
      await pointManager.create(
        PointAnnotationOptions(
          geometry: point.point.toPoint(),
          image: icon,
          iconSize: 1.4,
          textField: point.label,
          textColor: AppColors.primary.toARGB32(),
          textHaloColor: Colors.white.toARGB32(),
          textHaloWidth: 1.5,
          textSize: 11,
          textAnchor: TextAnchor.TOP,
          textOffset: const [0.0, 1.6],
          symbolSortKey: 3000,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(covariant _MapTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.event != widget.event) {
      _syncAnnotations();
    }
  }

  @override
  void dispose() {
    _polylineManager = null;
    _pointManager = null;
    _houseIconBytes = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.event == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No hay geometría disponible para esta hermandad en esta jornada.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (kMapboxAccessToken.isEmpty) {
      return Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Falta MAPBOX_ACCESS_TOKEN. Ejecuta la app con --dart-define=MAPBOX_ACCESS_TOKEN=tu_token.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final accent =
        _parseColor(widget.event?.brotherhoodColorHex ?? '') ?? AppColors.primary;

    return Stack(
      children: [
        MapWidget(
          key: const ValueKey('brotherhood-detail-map'),
          styleUri: mapboxStyleUriForBrightness(Theme.of(context).brightness),
          gestureRecognizers: kMapGestureRecognizers,
          cameraOptions: cameraForPoints(_allPoints, fallbackZoom: 14),
          onMapCreated: _onMapCreated,
        ),
        Positioned(
          left: 12,
          bottom: 12,
          child: SafeArea(
            top: false,
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
                    size: 16,
                  ),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  label: Text(
                    _showLegend ? 'Ocultar' : 'Leyenda',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                if (_showLegend) ...[
                  const SizedBox(height: 6),
                  Card(
                    margin: EdgeInsets.zero,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 190,
                        maxHeight: 145,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _LegendRow(
                                color: AppColors.primary,
                                label: 'Punto KML (casa)',
                              ),
                              const SizedBox(height: 6),
                              if (_kmlLinePlacemarks.isNotEmpty)
                                for (final line in _kmlLinePlacemarks) ...[
                                  _LegendRow(
                                    color: line.color ?? accent,
                                    label: line.label,
                                  ),
                                  const SizedBox(height: 6),
                                ]
                              else
                                _LegendRow(
                                  color: accent,
                                  label: widget.event?.brotherhoodName ?? 'Ruta',
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _KmlLinePlacemark {
  const _KmlLinePlacemark({
    required this.points,
    required this.label,
    this.color,
  });

  final List<MapPoint> points;
  final String label;
  final Color? color;
}

class _KmlPointPlacemark {
  const _KmlPointPlacemark({required this.point, required this.label});

  final MapPoint point;
  final String label;
}

class _ParsedKmlGeometry {
  const _ParsedKmlGeometry({
    required this.lines,
    required this.points,
  });

  final List<_KmlLinePlacemark> lines;
  final List<_KmlPointPlacemark> points;
}

_ParsedKmlGeometry _parseKml(String? rawKml) {
  final source = rawKml?.trim() ?? '';
  if (source.isEmpty) {
    return const _ParsedKmlGeometry(lines: [], points: []);
  }

  final styleColorById = <String, Color>{};
  final styleMapToStyleId = <String, String>{};

  final styleMatches = RegExp(
    r'<Style[^>]*id="([^"]+)"[^>]*>(.*?)</Style>',
    caseSensitive: false,
    dotAll: true,
  ).allMatches(source);
  for (final match in styleMatches) {
    final styleId = match.group(1)?.trim();
    final body = match.group(2) ?? '';
    final colorMatch = RegExp(
      r'<LineStyle[^>]*>.*?<color[^>]*>\s*([0-9a-fA-F]{8})\s*</color>.*?</LineStyle>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(body);
    if (styleId == null || styleId.isEmpty || colorMatch == null) {
      continue;
    }
    final color = _parseKmlColor(colorMatch.group(1)!);
    if (color != null) {
      styleColorById[styleId] = color;
    }
  }

  final styleMapMatches = RegExp(
    r'<StyleMap[^>]*id="([^"]+)"[^>]*>(.*?)</StyleMap>',
    caseSensitive: false,
    dotAll: true,
  ).allMatches(source);
  for (final match in styleMapMatches) {
    final styleMapId = match.group(1)?.trim();
    final body = match.group(2) ?? '';
    if (styleMapId == null || styleMapId.isEmpty) {
      continue;
    }
    final normalPair = RegExp(
      r'<Pair[^>]*>.*?<key>\s*normal\s*</key>.*?<styleUrl>\s*#?([^<\s]+)\s*</styleUrl>.*?</Pair>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(body);
    final resolved = normalPair?.group(1)?.trim();
    if (resolved != null && resolved.isNotEmpty) {
      styleMapToStyleId[styleMapId] = resolved;
    }
  }

  final lines = <_KmlLinePlacemark>[];
  final points = <_KmlPointPlacemark>[];

  final placemarkMatches = RegExp(
    r'<Placemark[^>]*>(.*?)</Placemark>',
    caseSensitive: false,
    dotAll: true,
  ).allMatches(source);

  for (final match in placemarkMatches) {
    final body = match.group(1) ?? '';
    final name = _extractXmlTag(body, 'name') ?? 'Punto KML';
    final styleUrl = _extractXmlTag(body, 'styleUrl')?.replaceAll('#', '').trim();
    final resolvedStyleId = styleMapToStyleId[styleUrl] ?? styleUrl;
    final inlineColorMatch = RegExp(
      r'<LineStyle[^>]*>.*?<color[^>]*>\s*([0-9a-fA-F]{8})\s*</color>.*?</LineStyle>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(body);
    final lineColor = inlineColorMatch != null
        ? _parseKmlColor(inlineColorMatch.group(1)!)
        : styleColorById[resolvedStyleId] ?? _parseColorFromStyleUrl(resolvedStyleId);

    final lineCoordinates = RegExp(
      r'<LineString[^>]*>.*?<coordinates[^>]*>\s*([^<]+?)\s*</coordinates>.*?</LineString>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(body);
    if (lineCoordinates != null) {
      final linePoints = _parseCoordinateTuples(lineCoordinates.group(1)!);
      if (linePoints.length >= 2) {
        lines.add(
          _KmlLinePlacemark(
            points: linePoints,
            label: name,
            color: lineColor,
          ),
        );
      }
    }

    final pointCoordinates = RegExp(
      r'<Point[^>]*>.*?<coordinates[^>]*>\s*([^<]+?)\s*</coordinates>.*?</Point>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(body);
    if (pointCoordinates != null) {
      final pointList = _parseCoordinateTuples(pointCoordinates.group(1)!);
      if (pointList.isNotEmpty) {
        points.add(_KmlPointPlacemark(point: pointList.first, label: name));
      }
    }
  }

  return _ParsedKmlGeometry(lines: lines, points: points);
}

Color? _parseKmlColor(String kmlColor) {
  final value = kmlColor.trim();
  if (value.length != 8) {
    return null;
  }
  final aa = value.substring(0, 2);
  final bb = value.substring(2, 4);
  final gg = value.substring(4, 6);
  final rr = value.substring(6, 8);
  final argbHex = '$aa$rr$gg$bb';
  final parsed = int.tryParse(argbHex, radix: 16);
  if (parsed == null) {
    return null;
  }
  return Color(parsed);
}

Color? _parseColorFromStyleUrl(String? styleUrl) {
  if (styleUrl == null || styleUrl.isEmpty) {
    return null;
  }
  final lineMatch = RegExp(
    r'line-([0-9a-fA-F]{6})-\d+',
    caseSensitive: false,
  ).firstMatch(styleUrl);
  if (lineMatch != null) {
    final parsed = int.tryParse(lineMatch.group(1)!, radix: 16);
    if (parsed != null) {
      return Color(0xFF000000 | parsed);
    }
  }
  final iconMatch = RegExp(
    r'icon-\d+-([0-9a-fA-F]{6})',
    caseSensitive: false,
  ).firstMatch(styleUrl);
  if (iconMatch != null) {
    final parsed = int.tryParse(iconMatch.group(1)!, radix: 16);
    if (parsed != null) {
      return Color(0xFF000000 | parsed);
    }
  }
  return null;
}

String? _extractXmlTag(String source, String tag) {
  final match = RegExp(
    '<$tag[^>]*>\\s*([^<]+?)\\s*</$tag>',
    caseSensitive: false,
    dotAll: true,
  ).firstMatch(source);
  return match?.group(1)?.trim();
}

List<MapPoint> _parseCoordinateTuples(String rawCoordinates) {
  final points = <MapPoint>[];
  for (final tuple in rawCoordinates.trim().split(RegExp(r'\s+'))) {
    final values = tuple.split(',');
    if (values.length < 2) {
      continue;
    }
    final longitude = double.tryParse(values[0].trim());
    final latitude = double.tryParse(values[1].trim());
    if (latitude == null || longitude == null) {
      continue;
    }
    points.add(MapPoint(latitude: latitude, longitude: longitude));
  }
  return points;
}

Future<Uint8List> _buildHouseIconBytes(Color color) async {
  const size = 64.0;
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  final fill = ui.Paint()..color = color;
  final stroke = ui.Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = ui.PaintingStyle.stroke
    ..strokeWidth = 2.0;

  final roof = ui.Path()
    ..moveTo(size * 0.12, size * 0.52)
    ..lineTo(size * 0.50, size * 0.18)
    ..lineTo(size * 0.88, size * 0.52)
    ..close();
  final body = ui.RRect.fromRectAndRadius(
    ui.Rect.fromLTWH(size * 0.24, size * 0.50, size * 0.52, size * 0.32),
    const ui.Radius.circular(4),
  );
  final door = ui.RRect.fromRectAndRadius(
    ui.Rect.fromLTWH(size * 0.45, size * 0.62, size * 0.12, size * 0.20),
    const ui.Radius.circular(2),
  );

  canvas.drawPath(roof, fill);
  canvas.drawRRect(body, fill);
  canvas.drawRRect(door, ui.Paint()..color = const Color(0xFFFFFFFF));
  canvas.drawPath(roof, stroke);
  canvas.drawRRect(body, stroke);

  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List();
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 9,
          height: 9,
          margin: const EdgeInsets.only(top: 3),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

class _BrotherhoodHeaderBackground extends StatelessWidget {
  const _BrotherhoodHeaderBackground({
    required this.imageUrl,
    required this.accent,
  });

  final String? imageUrl;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    final imageWidget = hasImage
        ? _PrivateHeaderBackgroundImage(
            imageUrl: imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: () => _FallbackBrotherhoodHeader(accent: accent),
          )
        : _FallbackBrotherhoodHeader(accent: accent);

    return Stack(
      fit: StackFit.expand,
      children: [
        imageWidget,
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.14),
                Colors.black.withValues(alpha: 0.58),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PrivateHeaderBackgroundImage extends StatefulWidget {
  const _PrivateHeaderBackgroundImage({
    required this.imageUrl,
    required this.fit,
    required this.errorBuilder,
  });

  final String imageUrl;
  final BoxFit fit;
  final Widget Function() errorBuilder;

  @override
  State<_PrivateHeaderBackgroundImage> createState() =>
      _PrivateHeaderBackgroundImageState();
}

class _PrivateHeaderBackgroundImageState
    extends State<_PrivateHeaderBackgroundImage> {
  File? _cachedFile;

  @override
  void initState() {
    super.initState();
    _loadCachedFile();
  }

  @override
  void didUpdateWidget(covariant _PrivateHeaderBackgroundImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _cachedFile = null;
      _loadCachedFile();
    }
  }

  Future<void> _loadCachedFile() async {
    try {
      final file = await PrivateImageCache.getOrFetchHeader(widget.imageUrl);
      if (!mounted) {
        return;
      }
      if (file != null) {
        setState(() {
          _cachedFile = file;
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _cachedFile = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cachedFile != null) {
      return Image.file(_cachedFile!, fit: widget.fit);
    }
    return Image.network(
      widget.imageUrl,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) => widget.errorBuilder(),
    );
  }
}

class _FallbackBrotherhoodHeader extends StatelessWidget {
  const _FallbackBrotherhoodHeader({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [accent.withValues(alpha: 0.88), const Color(0xFF2A1515)],
        ),
      ),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 12),
          child: Icon(
            Icons.church_rounded,
            size: 120,
            color: Colors.white.withValues(alpha: 0.14),
          ),
        ),
      ),
    );
  }
}

class _BrotherhoodHeaderIdentity extends StatelessWidget {
  const _BrotherhoodHeaderIdentity({
    required this.shortName,
    required this.shieldImageUrl,
    required this.accent,
  });

  final String shortName;
  final String? shieldImageUrl;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    var collapse = 0.0;
    if (settings != null && settings.maxExtent > settings.minExtent) {
      final expandedRatio =
          ((settings.currentExtent - settings.minExtent) /
                  (settings.maxExtent - settings.minExtent))
              .clamp(0.0, 1.0);
      collapse = 1 - expandedRatio;
    }
    final titleColor = isDark
        ? Colors.white
        : (Color.lerp(Colors.white, Colors.black, collapse) ?? Colors.black);
    final shieldBorderColor =
        Color.lerp(
          Colors.white.withValues(alpha: 0.75),
          Colors.black.withValues(alpha: 0.45),
          collapse,
        ) ??
        Colors.white.withValues(alpha: 0.75);
    final isCompactLandscape =
        MediaQuery.sizeOf(context).width > MediaQuery.sizeOf(context).height &&
        MediaQuery.sizeOf(context).width < 840;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _BrotherhoodShieldAvatar(
          imageUrl: shieldImageUrl,
          accent: accent,
          size: 30,
          borderColor: shieldBorderColor,
          foregroundColor: titleColor,
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            shortName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: titleColor,
              fontWeight: FontWeight.w800,
              fontFamily: 'Cinzel',
              fontSize: isCompactLandscape ? 20 : 24,
              height: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}

class _BrotherhoodShieldAvatar extends StatefulWidget {
  const _BrotherhoodShieldAvatar({
    required this.imageUrl,
    required this.accent,
    required this.size,
    required this.borderColor,
    required this.foregroundColor,
  });

  final String? imageUrl;
  final Color accent;
  final double size;
  final Color borderColor;
  final Color foregroundColor;

  @override
  State<_BrotherhoodShieldAvatar> createState() => _BrotherhoodShieldAvatarState();
}

class _BrotherhoodShieldAvatarState extends State<_BrotherhoodShieldAvatar> {
  File? _cachedFile;

  @override
  void initState() {
    super.initState();
    _loadCachedFile();
  }

  @override
  void didUpdateWidget(covariant _BrotherhoodShieldAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _cachedFile = null;
      _loadCachedFile();
    }
  }

  Future<void> _loadCachedFile() async {
    final url = widget.imageUrl;
    if (url == null || url.trim().isEmpty) {
      return;
    }
    try {
      final file = await PrivateImageCache.getOrFetchShield(url);
      if (!mounted) {
        return;
      }
      if (file != null) {
        setState(() {
          _cachedFile = file;
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _cachedFile = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.imageUrl != null && widget.imageUrl!.trim().isNotEmpty;

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: widget.borderColor, width: 1.2),
        color: widget.accent.withValues(alpha: 0.25),
      ),
      clipBehavior: Clip.antiAlias,
      child: _cachedFile != null
          ? Image.file(_cachedFile!, fit: BoxFit.cover)
          : hasImage
          ? Image.network(
              widget.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.shield_rounded,
                color: widget.foregroundColor,
                size: widget.size * 0.62,
              ),
            )
          : Icon(
              Icons.shield_rounded,
              color: widget.foregroundColor,
              size: widget.size * 0.62,
            ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.title, required this.child});

  final String title;
  final Widget child;

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
            child,
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _FigureCardsContent extends StatelessWidget {
  const _FigureCardsContent({required this.figures, required this.emptyLabel});

  final List<_BrotherhoodFigureItem> figures;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (figures.isEmpty) {
      return Text(emptyLabel);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < figures.length; i++) ...[
          Text(
            figures[i].name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (figures[i].description != null &&
              figures[i].description!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(_sanitizeHistoryText(figures[i].description!.trim())),
          ],
          if (i != figures.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _PasoCardsContent extends StatelessWidget {
  const _PasoCardsContent({required this.pasos, required this.emptyLabel});

  final List<_BrotherhoodPasoItem> pasos;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (pasos.isEmpty) {
      return Text(emptyLabel);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < pasos.length; i++) ...[
          Text(
            pasos[i].name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (pasos[i].description != null &&
              pasos[i].description!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(_sanitizeHistoryText(pasos[i].description!.trim())),
          ],
          if (i != pasos.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

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
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
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

String _resolveShortName(
  DayProcessionEvent? event, {
  required String fallback,
}) {
  final fromApi = event?.brotherhoodShortName;
  if (fromApi != null && fromApi.trim().isNotEmpty) {
    return fromApi.trim();
  }

  final name = event?.brotherhoodName ?? fallback;
  final normalized = name.trim();
  if (normalized.isEmpty) {
    return fallback;
  }

  const ignored = {'la', 'el', 'los', 'las', 'de', 'del', 'y'};
  final parts = normalized
      .split(RegExp(r'\s+'))
      .where((part) => part.trim().isNotEmpty)
      .toList(growable: false);
  final filtered = parts
      .where((part) => !ignored.contains(part.toLowerCase()))
      .toList(growable: false);

  if (filtered.isEmpty) {
    return normalized;
  }

  if (filtered.length == 1) {
    return filtered.first;
  }

  return '${filtered[0]} ${filtered[1]}';
}

class _BrotherhoodVisualData {
  const _BrotherhoodVisualData({
    required this.shortName,
    required this.fullName,
    required this.foundationYear,
    required this.history,
    required this.dressCode,
    required this.figures,
    required this.pasos,
    required this.headerImageUrl,
    required this.shieldImageUrl,
  });

  final String? shortName;
  final String? fullName;
  final int? foundationYear;
  final String? history;
  final String? dressCode;
  final List<_BrotherhoodFigureItem> figures;
  final List<_BrotherhoodPasoItem> pasos;
  final String? headerImageUrl;
  final String? shieldImageUrl;
}

class _BrotherhoodFigureItem {
  const _BrotherhoodFigureItem({
    required this.name,
    required this.description,
  });

  final String name;
  final String? description;
}

class _BrotherhoodPasoItem {
  const _BrotherhoodPasoItem({
    required this.name,
    required this.description,
  });

  final String name;
  final String? description;
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
    if (value is int) {
      return value;
    }
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

String? _resolveHistoryText(Map<String, dynamic> source) {
  final direct = _pickString(source, const ['history', 'historia', 'about']);
  if (direct != null && direct.trim().isNotEmpty) {
    return _sanitizeHistoryText(direct);
  }

  final metadata = source['metadata'];
  if (metadata is Map<String, dynamic>) {
    final metaText = _pickString(
      metadata,
      const ['history', 'historia', 'about', 'description'],
    );
    if (metaText != null && metaText.trim().isNotEmpty) {
      return _sanitizeHistoryText(metaText);
    }
  }

  final rich = source['history'];
  final extracted = _extractHistoryFromDynamic(rich);
  if (extracted != null && extracted.trim().isNotEmpty) {
    return _sanitizeHistoryText(extracted);
  }

  return null;
}

String? _resolveDressCodeText(Map<String, dynamic> source) {
  final direct = _pickString(source, const ['dress_code', 'dressCode']);
  if (direct != null && direct.trim().isNotEmpty) {
    return direct.trim();
  }

  final metadata = source['metadata'];
  if (metadata is Map<String, dynamic>) {
    final fromMetadata = _pickString(metadata, const [
      'dress_code',
      'dressCode',
    ]);
    if (fromMetadata != null && fromMetadata.trim().isNotEmpty) {
      return fromMetadata.trim();
    }
  }
  return null;
}

List<_BrotherhoodFigureItem> _parseFigureItems(Object? raw) {
  if (raw is! List) {
    return const [];
  }
  final items = <_BrotherhoodFigureItem>[];
  for (final entry in raw) {
    if (entry is! Map<String, dynamic>) {
      continue;
    }
    final name = _pickString(entry, const ['name']);
    if (name == null || name.trim().isEmpty) {
      continue;
    }
    items.add(
      _BrotherhoodFigureItem(
        name: name.trim(),
        description: _resolveDescriptionText(entry),
      ),
    );
  }
  return items;
}

List<_BrotherhoodPasoItem> _parsePasoItems(Object? raw) {
  if (raw is! List) {
    return const [];
  }
  final items = <_BrotherhoodPasoItem>[];
  for (final entry in raw) {
    if (entry is! Map<String, dynamic>) {
      continue;
    }
    final name = _pickString(entry, const ['name']);
    if (name == null || name.trim().isEmpty) {
      continue;
    }
    items.add(
      _BrotherhoodPasoItem(
        name: name.trim(),
        description: _resolveDescriptionText(entry),
      ),
    );
  }
  return items;
}

String? _resolveDescriptionText(Map<String, dynamic> source) {
  final direct = _pickString(source, const ['description', 'desc', 'text']);
  if (direct != null && direct.trim().isNotEmpty) {
    return direct.trim();
  }

  final dynamicDescription = _extractHistoryFromDynamic(
    source['description'] ?? source['text'] ?? source['content'],
  );
  if (dynamicDescription != null && dynamicDescription.trim().isNotEmpty) {
    return dynamicDescription.trim();
  }

  final metadata = source['metadata'];
  if (metadata is Map<String, dynamic>) {
    final fromMetadata = _pickString(
      metadata,
      const ['description', 'desc', 'text'],
    );
    if (fromMetadata != null && fromMetadata.trim().isNotEmpty) {
      return fromMetadata.trim();
    }
  }

  return null;
}

String? _extractHistoryFromDynamic(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value;
  }
  if (value is List) {
    final parts = value
        .map(_extractHistoryFromDynamic)
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return null;
    }
    return parts.join('\n');
  }
  if (value is Map) {
    final parts = <String>[];
    for (final key in const ['text', 'content', 'value', 'history', 'html']) {
      final candidate = _extractHistoryFromDynamic(value[key]);
      if (candidate != null && candidate.trim().isNotEmpty) {
        parts.add(candidate);
      }
    }
    if (parts.isNotEmpty) {
      return parts.join('\n');
    }
    final nested = value.values
        .map(_extractHistoryFromDynamic)
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (nested.isEmpty) {
      return null;
    }
    return nested.join('\n');
  }
  return value.toString();
}

String _sanitizeHistoryText(String raw) {
  var text = raw;
  text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
  text = text.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n');
  text = text.replaceAll(RegExp(r'<[^>]+>'), '');
  text = text.replaceAll('&nbsp;', ' ');
  text = text.replaceAll('&amp;', '&');
  text = text.replaceAll('&quot;', '"');
  text = text.replaceAll('&#39;', "'");
  text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return text.trim();
}

String? _resolveImageUrl(String? raw, String baseApiUrl) {
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

String _formatCount(int? value) {
  if (value == null || value <= 0) {
    return '--';
  }

  final raw = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final reverseIndex = raw.length - i;
    buffer.write(raw[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write('.');
    }
  }
  return buffer.toString();
}

String _formatTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
