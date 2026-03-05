import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/larevira_api_client.dart';

const _pendingProcessionStatusUpdateKey = 'pending_procession_status_update_v1';

class ProcessionStatusUpdate {
  const ProcessionStatusUpdate({
    required this.citySlug,
    required this.year,
    required this.daySlug,
    required this.dayName,
    required this.status,
    required this.brotherhoodSlug,
    required this.brotherhoodName,
    required this.title,
    required this.body,
  });

  final String citySlug;
  final int year;
  final String daySlug;
  final String dayName;
  final String status;
  final String brotherhoodSlug;
  final String brotherhoodName;
  final String title;
  final String body;

  Map<String, dynamic> toJson() {
    return {
      'city_slug': citySlug,
      'year': year,
      'day_slug': daySlug,
      'day_name': dayName,
      'status': status,
      'brotherhood_slug': brotherhoodSlug,
      'brotherhood_name': brotherhoodName,
      'title': title,
      'body': body,
    };
  }

  static ProcessionStatusUpdate? fromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    if (data['type'] != 'procession_status_changed') {
      return null;
    }

    final citySlug = (data['city_slug'] ?? '').trim();
    final daySlug = (data['day_slug'] ?? '').trim();
    final year = int.tryParse((data['year'] ?? '').toString());

    if (citySlug.isEmpty || daySlug.isEmpty || year == null) {
      return null;
    }

    return ProcessionStatusUpdate(
      citySlug: citySlug,
      year: year,
      daySlug: daySlug,
      dayName: (data['day_name'] ?? '').toString(),
      status: (data['status'] ?? '').toString(),
      brotherhoodSlug: (data['brotherhood_slug'] ?? '').toString(),
      brotherhoodName: (data['brotherhood_name'] ?? '').toString(),
      title: (data['title'] ?? message.notification?.title ?? 'Actualización')
          .toString(),
      body:
          (data['body'] ??
                  message.notification?.body ??
                  'Hay cambios en una jornada.')
              .toString(),
    );
  }

  static ProcessionStatusUpdate? fromJson(Map<String, dynamic> json) {
    final citySlug = (json['city_slug'] ?? '').toString().trim();
    final daySlug = (json['day_slug'] ?? '').toString().trim();
    final year = switch (json['year']) {
      final int value => value,
      final num value => value.toInt(),
      _ => int.tryParse((json['year'] ?? '').toString()),
    };

    if (citySlug.isEmpty || daySlug.isEmpty || year == null) {
      return null;
    }

    return ProcessionStatusUpdate(
      citySlug: citySlug,
      year: year,
      daySlug: daySlug,
      dayName: (json['day_name'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      brotherhoodSlug: (json['brotherhood_slug'] ?? '').toString(),
      brotherhoodName: (json['brotherhood_name'] ?? '').toString(),
      title: (json['title'] ?? 'Actualización').toString(),
      body: (json['body'] ?? 'Hay cambios en una jornada.').toString(),
    );
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (_) {
    // Ignore Firebase init errors in background isolate and still persist payload.
  }

  await _persistPendingProcessionStatusUpdate(message);
}

Future<void> _persistPendingProcessionStatusUpdate(RemoteMessage message) async {
  final update = ProcessionStatusUpdate.fromRemoteMessage(message);
  if (update == null) {
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _pendingProcessionStatusUpdateKey,
    jsonEncode(update.toJson()),
  );
}

Future<ProcessionStatusUpdate?> takePendingProcessionStatusUpdate() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_pendingProcessionStatusUpdateKey);
  if (raw == null || raw.isEmpty) {
    return null;
  }
  await prefs.remove(_pendingProcessionStatusUpdateKey);

  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return ProcessionStatusUpdate.fromJson(decoded);
    }
    if (decoded is Map) {
      return ProcessionStatusUpdate.fromJson(
        decoded.map((key, value) => MapEntry(key.toString(), value)),
      );
    }
  } catch (error, stackTrace) {
    developer.log(
      'Failed to decode pending background push payload.',
      name: 'PushNotificationsController',
      error: error,
      stackTrace: stackTrace,
    );
  }

  return null;
}

class PushNotificationsController {
  PushNotificationsController({
    required LareviraApiClient apiClient,
    required String citySlug,
    required int Function() currentEditionYear,
  })  : _apiClient = apiClient,
        _citySlug = citySlug,
        _currentEditionYear = currentEditionYear;

