import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/src/common_widgets/stacked_avatars.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';

class InsightsInfo extends StatelessWidget {
  final Podcast podcast;
  const InsightsInfo({Key? key, required this.podcast}) : super(key: key);

  int get insightsCount => podcast.comments;
  int get insightUsersCount => podcast.commentsImg.length;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        insightUsersCount > 1
            ? StackedAvatars(imageUrls: podcast.commentsImg)
            : Consumer(
                builder: (context, ref, _) {
                  final user = ref.watch(currentUserProvider);
                  return UserAvatar(user: user);
                },
              ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            insightsCount == 0
                ? Locales.string(context, "noinsigths")
                : insightsCount == 1
                    ? '1 insight'
                    : '${podcast.comments} insights',
            style: context.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
