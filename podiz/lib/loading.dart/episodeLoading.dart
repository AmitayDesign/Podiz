import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/loading.dart/shimmerContainer.dart';

class EpisodeLoading extends StatelessWidget {
  const EpisodeLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      width: kScreenWidth - 32,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            const ShimmerContainer(width: 120, height: 31, borderRadius: 20),
            const SizedBox(height: 16),
            Row(
              children: [
                const ShimmerContainer(width: 68, height: 68, borderRadius: 5),
                const SizedBox(width: 8),
                Column(
                  children: const [
                    ShimmerContainer(width: 120, height: 21, borderRadius: 20),
                    SizedBox(height: 8),
                    ShimmerContainer(width: 120, height: 19, borderRadius: 20),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
