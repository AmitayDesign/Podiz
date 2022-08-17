import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';

class SpoilerAlertCard extends StatelessWidget {
  const SpoilerAlertCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleStyle = context.textTheme.titleMedium;
    final subtitleStyle = context.textTheme.bodyMedium;

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 0,
      clipBehavior: Clip.hardEdge,
      color: context.colorScheme.error,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16)
            .add(const EdgeInsets.only(top: 8, bottom: 12)),
        child: Column(
          children: [
            Text(
              'Spoiler Alert',
              style: titleStyle,
            ),
            Text(
              'Are you sure you want to see comments beyond your current listening time?',
              style: subtitleStyle,
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text('YES'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('NO'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
