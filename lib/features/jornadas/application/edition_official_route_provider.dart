import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_instance_controller.dart';
import '../../../core/models/day_detail.dart';
import '../../../core/network/larevira_api_client.dart';

final editionOfficialRouteProvider = FutureProvider<EditionOfficialRoute?>((
  ref,
) async {
  final appInstance = ref.watch(appInstanceProvider);
  final year = ref.watch(editionYearProvider);
  final apiClient = ref.watch(lareviraApiClientProvider);

  try {
    final response = await apiClient.getScoped(
      appInstance.citySlug,
      year,
      '/edition',
    );
    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      return null;
    }

    final data = (payload['data'] as Map<String, dynamic>? ?? const {});
    return EditionOfficialRoute.fromEditionJson(data);
  } catch (_) {
    return null;
  }
});

class EditionOfficialRoute {
  const EditionOfficialRoute({
    required this.argb,
    required this.points,
  });

  final String? argb;
  final List<RoutePoint> points;

  bool get hasGeometry => points.where((point) => point.hasLocation).length >= 2;

  factory EditionOfficialRoute.fromEditionJson(Map<String, dynamic> json) {
    final route = _resolveOfficialRouteContainer(json);
    final points = _resolveRoutePoints(route);
    final argb = _resolveArgb(route);

    return EditionOfficialRoute(
      argb: argb,
      points: points,
    );
  }
}

Map<String, dynamic> _resolveOfficialRouteContainer(Map<String, dynamic> json) {
  for (final key in const [
    'official_route',
    'official_itinerary',
    'carrera_oficial',
    'race_course',
    'route',
  ]) {
    final value = json[key];
    if (value is Map<String, dynamic>) {
      return value;
    }
  }

  return json;
}

List<RoutePoint> _resolveRoutePoints(Map<String, dynamic> container) {
  for (final key in const ['path_points', 'route_points', 'points']) {
    final raw = container[key];
    if (raw is List<dynamic>) {
      final points = raw
          .whereType<Map<String, dynamic>>()
          .map(RoutePoint.fromJson)
          .where((point) => point.hasLocation)
          .toList(growable: false);
      if (points.length >= 2) {
        return points;
      }
    }
  }

  final sections = container['route_sections'];
  if (sections is List<dynamic>) {
    for (final rawSection in sections) {
      if (rawSection is! Map<String, dynamic>) {
        continue;
      }
      final name = (rawSection['name'] ?? '').toString().toLowerCase();
      if (!name.contains('carrera oficial') && !name.contains('carreda oficial')) {
        continue;
      }
      final rawPoints = rawSection['points'];
      if (rawPoints is! List<dynamic>) {
        continue;
      }
      final points = rawPoints
          .whereType<Map<String, dynamic>>()
          .map(RoutePoint.fromJson)
          .where((point) => point.hasLocation)
          .toList(growable: false);
      if (points.length >= 2) {
        return points;
      }
    }
  }

  return const [];
}

String? _resolveArgb(Map<String, dynamic> route) {
  for (final key in const ['argb', 'color_argb', 'line_color_argb', 'stroke_argb']) {
    final value = route[key];
    if (value == null) {
      continue;
    }
    final normalized = _normalizeArgb(value.toString());
    if (normalized != null) {
      return normalized;
    }
  }

  return null;
}

String? _normalizeArgb(String raw) {
  final value = raw.trim();
  if (value.isEmpty) {
    return null;
  }

  if (value.startsWith('#') && value.length == 9) {
    return value;
  }
  if ((value.startsWith('0x') || value.startsWith('0X')) && value.length == 10) {
    return '#${value.substring(2)}';
  }
  if (RegExp(r'^[0-9a-fA-F]{8}$').hasMatch(value)) {
    return '#$value';
  }

  return value;
}
