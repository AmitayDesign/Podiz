import 'dart:io' as io;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:podiz/src/common_widgets/symbols.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/data/user_repository.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/features/discussion/data/discussion_repository.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/discussion/presentation/comment/comment_menu_button.dart';
import 'package:podiz/src/features/discussion/presentation/sheet/comment_sheet.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/episodes/data/podcast_repository.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/presentation/time_chip.dart';
import 'package:podiz/src/features/showcase/presentation/package_files/showcase_widget.dart';
import 'package:podiz/src/features/showcase/presentation/showcase_step.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/statistics/mix_panel_repository.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:share_plus/share_plus.dart';

import 'comment_text.dart';
import 'comment_text_field.dart';
import 'comment_trailing.dart';
import 'reply_widget.dart';

class CommentCard extends ConsumerStatefulWidget {
  final Comment comment;
  final String episodeId;
  final bool navigate;
  final bool showcase;

  final VoidCallback? onReply;

  const CommentCard(
    this.comment, {
    Key? key,
    required this.episodeId,
    this.navigate = false,
    this.showcase = false,
    this.onReply,
  }) : super(key: key);

  @override
  ConsumerState<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends ConsumerState<CommentCard> {
  late var collapsed = widget.comment.replyCount > 1;
  late DateTime date;

  @override
  void initState() {
    date = DateTime.now();
    super.initState();
  }

  void seekToTimestamp() async {
    // play 10 seconds before
    const delay = Duration(seconds: 10);
    final playTime = widget.comment.timestamp - delay;
    if (widget.navigate) {
      context.pushNamed(
        AppRoute.discussion.name,
        params: {'episodeId': widget.episodeId},
        queryParams: {'t': playTime.inSeconds.toString()},
      );
    } else {
      ref.read(playerRepositoryProvider).resume(widget.episodeId, playTime);
    }
  }

  Future<bool> isIpad() async {
    if (!io.Platform.isIOS) return false;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo info = await deviceInfo.iosInfo;
    if (info.model != null && info.model!.toLowerCase().contains("ipad")) {
      return true;
    }
    return false;
  }

  void share(Comment comment) async {
    final episodeId = comment.episodeId;
    final episode = ref.read(episodeFutureProvider(episodeId)).valueOrNull!;
    final podcast =
        ref.read(podcastFutureProvider(episode.showId)).valueOrNull!;
    final timestamp = comment.timestamp.inSeconds;
    var url = 'https://podiz.io';
    // if (Platform.isIOS) {
    //   final dynamicLinkParamenters = DynamicLinkParameters(
    //       link: Uri.parse(link),
    //       uriPrefix: '',
    //       iosParameters: const IOSParameters(bundleId: "com.amitay.podiz"));
    //   var dynamicLink =
    //       await FirebaseDynamicLinks.instance.buildLink(dynamicLinkParamenters);
    //   link = dynamicLink.toString();
    // }
    RenderBox? box = context.findRenderObject() as RenderBox?;
    final ipad = await isIpad();

    final DynamicLinkParameters params = DynamicLinkParameters(
      link: Uri.parse("$url/discussion/$episodeId?t=$timestamp"),
      uriPrefix: "https://amitay.page.link",
      iosParameters: const IOSParameters(
        bundleId: "com.amitay.podiz",
        minimumVersion: "0",
      ),
      androidParameters: const AndroidParameters(
        packageName: "com.amitay.podiz",
        minimumVersion: 0,
      ),
    );

    final link = await FirebaseDynamicLinks.instance.buildLink(params);

    Share.share(
      'Check out this comment I found on Podiz about ${podcast.name}!\n\n'
      '${comment.text}\n'
      '${link.toString()}',
      subject: 'Insight I found on Podiz about ${podcast.name}',
      sharePositionOrigin:
          ipad ? box!.localToGlobal(Offset.zero) & box.size : null,
    );

    ref.read(mixPanelRepository).userShare();
  }

  String format(DateTime d) {
    var dateSub60min = date.subtract(const Duration(minutes: 60));
    var dateSub24h = date.subtract(const Duration(hours: 24));

    if (dateSub24h.compareTo(d) == -1) {
      var minutes = date.difference(d);
      return '${minutes.inMinutes}m\' ago';
    } else if (dateSub60min.compareTo(d) == -1) {
      var hours = date.difference(d);
      return '${hours.inHours}h\' ago';
    }
    if (d.year == DateTime.now().year) {
      return DateFormat('HH:mm MMM dd').format(d);
    } else {
      return DateFormat('HH:mm MMM dd yyyy').format(d);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user =
        ref.watch(userFutureProvider(widget.comment.userId)).valueOrNull;
    if (user == null) return const SizedBox.shrink();
    return Material(
      color: context.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 4),
              child: Row(
                children: [
                  if (widget.showcase)
                    showcase(
                      user: user,
                      child: UserAvatar(
                        user: user,
                        radius: kMinInteractiveDimension * 5 / 12,
                      ),
                    )
                  else
                    UserAvatar(
                      user: user,
                      radius: kMinInteractiveDimension * 5 / 12,
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: context.textTheme.titleSmall,
                        ),
                        Text(
                          '${user.followers.length} followers'
                          ' $dot ${format(widget.comment.date!)}',
                          maxLines: 1,
                          style: context.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TimeChip(
                    icon: Icons.play_arrow_rounded,
                    position: widget.comment.timestamp,
                    onTap: seekToTimestamp,
                  ),
                  CommentMenuButton(target: user, comment: widget.comment),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  CommentText(widget.comment.text),
                  const SizedBox(height: 16),
                  CommentTrailing(
                    onReply: () {
                      ref.read(commentSheetEditProvider.notifier).state = null;
                      ref.read(commentControllerProvider).clear();
                      ref.read(commentSheetTargetProvider.notifier).state =
                          widget.comment;
                      widget.onReply?.call();
                    },
                    onShare: () => share(widget.comment),
                  ),
                  if (widget.comment.replyCount > 0) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                  ],
                ],
              ),
            ),
            if (collapsed)
              Consumer(builder: (context, ref, _) {
                final lastReply = ref
                    .watch(lastReplyStreamProvider(widget.comment.id))
                    .valueOrNull;
                if (lastReply == null) return const SizedBox.shrink();
                return InkWell(
                  onTap: () => setState(() => collapsed = false),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      replyWidget(lastReply),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          widget.comment.replyCount == 2
                              ? '1 more reply...'.hardcoded
                              : '${widget.comment.replyCount - 1} more replies...'
                                  .hardcoded,
                          style: context.textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              })
            else
              Consumer(
                builder: (context, ref, _) {
                  final replies = ref
                      .watch(repliesStreamProvider(widget.comment.id))
                      .valueOrNull;
                  if (replies == null) return const SizedBox.shrink();
                  final directReplies = replies.where(
                    (reply) => reply.parentIds.last == widget.comment.id,
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final reply in directReplies)
                        replyWidget(
                          reply,
                          replies
                              .where((r) => r.parentIds.contains(reply.id))
                              .toList(),
                        ),
                      if (widget.comment.replyCount > 1) ...[
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => setState(() => collapsed = true),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(
                              'Collapse comments'.hardcoded,
                              style: context.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget replyWidget(
    Comment reply, [
    List<Comment> replies = const [],
  ]) =>
      ReplyWidget(
        reply,
        replies: replies,
        collapsed: collapsed,
        episodeId: widget.episodeId,
        onReply: widget.onReply,
        onShare: (comment) => share(comment),
      );

  Widget showcase({required UserPodiz user, required Widget child}) {
    next() {
      context.goNamed(
        AppRoute.profile.name,
        params: {'userId': user.id},
      );
      final isFollowing =
          ref.read(currentUserProvider).following.contains(user.id);
      if (isFollowing) {
        ShowCaseWidget.of(context).next();
      }
    }

    return ShowcaseStep(
      step: 3,
      skipOnTop: true,
      shapeBorder: const CircleBorder(),
      onTap: () {
        next();
        ShowCaseWidget.of(context).next();
      },
      onNext: next,
      title: 'Find interesting people',
      description: '${user.name} could be a great start with',
      child: child,
    );
  }
}
