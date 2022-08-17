// import 'package:expandable/expandable.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:podiz/aspect/extensions.dart';
// import 'package:podiz/providers.dart';
// import 'package:podiz/src/common_widgets/user_avatar.dart';
// import 'package:podiz/src/features/discussion/domain/comment.dart';
// import 'package:podiz/src/features/episodes/data/episode_repository.dart';
// import 'package:podiz/src/features/player/data/player_repository.dart';
// import 'package:podiz/src/features/player/presentation/time_chip.dart';

// class CommentCard extends ConsumerStatefulWidget {
//   final String episodeId;
//   final Comment comment;
//   const CommentCard(this.episodeId, this.comment, {Key? key}) : super(key: key);

//   @override
//   ConsumerState<CommentCard> createState() => _DiscussionCardState();
// }

// class _DiscussionCardState extends ConsumerState<CommentCard> {
//   final controller = ExpandableController(initialExpanded: true);

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final playerRepository = ref.watch(playerRepositoryProvider);
//     final userValue = ref.watch(userFutureProvider(widget.comment.userId));
//     final episode = ref.watch(episodeFutureProvider(widget.episodeId));
//     // final numberOfReplies =
//     //     ref.read(playerRepositoryProvider).getNumberOfReplies(widget.comment.id);
//     return userValue.when(
//       loading: () => SizedBox.fromSize(), //!
//       error: (e, _) => const SizedBox.shrink(), //!
//       data: (user) {
//         return Material(
//           color: context.colorScheme.surface,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     UserAvatar(
//                       user: user,
//                       radius: kMinInteractiveDimension * 5 / 12,
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             user.name,
//                             style: context.textTheme.titleSmall,
//                           ),
//                           Text('${user.followers.length} followers'),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     TimeChip(
//                       icon: Icons.play_arrow,
//                       position: widget.comment.time,
//                       // TODO what if the playingnpodcast is different
//                       onTap: () => playerRepository.play(
//                           episode.id, widget.comment.time - 10000),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
