const admin = require("firebase-admin");
const fetch = require("node-fetch");

const host = "https://api.spotify.com/v1";

// FETCH

exports.fetchFrom = (path, accessToken) =>
  fetch(path, {
    headers: {
      Accept: "application/json",
      Authorization: "Bearer " + accessToken,
      "Content-Type": "application/json",
    },
    method: "GET",
  });

exports.fetchFromHost = (path, accessToken) =>
  fetch(host + path, {
    headers: {
      Accept: "application/json",
      Authorization: "Bearer " + accessToken,
      "Content-Type": "application/json",
    },
    method: "GET",
  });

// USER

const userRef = (userId) => admin.firestore().collection("users").doc(userId);

exports.checkUserExists = async (userId) => {
  var episodeDoc = await userRef(userId).get();
  return episodeDoc.exists;
};

exports.addUserToFirestore = (user) =>
  userRef(user.id).set(
    {
      name: user.display_name,
      email: user.email,
      imageUrl: user.images[0].url,
      searchArray: buildSearchArray(user.display_name),
    },
    { merge: true }
  );

exports.addUserFavorites = (userId, favoritIds) =>
  userRef(userId).update({
    favPodcasts: admin.firestore.FieldValue.arrayUnion(...favoritIds),
  });

exports.getUserFavorites = async (userId) => {
  var doc = await userRef(userId).get();
  return doc.data().favPodcasts;
};

// EPISODE

const episodeRef = (episodeId) =>
  admin.firestore().collection("episodes").doc(episodeId);

exports.checkEpisodeExists = async (episodeId) => {
  var episodeDoc = await episodeRef(episodeId).get();
  return episodeDoc.exists;
};

exports.addEpisodeToFirestore = (episode, showId) =>
  episodeRef(episode.id).set(
    {
      name: episode.name,
      commentsCount: 0,
      description: episode.description,
      imageUrl: episode.images[0]?.url,
      duration: episode.duration_ms,
      showId: showId,
      releaseDate: episode.release_date,
      searchArray: buildSearchArray(episode.name),
    },
    { merge: true }
  );

exports.addEpisodeToFirestoreT = (t, episode, showId) =>
  t.set(
    episodeRef(episode.id),
    {
      name: episode.name,
      commentsCount: 0,
      description: episode.description,
      imageUrl: episode.images[0]?.url,
      duration: episode.duration_ms,
      showId: showId,
      releaseDate: episode.release_date,
      searchArray: buildSearchArray(episode.name),
    },
    { merge: true }
  );

exports.addUserToEpisodeListening = (episodeId, userId) =>
  episodeRef(episodeId).update({
    usersWatching: admin.firestore.FieldValue.arrayUnion(userId),
  });

exports.removeUserFromEpisodeListening = (episodeId, userId) =>
  episodeRef(episodeId).update({
    usersWatching: admin.firestore.FieldValue.arrayRemove(userId),
  });

// SHOW

const showRef = (showId) => admin.firestore().collection("shows").doc(showId);

exports.checkShowExists = async (showId) => {
  var showDoc = await showRef(showId).get();
  return showDoc.exists;
};

exports.addShowToFirestore = (show) =>
  showRef(show.id).set(
    {
      name: show.name,
      publisher: show.publisher,
      description: show.description,
      imageUrl: show.images[0]?.url,
      searchArray: buildSearchArray(show.name),
      // for fetching purposes
      lastKnownEpisode: show.episodes.items[0].id,
      // lastSavedEpisode:
    },
    { merge: true }
  );

exports.getShowT = async (t, showId) => {
  var doc = await t.get(showRef(showId));
  return doc.data();
};

exports.addLastSavedEpisodeT = (t, showId, episodeId) =>
  t.update(showRef(showId), {
    lastSavedEpisode: episodeId,
  });

// HELPERS

const buildSearchArray = (text) => {
  var previousWord = "";
  var searchArray = [];
  for (letter of text) {
    previousWord += letter;
    word = previousWord.toLowerCase();
    searchArray.push(word);
  }
  return searchArray;
};
