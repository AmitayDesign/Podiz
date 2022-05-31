import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class RouteAwareState<T extends ConsumerStatefulWidget>
    extends ConsumerState<T>
    with RouteAware, AfterLayoutMixin<T>, WidgetsBindingObserver {
  //
  static RouteObserver observer = RouteObserver<PageRoute>();
  bool enteredScreen = false;

  @override
  @mustCallSuper
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  @mustCallSuper
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    _enterScreen();
  }

  @override
  @mustCallSuper
  void afterFirstLayout(BuildContext context) {
    if (mounted) {
      observer.subscribe(this, ModalRoute.of(context) as PageRoute);
      Timer.run(_enterScreen);
    }
  }

  void _enterScreen() {
    onEnterScreen();
    enteredScreen = true;
  }

  void _leaveScreen() {
    onLeaveScreen();
    enteredScreen = false;
  }

  @override
  @mustCallSuper
  void dispose() {
    if (enteredScreen) _leaveScreen();
    observer.unsubscribe(this);
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  @mustCallSuper
  void didPopNext() => Timer.run(_enterScreen);

  @override
  @mustCallSuper
  void didPop() => _leaveScreen();

  @override
  @mustCallSuper
  void didPushNext() => _leaveScreen();

  /// this method will always be executed on enter this screen
  void onEnterScreen();

  /// this method will always be executed on leaving this screen
  void onLeaveScreen();
}
