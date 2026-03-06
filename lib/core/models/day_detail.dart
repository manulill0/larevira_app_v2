import 'package:flutter/foundation.dart';

import '../config/debug_flags.dart';

class DayDetail {
  const DayDetail({
    required this.slug,
    required this.name,
    required this.mode,
    required this.officialRouteArgb,
    required this.officialRoutePoints,
    required this.processionEvents,
  });

  final String slug;
  final String name;
  final String mode;
  final String? officialRouteArgb;
  final List<RoutePoint> officialRoutePoints;
  final List<DayProcessionEvent> processionEvents;

  DayDetail copyWith({
    String? slug,
    String? name,
    String? mode,
    String? officialRouteArgb,
    List<RoutePoint>? officialRoutePoints,
    List<DayProcessionEvent>? processionEvents,
  }) {
    return DayDetail(
      slug: slug ?? this.slug,
      name: name ?? this.name,
      mode: mode ?? this.mode,
      officialRouteArgb: officialRouteArgb ?? this.officialRouteArgb,
      officialRoutePoints: officialRoutePoints ?? this.officialRoutePoints,
      processionEvents: processionEvents ?? this.processionEvents,
    );
  }

  factory DayDetail.fromJson(Map<String, dynamic> json) {
    final rawEvents = (json['procession_events'] as List<dynamic>? ?? const []);
    final officialRoute = _resolveOfficialRoute(json);
    final officialRoutePoints = _resolveRoutePointsFromContainer(officialRoute);

    return DayDetail(
      slug: (json['slug'] ?? '') as String,
      name: (json['name'] ?? 'Jornada') as String,
      mode: (json['mode'] ?? 'all') as String,
      officialRouteArgb: _resolveOfficialRouteArgb(officialRoute),
      officialRoutePoints: officialRoutePoints,
      processionEvents: rawEvents
          .whereType<Map<String, dynamic>>()
          .map(DayProcessionEvent.fromJson)
          .toList(growable: false),
    );
  }
}

class DayProcessionEvent {
  const DayProcessionEvent({
    required this.status,
    required this.officialNote,
    required this.passDurationMinutes,
    this.brothersCount,
    this.nazarenesCount,
    required this.brotherhoodName,
    required this.brotherhoodSlug,
    required this.brotherhoodColorHex,
    this.brotherhoodShortName,
    this.brotherhoodHeaderImageUrl,
    this.brotherhoodShieldImageUrl,
    required this.routeArgb,
    required this.schedulePoints,
    required this.routePoints,
  });

  final String status;
  final String officialNote;
  final int? passDurationMinutes;
  final int? brothersCount;
  final int? nazarenesCount;
  final String brotherhoodName;
  final String brotherhoodSlug;
  final String brotherhoodColorHex;
  final String? brotherhoodShortName;
  final String? brotherhoodHeaderImageUrl;
  final String? brotherhoodShieldImageUrl;
  final String? routeArgb;
  final List<SchedulePoint> schedulePoints;
  final List<RoutePoint> routePoints;

  DayProcessionEvent copyWith({
    String? status,
    String? officialNote,
    int? passDurationMinutes,
    int? brothersCount,
    int? nazarenesCount,
    String? brotherhoodName,
    String? brotherhoodSlug,
    String? brotherhoodColorHex,
    String? brotherhoodShortName,
    String? brotherhoodHeaderImageUrl,
    String? brotherhoodShieldImageUrl,
    String? routeArgb,
    List<SchedulePoint>? schedulePoints,
    List<RoutePoint>? routePoints,
  }) {
    return DayProcessionEvent(
      status: status ?? this.status,
      officialNote: officialNote ?? this.officialNote,
      passDurationMinutes: passDurationMinutes ?? this.passDurationMinutes,
      brothersCount: brothersCount ?? this.brothersCount,
      nazarenesCount: nazarenesCount ?? this.nazarenesCount,
      brotherhoodName: brotherhoodName ?? this.brotherhoodName,
      brotherhoodSlug: brotherhoodSlug ?? this.brotherhoodSlug,
      brotherhoodColorHex: brotherhoodColorHex ?? this.brotherhoodColorHex,
      brotherhoodShortName: brotherhoodShortName ?? this.brotherhoodShortName,
      brotherhoodHeaderImageUrl:
          brotherhoodHeaderImageUrl ?? this.brotherhoodHeaderImageUrl,
      brotherhoodShieldImageUrl:
          brotherhoodShieldImageUrl ?? this.brotherhoodShieldImageUrl,
      routeArgb: routeArgb ?? this.routeArgb,
      schedulePoints: schedulePoints ?? this.schedulePoints,
      routePoints: routePoints ?? this.routePoints,
    );
  }

