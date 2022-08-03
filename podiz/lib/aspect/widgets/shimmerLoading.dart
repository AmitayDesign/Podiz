import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

const _shimmerGradient = LinearGradient(
  colors: [
    Colors.grey,
    Colors.white,
    Colors.grey,
  ],
  stops: [
    0.1,
    0.3,
    0.4,
  ],
  begin: Alignment(-1.0, -0.3),
  end: Alignment(1.0, 0.3),
  tileMode: TileMode.clamp,
);

class ShimmerLoading extends StatelessWidget {
  final Widget child;
  const ShimmerLoading({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer(child: child);
  }
}
