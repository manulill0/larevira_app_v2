import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_instance_controller.dart';
import '../../../core/local/app_database.dart';
import '../../../core/models/day_detail.dart';

final dayDetailProvider =
    FutureProvider.family<DayDetail, String>((ref, daySlug) async {
  final appInstance = ref.watch(appInstanceProvider);
  final year = ref.watch(editionYearProvider);
  final appDatabase = ref.watch(appDatabaseProvider);
  const mode = 'all';

  final local = await appDatabase.getDayDetail(
    city: appInstance.citySlug,
    year: year,
    modeValue: mode,
    daySlugValue: daySlug,
  );
  if (local != null) {
    return local;
  }
  throw StateError(
    'Aun no hay detalle sincronizado para esta jornada. Usa "Mas" para sincronizar datos.',
  );
});
