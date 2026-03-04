import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/adaptive_app_bar_title.dart';

class HoyPage extends StatefulWidget {
  const HoyPage({super.key});

  @override
  State<HoyPage> createState() => _HoyPageState();
}

class _HoyPageState extends State<HoyPage> {
  bool _hasScrolled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final appBarBackground = isDark
        ? AppColors.backgroundDarkTop
        : AppColors.lightChrome;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.depth != 0) {
          return false;
        }

        final nextHasScrolled = notification.metrics.pixels > 0;
        if (nextHasScrolled != _hasScrolled) {
          setState(() {
            _hasScrolled = nextHasScrolled;
          });
        }
        return false;
      },
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor:
                _hasScrolled ? appBarBackground : Colors.transparent,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            forceMaterialTransparency: !_hasScrolled,
            title: const AdaptiveAppBarTitle('Hoy'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverList.list(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.wb_sunny_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Vista inmediata de la jornada activa y los hitos clave.',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pensada para abrir la app y entender la situacion en segundos, incluso sin red.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Prioridades iniciales',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                const _PriorityCard(
                  text: 'Resumen del dia disponible 100% en local.',
                ),
                const SizedBox(height: 12),
                const _PriorityCard(
                  text:
                      'Eventos proximos y cambios recientes preparados para cache persistente.',
                ),
                const SizedBox(height: 12),
                const _PriorityCard(
                  text:
                      'Diseno orientado a reaccion rapida en entornos con poca cobertura.',
                ),
                const SizedBox(height: 20),
                Text(
                  'En camino',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Aqui mostraremos el resumen vivo del dia, con foco en la consulta mas rapida posible.',
                          ),
                        ),
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
}

class _PriorityCard extends StatelessWidget {
  const _PriorityCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        leading: Icon(
          Icons.check_circle_outline,
          color: colorScheme.primary,
        ),
        title: Text(text),
      ),
    );
  }
}
