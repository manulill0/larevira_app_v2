import 'package:flutter/material.dart';

mixin SliverScrollStateMixin<T extends StatefulWidget> on State<T> {
  bool hasScrolled = false;

  bool handleRootScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) {
      return false;
    }

    final nextHasScrolled = notification.metrics.pixels > 0;
    if (nextHasScrolled == hasScrolled) {
      return false;
    }

    if (!mounted) {
      return false;
    }

    setState(() {
      hasScrolled = nextHasScrolled;
    });
    return false;
  }
}
