import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/theme/palette.dart';

class QuickNoteSheet extends ConsumerStatefulWidget {
  final Episode episode;
  const QuickNoteSheet({Key? key, required this.episode}) : super(key: key);

  @override
  ConsumerState<QuickNoteSheet> createState() => _QuickNoteSheetState();
}

class _QuickNoteSheetState extends ConsumerState<QuickNoteSheet> {
  final buttonSize = kMinInteractiveDimension * 5 / 6;
  final commentController = TextEditingController();
  String get comment => commentController.text;

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  //TODO send comment
  void sendComment() {
    // ref.read(authManagerProvider).doComment(
    //       commentController.text,
    //       widget.episode.id,
    //       widget.episode.duration,
    //     );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
                    autofocus: true,
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
              child: Text(
                //TODO locales text
                "${widget.episode.userIdsWatching.length} listening right now",
                style: context.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
