const admin = require("firebase-admin");
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
		populateFirestoreWithEpisodes(accessToken, show.id, show.episodes);
		return true;

	} catch (e) {
		console.log(e);
		return false;
	}
}

const populateFirestoreWithEpisodes = async (accessToken, showId, episodes) => {
	if (!episodes.items.length) return;

	//TODO save oldest episodeId aswell in case of an error
	var fetchMore = await admin.firestore().runTransaction(async (t) => {
		var show = await helpers.getShowT(t, showId);
		for (var episode of episodes.items) {
			// check if episode is the last one fetched
			if (episode.id == show.lastSavedEpisode) {
				return false;
			}
			// add episode to firestore
			helpers.addEpisodeToFirestoreT(t, episode, showId);
			// if episode is the last known, save it as last saved
			if (episode.id == show.lastKnownEpisode)
				helpers.addLastSavedEpisodeT(t, showId, show.lastKnownEpisode);
		}
		return true;
	});

	// fetch more
	if (fetchMore && episodes.next != null)
		fetchMoreEpisodes(accessToken, showId, episodes.next);
}

const fetchMoreEpisodes = async (accessToken, showId, episodesRef) => {
	var response = await helpers.fetchFrom(episodesRef, accessToken);

	if (response["status"] != 200) return;
	var episodes = await response.json();

	populateFirestoreWithEpisodes(accessToken, showId, episodes);
}

exports.fetchMyCast = async (accessToken, favPodcasts) => {
	for(showId of favPodcasts) {
		var response = await helpers.fetchFromHost("/shows/" + showId + "episodes?offset=0&limit=1", accessToken);
		if (response["status"] != 200) return false;

		var result = await response.json();
		if(result["items"].length == 0 ) {
			continue;
		}

		var episode = result["items"][0];
		var aux_show = helpers.getShow(showId);
		if(aux_show["lastSavedEpisode"] != episode["id"]){
			helpers.addEpisodeToFirestore(episode, showId);
			helpers.updateShowLastSavedEpisode(showId, episode["id"])
		}	
	}
};