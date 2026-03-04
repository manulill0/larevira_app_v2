import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static const _titleFontFamily = 'Cinzel';
  static const _referenceShortestSide = 390.0;
  static const _minFontScale = 0.92;
  static const _maxFontScale = 1.12;

  static ThemeData light() {
    return _buildTheme(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.lightSurface,
        brightness: Brightness.light,
      ),
      outline: AppColors.secondary.withValues(alpha: 0.22),
      scaffoldBackground: AppColors.lightPage,
      appBarBackground: AppColors.lightChrome,
      navigationBackground: AppColors.lightNavigation,
      appBarForeground: AppColors.lightTextPrimary,
      cardColor: AppColors.lightCard,
    );
  }

  static ThemeData dark() {
    return _buildTheme(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.darkPrimary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        brightness: Brightness.dark,
      ),
      outline: AppColors.darkPrimary.withValues(alpha: 0.22),
      scaffoldBackground: AppColors.darkSurface,
      appBarBackground: AppColors.darkSurface,
      navigationBackground: AppColors.darkNavigation,
      appBarForeground: AppColors.darkTextPrimary,
      cardColor: AppColors.darkCard,
    );
  }

  static ThemeData adaptToScreen({
    required ThemeData theme,
    required Size screenSize,
  }) {
    final fontScale = _fontScale(screenSize);
    final navigationLabelStyle = theme.navigationBarTheme.labelTextStyle;

    return theme.copyWith(
      textTheme: theme.textTheme.apply(fontSizeFactor: fontScale),
      primaryTextTheme: theme.primaryTextTheme.apply(fontSizeFactor: fontScale),
      appBarTheme: theme.appBarTheme.copyWith(
        titleTextStyle: _scaleTextStyle(
          theme.appBarTheme.titleTextStyle,
          fontScale,
        ),
      ),
      navigationBarTheme: theme.navigationBarTheme.copyWith(
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final style = navigationLabelStyle?.resolve(states);
          return _scaleTextStyle(style, fontScale);
        }),
      ),
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Color outline,
    required Color scaffoldBackground,
    required Color appBarBackground,
    required Color navigationBackground,
    required Color appBarForeground,
    required Color cardColor,
  }) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
    );
    final baseTextTheme = baseTheme.textTheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final navigationSelectedColor = isDark
        ? colorScheme.onSurface
        : AppColors.lightTextPrimary;
    final navigationIndicatorColor = isDark
        ? colorScheme.primary.withValues(alpha: 0.18)
        : colorScheme.secondary;

    final textTheme = baseTextTheme.copyWith(
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontFamily: _titleFontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 30,
        letterSpacing: 0.3,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontFamily: _titleFontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 28,
        letterSpacing: 0.3,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontFamily: _titleFontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        letterSpacing: 0.15,
      ),
    );

    return baseTheme.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: appBarForeground,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: appBarForeground),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navigationBackground,
        indicatorColor: navigationIndicatorColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.0 : 0.04),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected
                ? navigationSelectedColor
                : colorScheme.onSurfaceVariant,
            size: isSelected ? 26 : 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected
                ? navigationSelectedColor
                : colorScheme.onSurfaceVariant,
          );
        }),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: outline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withValues(alpha: 0.12);
            }
            return colorScheme.primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withValues(alpha: 0.38);
            }
            return colorScheme.onPrimary;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(colorScheme.primary),
          side: WidgetStateProperty.resolveWith((states) {
            final alpha = states.contains(WidgetState.disabled) ? 0.12 : 0.36;

            return BorderSide(
              color: colorScheme.primary.withValues(alpha: alpha),
            );
          }),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.accentRose.withValues(alpha: 0.14);
            }
            return colorScheme.surface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary;
            }
            return colorScheme.onSurfaceVariant;
          }),
          side: WidgetStatePropertyAll(BorderSide(color: outline)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withValues(alpha: 0.35);
          }
          return null;
        }),
      ),
      dividerColor: colorScheme.outlineVariant,
    );
  }

  static double _fontScale(Size screenSize) {
    final shortestSide = screenSize.shortestSide;
    final rawScale = shortestSide / _referenceShortestSide;

    return rawScale.clamp(_minFontScale, _maxFontScale);
  }

  static TextStyle? _scaleTextStyle(TextStyle? style, double factor) {
    if (style == null || style.fontSize == null) {
      return style;
    }

    return style.copyWith(fontSize: style.fontSize! * factor);
  }
}
