import 'package:flutter/material.dart';

class AdaptiveAppBarTitle extends StatelessWidget {
  const AdaptiveAppBarTitle(
    this.text, {
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle =
        theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleLarge;

    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedStyle = baseStyle?.copyWith(letterSpacing: 0.1);

        if (constraints.maxWidth.isInfinite) {
          return Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: resolvedStyle,
          );
        }

        return SizedBox(
          width: constraints.maxWidth,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              text,
              maxLines: 1,
              softWrap: false,
              style: resolvedStyle,
            ),
          ),
        );
      },
    );
  }
}
