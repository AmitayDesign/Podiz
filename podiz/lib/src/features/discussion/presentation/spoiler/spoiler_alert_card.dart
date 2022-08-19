import 'package:flutter/material.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/theme/context_theme.dart';

class SpoilerAlertCard extends StatelessWidget {
  final ValueSetter<bool> onAction;
  const SpoilerAlertCard({Key? key, required this.onAction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleStyle = context.textTheme.titleSmall;
    final subtitleStyle = context.textTheme.bodyMedium;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16)
          .add(const EdgeInsets.only(top: 16, bottom: 8)),
      decoration: BoxDecoration(
        color: context.colorScheme.error,
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Column(
        children: [
          Text(
            'Spoiler Alert',
            style: titleStyle,
          ),
          const SizedBox(height: 8),
          Text(
            'Are you sure you want to see comments beyond your current listening time?',
            style: subtitleStyle,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  shape: const StadiumBorder(),
                ),
                onPressed: () => onAction(true),
                child: Text('YES', style: titleStyle),
              ),
              const SizedBox(width: 8),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: const StadiumBorder(),
                ),
                onPressed: () => onAction(false),
                child: Text(
                  'NO',
                  style: titleStyle!.copyWith(
                    color: context.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
