# La Revirá App v2

Cliente móvil Flutter de La Revirá con foco en consulta rápida, sincronización inicial y uso offline con caché local.

## Stack técnico

- Flutter + Dart (`sdk: ^3.11.1`)
- Riverpod (estado e inyección de dependencias)
- GoRouter (navegación con `StatefulShellRoute`)
- Drift + SQLite (persistencia local)
- Dio (HTTP + fallback a caché)
- Mapbox (mapas y rutas)
- Firebase Analytics (telemetría opcional)

## Estructura del proyecto

```text
lib/
  main.dart
  app.dart
  core/
    analytics/
    config/
    local/
    maps/
    models/
    network/
    routing/
    theme/
    time/
    widgets/
  features/
    home/
    hoy/
    jornadas/
    more/
    planning/
    shared/
    sync/
test/
```

Puntos de entrada clave:

- `lib/main.dart`: bootstrap, `ProviderScope`, Mapbox token y analytics.
- `lib/app.dart`: `MaterialApp.router`, tema light/dark y adaptación por tamaño de pantalla.
- `lib/core/routing/app_router.dart`: rutas, shell con tabs y redirect por estado de sincronización.
- `lib/features/sync/application/sync_controller.dart`: sincronización inicial/manual.
- `lib/core/local/app_database.dart`: esquema Drift, migraciones y acceso a datos locales.
- `lib/core/network/larevira_api_client.dart`: cliente API y fallback a caché HTTP.

## Flujo de arranque y navegación

1. La app abre en `/`.
2. El router redirige a `/startup` hasta completar la sincronización inicial.
3. `AppStartupGate` ejecuta `syncOnAppLaunch()`.
4. Cuando `isInitialSyncComplete == true`, el redirect envía a `/hoy`.
5. La navegación principal usa 4 tabs:
   - `/hoy`
   - `/jornadas`
   - `/planning`
   - `/more`

Rutas adicionales:

- `'/jornadas/day/:slug'` detalle de jornada.
- `'/brotherhoods/:slug'` detalle de hermandad.

## Sincronización y modo offline

La sincronización está centralizada en `SyncController`:

- Primera apertura: intenta sincronización inicial.
- Manual: desde la pantalla `Más` (`Sincronizar datos`).
- Recurso índice: `GET /{city}/{year}/days?mode=all`.
- Recursos detalle: `GET /{city}/{year}/days/{slug}?mode=all`.
- Manifest opcional: `GET /{city}/{year}/sync-manifest` para evitar descargar si no hay cambios.

Persistencia:

- Índice de jornadas y detalles completos se guardan en SQLite (Drift).
- Versiones de recursos y `lastSyncedAt` también quedan persistidas.
- Si falla red y hay datos locales, se mantiene operación offline.

Fallback HTTP:

- `LareviraApiClient.getScoped()` intenta red; ante `DioException`, devuelve respuesta desde caché local si existe.

## Base de datos local (Drift)

Archivo: `lib/core/local/app_database.dart`

Tablas principales:

- `days`
- `day_detail_entries`
- `day_procession_event_entries`
- `day_schedule_point_entries`
- `day_route_point_entries`
- `day_official_route_point_entries`
- `sync_status_entries`
- `app_settings_entries`
- `http_cache_entries`

Versión de esquema actual: `8`.

Nota: no editar a mano `lib/core/local/app_database.g.dart` (generado).

## Configuración por entorno (`--dart-define`)

Variables soportadas:

- `CITY_SLUG` (default: `sevilla`)
- `EDITION_YEAR` (default: `2025`)
- `API_BASE_URL` (default: `https://admin.larevira.app/api/v1`)
- `ALLOW_INSTANCE_OVERRIDES` (default: `false`, habilitado en `debug`)
- `MAPBOX_ACCESS_TOKEN` (default: vacío)
- `MAPBOX_STYLE_URI` (default: `mapbox://styles/mapbox/streets-v12`)
- `MAPBOX_DARK_STYLE_URI` (default: `mapbox://styles/mapbox/dark-v11`)
- `FIREBASE_ANALYTICS_ENABLED` (default: `true`)
- `SCHEDULE_DEBUG_LOGS` (default: `false`)

Ejemplo:

```bash
flutter run \
  --dart-define=CITY_SLUG=sevilla \
  --dart-define=EDITION_YEAR=2025 \
  --dart-define=API_BASE_URL=https://admin.larevira.app/api/v1 \
  --dart-define=MAPBOX_ACCESS_TOKEN=tu_token
```

## Desarrollo local

Instalación:

```bash
flutter pub get
```

Ejecución:

```bash
flutter run
```

Checks mínimos:

```bash
flutter analyze
flutter test
```

Si cambias código generado (Drift/Riverpod):

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Estado funcional actual (resumen)

- `Hoy`: base visual + placeholders.
- `Jornadas`: listado desde base local.
- `Detalle de jornada`: horario, mapa, hermandades y plan con datos locales.
- `Más`: configuración visible, tema, reloj de pruebas y sync manual.
- `Planning`: placeholder.
