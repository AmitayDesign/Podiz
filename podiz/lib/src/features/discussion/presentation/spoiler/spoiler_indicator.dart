import 'dart:async';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:podiz/src/features/discussion/presentation/spoiler/spoiler_alert_card.dart';

class SpoilerIndicator extends StatefulWidget {
  final bool enabled;
  final bool reverse;
  final ValueSetter<bool> onAction;
  final Widget Function(bool showingAlert) builder;

  const SpoilerIndicator({
    Key? key,
    this.enabled = true,
    this.reverse = true,
    required this.onAction,
    required this.builder,
  }) : super(key: key);

  @override
  State<SpoilerIndicator> createState() => _SpoilerIndicatorState();
}

class _SpoilerIndicatorState extends State<SpoilerIndicator> {
  final height = 200.0;
  final controller = IndicatorController();
  var previousState = IndicatorState.idle;
  var completer = Completer();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (previousState == IndicatorState.armed &&
          controller.isLoading &&
          mounted) setState(() {});
      if (previousState == IndicatorState.loading &&
          (controller.isHiding || controller.isIdle) &&
          mounted) setState(() {});
      previousState = controller.state;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !widget.enabled
        ? widget.builder(false)
        : CustomRefreshIndicator(
            controller: controller,
            onRefresh: () async {
              await completer.future;
              completer = Completer();
            },
            reversed: widget.reverse,
            trailingScrollIndicatorVisible: !widget.reverse,
            leadingScrollIndicatorVisible: widget.reverse,
            child: widget.builder(controller.isLoading),
            builder: (context, child, controller) {
              return AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  final dy = -controller.value.clamp(0.0, 1.2) * (height - 44);
                  return Stack(
                    children: [
                      Transform.translate(
                        offset: Offset(0.0, dy),
                        child: child,
                      ),
                      Positioned(
                        bottom: -height + 16,
                        left: 0,
                        right: 0,
                        height: height,
                        child: Container(
                          transform: Matrix4.translationValues(0.0, dy, 0.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
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
