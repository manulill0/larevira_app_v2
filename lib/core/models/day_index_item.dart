class DayIndexItem {
  const DayIndexItem({
    required this.slug,
    required this.name,
    required this.startsAt,
    required this.liturgicalDate,
    required this.processionEventsCount,
    this.weather,
  });

  final String slug;
  final String name;
  final DateTime? startsAt;
  final DateTime? liturgicalDate;
  final int processionEventsCount;
  final DayWeatherSummary? weather;
  int get processionEventCount => processionEventsCount;

  factory DayIndexItem.fromJson(Map<String, dynamic> json) {
    return DayIndexItem(
      slug: (json['slug'] ?? '') as String,
      name: (json['name'] ?? 'Jornada') as String,
      startsAt: _parseDateTimeWallClock((json['starts_at'] ?? '') as String),
      liturgicalDate: _parseDateOnly((json['liturgical_date'] ?? '') as String),
      processionEventsCount: _parseProcessionEventsCount(json),
      weather: DayWeatherSummary.fromJson(
        json['day_weather'] as Map<String, dynamic>?,
      ),
    );
  }
}

class DayWeatherSummary {
  const DayWeatherSummary({
    this.iconCode,
    this.conditionLabel,
    this.tempMinC,
    this.tempMaxC,
    this.hourly = const <DayWeatherHourlyPoint>[],
  });

  final String? iconCode;
  final String? conditionLabel;
  final double? tempMinC;
  final double? tempMaxC;
  final List<DayWeatherHourlyPoint> hourly;

  bool get hasCompactSummary =>
      (iconCode?.trim().isNotEmpty ?? false) ||
      tempMinC != null ||
      tempMaxC != null ||
      (conditionLabel?.trim().isNotEmpty ?? false);

  bool get hasHourlyBreakdown => hourly.isNotEmpty;

  factory DayWeatherSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DayWeatherSummary();
    }

    final rawHourly = json['hourly'];
    final hourly = rawHourly is List
        ? rawHourly
              .whereType<Map<String, dynamic>>()
              .map(DayWeatherHourlyPoint.fromJson)
              .where((entry) => entry.hourLabel.isNotEmpty)
              .toList(growable: false)
        : const <DayWeatherHourlyPoint>[];

    return DayWeatherSummary(
      iconCode: _parseTrimmedString(json['icon_code']),
      conditionLabel: _parseTrimmedString(json['condition_label']),
      tempMinC: _parseNullableDouble(json['temp_min_c']),
      tempMaxC: _parseNullableDouble(json['temp_max_c']),
      hourly: hourly,
    );
  }
}

class DayWeatherHourlyPoint {
  const DayWeatherHourlyPoint({
    required this.hourLabel,
    this.iconCode,
    this.conditionLabel,
    this.temperatureC,
    this.precipitationProbability,
  });

  final String hourLabel;
  final String? iconCode;
  final String? conditionLabel;
  final double? temperatureC;
  final int? precipitationProbability;

  factory DayWeatherHourlyPoint.fromJson(Map<String, dynamic> json) {
    return DayWeatherHourlyPoint(
      hourLabel: _parseTrimmedString(json['hour_label']) ?? '',
      iconCode: _parseTrimmedString(json['icon_code']),
      conditionLabel: _parseTrimmedString(json['condition_label']),
      temperatureC: _parseNullableDouble(json['temperature_c']),
      precipitationProbability: _parseNullableInt(
        json['precipitation_probability'],
      ),
    );
  }
}

int _parseProcessionEventsCount(Map<String, dynamic> json) {
  final directCount = (json['procession_events_count'] as num?)?.toInt() ??
      (json['procession_event_count'] as num?)?.toInt() ??
      (json['procesion_events_count'] as num?)?.toInt() ??
      (json['procesion_event_count'] as num?)?.toInt();

  if (directCount != null) {
    return directCount;
  }

  final events = json['procession_events'] ?? json['procession_event'];
  if (events is List) {
    return events.length;
  }

  return 0;
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

DateTime? _parseDateOnly(String raw) {
  final value = raw.trim();
  if (value.isEmpty) {
    return null;
  }

  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
  if (match != null) {
    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  return null;
}

String? _parseTrimmedString(Object? value) {
  if (value is! String) {
    return null;
  }
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

double? _parseNullableDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value.trim());
  }
  return null;
}

int? _parseNullableInt(Object? value) {
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim());
  }
  return null;
}
