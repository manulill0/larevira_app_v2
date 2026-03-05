class SyncChanges {
  const SyncChanges({
    required this.brotherhoods,
    required this.days,
    required this.processionEvents,
    required this.itineraries,
  });

  final SyncChangesResource brotherhoods;
  final SyncChangesResource days;
  final SyncChangesResource processionEvents;
  final SyncChangesResource itineraries;

  factory SyncChanges.fromJson(Map<String, dynamic> json) {
    return SyncChanges(
      brotherhoods: SyncChangesResource.fromJson(
        (json['brotherhoods'] as Map<String, dynamic>? ?? const {}),
      ),
      days: SyncChangesResource.fromJson(
        (json['days'] as Map<String, dynamic>? ?? const {}),
      ),
      processionEvents: SyncChangesResource.fromJson(
        (json['procession_events'] as Map<String, dynamic>? ?? const {}),
      ),
      itineraries: SyncChangesResource.fromJson(
        (json['itineraries'] as Map<String, dynamic>? ?? const {}),
      ),
    );
  }
}

class SyncChangesResource {
  const SyncChangesResource({
    required this.changedSlugs,
    required this.changedEventIds,
    required this.fullResyncRequired,
  });

  final List<String> changedSlugs;
  final List<int> changedEventIds;
  final bool fullResyncRequired;

  factory SyncChangesResource.fromJson(Map<String, dynamic> json) {
    final rawSlugs = (json['changed_slugs'] as List<dynamic>? ?? const []);
    final rawIds = (json['changed_event_ids'] as List<dynamic>? ?? const []);

    return SyncChangesResource(
      changedSlugs: rawSlugs
          .whereType<Object>()
          .map((value) => value.toString().trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false),
      changedEventIds: rawIds
          .whereType<num>()
          .map((value) => value.toInt())
          .toList(growable: false),
      fullResyncRequired: json['full_resync_required'] == true,
    );
  }
}
