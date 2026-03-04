import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

const String kMapboxAccessToken = String.fromEnvironment(
  'MAPBOX_ACCESS_TOKEN',
  defaultValue: '',
);
const String kMapboxStyleUri = String.fromEnvironment(
  'MAPBOX_STYLE_URI',
  defaultValue: 'mapbox://styles/mapbox/streets-v12',
);
const String kMapboxDarkStyleUri = String.fromEnvironment(
  'MAPBOX_DARK_STYLE_URI',
  defaultValue: 'mapbox://styles/mapbox/dark-v11',
);

final Set<Factory<OneSequenceGestureRecognizer>> kMapGestureRecognizers = {
  Factory<EagerGestureRecognizer>(EagerGestureRecognizer.new),
};

class MapPoint {
  const MapPoint({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  Point toPoint() => Point(coordinates: Position(longitude, latitude));
}

void configureMapboxTokenIfPresent() {
  if (kMapboxAccessToken.isNotEmpty) {
    MapboxOptions.setAccessToken(kMapboxAccessToken);
  }
}

String mapboxStyleUriForBrightness(Brightness brightness) {
  return brightness == Brightness.dark ? kMapboxDarkStyleUri : kMapboxStyleUri;
}

MapPoint _defaultSevillePoint() =>
    const MapPoint(latitude: 37.3891, longitude: -5.9845);

CameraOptions cameraForPoints(
  List<MapPoint> points, {
  double fallbackZoom = 14,
}) {
  final center = _centerForPoints(points);
  final zoom = _zoomForPoints(points, fallback: fallbackZoom);

  return CameraOptions(
    center: Point(coordinates: Position(center.longitude, center.latitude)),
    zoom: zoom,
  );
}

Future<void> easeToPoints(
  MapboxMap? map,
  List<MapPoint> points, {
  double fallbackZoom = 14,
}) async {
  if (map == null || points.isEmpty) {
    return;
  }

  await map.easeTo(
    cameraForPoints(points, fallbackZoom: fallbackZoom),
    MapAnimationOptions(duration: 900),
  );
}

MapPoint _centerForPoints(List<MapPoint> points) {
  if (points.isEmpty) {
    return _defaultSevillePoint();
  }

  var minLat = points.first.latitude;
  var maxLat = points.first.latitude;
  var minLng = points.first.longitude;
  var maxLng = points.first.longitude;

  for (final point in points.skip(1)) {
    minLat = math.min(minLat, point.latitude);
    maxLat = math.max(maxLat, point.latitude);
    minLng = math.min(minLng, point.longitude);
    maxLng = math.max(maxLng, point.longitude);
  }

  return MapPoint(
    latitude: (minLat + maxLat) / 2,
    longitude: (minLng + maxLng) / 2,
  );
}

double _zoomForPoints(List<MapPoint> points, {double fallback = 14}) {
  if (points.length < 2) {
    return fallback;
  }

  var minLat = points.first.latitude;
  var maxLat = points.first.latitude;
  var minLng = points.first.longitude;
  var maxLng = points.first.longitude;

  for (final point in points.skip(1)) {
    minLat = math.min(minLat, point.latitude);
    maxLat = math.max(maxLat, point.latitude);
    minLng = math.min(minLng, point.longitude);
    maxLng = math.max(maxLng, point.longitude);
  }

  final latSpan = (maxLat - minLat).abs();
  final lngSpan = (maxLng - minLng).abs();
  final span = math.max(latSpan, lngSpan);

  if (span < 0.002) return 16.6;
  if (span < 0.004) return 15.8;
  if (span < 0.008) return 15.2;
  if (span < 0.016) return 14.6;
  if (span < 0.03) return 14.0;
  if (span < 0.06) return 13.2;
  if (span < 0.12) return 12.4;
  return 11.4;
}
