const helpers = require("./helpers.js");
const admin = require("firebase-admin");

exports.updateEpisodeListening = async (userId, lastListened, listeningNow) => {
	if (lastListened != null)
		await helpers.removeUserFromEpisodeListening(lastListened, userId);

	if (listeningNow != null)
		await helpers.addUserToEpisodeListening(listeningNow, userId);
}


exports.removeEpisodeListening = async (userId, connections) => {
	const isDisconnected = connections.size == 0;
	if (isDisconnected) {
		await admin.database().ref(`users/${userId}/lastListened`).set(null);
	}
}