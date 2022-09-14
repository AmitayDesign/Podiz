// dependencies
const functions = require("firebase-functions");
const admin = require("firebase-admin");
// functions
const auth = require("./src/auth.js");
const favorites = require("./src/user-favorites.js");
const listening = require("./src/episode-listening.js");
const episodes = require("./src/episodes.js");
const shows = require("./src/shows.js");
const search = require("./src/search.js");
const comments = require("./src/comments.js");
const player = require("./src/player.js");

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

exports.getAccessTokenWithRefreshToken = functions.https.onCall((data, _) =>
  auth.getAccessTokenWithRefreshToken(data.userId)
);

exports.scheduleWeeklyComments = functions.pubsub
  .schedule("0 0 * * *")
  .timeZone("Europe/Lisbon")
  .onRun((_) => comments.updateWeeklyComments());

exports.playEpisode = functions.https.onCall((data, _) =>
  player.playEpisode(data.accessToken, data.episodeId, data.time)
);

exports.pauseEpisode = functions.https.onCall((data, _) =>
  player.pauseEpisode(data.accessToken)
);
