import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_instance_config.dart';

final appInstanceProvider = Provider<AppInstanceConfig>((ref) {
  return AppInstanceConfig(
    citySlug: const String.fromEnvironment(
      'CITY_SLUG',
      defaultValue: 'sevilla',
    ),
    baseApiUrl: const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://admin.larevira.app/api/v1',
    ),
    defaultEditionYear: int.fromEnvironment('EDITION_YEAR', defaultValue: 2025),
  );
});

final instanceOverridesEnabledProvider = Provider<bool>((ref) {
  return kDebugMode ||
      const bool.fromEnvironment(
        'ALLOW_INSTANCE_OVERRIDES',
        defaultValue: false,
      );
});

final editionYearProvider = NotifierProvider<EditionYearController, int>(
  EditionYearController.new,
);

class EditionYearController extends Notifier<int> {
  @override
  int build() {
    return ref.read(appInstanceProvider).defaultEditionYear;
  }

  void setYear(int year) {
    if (!ref.read(instanceOverridesEnabledProvider)) {
      return;
    }
    state = year;
  }

  void increment() {
    if (!ref.read(instanceOverridesEnabledProvider)) {
      return;
    }
    state = state + 1;
  }

  void decrement() {
    if (!ref.read(instanceOverridesEnabledProvider)) {
      return;
    }
    state = state - 1;
  }
}
