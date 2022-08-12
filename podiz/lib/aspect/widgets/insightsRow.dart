import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/widgets/stackedImages.dart';
import 'package:podiz/home/components/profileAvatar.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/providers.dart';

class InsightsRow extends StatelessWidget {
  final Podcast podcast;
  const InsightsRow({Key? key, required this.podcast}) : super(key: key);

  bool get hasComments => podcast.comments > 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        hasComments
            ? StackedImages(podcast, size: 16)
            : Consumer(
                builder: (context, ref, _) {
                  final user = ref.watch(currentUserProvider);
                  return ProfileAvatar(user: user, radius: 16);
                },
              ),
        // const SizedBox(width: 8),
        Expanded(
          child: Text(
            hasComments
                ? '${podcast.comments} insights'
                : Locales.string(context, "noinsigths"),
            style: context.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
