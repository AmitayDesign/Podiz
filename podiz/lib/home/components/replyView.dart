import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/authentication/auth_manager.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/theme/palette.dart';

class ReplyView extends ConsumerWidget {
  final Comment comment;
  final UserPodiz user;
  ReplyView({Key? key, required this.comment, required this.user})
      : super(key: key);
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: kScreenWidth,
      decoration: const BoxDecoration(
        color: Color(0xFF4E4E4E),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Replying to...",
                style: context.textTheme.bodyMedium!.copyWith(
                  color: Palette.grey600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                UserAvatar(user: user, radius: 20),
                const SizedBox(width: 8),
                Column(
                  children: [
                    Text(
                      user.name,
                      style: context.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${user.followers.length} Followers",
                      style: context.textTheme.bodyMedium!.copyWith(
                        color: Palette.grey600,
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                comment.comment,
                style: context.textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                UserAvatar(user: user, radius: 15.5),
                const SizedBox(width: 8),
                LimitedBox(
                  maxWidth: kScreenWidth - (14 + 31 + 8 + 31 + 8 + 14),
                  maxHeight: 31,
                  child: TextField(
                    // key: _key,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    controller: controller,
                    style: context.textTheme.bodyMedium!.copyWith(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF262626),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      hintStyle: context.textTheme.bodyMedium!.copyWith(
                        color: Palette.white90,
                      ),
                      hintText: "Comment on ${user.name} insight...",
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => ref
                      .read(authManagerProvider)
                      .doReply(comment, controller.text),
                  child: Container(
                    height: 31,
                    width: 31,
                    decoration: BoxDecoration(
                      color: Palette.purple,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.send,
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}
