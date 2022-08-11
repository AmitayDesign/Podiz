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
