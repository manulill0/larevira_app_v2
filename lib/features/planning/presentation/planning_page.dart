import 'package:flutter/material.dart';

import '../../shared/presentation/feature_placeholder_page.dart';

class PlanningPage extends StatelessWidget {
  const PlanningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Mi planning',
      icon: Icons.route,
      summary: 'Espacio personal para organizar recorridos y decisiones del usuario.',
      highlights: [
        'Cambios del usuario persistidos en local como fuente principal.',
        'Base para favoritos, rutas, notas y puntos guardados.',
        'Pensado para sincronizacion diferida cuando exista conectividad.',
      ],
    );
  }
}
