const helpers = require("./helpers.js");
const admin = require("firebase-admin");
const fs = require("fs");
const AdmZip = require("adm-zip");

exports.requestData = async (mailId, res) => {
	let userId = await getUserId(mailId);
	if (!userId) linkDisabled(res);

	let user = await helpers.userRef(userId).get();
	let dbUserData = user.data();
	let userData = {
		id: user.id,
		email: dbUserData.email,
		imageUrl: dbUserData.imageUrl,
	}
	let follow = {
		followerCount: dbUserData.followers.length,
		followingUsersCount: dbUserData.following.length,
		favoriteShowsCount: dbUserData.favPodcasts.length,
	};

	let episode = await helpers.episodeRef(dbUserData.lastListened).get();
	let episodeData = episode.data();
	let show = await helpers.showRef(episodeData.showId).get();
	let showData = show.data();
	let streamingHistory = {
		lastPlayedEpisode: {
			id: episode.id,
			name: episodeData.name,
			show: showData.name,
			publisher: showData.publisher,
		},
	}

	let shows = await Promise.all(dbUserData.favPodcasts.map(async (showId) => {
		let show = await helpers.showRef(showId).get();
		let showData = show.data();
		return {
			id: show.id,
			name: showData.name,
			publisher: showData.publisher,
		}
	}));
	let favoriteShows = { shows };

	const zip = new AdmZip();
	zip.addFile("userData.json", JSON.stringify(userData));
	zip.addFile("follow.json", JSON.stringify(follow));
	zip.addFile("streamingHistory.json", JSON.stringify(streamingHistory));
	zip.addFile("favoriteShows.json", JSON.stringify(favoriteShows));

	var zipFileContents = zip.toBuffer();
	const fileName = 'my_podiz_data.zip';
	const fileType = 'application/zip';
	res.writeHead(200, {
		'Content-Disposition': `attachment; filename="${fileName}"`,
		'Content-Type': fileType,
	})
	return res.end(zipFileContents);
}

exports.whipeData = async (mailId, res) => {
	let userId = await getUserId(mailId);
	if (!userId) linkDisabled(res);

	await admin.firestore().runTransaction(async (t) => {
		let user = await t.get(helpers.userRef(userId));
		let userData = user.data();
		let episodeCounters = {};
		let comments = await t.get(
			helpers.commentsRef().where('userId', '==', userId)
		);
		let commentsToDelete = [];
		for (let comment of comments.docs) {
			// save episode counters
			let episodeId = comment.get('episodeId');
			if (episodeCounters[episodeId] == null) episodeCounters[episodeId] = 1;
			else episodeCounters[episodeId]++;
			// delete main comment
			commentsToDelete.push(comment.ref);
			// delete child comments
			let childComments = await t.get(
				helpers.commentsRef().where('parentIds', 'array-contains', comment.id)
			);
			for (let child of childComments.docs) {
				commentsToDelete.push(child.ref);
			}
		}
		for (let comment of commentsToDelete) t.delete(comment);
		// decrement episode counters
		for (let episodeId in episodeCounters) {
			let counter = episodeCounters[episodeId];
			t.update(helpers.episodeRef(episodeId), {
				commentsCount: admin.firestore.FieldValue.increment(-counter)
			});
		}
		// remove user from following
		let followers = userData.followers ?? [];
		for (let id of followers) {
			t.update(helpers.userRef(id), {
				following: admin.firestore.FieldValue.arrayRemove(userId)
			})
		}
		// remove user from followers
		let following = userData.following ?? [];
		for (let id of following) {
			t.update(helpers.userRef(id), {
				followers: admin.firestore.FieldValue.arrayRemove(userId)
			})
		}
		// remove user from podcast followers
		let favPodcasts = userData.favPodcasts ?? [];
		for (let id of favPodcasts) {
			t.update(helpers.showRef(id), {
				followers: admin.firestore.FieldValue.arrayRemove(userId)
			})
		}
		// remove user data
		t.delete(user.ref);
		t.delete(helpers.userPrivateRef(userId));
		t.delete(admin.firestore().collection('spotifyAuth').doc(userId));
	});

	return res.send(`<p>Your data was erased successfuly!</p>`);
}

function linkDisabled(res) {
	return res.send('<p>For your safety we disabled this link, you can ask again for another!</p>');
}

async function getUserId(mailId) {
	let currentTime = new Date();
	let mailDoc = await helpers.mailRef(mailId).get();
	if (!mailDoc.exists) return null
	let mailData = mailDoc.data();
	if (!mailData) return null
	let delivery = mailData.delivery;
	if (!delivery) return null
	let endTimestamp = delivery.endTime;
	if (!endTimestamp) return null
	let endTime = endTimestamp.toDate();
	if (currentTime > helpers.addHours(1, endTime)) return null
	return mailData.toUids[0];
}