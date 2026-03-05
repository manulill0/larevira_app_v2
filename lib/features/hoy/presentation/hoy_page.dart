import 'package:flutter/material.dart';

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
        'Resumen del día disponible 100% en local.',
        'Eventos próximos y cambios recientes preparados para caché persistente.',
        'Diseño orientado a reacción rápida en entornos con poca cobertura.',
      ],
      extraContent: [_UpcomingContent()],
    );
  }
}

class _UpcomingContent extends StatelessWidget {
  const _UpcomingContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
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
                Icon(Icons.schedule_rounded, color: colorScheme.secondary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Aquí mostraremos el resumen vivo del día, con foco en la consulta más rápida posible.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
