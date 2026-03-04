import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/app_database.dart';

final themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

class ThemeModeController extends Notifier<ThemeMode> {
  static const _themeModeSettingKey = 'theme_mode';

  @override
  ThemeMode build() {
    _restorePersistedThemeMode();
    return ThemeMode.system;
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await ref.read(appDatabaseProvider).saveSetting(
      key: _themeModeSettingKey,
      value: mode.name,
    );
  }

  Future<void> _restorePersistedThemeMode() async {
    final savedValue = await ref
        .read(appDatabaseProvider)
        .readSetting(_themeModeSettingKey);
    final savedMode = _themeModeFromName(savedValue);
    if (savedMode == null) {
      return;
    }

    state = savedMode;
  }

  ThemeMode? _themeModeFromName(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }

    for (final value in ThemeMode.values) {
      if (value.name == raw) {
        return value;
      }
    }

    return null;
  }
}
