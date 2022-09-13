import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/discussion/presentation/header/discussion_header.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:podiz/src/theme/palette.dart';

class ErrorDiscussionHeader extends ConsumerWidget {
  const ErrorDiscussionHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: DiscussionHeader.height,
      color: Palette.darkPurple,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox.square(
                    dimension: 64,
                    child: Center(
                      child: Icon(Icons.error_outline_rounded),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'There was an error playing this episode.',
                      style: TextStyle(
                        color: context.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(height: 4, color: Colors.white38),
        ],
      ),
    );
  }
}
