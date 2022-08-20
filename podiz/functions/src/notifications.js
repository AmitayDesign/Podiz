
// export const sendNotificatioToDevice = firestore
// .document("users/{uid}/notifications/{notificationId}")
// .onCreate(async (snapshot) => {
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
// });