import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/adaptive_app_bar_title.dart';

class FeaturePlaceholderPage extends StatefulWidget {
  const FeaturePlaceholderPage({
    super.key,
    required this.title,
    required this.icon,
    required this.summary,
    required this.highlights,
  });

  final String title;
  final IconData icon;
  final String summary;
  final List<String> highlights;

  @override
  State<FeaturePlaceholderPage> createState() => _FeaturePlaceholderPageState();
}

class _FeaturePlaceholderPageState extends State<FeaturePlaceholderPage> {
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
            title: AdaptiveAppBarTitle(widget.title),
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
                      Icon(widget.icon, color: Colors.white, size: 28),
                      const SizedBox(height: 16),
                      Text(
                        widget.summary,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Base pensada para consulta rápida y operativa sin red.',
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
                for (final item in widget.highlights) ...[
                  Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      leading: Icon(
                        Icons.check_circle_outline,
                        color: colorScheme.primary,
                      ),
                      title: Text(item),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
