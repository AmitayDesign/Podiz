import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/widgets/shimmerLoading.dart';
import 'package:podiz/player/PlayerManager.dart';
import 'package:podiz/player/components/discussionAppBar.dart';
import 'package:podiz/player/components/discussionCard.dart';
import 'package:podiz/player/components/discussionSnackBar.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/src/common_widgets/splash_screen.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/domain/player.dart';

class DiscussionPage extends ConsumerStatefulWidget {
  final String episodeId;
  const DiscussionPage(this.episodeId, {Key? key}) : super(key: key);

  @override
  ConsumerState<DiscussionPage> createState() => _DiscussionPageState();
}

class _DiscussionPageState extends ConsumerState<DiscussionPage> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(playerManagerProvider).setUpDiscussionPageStream(widget.episodeId);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget get loadingWidget => Column(children: [
        const Spacer(),
        ShimmerLoading(
          child: Container(
            width: kScreenWidth,
            height: 127,
            decoration: const BoxDecoration(
              color: Color(0xFF4E4E4E),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
          ),
        )
      ]);

  @override
  Widget build(BuildContext context) {
    final commentsValue = ref.watch(commentsStreamProvider);
    final episodeValue = ref.watch(episodeFutureProvider(widget.episodeId));
    ref.listen<AsyncValue<Player?>>(
      playerStateChangesProvider,
      (_, positionValue) {
        positionValue.whenOrNull(data: (player) {
          if (player == null) return;
          final playerManager = ref.read(playerManagerProvider);
          playerManager.showComments(player.playbackPosition);
        });
      },
    );
    return episodeValue.when(
        error: (e, st) {
          print('discussionPage episode: ${e.toString()}');
          return const SplashScreen.error();
        },
        loading: () => loadingWidget,
        data: (episode) {
          return Scaffold(
            appBar: DiscussionAppBar(episode),
            body: commentsValue.when(
                error: (e, _) {
                  print('discussionPage comments: ${e.toString()}');
                  return const SplashScreen.error();
                },
                loading: () => loadingWidget,
                data: (comments) {
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          reverse: true,
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            return DiscussionCard(
                              episode,
                              comments[index],
                            );
                          },
                        ),
                      ),
                      DiscussionSnackBar(episode),
                    ],
                  );
                }),
          );
        });
  }
}
