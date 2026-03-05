import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/day_index_item.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_page_surfaces.dart';
import '../../../core/widgets/adaptive_app_bar_title.dart';
import '../../../core/widgets/sliver_scroll_state_mixin.dart';
import '../application/jornadas_controller.dart';

class JornadasPage extends ConsumerStatefulWidget {
  const JornadasPage({super.key});

  @override
  ConsumerState<JornadasPage> createState() => _JornadasPageState();
}

class _JornadasPageState extends ConsumerState<JornadasPage>
    with SliverScrollStateMixin<JornadasPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final appBarBackground = AppPageSurfaces.sliverAppBarBackground(brightness);
    final jornadasAsync = ref.watch(jornadasProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppPageSurfaces.jornadasBackground(brightness),
      ),
      child: NotificationListener<ScrollNotification>(
        onNotification: handleRootScrollNotification,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: hasScrolled
                  ? appBarBackground
                  : Colors.transparent,
              surfaceTintColor: Colors.transparent,
              scrolledUnderElevation: 0,
              forceMaterialTransparency: !hasScrolled,
              title: const AdaptiveAppBarTitle('Jornadas'),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList.list(
                children: [
                  jornadasAsync.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return const _EmptyState();
                      }

                      return Column(
                        children: [
                          for (final item in items) ...[
                            _JornadaCard(item: item),
                            const SizedBox(height: 10),
                          ],
                        ],
                      );
                    },
                    loading: () => const _LoadingState(),
                    error: (error, stackTrace) {
                      return _ErrorState(
                        message: error.toString(),
                        onRetry: () => ref.invalidate(jornadasProvider),
                      );
                    },
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

class _JornadaCard extends StatelessWidget {
  const _JornadaCard({required this.item});

  final DayIndexItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final dateBadgeLabel = _weekdayShortLabel(item.startsAt);
    final dayNumber = _dayNumberLabel(item.startsAt);

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
          onTap: () {
            context.pushDayDetail(item);
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.primary.withValues(alpha: 0.18)
                        : AppColors.accentRose.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dateBadgeLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isDark
                              ? colorScheme.primary
                              : AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        dayNumber,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isDark
                              ? colorScheme.primary
                              : AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontSize:
                              (theme.textTheme.titleSmall?.fontSize ?? 14) + 1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${item.processionEventsCount} hermandades',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 26,
                  color: isDark ? colorScheme.onSurface : AppColors.primary,
                ),
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
              'No se pudo cargar la API',
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('No hay jornadas disponibles.'),
      ),
    );
  }
}

String _weekdayShortLabel(DateTime? value) {
  if (value == null) {
    return '--';
  }

  const labels = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
  return labels[value.weekday - 1];
}

String _dayNumberLabel(DateTime? value) {
  if (value == null) {
    return '--';
  }

  return value.day.toString().padLeft(2, '0');
}
