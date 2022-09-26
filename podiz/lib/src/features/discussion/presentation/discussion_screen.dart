import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/back_text_button.dart';
import 'package:podiz/src/common_widgets/empty_screen.dart';
import 'package:podiz/src/common_widgets/tap_to_unfocus.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/domain/player_time.dart';
import 'package:podiz/src/features/player/domain/playing_episode.dart';
import 'package:podiz/src/features/player/presentation/player_slider_controller.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/theme/palette.dart';

import 'comment/comment_card.dart';
import 'discussion_controller.dart';
import 'header/discussion_header.dart';
import 'sheet/comment_sheet.dart';
import 'spoiler/spoiler_indicator.dart';

class DiscussionScreen extends ConsumerStatefulWidget {
  final String episodeId;
  final Duration? time;
  const DiscussionScreen(this.episodeId, {Key? key, this.time})
      : super(key: key);

  @override
  ConsumerState<DiscussionScreen> createState() => _DiscussionScreenState();
}

class _DiscussionScreenState extends ConsumerState<DiscussionScreen> {
  late String episodeId = widget.episodeId;
  bool blockNewEpisode = true;

  @override
  void initState() {
    super.initState();
    initEpisode();
  }

  Future<void> initEpisode() async {
    final playerRepository = ref.read(playerRepositoryProvider);
    final playingEpisode = await playerRepository.fetchPlayingEpisode();
    final episodeIsPlaying = playingEpisode?.id == widget.episodeId;

    if (!episodeIsPlaying) {
      playerRepository.play(widget.episodeId, widget.time);
    } else if (widget.time != null) {
      playerRepository.resume(widget.episodeId, widget.time);
    }
  }

  @override
  Widget build(BuildContext context) {
    // update discussion episode
    ref.listen<AsyncValue<PlayingEpisode?>>(
      playerStateChangesProvider,
      (_, episodeValue) => episodeValue.whenData((episode) {
        if (episode != null) {
          if (blockNewEpisode) {
            if (episodeId == episode.id) blockNewEpisode = false;
          } else {
            Future.microtask(() => setState(() => episodeId = episode.id));
          }
        }
      }),
    );
    // filter comments based on player position
    ref.listen<PlayerTime>(
      playerSliderControllerProvider,
      (_, playerTime) => ref
          .read(filteredCommentsProvider(episodeId).notifier)
          .updateComments(playerTime.position),
    );

    final totalComments =
        ref.watch(filteredCommentsProvider(episodeId).notifier).comments;
    final comments = ref.watch(filteredCommentsProvider(episodeId));
    final showingAll = ref.watch(showingAllCommentsProvider.notifier);

    return TapToUnfocus(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Palette.darkPurple,
          automaticallyImplyLeading: false,
          title: const BackTextButton(),
        ),
        body: KeyboardVisibilityBuilder(
          builder: (context, isKeyBoardOpen) {
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: DiscussionHeader.height,
                    bottom: CommentSheet.height,
                  ),
                  child: totalComments.isEmpty
                      ? EmptyScreen.text(
                          'Be the first to comment on this podcast!'.hardcoded,
                        )
                      : SpoilerIndicator(
                          reverse: false,
                          enabled: !showingAll.state,
                          onAction: (showAll) {
                            if (showAll) showingAll.state = true;
                          },
                          builder: (showingAlert) {
                            return LayoutBuilder(
                                builder: (context, constraints) {
                              //TODO animated list view
                              return ListView(
                                reverse: true,
                                physics: showingAlert
                                    ? const NeverScrollableScrollPhysics()
                                    : const AlwaysScrollableScrollPhysics(),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                children: [
                                  if (comments.isEmpty)
                                    Padding(
                                      padding: EdgeInsets.only(
                                        //! hardcoded
                                        bottom: constraints.maxHeight / 2 - 25,
                                      ),
                                      child: EmptyScreen.text(
                                        'Comments will be displayed at their respective timestamp...'
                                            .hardcoded,
                                      ),
                                    ),
                                  for (final comment in comments)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: CommentCard(
                                        comment,
                                        episodeId: episodeId,
                                        showcase: comment.id == 'showcase',
                                      ),
                                    ),
                                ],
                              );
                            });
                          },
                        ),
                ),
                if (isKeyBoardOpen)
                  GestureDetector(
                    onTap: () {
                      ref.read(commentSheetTargetProvider.notifier).state =
                          null;
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: Container(color: Colors.black54),
                  ),
                DiscussionHeader(episodeId),
              ],
            );
          },
        ),
        bottomSheet: const CommentSheet(),
      ),
    );
  }
}
