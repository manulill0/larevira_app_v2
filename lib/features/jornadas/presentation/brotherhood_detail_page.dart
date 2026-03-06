import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_instance_controller.dart';
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
              _MapTab(event: event),
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
              if (isTablet)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _InfoBlock(
                        title: 'Estado',
                        child: Text(_statusLabel(event!)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoBlock(
                        title: 'Identificador',
                        child: SelectableText(
                          event!.brotherhoodSlug.isEmpty
                              ? 'Sin slug disponible'
                              : event!.brotherhoodSlug,
                        ),
                      ),
                    ),
                  ],
                )
              else ...[
                _InfoBlock(title: 'Estado', child: Text(_statusLabel(event!))),
                const SizedBox(height: 12),
                _InfoBlock(
                  title: 'Identificador',
                  child: SelectableText(
                    event!.brotherhoodSlug.isEmpty
                        ? 'Sin slug disponible'
                        : event!.brotherhoodSlug,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              if (isTablet)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _InfoBlock(
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
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoBlock(
                        title: 'Nota oficial',
                        child: Text(
                          event!.officialNote.isEmpty
                              ? 'No hay nota oficial para esta hermandad en la jornada.'
                              : event!.officialNote,
                        ),
                      ),
                    ),
                  ],
                )
              else ...[
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
                const SizedBox(height: 12),
                _InfoBlock(
                  title: 'Nota oficial',
                  child: Text(
                    event!.officialNote.isEmpty
                        ? 'No hay nota oficial para esta hermandad en la jornada.'
                        : event!.officialNote,
                  ),
                ),
              ],
            ],
    );
  }
}

class _ItineraryTab extends StatelessWidget {
  const _ItineraryTab({required this.event});

  final DayProcessionEvent? event;

  @override
  Widget build(BuildContext context) {
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

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      itemCount: points.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final point = points[index];
        return _InfoBlock(
          title: '${index + 1}. ${point.name}',
          child: Text(
            point.plannedAt == null
                ? 'Hora no disponible'
                : 'Hora prevista: ${_formatTime(point.plannedAt!)}',
          ),
        );
      },
    );
  }
}

class _MapTab extends StatelessWidget {
  const _MapTab({required this.event});

  final DayProcessionEvent? event;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      children: [
        _InfoBlock(
          title: 'Mapa',
          child: Text(
            event == null
                ? 'No hay geometría disponible para esta hermandad en esta jornada.'
                : 'Vista de mapa específica de hermandad en preparación.',
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
        ? Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _FallbackBrotherhoodHeader(accent: accent),
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

class _BrotherhoodShieldAvatar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.2),
        color: accent.withValues(alpha: 0.25),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.shield_rounded,
                color: foregroundColor,
                size: size * 0.62,
              ),
            )
          : Icon(
              Icons.shield_rounded,
              color: foregroundColor,
              size: size * 0.62,
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

String _statusLabel(DayProcessionEvent event) {
  final pass = event.passDurationMinutes;
  if (pass != null) {
    return '${event.status} · $pass min';
  }
  return event.status;
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
    required this.headerImageUrl,
    required this.shieldImageUrl,
  });

  final String? shortName;
  final String? fullName;
  final int? foundationYear;
  final String? headerImageUrl;
  final String? shieldImageUrl;
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
