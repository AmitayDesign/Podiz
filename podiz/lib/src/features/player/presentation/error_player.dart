import 'dart:io';

import 'package:flutter/material.dart';
import 'package:podiz/src/features/player/presentation/player.dart';
import 'package:podiz/src/theme/context_theme.dart';

class ErrorPlayer extends StatelessWidget {
  final bool extraBottomPadding;
  const ErrorPlayer(this.extraBottomPadding, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.errorContainer,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 4, color: Colors.white38),
          Container(
            height:
                (extraBottomPadding ? Player.extraHeight : Player.height) - 4,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12).add(
              Platform.isIOS && extraBottomPadding
                  ? const EdgeInsets.only(bottom: 16)
                  : EdgeInsets.zero,
            ),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const SizedBox.square(
                  dimension: 52,
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
        ],
      ),
    );
  }
}
