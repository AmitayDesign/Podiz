import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/discussion/presentation/skeleton_discussion_header.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/episodes/presentation/card/episode_content.dart';
import 'package:podiz/src/features/player/presentation/player_slider.dart';
import 'package:podiz/src/theme/palette.dart';

class DiscussionHeader extends ConsumerWidget {
  static const height = 120.0; //! hardcoded
  final String episodeId;
  const DiscussionHeader(this.episodeId, {Key? key}) : super(key: key);

  final backgroundColor = Palette.darkPurple;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodeValue = ref.watch(episodeFutureProvider(episodeId));
    return episodeValue.when(
      loading: () => const SkeletonDiscussionHeader(),
      error: (e, _) => const SizedBox.shrink(),
      data: (episode) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(bottom: PlayerSlider.height / 2 + 2),
                child: Material(
                  color: backgroundColor,
                  child: EpisodeContent(
                    episode,
                    disableAvatarNavigation: true,
                    color: backgroundColor,
                    avatarSize: 48,
                    titleMaxLines: 1,
                  ),
                ),
              ),
              const PlayerSlider(),
            ],
          ),
        ],
      ),
    );
  }
}
