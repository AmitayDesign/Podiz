import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/discussion/data/discussion_repository.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/discussion/presentation/sound_controller.dart';
import 'package:podiz/src/features/player/presentation/player_slider_controller.dart';

final showingAllCommentsProvider = StateProvider.autoDispose<bool>(
  (ref) => false,
);

final filteredCommentsProvider = StateNotifierProvider.family
    .autoDispose<DiscussionController, List<Comment>, String>(
  (ref, episodeId) {
    final comments = ref.watch(commentsStreamProvider(episodeId)).value ?? [];
    final playerTime = ref.read(playerSliderControllerProvider);
    final position =
        playerTime.episodeId == episodeId ? playerTime.position : Duration.zero;
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
  final BeepController? beepController;

  DiscussionController({
    required this.comments,
    required this.showingAll,
    required Duration currentPosition,
    this.beepController,
  }) : super(showingAll ? comments : filterComments(comments, currentPosition));

  static List<Comment> filterComments(List<Comment> comments, Duration pos) {
    return comments.where((c) => c.timestamp <= pos).toList();
  }

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
}
