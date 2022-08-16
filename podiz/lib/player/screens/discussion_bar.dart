import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/profile/components.dart/backAppBar.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/features/episodes/presentation/card/episode_content.dart';
import 'package:podiz/src/features/player/presentation/player_slider.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/theme/palette.dart';

class DiscussionBar extends StatelessWidget with PreferredSizeWidget {
  final String episodeId;
  const DiscussionBar(this.episodeId, {Key? key}) : super(key: key);

  void openShow(Episode episode, BuildContext context) {
    context.goNamed(
      AppRoute.show.name,
      params: {'showId': episode.showId},
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(GradientBar.height + 8 + 108 + 4);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: GradientBar.height,
      automaticallyImplyLeading: false,
      backgroundColor: Palette.darkPurple,
      title: const BackAppBarButton(), //!
      flexibleSpace: Padding(
        padding: const EdgeInsets.only(
          top: GradientBar.height + 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer(
              builder: (context, ref, _) {
                final episodeValue =
                    ref.watch(episodeFutureProvider(episodeId));
                return episodeValue.when(
                  loading: () => const SizedBox.shrink(), //!
                  error: (e, _) => const SizedBox.shrink(), //!
                  data: (episode) => EpisodeContent(episode),
                );
              },
            ),
            const PlayerSlider(),
          ],
        ),
      ),
    );
  }
}
