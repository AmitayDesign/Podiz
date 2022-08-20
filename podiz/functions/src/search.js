const helpers = require("./helpers.js");
const { fetchSpotifyShow } = require("./shows.js");
const { fetchSpotifyEpisode } = require("./episodes.js");

exports.fetchSpotifySearch = async (accessToken, query) => {
	try {
		// fetch shows and episodes from spotify
		var response = await helpers.fetchFromHost(
			"/search?q=" + query + "&type=show,episode", accessToken
		);
		if (response["status"] != 200) return false;

		var search = await response.json();

		var resultList = await Promise.all([
			// add shows to firestore
			...search.shows.items.map(async (show) => {
				var showExists = await helpers.checkShowExists(show.id);
				if (!showExists)
					return await fetchSpotifyShow(accessToken, show.id);
				return true;
			}),
			// add episodes to firestore
			...search.episodes.items.map(async (episode) => {
				var episodeExists = await helpers.checkEpisodeExists(episode.id);
				if (!episodeExists)
					return await fetchSpotifyEpisode(accessToken, episode.id);
				return true;
			})
		]);

		var success = resultList.every((result) => result);
		return success;

	} catch (err) {
		console.log(err);
		return false;
	}
}