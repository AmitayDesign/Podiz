const helpers = require("./helpers.js");
const { fetchSpotifyShow } = require("./shows.js");

exports.fetchSpotifyUserFavorites = async (accessToken, userId) => {
	try {
		var response = await helpers.fetchFromHost("/me/shows", accessToken);
		if (response["status"] != 200) return false;

		var favorites = await response.json();

		var lastFavorite = await helpers.getUserFavorites(userId);
		await saveFavorites(accessToken, userId, favorites, lastFavorite);
		return true;

	} catch (e) {
		console.log(e);
		return false;
	}
}

//TODO remove favorites
//TODO check for already save shows to user refresh on user screen
const saveFavorites = async (accessToken, userId, favorites, lastFavorite) => {

	var fetchMore = true;

	//TODO do not fetch the show again, call show/showId/episodes
	var favoriteIds = await Promise.all(
		favorites.items.map(async (item) => {
			var show = item.show;
			var showExists = await helpers.checkShowExists(show.id);
			if (!showExists) await fetchSpotifyShow(accessToken, show.id);
			if (show.id == lastFavorite) fetchMore = false;
			return show.id;
		})
	);

	if (favoriteIds.length)
		await helpers.addUserFavorites(userId, favoriteIds);

	if (fetchMore && favorites.next != null)
		fetchMoreFavorites(accessToken, userId, favorites.next, lastFavorite);
}

const fetchMoreFavorites =
	async (accessToken, userId, favoritesRef, lastFavorite) => {
		var response = await helpers.fetchFrom(favoritesRef, accessToken);

		if (response["status"] != 200) return;
		var favorites = await response.json();

		saveFavorites(accessToken, userId, favorites, lastFavorite);
	}
