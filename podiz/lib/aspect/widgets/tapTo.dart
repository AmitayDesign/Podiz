import 'package:flutter/material.dart';

class TapTo extends StatelessWidget {
  final void Function(BuildContext context) onTap;
  final HitTestBehavior behavior;
  final Widget child;

  const TapTo(
    this.onTap, {
    this.behavior = HitTestBehavior.translucent,
    required this.child,
  });

  factory TapTo.unfocus({required Widget child}) => TapTo(
        (context) => FocusScope.of(context).unfocus(),
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(context),
      behavior: behavior,
      child: child,
    );
  }
}
