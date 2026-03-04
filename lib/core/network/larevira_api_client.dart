import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_instance_controller.dart';
import '../local/app_database.dart';

final lareviraApiClientProvider = Provider<LareviraApiClient>((ref) {
  final config = ref.watch(appInstanceProvider);
  final appDatabase = ref.watch(appDatabaseProvider);
  return LareviraApiClient(
    baseUrl: config.baseApiUrl,
    appDatabase: appDatabase,
  );
});

class LareviraApiClient {
  LareviraApiClient({
    required String baseUrl,
    required AppDatabase appDatabase,
  })  : _appDatabase = appDatabase,
        _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 12),
            sendTimeout: const Duration(seconds: 10),
            responseType: ResponseType.json,
          ),
        );

  final Dio _dio;
  final AppDatabase _appDatabase;
  static const _cachePrefix = 'http_cache_get_v1:';

  Future<Response<dynamic>> fetchScoped(
    String citySlug,
    int year,
    String resourcePath, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final normalized = resourcePath.startsWith('/')
        ? resourcePath
        : '/$resourcePath';
    final path = '/$citySlug/$year$normalized';
    final response = await _dio.get<dynamic>(
      path,
      queryParameters: queryParameters,
    );
    final cacheKey = _cacheKeyFor(path, queryParameters);
    await _saveCache(cacheKey, response.data);
    return response;
  }

  Future<Response<dynamic>> getScoped(
    String citySlug,
    int year,
    String resourcePath, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final normalized = resourcePath.startsWith('/')
        ? resourcePath
        : '/$resourcePath';
    final path = '/$citySlug/$year$normalized';
    final requestOptions = RequestOptions(
      path: path,
      queryParameters: queryParameters ?? const <String, dynamic>{},
    );
    final cacheKey = _cacheKeyFor(path, queryParameters);

    try {
      return await fetchScoped(
        citySlug,
        year,
        resourcePath,
        queryParameters: queryParameters,
      );
    } on DioException {
      final cached = await _readCache(cacheKey);
      if (cached != null) {
        return Response<dynamic>(
          requestOptions: requestOptions,
          data: cached,
          statusCode: 200,
          extra: const {'fromCache': true},
        );
      }
      rethrow;
    }
  }

  String buildScopedPath(
    String citySlug,
    int year,
    String resourcePath,
  ) {
    final normalized = resourcePath.startsWith('/')
        ? resourcePath
        : '/$resourcePath';
    return '/$citySlug/$year$normalized';
  }

  Future<void> clearHttpCache() async {
    await _appDatabase.clearHttpCache();
  }

  String _cacheKeyFor(String path, Map<String, dynamic>? queryParameters) {
    final sortedQuery = <String, dynamic>{...(queryParameters ?? const {})};
    final orderedKeys = sortedQuery.keys.toList()..sort();
    final compact = orderedKeys
        .map((key) => '$key=${sortedQuery[key]}')
        .join('&');
    return '$_cachePrefix$path?$compact';
  }

  Future<void> _saveCache(String key, dynamic data) async {
    if (data is! Map<String, dynamic> && data is! List<dynamic>) {
      return;
    }

    await _appDatabase.saveHttpCache(
      key: key,
      payload: jsonEncode(<String, dynamic>{
        'saved_at': DateTime.now().toIso8601String(),
        'data': data,
      }),
    );
  }

  Future<dynamic> _readCache(String key) async {
    final raw = await _appDatabase.readHttpCache(key);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded['data'];
    } catch (_) {
      return null;
    }
  }
}
