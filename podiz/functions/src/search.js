const helpers = require("./helpers.js");
const showFunctions = require("./shows.js");
const episodeFunctions = require("./episodes.js");

exports.fetchSpotifySearch = async (accessToken, query) => {
	try {
		// fetch shows and episodes from spotify
		var response = await helpers.fetchFromHost(
			"/search?q=" + query + "&type=show,episodes", accessToken
		);
		if (response["status"] != 200) return false;
		var search = await response.json();

		// add shows to firestore
		await Promise.all(search.shows.items.map(async (show) => {
			// var showExists = await helpers.checkShowExists(show.id);
			if (!showExists) await showFunctions.fetchShow(accessToken, show);
		}));

		// // add shows to firestore based on episodes
		await Promise.all(search.episodes.items.map(async (episode) => {
			// var episodeExists = await helpers.checkEpisodeExists(episode.id);
			if (!episodeExists) await episodeFunctions.fetchEpisode(accessToken, episode);
		}));

		return true;

	} catch (err) {
		console.log(err);
		return false;
	}
}