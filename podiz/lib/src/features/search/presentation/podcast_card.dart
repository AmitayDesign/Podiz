import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/features/episodes/domain/podcast.dart';
import 'package:podiz/src/features/episodes/presentation/avatar/podcast_avatar.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:podiz/src/utils/string_zwsp.dart';

class PodcastCard extends ConsumerWidget {
  final Podcast podcast;
  final Widget? bottom;
  const PodcastCard(this.podcast, {Key? key, this.bottom}) : super(key: key);

  void openPodcast(BuildContext context, Reader read, Podcast podcast) {
    context.goNamed(
      AppRoute.podcast.name,
      params: {'podcastId': podcast.id},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleStyle = context.textTheme.titleMedium;
    final subtitleStyle = context.textTheme.bodyMedium;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: InkWell(
        onTap: () => openPodcast(context, ref.read, podcast),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PodcastAvatar(imageUrl: podcast.imageUrl),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        podcast.name,
                        style: titleStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                podcast.description.useCorrectEllipsis(),
                style: subtitleStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
