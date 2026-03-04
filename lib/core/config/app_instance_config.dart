class AppInstanceConfig {
  const AppInstanceConfig({
    required this.citySlug,
    required this.baseApiUrl,
    required this.defaultEditionYear,
  });

  final String citySlug;
  final String baseApiUrl;
  final int defaultEditionYear;

  String scopedPath(String resourcePath) {
    final normalized = resourcePath.startsWith('/')
        ? resourcePath
        : '/$resourcePath';
    return '/$citySlug/$defaultEditionYear$normalized';
  }
}
