const admin = require("firebase-admin");

exports.replyNotificationTrigger = async (
	targetUserId, commentId, episodeId, userId, text
) => {
	// Get the users details
	var user = await admin.firestore()
		.collection("users").doc(userId).get()
		.then((user) => user.data());

	// Get the episode details
	var episode = await admin.firestore()
		.collection("episodes").doc(episodeId).get()
		.then((episode) => episode.data());

	return sendNotification(
		targetUserId,
		commentId,
		'replies',
		`${user.name} replied to your comment`,
		`${text} - ${episode.name}`
	);
}

exports.followNotificationTrigger = async (
	targetUserId, userId
) => {
	// Get the users details
	var user = await admin.firestore()
		.collection("users").doc(userId).get()
		.then((user) => user.data());

	return sendNotification(
		targetUserId,
		userId,
		'follows',
		`${user.name} started following you`,
		`Check out ${user.name} profile`
	);
}

const sendNotification = async (
	targetUserId, id, channel, title, body
) => {
	// Get the notification target user details
	var targetUser = await admin.firestore()
		.collection("usersPrivate").doc(targetUserId).get();
	var tokens = targetUser.data().notificationTokens;

	if (tokens.length)
		await admin.messaging().sendToDevice(
			tokens,
			{
				notification: {
					title: title,
					body: body,
					android_channel_id: channel,
				},
				data: {
					id: id,
					channel: channel
				},
			},
			{
				// Required for background/quit data-only messages on iOS
				contentAvailable: true,
				// Required for background/quit data-only messages on Android
				priority: "high",
			}
		).then((response) => {
			print(`success: ${response.successCount}`);
			print(`failure: ${response.failureCount}`);
			return removedUnusedTokens(targetUserId, tokens, response);
		});
}


const removedUnusedTokens = async (uid, tokens, response) => {
	var tokensToRemove = [];
	response.results.forEach((result, i) => {
		var error = result.error;
		if (error)
			if (error.code === 'messaging/invalid-registration-token' ||
				error.code === 'messaging/registration-token-not-registered')
				tokensToRemove.push(tokens[i]);
	});
	if (tokensToRemove.length)
		await admin.firestore().collection("usersPrivate")
			.doc(targetUserId).set({
				notificationTokens: db.FieldValue.arrayRemove(...tokensToRemove)
			});
};