import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/features/episodes/presentation/card/episode_content.dart';
import 'package:podiz/src/features/player/presentation/player_slider.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/theme/palette.dart';

class DiscussionHeader extends ConsumerWidget {
  final String episodeId;
  const DiscussionHeader(this.episodeId, {Key? key}) : super(key: key);

  final backgroundColor = Palette.darkPurple;

  void openShow(Episode episode, BuildContext context) {
    context.goNamed(
      AppRoute.show.name,
      params: {'showId': episode.showId},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodeValue = ref.watch(episodeFutureProvider(episodeId));
    return episodeValue.when(
      loading: () => const SizedBox.shrink(), //TODO skeleton
      error: (e, _) => const SizedBox.shrink(),
      data: (episode) => Container(
        color: backgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EpisodeContent(episode, color: backgroundColor),
            const PlayerSlider(),
          ],
        ),
      ),
    );
  }
}
