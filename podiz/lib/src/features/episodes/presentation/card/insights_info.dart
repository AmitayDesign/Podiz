import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/src/common_widgets/stacked_avatars.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';

class InsightsInfo extends StatelessWidget {
  final Episode episode;
  const InsightsInfo({Key? key, required this.episode}) : super(key: key);

  int get insightsCount => episode.commentsCount;
  int get insightUsersCount => episode.commentImageUrls.length;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        insightUsersCount > 1
            ? StackedAvatars(imageUrls: episode.commentImageUrls)
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
                    : '${episode.commentsCount} insights',
            style: context.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
