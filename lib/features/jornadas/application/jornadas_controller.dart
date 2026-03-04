import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_instance_controller.dart';
import '../../../core/local/app_database.dart';
import '../../../core/models/day_index_item.dart';

final jornadasProvider = FutureProvider<List<DayIndexItem>>((ref) async {
  final appInstance = ref.watch(appInstanceProvider);
  final year = ref.watch(editionYearProvider);
  final appDatabase = ref.watch(appDatabaseProvider);
  const mode = 'all';

  return appDatabase.getDays(
    city: appInstance.citySlug,
    year: year,
    modeValue: mode,
  );
});
