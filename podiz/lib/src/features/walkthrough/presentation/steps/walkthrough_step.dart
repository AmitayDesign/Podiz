import 'package:flutter/material.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:podiz/src/theme/palette.dart';

class WalkthroughStep extends StatelessWidget {
  final String title;
  final String boldTitle;
  final List<String> texts;

  const WalkthroughStep({
    Key? key,
    required this.title,
    required this.boldTitle,
    required this.texts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text.rich(TextSpan(
            text: title,
            style: context.textTheme.bodyLarge!.copyWith(
              fontSize: 18,
              color: Palette.deepPurple,
            ),
            children: [
              const TextSpan(text: ' '),
              TextSpan(
                text: boldTitle,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          )),
        ),
        const SizedBox(height: 24),
        for (final text in texts) ...[
          Text(text, style: const TextStyle(color: Palette.deepPurple)),
          const SizedBox(height: 16),
        ],
        const Expanded(
          child: SizedBox.shrink(), //TODO walkthrough video
        ),
      ],
    );
  }
}
