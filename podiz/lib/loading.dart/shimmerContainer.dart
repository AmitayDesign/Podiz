import 'package:flutter/material.dart';
import 'package:podiz/aspect/widgets/shimmerLoading.dart';

class ShimmerContainer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerContainer(
      {Key? key,
      required this.width,
      required this.height,
      required this.borderRadius})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: width,
        height: height,
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(borderRadius)),
      ),
    );
  }
}
