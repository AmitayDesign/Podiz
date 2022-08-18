import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/common_widgets/splash_screen.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/episodes/presentation/card/episode_card.dart';
import 'package:podiz/src/features/episodes/presentation/card/skeleton_episode_card.dart';
import 'package:podiz/src/features/episodes/presentation/podcast/podcast_follow_fab.dart';
import 'package:podiz/src/features/episodes/presentation/podcast/podcast_sliver_bar.dart';
import 'package:podiz/src/utils/zwsp_string.dart';

class PodcastScreen extends ConsumerStatefulWidget {
  final String podcastId;
  const PodcastScreen(this.podcastId, {Key? key}) : super(key: key);

  @override
  ConsumerState<PodcastScreen> createState() => _PodcastScreenState();
}

class _PodcastScreenState extends ConsumerState<PodcastScreen> {
  final scrollController = ScrollController();

  double get statusBarHeight => MediaQuery.of(context).padding.top;
  double get minHeight => statusBarHeight + GradientBar.height * 1.5;
  double get maxHeight => statusBarHeight + 320;

  void snapHeader() {
    final distance = maxHeight - minHeight;
    final offset = scrollController.offset;
    if (offset > 0 && offset < distance) {
      final snapOffset = offset / distance > 0.5 ? distance : 0.0;
      Future.microtask(
        () => scrollController.animateTo(
          snapOffset,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final podcastValue = ref.watch(showFutureProvider(widget.podcastId));
    return podcastValue.when(
      error: (e, _) => const SplashScreen.error(), //!
      loading: () => const SplashScreen(), //!
      data: (podcast) => Scaffold(
        extendBodyBehindAppBar: true,
        body: NotificationListener<ScrollEndNotification>(
          onNotification: (_) {
            snapHeader();
            return false;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: scrollController,
            slivers: [
              PodcastSliverHeader(
                podcast: podcast,
                minHeight: minHeight,
                maxHeight: maxHeight,
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Consumer(
                    builder: (context, ref, _) {
                      final episodeId = podcast.podcasts[i];
                      final episodeValue =
                          ref.watch(episodeFutureProvider(episodeId));
                      return episodeValue.when(
                        loading: () => const SkeletonEpisodeCard(),
                        error: (e, _) => const SizedBox.shrink(),
                        data: (episode) => EpisodeCard(
                          episode,
                          bottom: Text(
                            episode.description.useCorrectEllipsis(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  ),
                  childCount: podcast.podcasts.length,
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: PodcastFollowFab(
          podcastId: widget.podcastId,
          imageUrl: podcast.imageUrl,
        ),
      ),
    );
  }
}
