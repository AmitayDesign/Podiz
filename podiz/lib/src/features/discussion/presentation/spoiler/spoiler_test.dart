import 'package:flutter/material.dart';
import 'package:podiz/src/features/player/presentation/player.dart';

import 'spoiler_indicator.dart';

//TODO delete this file

class SpoilerTest extends StatelessWidget {
  const SpoilerTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: kBottomNavigationBarHeight + Player.height),
      child: SpoilerIndicator(
        onAction: (value) => print(value ? 'yes' : 'no'),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: 15,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (_, i) => Container(
            height: 50,
            color: Colors.white12,
            child: Text('spoiler test ${i + 1}'),
          ),
        ),
      ),
    );
  }
}
