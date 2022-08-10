import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class StreamNotifier<T> extends StateNotifier<T> {
  StreamNotifier({
    required T initial,
    required Stream<T> stream,
  }) : super(initial) {
    _listen(stream);
  }

  late final StreamSubscription sub;
  void _listen(Stream<T> stream) =>
      sub = stream.listen((setting) => state = setting);

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }
}
