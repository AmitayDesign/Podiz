import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/player/components/discussionCard.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/objects/Podcast.dart';

class CommentCard extends ConsumerWidget {
  Comment comment;
  CommentCard(this.comment, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    Podcast podcast = ref
        .read(podcastManagerProvider)
        .getPodcastById(comment.uid)
        .searchResultToPodcast();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              PodcastAvatar(imageUrl: podcast.image_url, size: 32),
              const SizedBox(width: 8),
              Container(
                width: 250,
                height: 32,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        podcast.name,
                        style: discussionCardProfile(),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(podcast.show_name,
                            style: discussionAppBarInsights())),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          color: theme.colorScheme.surface,
          width: kScreenWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Text(
              comment.comment,
              style: discussionCardComment(),
              textAlign: TextAlign.left,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
