class SyncManifest {
  const SyncManifest({
    required this.version,
    required this.lastModifiedAt,
    required this.resources,
  });

  final String version;
  final DateTime? lastModifiedAt;
  final Map<String, SyncManifestResource> resources;

  SyncManifestResource? resource(String key) => resources[key];

  factory SyncManifest.fromJson(Map<String, dynamic> json) {
    final rawResources =
        (json['resources'] as Map<String, dynamic>? ?? const {});

    return SyncManifest(
      version: (json['version'] ?? '') as String,
      lastModifiedAt: _parseDateTime((json['last_modified_at'] ?? '') as String),
      resources: rawResources.map(
        (key, value) => MapEntry(
          key,
          SyncManifestResource.fromJson(
            value is Map<String, dynamic> ? value : const {},
          ),
        ),
      ),
    );
  }
}

class SyncManifestResource {
  const SyncManifestResource({
    required this.version,
    required this.lastModifiedAt,
  });

  final String version;
  final DateTime? lastModifiedAt;

  factory SyncManifestResource.fromJson(Map<String, dynamic> json) {
    return SyncManifestResource(
      version: (json['version'] ?? '') as String,
      lastModifiedAt: _parseDateTime((json['last_modified_at'] ?? '') as String),
    );
  }
}

DateTime? _parseDateTime(String raw) {
  final value = raw.trim();
  if (value.isEmpty) {
    return null;
  }

  return DateTime.tryParse(value);
}
