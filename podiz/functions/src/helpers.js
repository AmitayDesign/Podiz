const admin = require("firebase-admin");
const fetch = require("node-fetch");

const host = "https://api.spotify.com/v1";

// FETCH

exports.fetchFromHost = (path, accessToken) =>
	fetch(
		host + path, {
		headers: {
			Accept: "application/json",
			Authorization: "Bearer " + accessToken,
			"Content-Type": "application/json",
		},
		method: "GET",
	});

// USER

userRef = (userId) =>
	admin.firestore().collection("test_users").doc(userId);


exports.checkUserExists = async (userId) => {
	var episodeDoc = await userRef(userId).get();
	return episodeDoc.exists;
}

exports.addUserToFirestore = (user) =>
	userRef(user.id).set({
		name: user.display_name,
		email: user.email,
		imageUrl: user.images[0].url,
		searchArray: helpers.buildSearchArray(user.display_name),
	}, { merge: true });

// EPISODE

episodeRef = (episodeId) =>
	admin.firestore().collection("test_episodes").doc(episodeId);


exports.checkEpisodeExists = async (episodeId) => {
	var episodeDoc = await episodeRef(episodeId).get();
	return episodeDoc.exists;
}

exports.addEpisodeToFirestore = (episode, showId) =>
	episodeRef(episode.id).set({
		name: spotifyEpisode.name,
		description: spotifyEpisode.description,
		imageUrl: spotifyEpisode.images[0]?.url,
		duration: spotifyEpisode.duration_ms,
		showId: showId,
		releaseDate: spotifyEpisode.release_date,
		searchArray: buildSearchArray(spotifyEpisode.name),
	}, { merge: true });

exports.addUserToEpisodeListening = (episodeId, userId) =>
	episodeRef(episodeId).update({
		usersWatching: admin.firestore.FieldValue.arrayUnion(userId)
	});

exports.removeUserFromEpisodeListening = (episodeId, userId) =>
	episodeRef(episodeId).update({
		usersWatching: admin.firestore.FieldValue.arrayRemove(userId)
	});

// SHOW

showRef = (showId) =>
	admin.firestore().collection("test_shows").doc(showId);

exports.checkShowExists = async (showId) => {
	var showDoc = await showRef(showId).get();
	return showDoc.exists;
}

exports.addShowToFirestore = async (show) => {
	return showRef(show.id).set({
		name: show.name,
		publisher: show.publisher,
		description: show.description,
		imageUrl: show.images[0]?.url,
		searchArray: buildSearchArray(show.name),
	}, { merge: true });
}

// HELPERS

exports.buildSearchArray = (text) => {
	var previousWord = "";
	var searchArray = [];
	for (letter of text) {
		previousWord += letter;
		word = previousWord.toLowerCase();
		searchArray.push(word);
	}
	return searchArray;
}