import 'package:flutter/material.dart';
import 'package:podiz/loading.dart/shimmerContainer.dart';

class TabBarLabelLoading extends StatelessWidget {
  const TabBarLabelLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ShimmerContainer(width: 50, height: 32, borderRadius: 20);
  }
}
