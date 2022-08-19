import 'dart:async';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:podiz/src/features/discussion/presentation/spoiler/spoiler_alert_card.dart';

class SpoilerIndicator extends StatefulWidget {
  final bool enabled;
  final ValueSetter<bool> onAction;
  final Widget child;

  const SpoilerIndicator({
    Key? key,
    this.enabled = true,
    required this.onAction,
    required this.child,
  }) : super(key: key);

  @override
  State<SpoilerIndicator> createState() => _SpoilerIndicatorState();
}

class _SpoilerIndicatorState extends State<SpoilerIndicator> {
  var completer = Completer();

  @override
  Widget build(BuildContext context) {
    const height = 200.0;
    return !widget.enabled
        ? widget.child
        : CustomRefreshIndicator(
            onRefresh: () async {
              await completer.future;
              completer = Completer();
            },
            reversed: true,
            trailingScrollIndicatorVisible: false,
            leadingScrollIndicatorVisible: true,
            child: widget.child,
            builder: (context, child, controller) {
              return AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  final dy =
                      -controller.value.clamp(0.0, 1.25) * (height * 0.8);
                  return Stack(
                    children: [
                      Transform.translate(
                        offset: Offset(0.0, dy),
                        child: child,
                      ),
                      Positioned(
                        bottom: -height,
                        left: 0,
                        right: 0,
                        height: height,
                        child: Container(
                          transform: Matrix4.translationValues(0.0, dy, 0.0),
                          child: Column(
                            children: [
                              SpoilerAlertCard(
                                onAction: (value) {
                                  widget.onAction(value);
                                  completer.complete();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
  }
}
