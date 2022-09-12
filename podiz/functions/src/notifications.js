
// exports.replyNotificationTrigger = async (commentId) => {


// 	let notification = snapshot.data();
// 	let type = notification.type;
// 	if (type == "follower") {
// 		data = {
// 			type: notification.type,
// 			timestamp: notification.timestamp,
// 			user: notification.user,
// 		};
// 	} else {
// 		data = {
// 			type: notification.type,
// 			timestamp: notification.timestamp,
// 			user: notification.user,
// 			podcast: notification.podcast,
// 			comment: notification.comment,
// 		};
// 	}
// 	let token = await getDeviceToken(uid);
// 	messaging().sendToDevice(
// 		token,
// 		{
// 			data: data,
// 		},
// 		{
// 			contentAvailable: true,
// 			priority: "high",
// 		}
// 	);
// 	await admin.messaging().sendToDevice(
// 		owner.tokens, // ['token_1', 'token_2', ...]
// 		{
// 			data: {
// 				owner: JSON.stringify(owner),
// 				user: JSON.stringify(user),
// 				picture: JSON.stringify(picture),
// 			},
// 		},
// 		{
// 			// Required for background/quit data-only messages on iOS
// 			contentAvailable: true,
// 			// Required for background/quit data-only messages on Android
// 			priority: "high",
// 		}
// 	);
// }