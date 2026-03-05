import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppPageSurfaces {
  const AppPageSurfaces._();

  static Color sliverAppBarBackground(Brightness brightness) {
    return brightness == Brightness.dark
        ? AppColors.backgroundDarkTop
        : AppColors.lightChrome;
  }

  static LinearGradient jornadasBackground(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final top = isDark ? AppColors.backgroundDarkTop : AppColors.lightPage;
    final mid = isDark
        ? Color.lerp(
            AppColors.backgroundDarkTop,
            AppColors.backgroundDarkBottom,
            0.45,
          )!
        : Color.lerp(
            AppColors.lightSurface,
            AppColors.backgroundLightTop,
            0.55,
          )!;
    final bottom = isDark
        ? AppColors.backgroundDarkBottom
        : AppColors.backgroundLightBottom;

    return LinearGradient(
      colors: [top, mid, bottom],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  static LinearGradient startupBackground(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? const [AppColors.backgroundDarkTop, AppColors.backgroundDarkBottom]
          : const [
              AppColors.backgroundLightTop,
              AppColors.backgroundLightBottom,
            ],
    );
  }
}
