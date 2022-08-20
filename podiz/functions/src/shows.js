const helpers = require("./helpers.js");

exports.fetchSpotifyShow = async (accessToken, showId) => {
	try {
		// fetch show from spotify
		var response = await helpers.fetchFromHost("/shows/" + showId, accessToken);
		if (response["status"] != 200) return false;
		var show = await response.json();

		// add show to firestore
		await helpers.addShowToFirestore(show);

		// add show episodes to firestore
		await populateFirestoreWithEpisodes(accessToken, show.episodes);
		return true;

	} catch (err) {
		console.log(err);
		return false;
	}
}

populateFirestoreWithEpisodes = async (accessToken, episodes) => {
	var episodesToFetch = [];
	for (var episode of episodes.items) {
		var episodeExists = await helpers.checkEpisodeExists(episode.id);
		if (!episodeExists) episodesToFetch.push(episode);
		else break;
	}

	await Promise.all(episodesToFetch.map((episode) => {
		return helpers.addEpisodeToFirestore(episode, show.id);
	}));

	if (episodesToFetch.length == episodes.items.length)
		fetchMoreEpisodes(accessToken, episodes.next);
}

fetchMoreEpisodes = async (accessToken, episodesRef) => {
	var response = await fetch.fetch(episodesRef, {
		headers: {
			Accept: "application/json",
			Authorization: "Bearer " + accessToken,
			"Content-Type": "application/json",
		},
		method: "GET",
	});

	if (response["status"] != 200) return;
	var episodes = await response.json();
	populateFirestoreWithEpisodes(accessToken, episodes);
}