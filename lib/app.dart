import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_instance_controller.dart';
import 'core/network/larevira_api_client.dart';
import 'core/push/push_notifications_controller.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';
import 'features/sync/application/sync_controller.dart';

class LaReviraApp extends ConsumerStatefulWidget {
  const LaReviraApp({super.key});

  @override
  ConsumerState<LaReviraApp> createState() => _LaReviraAppState();
}

class _LaReviraAppState extends ConsumerState<LaReviraApp>
    with WidgetsBindingObserver {
  static const _liveWeatherInterval = Duration(minutes: 5);
  PushNotificationsController? _pushController;
  StreamSubscription<ProcessionStatusUpdate>? _pushUpdatesSubscription;
  Timer? _liveWeatherTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future<void>.microtask(_initializePushNotifications);
    Future<void>.microtask(_initializeLiveWeatherRefresh);
  }

  Future<void> _initializePushNotifications() async {
    final appInstance = ref.read(appInstanceProvider);
    final apiClient = ref.read(lareviraApiClientProvider);

    final controller = PushNotificationsController(
      apiClient: apiClient,
      citySlug: appInstance.citySlug,
      currentEditionYear: () => ref.read(editionYearProvider),
    );

    _pushController = controller;
    _pushUpdatesSubscription = controller.updates.listen((update) {
      final currentYear = ref.read(editionYearProvider);
      if (update.citySlug != appInstance.citySlug ||
          update.year != currentYear) {
        return;
      }

      ref.read(syncControllerProvider.notifier).syncManually();
    });
    await controller.initialize();
  }

  Future<void> _initializeLiveWeatherRefresh() async {
    await ref.read(syncControllerProvider.notifier).syncLiveWeather();

    _liveWeatherTimer?.cancel();
    _liveWeatherTimer = Timer.periodic(_liveWeatherInterval, (_) {
      unawaited(ref.read(syncControllerProvider.notifier).syncLiveWeather());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(
        ref.read(syncControllerProvider.notifier).syncLiveWeather(force: true),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _liveWeatherTimer?.cancel();
    _pushUpdatesSubscription?.cancel();
    unawaited(_pushController?.dispose() ?? Future<void>.value());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          child: SafeArea(
            top: false,
            bottom: false,
            left: true,
            right: true,
            child: child,
          ),
        );
      },
      routerConfig: router,
    );
  }
}
