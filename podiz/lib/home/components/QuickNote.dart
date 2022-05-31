import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';

class QuickNote extends StatelessWidget {
  const QuickNote({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 31,
      decoration: BoxDecoration(
        color: Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: InkWell(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(
            Icons.edit,
            size: 16,
            color: Color(0xFF9E9E9E),
          ),
          const SizedBox(width: 10),
          Text(Locales.string(context, "quicknote"),
              style: podcastArtistQuickNote()),
        ]),
        onTap: () {}, //TODO do this commentPage
      ),
    );
  }
}
