
// async function fetchUserSpotifyFavoritePodcasts(userId, accessToken) {
// 	var response = await fetch(host + "/me/shows?offset=0&limit=50", {
// 		headers: {
// 			Accept: "application/json",
// 			Authorization: "Bearer " + accessToken,
// 			"Content-Type": "application/json",
// 		},
// 		method: "GET",
// 	});

// 	if (response["status"] != 200) {
// 		return false;
// 	}

// 	result = await response.json();

// 	for (item of result["items"]) {
// 		s = item["show"];

// 		searchArrayShow = [];
// 		prev = "";
// 		for (letter of s["name"]) {
// 			prev += letter;
// 			word = prev.toLowerCase();
// 			searchArrayShow.push(word);
// 		}

// 		show = {
// 			uid: s["uri"],
// 			name: s["name"],
// 			publisher: s["publisher"],
// 			description: s["description"],
// 			image_url: s["images"][0]["url"],
// 			total_episodes: s["total_episodes"],
// 			podcasts: [],
// 			followers: [],
// 			searchArray: searchArrayShow,
// 		};

// 		if (!(await checkShowExists(show["uid"]))) {
// 			addShowToDataBase(show);
// 			getShowEpisodes(
// 				show["uid"],
// 				show["total_episodes"],
// 				show["name"],
// 				userUid
// 			);
// 		}
// 		_firestore()
// 			.collection("users")
// 			.doc(userUid)
// 			.update({
// 				favPodcasts: _firestore.FieldValue.arrayUnion(show["uid"]),
// 				followers: _firestore.FieldValue.arrayUnion(show["uid"]),
// 			});
// 	}

// 	let total = result["total"];
// 	if (total < 50) {
// 		return;
// 	}
// 	for (let i = 50; i < total; i += 50) {
// 		var response = await fetch(
// 			host + "/me/shows?offset=" + i.toString() + "&limit=50",
// 			{
// 				headers: {
// 					Accept: "application/json",
// 					Authorization: "Bearer " + code,
// 					"Content-Type": "application/json",
// 				},
// 				method: "GET",
// 			}
// 		);
// 		for (item of result["items"]) {
// 			s = item["show"];

// 			searchArrayShow = [];
// 			prev = "";
// 			for (letter of s["name"]) {
// 				prev += letter;
// 				word = prev.toLowerCase();
// 				searchArrayShow.push(word);
// 			}

// 			show = {
// 				uid: s["uri"],
// 				name: s["name"],
// 				publisher: s["publisher"],
// 				description: s["description"],
// 				image_url: s["images"][0]["url"],
// 				total_episodes: s["total_episodes"],
// 				podcasts: [],
// 				followers: [],
// 				searchArray: searchArrayShow,
// 			};

// 			if (!(await checkShowExists(show["uid"]))) {
// 				addShowToDataBase(show);
// 				getShowEpisodes(
// 					show["uid"],
// 					show["total_episodes"],
// 					show["name"],
// 					userUid
// 				);
// 				_firestore()
// 					.collection("users")
// 					.doc(userUid)
// 					.update({
// 						favPodcasts: _firestore.FieldValue.arrayUnion(show["uid"]),
// 						followers: _firestore.FieldValue.arrayUnion(show["uid"]),
// 					});
// 			}
// 		}
// 	}
// }
