import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Converts a [List<Stream>] into a [Listenable]
///
/// {@tool snippet}
/// Typical usage is as follows:
///
/// ```dart
/// GoRouter(
///  refreshListenable: GoRouterRefreshStreamList(streams),
/// );
/// ```
/// {@end-tool}
class GoRouterRefreshStreamList extends ChangeNotifier {
  /// Creates a [GoRouterRefreshStreamList].
  ///
  /// Every time one of the [streams] receives an event
  /// the [GoRouter] will refresh its current route.
  GoRouterRefreshStreamList(List<Stream<dynamic>> streams) {
    notifyListeners();
    for (final stream in streams) {
      final sub = stream.asBroadcastStream().listen(
            (dynamic _) => notifyListeners(),
          );
      _subscriptions.add(sub);
    }
  }

  final _subscriptions = <StreamSubscription<dynamic>>[];

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
}
