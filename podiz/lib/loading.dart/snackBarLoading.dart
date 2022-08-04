import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/loading.dart/shimmerContainer.dart';

class SnackBarLoading extends StatelessWidget {
  const SnackBarLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 127,
      decoration: const BoxDecoration(
        color: Color(0xFF4E4E4E),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 20),
        child: Column(
          children: [
            Row(
              children: [
                ShimmerContainer(width: 31, height: 31, borderRadius: 30),
                const SizedBox(width: 8),
                ShimmerContainer(
                    width: kScreenWidth - (14 + 31 + 8 + 31 + 8 + 14),
                    height: 31,
                    borderRadius: 20),
                const SizedBox(width: 8),
                ShimmerContainer(width: 31, height: 31, borderRadius: 30),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                ShimmerContainer(width: 120, height: 17, borderRadius: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
