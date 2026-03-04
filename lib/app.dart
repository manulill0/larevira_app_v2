import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';

class LaReviraApp extends ConsumerWidget {
  const LaReviraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'La Revirá',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      builder: (context, child) {
        final mediaQuery = MediaQuery.maybeOf(context);

        if (child == null || mediaQuery == null) {
          return child ?? const SizedBox.shrink();
        }

        return Theme(
          data: AppTheme.adaptToScreen(
            theme: Theme.of(context),
            screenSize: mediaQuery.size,
          ),
          child: child,
        );
      },
      routerConfig: router,
    );
  }
}
