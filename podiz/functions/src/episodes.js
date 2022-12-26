const helpers = require("./helpers.js");
const { fetchSpotifyShow } = require("./shows.js");

exports.fetchSpotifyEpisode = async (accessToken, episodeId) => {
	try {
		// fetch episode from spotify
		var response = await helpers.fetchFromHost(
			"/episodes/" + episodeId, accessToken
		);
		if (response["status"] != 200) return false;

		var episode = await response.json();
		var show = episode.show;

		// add show to firestore
		//TODO do not fetch the show again, call show/showId/episodes
		var showExists = await helpers.checkShowExists(show.id);
		if (!showExists) await fetchSpotifyShow(accessToken, show.id);

		// add episode to firestore
		await helpers.addEpisodeToFirestore(episode, show.id);
		return true;

	} catch (e) {
		console.log(e);
		return false;
	}
}