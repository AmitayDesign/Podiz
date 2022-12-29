import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/discussion/data/discussion_repository.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/discussion/presentation/sound_controller.dart';
import 'package:podiz/src/features/player/presentation/player_slider_controller.dart';
import 'package:podiz/src/features/showcase/presentation/showcase_controller.dart';

final showingAllCommentsProvider = StateProvider.autoDispose<bool>(
  (ref) => false,
);

final filteredCommentsProvider = StateNotifierProvider.family
    .autoDispose<DiscussionController, List<Comment>, String>(
  (ref, episodeId) {
    final isShowcaseRunning = ref.watch(showcaseRunningProvider);
    if (isShowcaseRunning) return DiscussionController.showcase();

    final comments = ref.watch(commentsStreamProvider(episodeId)).value ?? [];
    final position = ref.read(playerSliderControllerProvider).position;
    final showingAllComments = ref.watch(showingAllCommentsProvider);
    return DiscussionController(
      comments: comments.reversed.toList(),
      showingAll: showingAllComments,
      currentPosition: position,
      beepController: ref.watch(beepControllerProvider),
    );
  },
);

class DiscussionController extends StateNotifier<List<Comment>> {
  final List<Comment> comments;
  final bool showingAll;
  final bool showcase;
  final BeepController? beepController;

  DiscussionController({
    required this.comments,
    required this.showingAll,
    required Duration currentPosition,
    this.beepController,
  })  : showcase = false,
        super(
            showingAll ? comments : filterComments(comments, currentPosition));

  DiscussionController.showcase()
      : comments = [],
        showingAll = true,
        showcase = true,
        beepController = null,
        super([]);

  static List<Comment> filterComments(List<Comment> comments, Duration pos) =>
      comments.where((c) => c.timestamp <= pos).toList();

  void updateComments(Duration position, bool beep) {
    if (showingAll) return;
    final filteredComments = filterComments(comments, position);
    if (filteredComments.length != state.length) {
      if (beep && filteredComments.length > state.length) {
        if (Platform.isAndroid) beepController?.play();
      }
      state = filteredComments;
    }
  }

  void addComment(Comment comment) {
    assert(showcase == true);
    comments
      ..add(comment)
      ..sort((c1, c2) => c2.timestamp.compareTo(c1.timestamp));
    state = [...comments];
  }
}


    // //? Showcasing
    // final exampleComment = Comment(
    //   id: 'example',
    //   text: 'Great episode!',
    //   episodeId: episodeId,
    //   userId: '', //!
    //   timestamp: showcaseComment?.timestamp ?? Duration.zero,
    // );
    // final step = (ShowCaseWidget.of(context).activeWidgetId ?? -1) + 1;
    // late final List<Comment> filteredComments;
    // if (step == 0) {
    //   filteredComments = isShowingAllComments
    //       ? comments.reversed.toList()
    //       : comments.reversed
    //           .where((comment) => comment.timestamp <= playerTime.position)
    //           .toList();
    // } else {
    //   filteredComments = [
    //     exampleComment,
    //     if (step == 3 && showcaseComment != null) showcaseComment!,
    //   ];
    // }

    // if (showcasing && step == 2) []
    // if (sjowcasing && step == 3)
    // filteredComments = new Comment(Ami) + comments.firstWhere(fromUser)