import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_instance_controller.dart';
import '../../../core/network/larevira_api_client.dart';
import '../../../core/theme/theme_mode_controller.dart';
import '../../../core/time/test_clock_controller.dart';
import '../../../core/widgets/adaptive_app_bar_title.dart';
import '../../../core/widgets/sliver_scroll_state_mixin.dart';
import '../../sync/application/sync_controller.dart';

class MorePage extends ConsumerStatefulWidget {
  const MorePage({super.key});

  @override
  ConsumerState<MorePage> createState() => _MorePageState();
}

class _MorePageState extends ConsumerState<MorePage>
    with SliverScrollStateMixin<MorePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final appBarBackground = isDark
        ? Colors.black.withValues(alpha: 0.16)
        : Colors.white.withValues(alpha: 0.92);
    final appInstance = ref.watch(appInstanceProvider);
    final instanceOverridesEnabled = ref.watch(
      instanceOverridesEnabledProvider,
    );
    final editionYear = ref.watch(editionYearProvider);
    final themeMode = ref.watch(themeModeProvider);
    final apiClient = ref.watch(lareviraApiClientProvider);
    final testClock = ref.watch(testClockProvider);
    final syncState = ref.watch(syncControllerProvider);
    final sampleDaysPath = apiClient.buildScopedPath(
      appInstance.citySlug,
      editionYear,
      '/days',
    );

    return NotificationListener<ScrollNotification>(
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
            title: const AdaptiveAppBarTitle('Más'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverList.list(
              children: [
                _SectionTitle(title: 'API Base URL'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Base configurada',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(appInstance.baseApiUrl),
                        const SizedBox(height: 14),
                        Text(
                          'Ruta ejemplo',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(sampleDaysPath),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(title: 'Ciudad / Edición'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_city_outlined,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                appInstance.citySlug,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Edición activa',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      '$editionYear',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (instanceOverridesEnabled) ...[
                              const SizedBox(width: 12),
                              Column(
                                children: [
                                  OutlinedButton(
                                    onPressed: () {
                                      ref
                                          .read(editionYearProvider.notifier)
                                          .decrement();
                                    },
                                    child: const Icon(Icons.remove),
                                  ),
                                  const SizedBox(height: 8),
                                  OutlinedButton(
                                    onPressed: () {
                                      ref
                                          .read(editionYearProvider.notifier)
                                          .increment();
                                    },
                                    child: const Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          instanceOverridesEnabled
                              ? 'Modo desarrollo: puedes probar otra edición desde esta pantalla.'
                              : 'La ciudad y la edición vienen fijadas por la configuración de esta app.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(title: 'Tema'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 340;

                        if (isCompact) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _ThemeModeButton(
                                label: 'Claro',
                                icon: Icons.light_mode_outlined,
                                isSelected: themeMode == ThemeMode.light,
                                onPressed: () {
                                  ref
                                      .read(themeModeProvider.notifier)
                                      .setMode(ThemeMode.light);
                                },
                              ),
                              const SizedBox(height: 8),
                              _ThemeModeButton(
                                label: 'Sistema',
                                icon: Icons.brightness_auto_outlined,
                                isSelected: themeMode == ThemeMode.system,
                                onPressed: () {
                                  ref
                                      .read(themeModeProvider.notifier)
                                      .setMode(ThemeMode.system);
                                },
                              ),
                              const SizedBox(height: 8),
                              _ThemeModeButton(
                                label: 'Oscuro',
                                icon: Icons.dark_mode_outlined,
                                isSelected: themeMode == ThemeMode.dark,
                                onPressed: () {
                                  ref
                                      .read(themeModeProvider.notifier)
                                      .setMode(ThemeMode.dark);
                                },
                              ),
                            ],
                          );
                        }

                        return SegmentedButton<ThemeMode>(
                          showSelectedIcon: false,
                          expandedInsets: EdgeInsets.zero,
                          segments: const [
                            ButtonSegment(
                              value: ThemeMode.light,
                              icon: Icon(Icons.light_mode_outlined),
                              label: Text('Claro'),
                            ),
                            ButtonSegment(
                              value: ThemeMode.system,
                              icon: Icon(Icons.brightness_auto_outlined),
                              label: Text('Sistema'),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              icon: Icon(Icons.dark_mode_outlined),
                              label: Text('Oscuro'),
                            ),
                          ],
                          selected: {themeMode},
                          onSelectionChanged: (selection) {
                            ref
                                .read(themeModeProvider.notifier)
                                .setMode(selection.first);
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(title: 'Reloj de Pruebas'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Activar reloj simulado'),
                          subtitle: const Text(
                            'Permite adelantar o retrasar la hora visible para pruebas.',
                          ),
                          value: testClock.enabled,
                          onChanged: (value) {
                            ref
                                .read(testClockProvider.notifier)
                                .setEnabled(value);
                          },
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _formatDateTime(testClock.currentTime),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            ref
                                .read(testClockProvider.notifier)
                                .setTime(_palmSundayAtSevenPm(editionYear));
                          },
                          icon: const Icon(Icons.event_available_rounded),
                          label: Text('Domingo de Ramos $editionYear · 19:00'),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _ClockAdjustButton(
                              label: '-15 min',
                              onPressed: () {
                                ref
                                    .read(testClockProvider.notifier)
                                    .adjust(const Duration(minutes: -15));
                              },
                            ),
                            _ClockAdjustButton(
                              label: '+15 min',
                              onPressed: () {
                                ref
                                    .read(testClockProvider.notifier)
                                    .adjust(const Duration(minutes: 15));
                              },
                            ),
                            _ClockAdjustButton(
                              label: '+1 hora',
                              onPressed: () {
                                ref
                                    .read(testClockProvider.notifier)
                                    .adjust(const Duration(hours: 1));
                              },
                            ),
                            _ClockAdjustButton(
                              label: 'Reset',
                              onPressed: () {
                                ref.read(testClockProvider.notifier).reset();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(title: 'Sincronización manual de datos'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'La app intenta sincronizar al abrirse. Desde aquí puedes forzar una nueva sincronización manual.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          onPressed: syncState.isSyncing ? null : _syncAllData,
                          icon: syncState.isSyncing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.sync_rounded),
                          label: Text(
                            syncState.isSyncing
                                ? 'Sincronizando...'
                                : 'Sincronizar datos',
                          ),
                        ),
                        if (syncState.lastSyncedAt != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Última sincronización: ${_formatDateTime(syncState.lastSyncedAt!)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (syncState.message != null) ...[
                          const SizedBox(height: 8),
                          SelectableText(
                            syncState.message!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: syncState.message!.startsWith('OK')
                                  ? colorScheme.primary
                                  : colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _syncAllData() async {
    await ref.read(syncControllerProvider.notifier).syncManually();
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _ClockAdjustButton extends StatelessWidget {
  const _ClockAdjustButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(onPressed: onPressed, child: Text(label));
  }
}

class _ThemeModeButton extends StatelessWidget {
  const _ThemeModeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

String _formatDateTime(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString().padLeft(4, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}

DateTime _palmSundayAtSevenPm(int year) {
  final easterSunday = _easterSunday(year);
  final palmSunday = easterSunday.subtract(const Duration(days: 7));
  return DateTime(palmSunday.year, palmSunday.month, palmSunday.day, 19);
}

DateTime _easterSunday(int year) {
  final a = year % 19;
  final b = year ~/ 100;
  final c = year % 100;
  final d = b ~/ 4;
  final e = b % 4;
  final f = (b + 8) ~/ 25;
  final g = (b - f + 1) ~/ 3;
  final h = (19 * a + b - d - g + 15) % 30;
  final i = c ~/ 4;
  final k = c % 4;
  final l = (32 + 2 * e + 2 * i - h - k) % 7;
  final m = (a + 11 * h + 22 * l) ~/ 451;
  final month = (h + l - 7 * m + 114) ~/ 31;
  final day = ((h + l - 7 * m + 114) % 31) + 1;
  return DateTime(year, month, day);
}
