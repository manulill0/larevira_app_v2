class DayIndexItem {
  const DayIndexItem({
    required this.slug,
    required this.name,
    required this.startsAt,
    required this.processionEventsCount,
  });

  final String slug;
  final String name;
  final DateTime? startsAt;
  final int processionEventsCount;
  int get processionEventCount => processionEventsCount;

  factory DayIndexItem.fromJson(Map<String, dynamic> json) {
    return DayIndexItem(
      slug: (json['slug'] ?? '') as String,
      name: (json['name'] ?? 'Jornada') as String,
      startsAt: _parseDateTimeWallClock((json['starts_at'] ?? '') as String),
      processionEventsCount: _parseProcessionEventsCount(json),
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
