import 'package:flutter/material.dart';
import 'package:podiz/src/theme/context_theme.dart';

class EmptyProfile extends StatelessWidget {
  final String name;
  const EmptyProfile({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/noComments.png',
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 32),
          Text(
            '$name hasn\'t commented on podcasts yet...',
            style: context.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
