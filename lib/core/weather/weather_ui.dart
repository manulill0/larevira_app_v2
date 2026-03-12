import 'package:flutter/material.dart';

IconData weatherIconForCode(String? code) {
  final value = code?.toLowerCase() ?? '';
  if (value.contains('tormenta')) {
    return Icons.thunderstorm_rounded;
  }
  if (value.contains('lluv') || value.contains('rain')) {
    return Icons.water_drop_rounded;
  }
  if (value.contains('nieve')) {
    return Icons.ac_unit_rounded;
  }
  if (value.contains('nublado') || value.contains('cloud')) {
    return Icons.cloud_rounded;
  }
  if (value.contains('niebla')) {
    return Icons.blur_on_rounded;
  }
  return Icons.wb_sunny_rounded;
}

String formatTemperatureMinMax(double? min, double? max) {
  final minLabel = min == null ? '--' : '${min.round()}°';
  final maxLabel = max == null ? '--' : '${max.round()}°';
  return '$minLabel / $maxLabel';
}

String formatTemperature(double? value) {
  return value == null ? '--' : '${value.round()}°';
}
