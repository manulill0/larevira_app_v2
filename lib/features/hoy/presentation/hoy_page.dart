import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/day_index_item.dart';
import '../../../core/weather/weather_ui.dart';
import '../../jornadas/application/jornadas_controller.dart';
import '../../shared/presentation/feature_placeholder_page.dart';

class HoyPage extends StatelessWidget {
  const HoyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Hoy',
      icon: Icons.wb_sunny_rounded,
      summary: 'Vista inmediata de la jornada activa y los hitos clave.',
      highlights: [
        'Resumen meteorologico por horas para la jornada activa.',
        'Datos sincronizados y disponibles en local.',
        'Referencia rapida para decidir salida y seguimiento.',
      ],
      extraContent: [_TodayWeatherPanel()],
    );
  }
}

class _TodayWeatherPanel extends ConsumerWidget {
  const _TodayWeatherPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final jornadasAsync = ref.watch(jornadasProvider);

    return jornadasAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('No se pudo cargar la meteo local: $error'),
        ),
      ),
      data: (days) {
        final today = _resolveCurrentDay(days);
        final weather = today?.weather;

        if (today == null || weather == null || !weather.hasHourlyBreakdown) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.cloud_off_rounded, color: colorScheme.secondary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Aun no hay meteo por horas para hoy. Puedes cargarla en admin y sincronizar.',
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  weatherIconForCode(weather.iconCode),
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  today.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatTemperatureMinMax(weather.tempMinC, weather.tempMaxC),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    for (final point in weather.hourly) ...[
                      Row(
                        children: [
                          SizedBox(
                            width: 52,
                            child: Text(
                              point.hourLabel,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Icon(
                            weatherIconForCode(point.iconCode),
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              point.conditionLabel ?? 'Sin detalle',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            formatTemperature(point.temperatureC),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (point.precipitationProbability != null)
                            Text(
                              '  ${point.precipitationProbability}%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.75,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (point != weather.hourly.last)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(height: 1),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

DayIndexItem? _resolveCurrentDay(List<DayIndexItem> days) {
  if (days.isEmpty) {
    return null;
  }

  final now = DateTime.now();
  final todayOnly = DateTime(now.year, now.month, now.day);

  for (final day in days) {
    final liturgical = day.liturgicalDate;
    if (liturgical != null &&
        liturgical.year == todayOnly.year &&
        liturgical.month == todayOnly.month &&
        liturgical.day == todayOnly.day) {
      return day;
    }
  }

  for (final day in days) {
    final startsAt = day.startsAt;
    if (startsAt != null &&
        startsAt.year == todayOnly.year &&
        startsAt.month == todayOnly.month &&
        startsAt.day == todayOnly.day) {
      return day;
    }
  }

  final upcoming = days
      .where((day) => day.startsAt != null && day.startsAt!.isAfter(now))
      .toList(growable: false)
    ..sort((a, b) => a.startsAt!.compareTo(b.startsAt!));
  if (upcoming.isNotEmpty) {
    return upcoming.first;
  }

  return days.first;
}
