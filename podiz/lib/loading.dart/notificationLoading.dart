import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/loading.dart/shimmerContainer.dart';

class NotificationLoading extends StatelessWidget {
  const NotificationLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              ShimmerContainer(width: 32, height: 32, borderRadius: 30),
              const SizedBox(width: 8),
              LimitedBox(
                maxWidth: kScreenWidth - (16 + 8 + 32 + 16),
                maxHeight: 40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: ShimmerContainer(
                            width: 100, height: 21, borderRadius: 20)),
                    const SizedBox(height: 2),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: ShimmerContainer(
                            width: 100, height: 17, borderRadius: 20)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          color: theme.colorScheme.surface,
          width: kScreenWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 9),
            child: Column(
              children: [
                Row(
                  children: [
                    ShimmerContainer(width: 40, height: 40, borderRadius: 30),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ShimmerContainer(
                                width: 100, height: 19, borderRadius: 20),
                          ),
                          const SizedBox(height: 4),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: ShimmerContainer(
                                  width: 50, height: 19, borderRadius: 20)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    ShimmerContainer(width: 100, height: 19, borderRadius: 20)
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: kScreenWidth - 32,
                  child: ShimmerContainer(
                      width: kScreenWidth - 32, height: 31, borderRadius: 20),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        )
      ],
    );
  }
}
