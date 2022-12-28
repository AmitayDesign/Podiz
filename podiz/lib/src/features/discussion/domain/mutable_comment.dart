import 'package:podiz/src/features/discussion/domain/comment.dart';

extension MutableComment on Comment {
  Comment setText(String text) => Comment(
        text: text,
        episodeId: episodeId,
        userId: userId,
        timestamp: timestamp,
        date: date,
        id: id,
        parentIds: parentIds,
        parentUserId: parentUserId,
        replyCount: replyCount,
      );
}