  factory DayProcessionEvent.fromJson(Map<String, dynamic> json) {
    final brotherhood =
        (json['brotherhood'] as Map<String, dynamic>? ?? const {});
    final itinerary = (json['itinerary'] as Map<String, dynamic>? ?? const {});
    final rawSchedulePoints =
        (itinerary['schedule_points'] as List<dynamic>? ?? const []);
    final rawRoutePoints = _resolveRawRoutePoints(itinerary);
    final rawKml = _resolveRawKml(itinerary);
    final parsedRoutePoints = rawRoutePoints
        .whereType<Map<String, dynamic>>()
        .map(RoutePoint.fromJson)
        .where((point) => point.hasLocation)
        .toList(growable: false);

    return DayProcessionEvent(
      status: (json['status'] ?? 'scheduled') as String,
      officialNote: (json['official_note'] ?? '') as String,
      passDurationMinutes: (json['pass_duration_minutes'] as num?)?.toInt(),
      brothersCount: (json['brothers_count'] as num?)?.toInt(),
      nazarenesCount: (json['nazarenes_count'] as num?)?.toInt(),
      brotherhoodName: (brotherhood['name'] ?? 'Hermandad') as String,
      brotherhoodSlug: (brotherhood['slug'] ?? '') as String,
      brotherhoodColorHex: (brotherhood['color_hex'] ?? '#8B1E3F') as String,
      brotherhoodShortName: _firstNonEmptyString(
        brotherhood,
        const ['short_name', 'shortName', 'display_name', 'displayName'],
      ),
      brotherhoodHeaderImageUrl: _firstNonEmptyString(
        brotherhood,
        const [
          'header_image_url',
          'header_image',
          'cover_image_url',
          'cover_url',
          'image_url',
        ],
      ),
      brotherhoodShieldImageUrl: _firstNonEmptyString(
        brotherhood,
        const [
          'shield_url',
          'emblem_url',
          'coat_of_arms_url',
          'logo_url',
          'badge_url',
        ],
      ),
      routeArgb: _resolveItineraryArgb(itinerary, rawKml),
      schedulePoints: rawSchedulePoints
          .whereType<Map<String, dynamic>>()
          .map(SchedulePoint.fromJson)
          .toList(growable: false),
      routePoints: parsedRoutePoints.isNotEmpty
          ? parsedRoutePoints
          : _parseRoutePointsFromKml(rawKml),
    );
  }
}

