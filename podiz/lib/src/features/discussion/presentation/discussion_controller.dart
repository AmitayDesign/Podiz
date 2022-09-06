import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/discussion/data/discussion_repository.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/player/presentation/player_slider_controller.dart';

final filteredCommentsProvider =
    StateProvider.family.autoDispose<List<Comment>, String>(
  (ref, episodeId) {
    final time = ref.watch(playerSliderControllerProvider);
    final commentsValue = ref.watch(commentsStreamProvider(episodeId));
    return commentsValue.valueOrNull ?? [];
  },
);

class DiscussionController extends StateNotifier<List<Comment>> {
  DiscussionController() : super([]);
}
