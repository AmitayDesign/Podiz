import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/back_text_button.dart';
import 'package:podiz/src/common_widgets/tap_to_unfocus.dart';
import 'package:podiz/src/features/discussion/data/discussion_repository.dart';
import 'package:podiz/src/features/discussion/presentation/comment/comment_text_field.dart';
import 'package:podiz/src/features/discussion/presentation/spoiler/spoiler_indicator.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/domain/playing_episode.dart';
import 'package:podiz/src/features/player/presentation/player_slider_controller.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/showcase/showcase_keys.dart';
import 'package:podiz/src/theme/palette.dart';

import '../../../common_widgets/empty_screen.dart';
import 'comment/comment_card.dart';
import 'discussion_header.dart';
import 'sheet/comment_sheet.dart';

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
  final scrollController = ScrollController();
  int commentsCount = 0;
  var isShowingAllComments = false;

  @override
  void initState() {
    super.initState();
    if (widget.time != null) {
      final player = ref.read(playerSliderControllerProvider.notifier);
      player.seekTo(widget.time!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // update discussion episode
    ref.listen<AsyncValue<PlayingEpisode?>>(
      playerStateChangesProvider,
      (_, episodeValue) => episodeValue.whenData((episode) {
        if (episode != null) {
          Future.microtask(() => setState(() => episodeId = episode.id));
        }
      }),
    );
    return ShowcaseOverlay(
      step: 2,
      text: 'Comment what you think',
      alignment: ShowcaseAlignment.top,
      child: TapToUnfocus(
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
                  Consumer(
                    builder: (context, ref, _) {
                      // watch player time
                      final commentsValue =
                          ref.watch(commentsStreamProvider(episodeId));
                      final playerTime =
                          ref.watch(playerSliderControllerProvider);
                      const bodyPadding = EdgeInsets.only(
                        top: DiscussionHeader.height,
                        bottom: CommentSheet.height,
                      );

                      //* Loading / Error Widgets
                      return commentsValue.when(
                        loading: () => EmptyScreen.loading(
                          padding: bodyPadding,
                        ),
                        error: (e, _) => EmptyScreen.text(
                          'There was an error displaying the comments.'
                              .hardcoded,
                          padding: bodyPadding,
                        ),
                        data: (comments) {
                          if (comments.isEmpty) {
                            return EmptyScreen.text(
                              'Be the first to comment on this podcast!'
                                  .hardcoded,
                              padding: bodyPadding,
                            );
                          }
                          final filteredComments = isShowingAllComments
                              ? comments.reversed
                              : comments.reversed
                                  .where((comment) =>
                                      comment.timestamp <= playerTime.position)
                                  .toList();
                          if (commentsCount != 0 &&
                              commentsCount != filteredComments.length &&
                              scrollController.hasClients &&
                              scrollController.offset >
                                  scrollController.position.maxScrollExtent -
                                      100) {
                            Future.microtask(() => scrollController.animateTo(
                                  scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.ease,
                                ));
                          }
                          return Padding(
                            padding: bodyPadding,
                            child: SpoilerIndicator(
                              reverse: false,
                              enabled: !isShowingAllComments,
                              onAction: (showAll) {
                                if (showAll) {
                                  setState(() => isShowingAllComments = true);
                                }
                              },
                              builder: (showingAlert) {
                                return LayoutBuilder(
                                    builder: (context, constraints) {
                                  return ListView(
                                    reverse: true,
                                    controller: scrollController,
                                    physics: showingAlert
                                        ? const NeverScrollableScrollPhysics()
                                        : const AlwaysScrollableScrollPhysics(),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    children: [
                                      if (filteredComments.isEmpty)
                                        EmptyScreen.text(
                                          'Comments will be displayed at their respective timestamp...'
                                              .hardcoded,
                                          padding: EdgeInsets.only(
                                            //! hardcoded
                                            bottom:
                                                constraints.maxHeight / 2 - 25,
                                          ),
                                        ),
                                      for (final comment in filteredComments)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: CommentCard(
                                            comment,
                                            episodeId: episodeId,
                                            navigate: false,
                                          ),
                                        ),
                                    ],
                                  );
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
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
          bottomSheet: ShowcaseStep(
            step: 2,
            onTap: ref.read(commentNodeProvider).requestFocus,
            description: '"I love that example, it made me think about..."',
            child: const CommentSheet(),
          ),
        ),
      ),
    );
  }
}