  static const _installationIdKey = 'push_installation_id_v1';
  static const _channelId = 'procession_updates';
  static const _channelName = 'Actualizaciones de procesiones';

  final LareviraApiClient _apiClient;
  final String _citySlug;
  final int Function() _currentEditionYear;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final StreamController<ProcessionStatusUpdate> _updatesController =
      StreamController<ProcessionStatusUpdate>.broadcast();

  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;
  bool _ready = false;

  Stream<ProcessionStatusUpdate> get updates => _updatesController.stream;

  Future<void> initialize() async {
    if (_ready) {
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
    } catch (error, stackTrace) {
      developer.log(
        'Firebase initialization failed for push notifications.',
        name: 'PushNotificationsController',
        error: error,
        stackTrace: stackTrace,
      );
      return;
    }

    await _initializeLocalNotifications();

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      _ready = true;
      developer.log(
        'Push registration skipped because notifications are denied.',
        name: 'PushNotificationsController',
      );
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    await _registerCurrentToken();

    _messageSubscription = FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleUpdateEventOnly);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      await _handleUpdateEventOnly(initialMessage);
    }

    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((token) {
      _debugPush('FCM token refreshed: $token');
      _registerToken(token);
    });

    final pending = await takePendingProcessionStatusUpdate();
    if (pending != null) {
      _updatesController.add(pending);
    }

    _ready = true;
  }

  Future<void> _initializeLocalNotifications() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(initSettings);

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Avisos de cambios importantes en las procesiones.',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> _registerCurrentToken() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final apnsToken = await _waitForApnsToken();
      if (apnsToken == null || apnsToken.isEmpty) {
        _debugPush('APNs token not available after waiting.');
        return;
      }
      _debugPush('APNs token received: $apnsToken');
    }

    try {
      final token = await _messaging.getToken();
      _debugPush('FCM token received: ${token ?? '(null)'}');
      await _registerToken(token);
    } catch (_) {}
  }

  Future<String?> _waitForApnsToken() async {
    for (var attempt = 0; attempt < 10; attempt++) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null && apnsToken.isNotEmpty) {
        return apnsToken;
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }

    return null;
  }

  Future<void> _registerToken(String? token) async {
    final trimmed = token?.trim() ?? '';
    if (trimmed.isEmpty) {
      return;
    }

    final installationId = await _getOrCreateInstallationId();
    final year = _currentEditionYear();

    try {
      await _apiClient.post(
        '/push-tokens',
        data: <String, dynamic>{
          'installation_id': installationId,
          'token': trimmed,
          'platform': _platformName,
          'city_slug': _citySlug,
          'year': year,
        },
      );
      _debugPush(
        'Push token registered in backend (installation: $installationId, year: $year).',
      );
    } catch (_) {}
  }

  void _debugPush(String message) {
    if (!kDebugMode) {
      return;
    }
    debugPrint('[push] $message');
  }

  Future<String> _getOrCreateInstallationId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_installationIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final random = Random.secure();
    final created =
        '${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}'
        '-${random.nextInt(1 << 32).toRadixString(36)}';
    await prefs.setString(_installationIdKey, created);

    return created;
  }

  String get _platformName {
    if (kIsWeb) {
      return 'web';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ios';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'android';
    }
    return 'unknown';
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    final update = ProcessionStatusUpdate.fromRemoteMessage(message);
    if (update != null) {
      _updatesController.add(update);
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return;
    }

    final title = update?.title ?? message.notification?.title;
    final body = update?.body ?? message.notification?.body;
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    await _localNotifications.show(
      _notificationIdFor(message),
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Avisos de cambios importantes en las procesiones.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  int _notificationIdFor(RemoteMessage message) {
    const maxSigned32BitInt = 0x7fffffff;
    final rawId =
        (message.messageId ?? '${DateTime.now().microsecondsSinceEpoch}')
            .hashCode;

    return rawId & maxSigned32BitInt;
  }

  Future<void> _handleUpdateEventOnly(RemoteMessage message) async {
    final update = ProcessionStatusUpdate.fromRemoteMessage(message);
    if (update != null) {
      _updatesController.add(update);
    }
  }

  Future<void> dispose() async {
    await _messageSubscription?.cancel();
    await _tokenRefreshSubscription?.cancel();
    await _updatesController.close();
  }
}
