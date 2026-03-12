import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PrivateImageCache {
  PrivateImageCache._();

  static final Dio _dio = Dio();
  static final Map<String, Future<File?>> _pending = <String, Future<File?>>{};

  static Future<File?> getOrFetchShield(String url) {
    return _pending.putIfAbsent(
      url,
      () async {
        try {
          return await _getOrFetch(url, subfolder: 'shields');
        } finally {
          _pending.remove(url);
        }
      },
    );
  }

  static Future<File?> getOrFetchHeader(String url) {
    return _pending.putIfAbsent(
      'header:$url',
      () async {
        try {
          return await _getOrFetch(url, subfolder: 'headers');
        } finally {
          _pending.remove('header:$url');
        }
      },
    );
  }

  static Future<File?> _getOrFetch(
    String rawUrl, {
    required String subfolder,
  }) async {
    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null || !uri.hasScheme) {
      return null;
    }

    final rootDir = await getApplicationSupportDirectory();
    final cacheDir = Directory(
      p.join(rootDir.path, 'image_cache', subfolder),
    );
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    final extension = _safeExtension(uri.path);
    final fileName = '${_safeFileName(rawUrl)}$extension';
    final file = File(p.join(cacheDir.path, fileName));
    if (await file.exists() && await file.length() > 0) {
      return file;
    }

    final response = await _dio.getUri<List<int>>(
      uri,
      options: Options(responseType: ResponseType.bytes),
    );
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      return null;
    }
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static String _safeFileName(String value) {
    final encoded = base64UrlEncode(utf8.encode(value));
    return encoded.length > 180 ? encoded.substring(0, 180) : encoded;
  }

  static String _safeExtension(String path) {
    final dot = path.lastIndexOf('.');
    if (dot < 0 || dot == path.length - 1) {
      return '.img';
    }
    final extension = path.substring(dot).toLowerCase();
    final valid = RegExp(r'^\.[a-z0-9]{1,5}$');
    return valid.hasMatch(extension) ? extension : '.img';
  }
}
