import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/authentication/auth_manager.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/player/components/pinkTimer.dart';
import 'package:podiz/player/playerController.dart';
import 'package:podiz/player/playerWidget.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';

class InsightSheet extends ConsumerStatefulWidget {
  final Podcast podcast;
  const InsightSheet({Key? key, required this.podcast}) : super(key: key);

  @override
  ConsumerState<InsightSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends ConsumerState<InsightSheet> {
  final buttonSize = kMinInteractiveDimension * 5 / 6;
  final commentController = TextEditingController();
  String get comment => commentController.text;

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void sendComment() {
    ref.read(authManagerProvider).doComment(
          commentController.text,
          widget.podcast.uid!,
          ref.read(playerStateChangesProvider).value!.playbackPosition,
        );
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final playerValue = ref.watch(playerStateChangesProvider);
    final loadingAction = ref.watch(playerControllerProvider);
    return playerValue.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (player) {
        if (player == null) return const SizedBox.shrink();
        final action =
            player.isPlaying ? PlayerAction.pause : PlayerAction.play;
        final icon = player.isPlaying ? Icons.pause : Icons.play_arrow;
        final onTap = player.isPlaying
            ? () => ref.read(playerControllerProvider.notifier).pause()
            : () => ref.read(playerControllerProvider.notifier).play();
        return Padding(
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
                      onSubmitted: (_) => sendComment(),
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
                      onPressed: sendComment,
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
                      "${widget.podcast.watching} listening with you".hardcoded,
                      style: context.textTheme.bodySmall,
                    ),
                    const Spacer(),
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.all(8),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: loadingAction == null
                            ? () => ref
                                .read(playerControllerProvider.notifier)
                                .goBackward()
                            : null,
                        icon: loadingAction == PlayerAction.backward
                            ? const LoadingAction()
                            : const Icon(Icons.replay_30),
                      ),
                    ),
                    // const SizedBox(width: 18),
                    PinkTimer(
                      onPressed: loadingAction == null ? onTap : null,
                      icon: loadingAction == action
                          ? const LoadingAction()
                          : Icon(icon),
                    ),
                    // const SizedBox(width: 18),
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.all(8),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: loadingAction == null
                            ? () => ref
                                .read(playerControllerProvider.notifier)
                                .goForward()
                            : null,
                        icon: loadingAction == PlayerAction.forward
                            ? const LoadingAction()
                            : const Icon(Icons.forward_30),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
