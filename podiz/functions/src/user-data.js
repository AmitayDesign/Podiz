// const helpers = require("./helpers.js");
// const admin = require("firebase-admin");

// exports.whipeData = async (userId) => {
// 	await admin.firestore().runTransaction(async (t) => {
// 		var comments = await t.get(admin.firestore().collection('comments').where('userId', '==', userId));
// 		for (let comment of comments.docs) t.delete(comment.ref);
// 		// create a trigger for comment deletion to delete child comments
// 		// and decrement episode total comment counter
// 		t.delete(admin.firestore().collection('usersPrivate').doc(userId));
// 		t.delete(admin.firestore().collection('users').doc(userId));
// 		// create a trigger to unfollow all users
// 		t.delete(admin.firestore().collection('spotifyAuth').doc(userId));
// 	});
// }