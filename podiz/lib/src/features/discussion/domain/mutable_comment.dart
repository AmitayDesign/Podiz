import 'package:podiz/src/features/discussion/domain/comment.dart';

extension MutableComment on Comment {
  Comment setText(String text) => copyWith(text: text);
  Comment report() => copyWith(reported: true);

  Comment copyWith({
    String? text,
    bool? reported,
  }) =>
      Comment(
        text: text ?? this.text,
        reported: reported ?? this.reported,
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
