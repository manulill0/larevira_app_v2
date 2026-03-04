import 'package:flutter/material.dart';

import '../../../core/models/day_detail.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/adaptive_app_bar_title.dart';

class BrotherhoodDetailPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = _parseColor(event?.brotherhoodColorHex ?? '') ??
        colorScheme.primary;
    final backgroundTop = isDark
        ? AppColors.backgroundDarkTop
        : AppColors.lightPage;
    final backgroundBottom = isDark
        ? AppColors.backgroundDarkBottom
        : AppColors.backgroundLightBottom;
    final title = event?.brotherhoodName ?? 'Hermandad';

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (index) {
          if (index == 2) {
            return;
          }
          Navigator.of(context).pop(index);
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
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              backgroundTop,
              backgroundBottom,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: isDark
                  ? AppColors.backgroundDarkTop
                  : AppColors.lightChrome,
              title: AdaptiveAppBarTitle(title),
              actions: const [
                SizedBox(width: kToolbarHeight),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList.list(
                children: event == null
                    ? [
                        _InfoBlock(
                          title: 'Detalle pendiente',
                          child: Text(
                            'La ruta está preparada para esta hermandad ($slug), pero todavía necesitamos cargar aquí el detalle completo desde la API.',
                          ),
                        ),
                      ]
                    : [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 18,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: accent,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event!.brotherhoodName,
                                      style:
                                          theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dayName ?? 'Jornada',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _InfoBlock(
                          title: 'Estado',
                          child: Text(_statusLabel(event!)),
                        ),
                        const SizedBox(height: 12),
                        _InfoBlock(
                          title: 'Identificador',
                          child: SelectableText(
                            event!.brotherhoodSlug.isEmpty
                                ? 'Sin slug disponible'
                                : event!.brotherhoodSlug,
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
                        const SizedBox(height: 12),
                        _InfoBlock(
                          title: 'Nota oficial',
                          child: Text(
                            event!.officialNote.isEmpty
                                ? 'No hay nota oficial para esta hermandad en la jornada.'
                                : event!.officialNote,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const _InfoBlock(
                          title: 'Detalle ampliado',
                          child: Text(
                            'Esta ficha ya está conectada al router. El siguiente paso será cargar aquí el detalle completo desde /brotherhoods/{slug}.',
                          ),
                        ),
                      ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.title,
    required this.child,
  });

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
