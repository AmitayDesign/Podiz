const helpers = require("./helpers.js");

exports.fetchSpotifyUser = async (accessToken) => {
	try {
		// fetch user from spotify
		var response = await helpers.fetchFromHost("/me", accessToken);
		if (response["status"] != 200) return null;
		var user = await response.json();

		// if user exists, does nothing
		var userExists = await helpers.userExists(user.id);
		if (userExists) return user.id;

		// create user in firestore
		await helpers.addUserToFirestore(user);
		return user.id;

	} catch (err) {
		return null;
	}
}