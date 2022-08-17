import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/presentation/player_button.dart';
import 'package:podiz/src/features/player/presentation/player_controller.dart';
import 'package:podiz/src/features/player/presentation/time_chip.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/theme/palette.dart';

class DiscussionSheet extends ConsumerStatefulWidget {
  const DiscussionSheet({Key? key}) : super(key: key);

  @override
  ConsumerState<DiscussionSheet> createState() => _QuickNoteSheetState();
}

class _QuickNoteSheetState extends ConsumerState<DiscussionSheet> {
  final buttonSize = kMinInteractiveDimension * 5 / 6;
  final commentNode = FocusNode();
  final commentController = TextEditingController();
  String get comment => commentController.text;

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  //TODO close sheet
  //TODO send commnet
  void sendComment(String episodeId) {
    // ref.read(authManagerProvider).doComment(
    //       commentController.text,
    //       episodeId,
    //       ref.read(playerTimeStreamProvider).value!.position,
    //     );
    commentController.clear();
    commentNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final episode = ref.watch(playerStateChangesProvider).valueOrNull!;
    final state = ref.watch(playerControllerProvider);
    return Material(
      color: Palette.grey900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(kBorderRadius),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final user = ref.watch(currentUserProvider);
                    return UserAvatar(user: user, radius: buttonSize / 2);
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    focusNode: commentNode,
                    controller: commentController,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.send,
                    minLines: 1,
                    maxLines: 5,
                    style: context.textTheme.bodyMedium!.copyWith(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: context.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(
                          kMinInteractiveDimension / 2,
                        ),
                      ),
                      hintText: "Share your insight...",
                    ),
                    onSubmitted: (_) => sendComment(episode.id),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox.square(
                  dimension: buttonSize,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () => sendComment(episode.id),
                    child: const Icon(Icons.send, size: kSmallIconSize),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
              child: Row(
                children: [
                  Text(
                    "${episode.userIdsWatching.length - 1} listening with you"
                        .hardcoded,
                    style: context.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  PlayerButton(
                    loading: state.isLoading,
                    onPressed:
                        ref.read(playerControllerProvider.notifier).rewind,
                    icon: const Icon(Icons.replay_30),
                  ),
                  episode.isPlaying
                      ? TimeChip(
                          loading: state.isLoading,
                          onTap:
                              ref.read(playerControllerProvider.notifier).pause,
                          icon: Icons.pause,
                        )
                      : TimeChip(
                          loading: state.isLoading,
                          onTap:
                              ref.read(playerControllerProvider.notifier).play,
                          icon: Icons.play_arrow,
                        ),
                  PlayerButton(
                    loading: state.isLoading,
                    onPressed:
                        ref.read(playerControllerProvider.notifier).fastForward,
                    icon: const Icon(Icons.forward_30),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