String? _firstNonEmptyString(
  Map<String, dynamic> source,
  List<String> keys,
) {
  for (final key in keys) {
    final value = source[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}

class SchedulePoint {
  const SchedulePoint({
    required this.name,
    required this.plannedAt,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final DateTime? plannedAt;
  final double? latitude;
  final double? longitude;

  bool get hasLocation => latitude != null && longitude != null;

  factory SchedulePoint.fromJson(Map<String, dynamic> json) {
    final rawPlannedAt = (json['planned_at'] ?? '') as String;
    final parsedPlannedAt = _parseDateTimeWallClock(rawPlannedAt);

    _debugSchedulePoint(
      stage: 'json',
      pointName: (json['name'] ?? 'Punto') as String,
      rawPlannedAt: rawPlannedAt,
      resolvedPlannedAt: parsedPlannedAt,
    );

    return SchedulePoint(
      name: (json['name'] ?? 'Punto') as String,
      plannedAt: parsedPlannedAt,
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
    );
  }
}

class RoutePoint {
  const RoutePoint({
    required this.latitude,
    required this.longitude,
  });

  final double? latitude;
  final double? longitude;

  bool get hasLocation => latitude != null && longitude != null;

  factory RoutePoint.fromJson(Map<String, dynamic> json) {
    final coordinates = json['coordinates'];
    if (coordinates is List && coordinates.length >= 2) {
      final longitude = _toDouble(coordinates[0]);
      final latitude = _toDouble(coordinates[1]);
      return RoutePoint(
        latitude: latitude,
        longitude: longitude,
      );
    }

    return RoutePoint(
      latitude: _toDouble(json['lat']) ?? _toDouble(json['latitude']),
      longitude: _toDouble(json['lng']) ??
          _toDouble(json['lon']) ??
          _toDouble(json['longitude']),
    );
  }
}

List<dynamic> _resolveRawRoutePoints(Map<String, dynamic> itinerary) {
  for (final key in const ['path_points', 'route_points', 'points']) {
    final value = itinerary[key];
    if (value is List<dynamic>) {
      return value;
    }
  }

  return const [];
}

String _resolveRawKml(Map<String, dynamic> itinerary) {
  for (final key in const ['kml', 'path_kml', 'route_kml']) {
    final value = itinerary[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    if (value is Map<String, dynamic>) {
      for (final nestedKey in const ['content', 'raw', 'xml']) {
        final nestedValue = value[nestedKey];
        if (nestedValue is String && nestedValue.trim().isNotEmpty) {
          return nestedValue;
        }
      }
    }
  }

  return '';
}

Map<String, dynamic> _resolveOfficialRoute(Map<String, dynamic> json) {
  for (final key in const [
    'official_route',
    'official_itinerary',
    'carrera_oficial',
    'race_course',
  ]) {
    final value = json[key];
    if (value is Map<String, dynamic>) {
      return value;
    }
  }

  return const {};
}

String? _resolveOfficialRouteArgb(Map<String, dynamic> route) {
  for (final key in const [
    'argb',
    'color_argb',
    'line_color_argb',
    'stroke_argb',
  ]) {
    final value = route[key];
    if (value == null) {
      continue;
    }
    final text = value.toString().trim();
    if (text.isNotEmpty) {
      return text;
    }
  }

  return null;
}

List<RoutePoint> _resolveRoutePointsFromContainer(Map<String, dynamic> container) {
  final rawPoints = _resolveRawRoutePoints(container);
  final directPoints = rawPoints
      .whereType<Map<String, dynamic>>()
      .map(RoutePoint.fromJson)
      .where((point) => point.hasLocation)
      .toList(growable: false);
  if (directPoints.isNotEmpty) {
    return directPoints;
  }

  final rawKml = _resolveRawKml(container);
  if (rawKml.isEmpty) {
    return const [];
  }

  return _parseRoutePointsFromKml(rawKml);
}

String? _resolveItineraryArgb(
  Map<String, dynamic> itinerary,
  String rawKml,
) {
  for (final key in const [
    'argb',
    'color_argb',
    'line_color_argb',
    'stroke_argb',
  ]) {
    final value = itinerary[key];
    if (value == null) {
      continue;
    }
    final normalized = _normalizeArgb(value.toString());
    if (normalized != null) {
      return normalized;
    }
  }

  return _extractArgbFromKml(rawKml);
}

String? _extractArgbFromKml(String rawKml) {
  final source = rawKml.trim();
  if (source.isEmpty) {
    return null;
  }

  final match = RegExp(
    r'<color[^>]*>\s*([0-9a-fA-F]{8})\s*</color>',
    caseSensitive: false,
  ).firstMatch(source);
  if (match == null) {
    return null;
  }

  // KML color format is AABBGGRR. Convert to ARGB (AARRGGBB).
  final kml = match.group(1)!.toUpperCase();
  final aa = kml.substring(0, 2);
  final bb = kml.substring(2, 4);
  final gg = kml.substring(4, 6);
  final rr = kml.substring(6, 8);
  return '#$aa$rr$gg$bb';
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

List<RoutePoint> _parseRoutePointsFromKml(String rawKml) {
  final source = rawKml.trim();
  if (source.isEmpty) {
    return const [];
  }

  final matches = RegExp(
    r'<coordinates[^>]*>\s*([^<]+?)\s*</coordinates>',
    caseSensitive: false,
    dotAll: true,
  ).allMatches(source);
  if (matches.isEmpty) {
    return const [];
  }

  final points = <RoutePoint>[];
  for (final match in matches) {
    final rawCoordinates = match.group(1);
    if (rawCoordinates == null) {
      continue;
    }

    for (final tuple in rawCoordinates.trim().split(RegExp(r'\s+'))) {
      final values = tuple.split(',');
      if (values.length < 2) {
        continue;
      }

      final longitude = _toDouble(values[0]);
      final latitude = _toDouble(values[1]);
      if (latitude == null || longitude == null) {
        continue;
      }

      points.add(
        RoutePoint(
          latitude: latitude,
          longitude: longitude,
        ),
      );
    }
  }

  return List.unmodifiable(points);
}

double? _toDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value.toString());
}

DateTime? _parseDateTimeWallClock(String raw) {
  final value = raw.trim();
  if (value.isEmpty) {
    return null;
  }

  final match = RegExp(
    r'^(\d{4})-(\d{2})-(\d{2})[T ](\d{2}):(\d{2})(?::(\d{2}))?',
  ).firstMatch(value);
  if (match != null) {
    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      int.parse(match.group(4)!),
      int.parse(match.group(5)!),
      int.parse(match.group(6) ?? '0'),
    );
  }

  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    return null;
  }

  return DateTime(
    parsed.year,
    parsed.month,
    parsed.day,
    parsed.hour,
    parsed.minute,
    parsed.second,
    parsed.millisecond,
    parsed.microsecond,
  );
}

void _debugSchedulePoint({
  required String stage,
  required String pointName,
  required String rawPlannedAt,
  required DateTime? resolvedPlannedAt,
}) {
  if (!kDebugMode || !scheduleDebugLogsEnabled) {
    return;
  }

  debugPrint(
    '[schedule_point:$stage] $pointName | raw="$rawPlannedAt" | parsed=${resolvedPlannedAt?.toIso8601String()}',
  );
}
