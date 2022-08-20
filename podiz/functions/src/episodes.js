const helpers = require("./helpers.js");
const showFunctions = require("./shows.js");

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
		var showExists = await helpers.checkShowExists(show.id);
		if (!showExists) await showFunctions.fetchSpotifyShow(accessToken, show.id);

		// add episode to firestore
		await helpers.addEpisodeToFirestore(episode, show.id);
		return true;

	} catch (e) {
		console.log(e);
		return false;
	}
}