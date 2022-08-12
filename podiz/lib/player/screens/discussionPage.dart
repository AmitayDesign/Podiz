import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/widgets/shimmerLoading.dart';
import 'package:podiz/player/PlayerManager.dart';
import 'package:podiz/player/components/discussionAppBar.dart';
import 'package:podiz/player/components/discussionCard.dart';
import 'package:podiz/player/components/discussionSnackBar.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/splashScreen.dart';

class DiscussionPage extends ConsumerStatefulWidget {
  final String showId;
  const DiscussionPage(this.showId, {Key? key}) : super(key: key);

  @override
  ConsumerState<DiscussionPage> createState() => _DiscussionPageState();
}

class _DiscussionPageState extends ConsumerState<DiscussionPage> {
  late String episodeUid;

  final TextEditingController controller = TextEditingController();

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
    final podcastValue = ref.watch(podcastFutureProvider(widget.showId));
    ref.listen<AsyncValue<Duration?>>(
      playerPositionStreamProvider,
      (_, positionValue) {
        positionValue.whenOrNull(data: (position) {
          if (position == null) return;
          final playerManager = ref.read(playerManagerProvider);
          playerManager.showComments(position.inMilliseconds);
        });
      },
    );
    return Scaffold(
      appBar: DiscussionAppBar(podcastValue.valueOrNull),
      body: podcastValue.when(
          error: (e, st) {
            print('discussionPage: ${e.toString()}');
            return SplashScreen.error();
          },
          loading: () => loadingWidget,
          data: (podcast) {
            return commentsValue.when(
                error: (e, _) {
                  print('discussionPage: ${e.toString()}');
                  return SplashScreen.error();
                },
                loading: () => loadingWidget,
                data: (comments) {
                  return Column(children: [
                    Expanded(
                      child: ListView.builder(
                        reverse: true,
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          return DiscussionCard(
                            podcast,
                            comments[index],
                          );
                        },
                      ),
                    ),
                    DiscussionSnackBar(podcast)
                  ]);
                });
          }),
    );
  }
}
