import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/analytics/analytics_providers.dart';
import 'core/analytics/app_analytics.dart';
import 'core/maps/mapbox_map_helpers.dart';
import 'core/push/push_notifications_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  configureMapboxTokenIfPresent();
  const citySlug = String.fromEnvironment(
    'CITY_SLUG',
    defaultValue: 'sevilla',
  );
  const editionYear = int.fromEnvironment('EDITION_YEAR', defaultValue: 2025);

  final analytics = await AppAnalytics.create(
    citySlug: citySlug,
    editionYear: editionYear,
  );

  runApp(
    ProviderScope(
      overrides: [
        appAnalyticsProvider.overrideWithValue(analytics),
      ],
      child: const LaReviraApp(),
    ),
  );

  analytics?.track('app_open');
}
