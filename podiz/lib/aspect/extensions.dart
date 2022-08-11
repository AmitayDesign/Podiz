import 'package:flutter/material.dart';

extension GlobalKeyX on GlobalKey {
  /// global screen offset
  Offset? get offset {
    final box = currentContext?.findRenderObject() as RenderBox?;
    return box?.localToGlobal(Offset.zero);
  }

  Size? get size {
    final box = currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) return box.size;
    return null;
  }
}

extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
