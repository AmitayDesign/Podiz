const helpers = require("./helpers.js");
const { fetchSpotifyUserFavorites } = require("./user-favorites.js");

exports.fetchSpotifyUser = async (accessToken) => {
	try {
		// fetch user from spotify
		var response = await helpers.fetchFromHost("/me", accessToken);
		if (response["status"] != 200) return null;
		var user = await response.json();

		// if user does not exist, create user in firestore
		var userExists = await helpers.checkUserExists(user.id);
		if (!userExists) await helpers.addUserToFirestore(user);

		// save user favorite shows
		await fetchSpotifyUserFavorites(accessToken, user.id);
		return user.id;

	} catch (e) {
		console.log(e);
		return null;
	}
}