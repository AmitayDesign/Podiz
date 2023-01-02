// dependencies
const functions = require("firebase-functions");
const admin = require("firebase-admin");
// functions
const auth = require("./src/auth.js");
const auth_new = require("./src/auth_new.js");
const favorites = require("./src/user-favorites.js");
const listening = require("./src/episode-listening.js");
const episodes = require("./src/episodes.js");
const shows = require("./src/shows.js");
const search = require("./src/search.js");
const notifications = require("./src/notifications.js");
const comments = require("./src/comments.js");
const player = require("./src/player.js");
const userData = require("./src/user-data.js");

admin.initializeApp(functions.config().firebase);

exports.fetchSpotifyUser = functions.https.onCall((data, _) =>
  auth.fetchSpotifyUser(data.accessToken)
);

exports.fetchSpotifyUserFavorites = functions.https.onCall((data, _) =>
  favorites.fetchSpotifyUserFavorites(data.accessToken, data.userId)
);

exports.fetchSpotifyEpisode = functions.https.onCall((data, _) =>
  episodes.fetchSpotifyEpisode(data.accessToken, data.episodeId)
);

exports.fetchSpotifyShow = functions.https.onCall((data, _) =>
  shows.fetchSpotifyShow(data.accessToken, data.showId)
);

exports.fetchSpotifySearch = functions.https.onCall((data, _) =>
  search.fetchSpotifySearch(data.accessToken, data.query)
);

exports.updateEpisodeListening = functions.database
  .ref("users/{userId}/lastListened")
  .onWrite((change, context) => {
    const userId = context.params.userId;
    const lastListened = change.before.val();
    const listeningNow = change.after.val();
    return listening.updateEpisodeListening(userId, lastListened, listeningNow);
  });

exports.removeEpisodeListening = functions.database
  .ref("users/{userId}/connections")
  .onWrite((change, context) => {
    const userId = context.params.userId;
    const connections = change.after.val() ?? new Map();
    return listening.removeEpisodeListening(userId, connections);
  });

exports.getAccessTokenWithCode = functions.https.onCall((data, _) =>
  auth.getAccessTokenWithCode(data.code)
);

exports.getAccessTokenWithCode2 = functions.https.onCall((data, _) =>
  auth_new.getAccessTokenWithCode2(data.code)
);

exports.getAccessTokenWithRefreshToken = functions.https.onCall((data, _) =>
  auth.getAccessTokenWithRefreshToken(data.userId)
);

exports.replyNotificationTrigger = functions.firestore
  .document("/comments/{commentId}")
  .onCreate(async (snapshot, context) => {
    var commentId = context.params.commentId;
    var data = snapshot.data();
    var episodeId = data.episodeId;
    var targetUserId = data.parentUserId;
    var userId = data.userId;
    var text = data.text;
    if (targetUserId != null && targetUserId != userId)
      return notifications.replyNotificationTrigger(
        targetUserId,
        commentId,
        episodeId,
        userId,
        text
      );
  });

exports.followNotificationTrigger = functions.firestore
  .document("/users/{userId}")
  .onUpdate(async (snapshot, context) => {
    var targetUserId = context.params.userId;
    var followersBefore = snapshot.before.data().followers ?? [];
    var followersAfter = snapshot.after.data().followers ?? [];
    if (followersBefore.length < followersAfter.length) {
      var userId = followersAfter[followersAfter.length - 1];
      return notifications.followNotificationTrigger(targetUserId, userId);
    }
  });

exports.propagateCommentDeletion = functions.firestore
  .document("/comments/{commentId}")
  .onDelete(async (snapshot, context) => {
    var commentId = context.params.commentId;
    var episodeId = snapshot.data().episodeId;
    var parentIds = snapshot.data().parentIds;
    return comments.propagateDeletion(commentId, episodeId, parentIds);
  });

exports.scheduleWeeklyComments = functions.pubsub
  .schedule("0 0 * * *")
  .timeZone("Europe/Lisbon")
  .onRun((_) => comments.updateWeeklyComments());

exports.scheduleEpisodeUpdate = functions.pubsub
  .schedule("05 15 * * *")
  .timeZone("Europe/Lisbon")
  .onRun((_) => search.updateEpisodeDaily());

exports.updateTesting = functions.https.onCall((data, _) =>
  search.updateEpisodeDaily()
);

exports.playEpisode = functions.https.onCall((data, _) =>
  player.playEpisode(data.accessToken, data.episodeId, data.time)
);

exports.pauseEpisode = functions.https.onCall((data, _) =>
  player.pauseEpisode(data.accessToken)
);

exports.requestData = functions.https.onRequest((req, res) => {
  var mailId = req.query.id;
  return userData.requestData(mailId, res);
});

exports.whipeData = functions.https.onRequest((req, res) => {
  var mailId = req.query.id;
  return userData.whipeData(mailId, res);
});
