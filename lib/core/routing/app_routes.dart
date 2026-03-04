import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../models/day_detail.dart';
import '../models/day_index_item.dart';

enum AppTab {
  hoy,
  jornadas,
  planning,
  more,
}

final class AppRoutes {
  static const root = '/';
  static const startup = '/startup';
  static const hoy = '/hoy';
  static const jornadas = '/jornadas';
  static const planning = '/planning';
  static const more = '/more';

  static const defaultTab = AppTab.hoy;
  static const defaultHome = hoy;
  static const rootName = 'root';
  static const startupName = 'startup';
  static const hoyName = 'hoy';
  static const jornadasName = 'jornadas';
  static const dayDetailName = 'day-detail';
  static const brotherhoodDetailName = 'brotherhood-detail';
  static const planningName = 'planning';
  static const moreName = 'more';

  static String dayDetail(String slug) => '$jornadas/day/$slug';
  static String brotherhoodDetail(String slug) => '/brotherhoods/$slug';
}

class BrotherhoodDetailRouteData {
  const BrotherhoodDetailRouteData({
    required this.event,
    required this.dayName,
  });

  final DayProcessionEvent event;
  final String dayName;
}

extension AppTabRoute on AppTab {
  int get branchIndex {
    switch (this) {
      case AppTab.hoy:
        return 0;
      case AppTab.jornadas:
        return 1;
      case AppTab.planning:
        return 2;
      case AppTab.more:
        return 3;
    }
  }

  String get location {
    switch (this) {
      case AppTab.hoy:
        return AppRoutes.hoy;
      case AppTab.jornadas:
        return AppRoutes.jornadas;
      case AppTab.planning:
        return AppRoutes.planning;
      case AppTab.more:
        return AppRoutes.more;
    }
  }

  String get routeName {
    switch (this) {
      case AppTab.hoy:
        return AppRoutes.hoyName;
      case AppTab.jornadas:
        return AppRoutes.jornadasName;
      case AppTab.planning:
        return AppRoutes.planningName;
      case AppTab.more:
        return AppRoutes.moreName;
    }
  }
}

extension AppRouterContext on BuildContext {
  void goToStartup() => goNamed(AppRoutes.startupName);

  void goToTab(AppTab tab) => goNamed(tab.routeName);

  void goToToday() => goToTab(AppTab.hoy);

  void goToJornadas() => goToTab(AppTab.jornadas);

  void goToPlanning() => goToTab(AppTab.planning);

  void goToMore() => goToTab(AppTab.more);

  Future<T?> pushDayDetail<T>(DayIndexItem item) {
    return pushNamed<T>(
      AppRoutes.dayDetailName,
      pathParameters: {'slug': item.slug},
      extra: item,
    );
  }

  Future<T?> pushBrotherhoodDetail<T>(
    DayProcessionEvent event, {
    required String dayName,
  }) {
    return pushNamed<T>(
      AppRoutes.brotherhoodDetailName,
      pathParameters: {'slug': event.brotherhoodSlug},
      extra: BrotherhoodDetailRouteData(
        event: event,
        dayName: dayName,
      ),
    );
  }
}
