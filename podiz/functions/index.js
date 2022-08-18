const functions = require("firebase-functions");
const admin = require("firebase-admin");
const fetch = require("node-fetch");

const utf8 = require("utf8");
const { user } = require("firebase-functions/v1/auth");

var firebase_app = admin.initializeApp(functions.config().firebase);

var host = "https://api.spotify.com/v1";
var authenticationHost = "https://accounts.spotify.com/";

var client_id = "9a8daaf39e784f1c90770da4a252087f";
var client_secret = "10de465afd164e8e9196988aa738a127";

/*********************************************
 ******************AUTHENTICATION**************
 *********************************************/
exports.getAccessTokenWithCode = functions.https.onCall(
  async (data, context) => {
    /*
    data = {
      code : String
      userUid : String
    }
    */
    try {
      var response = await fetch(authenticationHost + "api/token", {
        body: encodeFormData({
          grant_type: "authorization_code",
          code: data.code,
          redirect_uri: "podiz:/",
          client_id: client_id,
          client_secret: client_secret,
        }),
        headers: {
          Accept: "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        method: "POST",
      });

      var result = await response.json();

      let userUid = await getUserInfo(result);

      return userUid;
    } catch (err) {
      console.log(err);
      return "0";
    }
  }
);

async function getAccessTokenWithRefreshToken(userUid) {
  try {
    spotifyAuth = await getSpotifyAuth(userUid);

    var response = await fetch(authenticationHost + "api/token", {
      headers: {
        Authorization: "Basic " + btoa(client_id + ":" + client_secret),
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: encodeFormData({
        grant_type: "refresh_token",
        refresh_token: spotifyAuth.refresh_token,
        client_id: client_id,
      }),
      method: "POST",
    });
    if (response["status"] == 200) {
      var result = await response.json();
      await admin
        .firestore()
        .collection("spotifyAuth")
        .doc(userUid)
        .update({ access_token: result.access_token });
      return { result: "ok" };
    } else if (response["status"] == 401) {
      return { result: "unauthorized" };
    }
    return { result: "devices" };
  } catch (err) {
    console.log(err);
    return false;
  }
}

async function getSpotifyAuth(userUid) {
  ref = await admin.firestore().collection("spotifyAuth").doc(userUid).get();
  let spotifyAuth = ref.data();
  return spotifyAuth;
}

async function getUserInfo(result) {
  try {
    var response = await fetch(host + "/me", {
      headers: {
        Accept: "application/json",
        Authorization: "Bearer " + result.access_token,
        "Content-Type": "application/json",
      },
      method: "GET",
    });

    var userResult = await response.json();

    var docRef = await admin
      .firestore()
      .collection("users")
      .doc(userResult.uri)
      .get();

    var exists = docRef.exists;

    await admin.firestore().collection("spotifyAuth").doc(userResult.uri).set({
      access_token: result.access_token,
      token_type: result.token_type,
      expires_in: result.expires_in,
      refresh_token: result.refresh_token,
      scope: result.scope,
    });

    if (exists) {
      return userResult.uri;
    }
    prev = "";
    searchArray = [];

    for (letter of userResult.display_name) {
      prev += letter;
      word = prev.toLowerCase();
      searchArray.push(word);
    }

    admin.firestore().collection("users").doc(userResult.uri).set({
      name: userResult.display_name,
      email: userResult.email,
      image_url: userResult.images[0].url,
      followers: [],
      following: [],
      lastListened: "",
      comments: [],
      favPodcasts: [],
      searchArray: searchArray,
    });

    getUserFavoriteShow(userResult.uri, result.access_token);
    return userResult.uri;
  } catch (err) {
    console.log(err);
  }
}

async function getUserFavoriteShow(userUid, code) {
  var response = await fetch(host + "/me/shows?offset=0&limit=50", {
    headers: {
      Accept: "application/json",
      Authorization: "Bearer " + code,
      "Content-Type": "application/json",
    },
    method: "GET",
  });

  if (response["status"] != 200) {
    return false;
  }

  result = await response.json();

  for (item of result["items"]) {
    s = item["show"];

    searchArrayShow = [];
    prev = "";
    for (letter of s["name"]) {
      prev += letter;
      word = prev.toLowerCase();
      searchArrayShow.push(word);
    }

    show = {
      uid: s["uri"],
      name: s["name"],
      publisher: s["publisher"],
      description: s["description"],
      image_url: s["images"][0]["url"],
      total_episodes: s["total_episodes"],
      podcasts: [],
      followers: [],
      searchArray: searchArrayShow,
    };

    if (!(await checkShowExists(show["uid"]))) {
      addShowToDataBase(show);
      getShowEpisodes(
        show["uid"],
        show["total_episodes"],
        show["name"],
        userUid
      );
    }
    admin
      .firestore()
      .collection("users")
      .doc(userUid)
      .update({
        favPodcasts: admin.firestore.FieldValue.arrayUnion(show["uid"]),
        followers: admin.firestore.FieldValue.arrayUnion(show["uid"]),
      });
  }

  let total = result["total"];
  if (total < 50) {
    return;
  }
  for (let i = 50; i < total; i += 50) {
    var response = await fetch(
      host + "/me/shows?offset=" + i.toString() + "&limit=50",
      {
        headers: {
          Accept: "application/json",
          Authorization: "Bearer " + code,
          "Content-Type": "application/json",
        },
        method: "GET",
      }
    );
    for (item of result["items"]) {
      s = item["show"];

      searchArrayShow = [];
      prev = "";
      for (letter of s["name"]) {
        prev += letter;
        word = prev.toLowerCase();
        searchArrayShow.push(word);
      }

      show = {
        uid: s["uri"],
        name: s["name"],
        publisher: s["publisher"],
        description: s["description"],
        image_url: s["images"][0]["url"],
        total_episodes: s["total_episodes"],
        podcasts: [],
        followers: [],
        searchArray: searchArrayShow,
      };

      if (!(await checkShowExists(show["uid"]))) {
        addShowToDataBase(show);
        getShowEpisodes(
          show["uid"],
          show["total_episodes"],
          show["name"],
          userUid
        );
        admin
          .firestore()
          .collection("users")
          .doc(userUid)
          .update({
            favPodcasts: admin.firestore.FieldValue.arrayUnion(show["uid"]),
            followers: admin.firestore.FieldValue.arrayUnion(show["uid"]),
          });
      }
    }
  }
}

const encodeFormData = (data) => {
  return Object.keys(data)
    .map((key) => encodeURIComponent(key) + "=" + encodeURIComponent(data[key]))
    .join("&");
};

async function checkShowExists(showUid) {
  var docRef = await admin
    .firestore()
    .collection("podcasters")
    .doc(showUid)
    .get();
  return docRef.exists;
}

function addShowToDataBase(show) {
  admin.firestore().collection("podcasters").doc(show["uid"]).set(show);
}

async function getShowEpisodes(showUid, total_episodes, showName, userUid) {
  var spotifyAuth = await getSpotifyAuth(userUid);
  episodeList = [];
  let offset = 0;
  while (offset < total_episodes) {
    var response = await fetch(
      host +
      "/shows/" +
      showUid.split(":")[2] +
      "/episodes?limit=50&offset=" +
      offset.toString(),
      {
        headers: {
          Accept: "application/json",
          Authorization: "Bearer " + spotifyAuth.access_token,
          "Content-Type": "application/json",
        },
        method: "GET",
      }
    );

    if (response["status"] != 200) {
      return false;
    }
    let result = await response.json();

    for (e of result["items"]) {
      searchArray = [];
      prev = "";
      for (letter of e["name"]) {
        prev += letter;
        word = prev.toLowerCase();
        searchArray.push(word);
      }

      episode = {
        uid: e["uri"],
        name: e["name"],
        description: e["description"],
        duration_ms: e["duration_ms"],
        show_name: showName,
        show_uri: showUid,
        image_url: e["images"][0]["url"],
        comments: 0,
        commentsImg: [],
        release_date: e["release_date"],
        watching: 0,
        searchArray: searchArray,
      };
      episodeList.push(episode);
    }
    offset += 50;
  }
  let sortedList = episodeList.sort((a, b) =>
    a.release_date < b.release_date
      ? 1
      : b.release_date < a.release_date
        ? -1
        : 0
  );
  let count = 0;
  for (aux of sortedList) {
    if (count > 10) {
      break;
    }
    if (!(await checkEpisodeExists(aux["uid"]))) {
      addEpisodeToDataBase(aux);
    }
    admin
      .firestore()
      .collection("podcasters")
      .doc(showUid)
      .update({
        podcasts: admin.firestore.FieldValue.arrayUnion(aux["uid"]),
      });
    count += 1;
  }
}

async function addEpisodeToDataBase(episode) {
  admin.firestore().collection("podcasts").doc(episode["uid"]).set(episode);
}

async function checkEpisodeExists(episodeUid) {
  var docRef = await admin
    .firestore()
    .collection("podcasts")
    .doc(episodeUid)
    .get();
  return docRef.exists;
}
/*********************************************
 ********************LOGICAL*******************
 *********************************************/

exports.play = functions.https.onCall(async (data, context) => {
  /*
    data = {
        episodeUid : String
        userUid : String
        position : int
    }
  */
  let episodeUid = data.episodeUid;
  let userUid = data.userUid;
  let position = data.position;
  let result = await playEpisode(episodeUid, userUid, position);
  if (result["result"] == "devices") {
    return result;
  }
  if (result["result"] == "unauthorized") {
    result = await getAccessTokenWithRefreshToken(userUid);
    if (result["result"] == "unauthorized") {
      return result;
    }
    result = await playEpisode(episodeUid, userUid, position);
  }
  return result;
});

exports.pause = functions.https.onCall(async (data, context) => {
  /*
    data = {
        episodeUid : String
        userUid : String
    }
  */
  let userUid = data.userUid;
  let result = await pauseEpisode(userUid);
  if (result["result"] == "devices") {
    return result;
  }
  if (result["result"] == "unauthorized") {
    result = await getAccessTokenWithRefreshToken(userUid);
    if (result["result"] == "unauthorized") {
      return result;
    }
    result = await pauseEpisode(userUid);
  }
  return result;
});

exports.devices = functions.https.onCall(async (data, context) => {
  /*
    data = {
        userUid : String
    }
  */
  let userUid = data.userUid;
  result = await getDevices(userUid);
  if (result["result"] == "unauthorized") {
    result = await getAccessTokenWithRefreshToken(userUid);
    if (result["result"] == "unauthorized") {
      return result;
    }
    result = await getDevices(userUid);
  }
  return result;
});

exports.searchInSpotify = functions.https.onCall(async (data, context) => {
  /*
  data = {
    query: String,
    userUid: String
  }
  */
  let userUid = data.userUid;
  let query = data.query;

  result = await search(userUid, query);
  if (result["result"] == "unauthorized") {
    result = await getAccessTokenWithRefreshToken(userUid);
    if (result["result"] == "unauthorized") {
      return false;
    }
    result = await search(userUid, query);
  }
  return result;
});

exports.fetchUserPlayer = functions.https.onCall(async (data, context) => {
  /*
    data = {
        userUid : String
    }
  */
  let userUid = data.userUid;
  result = await fecthUser(userUid);
  return result;
});

async function fecthUser(userUid) {
  try {
    var spotifyAuth = await getSpotifyAuth(userUid);
    var response = await fetch(
      host + "/me/player/currently-playing?additional_types=episode",
      {
        headers: {
          Accept: "application/json",
          Authorization: "Bearer " + spotifyAuth.access_token,
          "Content-Type": "application/json",
        },
        method: "GET",
      }
    );
    if (response["status"] != 200) {
      return false;
    }

    result = await response.json();
    console.log(result);
    if (result["item"]["type"] != "episode") {
      return false;
    }
    e = result["item"];
    s = result["item"]["show"];

    searchArrayEpisode = [];
    prev = "";
    for (letter of e["name"]) {
      prev += letter;
      word = prev.toLowerCase();
      searchArrayEpisode.push(word);
    }

    episode = {
      uid: e["uri"],
      name: e["name"],
      description: e["description"],
      duration_ms: e["duration_ms"],
      show_name: s["name"],
      show_uri: s["uri"],
      image_url: e["images"][0]["url"],
      comments: 0,
      commentsImg: [],
      release_date: e["release_date"],
      watching: 0,
      searchArray: searchArrayEpisode,
    };

    searchArrayShow = [];
    prev = "";
    for (letter of s["name"]) {
      prev += letter;
      word = prev.toLowerCase();
      searchArrayShow.push(word);
    }
    show = {
      uid: s["uri"],
      name: s["name"],
      publisher: s["publisher"],
      description: s["description"],
      image_url: s["images"][0]["url"],
      total_episodes: s["total_episodes"],
      podcasts: [],
      followers: [],
      searchArray: searchArrayShow,
    };
    if (!(await checkEpisodeExists(result["item"]["uri"]))) {
      await addEpisodeToDataBase(episode);
    }
    if (!(await checkShowExists(episode["show_uri"]))) {
      addShowToDataBase(show);
      getShowEpisodes(
        episode["show_uri"],
        show["total_episodes"],
        show["name"],
        userUid
      );
    }

    info = {
      uid: result["item"]["uri"],
      isPlaying: result["is_playing"],
      position: result["progress_ms"],
    };

    return info;
  } catch (err) {
    console.log(err);
    return false;
  }
}

async function search(userUid, query) {
  try {
    var spotifyAuth = await getSpotifyAuth(userUid);
    var response = await fetch(
      host + "/search?q=" + query + "&type=episode&limit=3&offset=0",
      {
        headers: {
          Accept: "application/json",
          Authorization: "Bearer " + spotifyAuth.access_token,
          "Content-Type": "application/json",
        },
        method: "GET",
      }
    );
    if (response["status"] == 200) {
      let result = await response.json();

      for (e of result["episodes"]["items"]) {
        let final_result = await getEpisode(e["id"], userUid);
        if (!(await checkEpisodeExists(final_result["episode"]["uid"]))) {
          addEpisodeToDataBase(final_result["episode"]);
        }
        if (!(await checkShowExists(final_result["episode"]["show_uri"]))) {
          addShowToDataBase(final_result["show"]);
          getShowEpisodes(
            final_result["show"]["uid"],
            final_result["show"]["total_episodes"],
            final_result["show"]["name"],
            userUid
          );
        }
      }
      return { result: "ok" };
    } else if (response["status"] == 401) {
      return { result: "unauthorized" };
    }
    return { result: "devices" };
  } catch (err) {
    console.log(err);
    return false;
  }
}

async function getEpisode(episodeUid, userUid) {
  try {
    var spotifyAuth = await getSpotifyAuth(userUid);
    var response = await fetch(host + "/episodes/" + episodeUid, {
      headers: {
        Accept: "application/json",
        Authorization: "Bearer " + spotifyAuth.access_token,
        "Content-Type": "application/json",
      },
      method: "GET",
    });
    if (response["status"] != 200) {
      return false;
    }

    let result = await response.json();

    searchArrayEpisode = [];
    prev = "";
    for (letter of e["name"]) {
      prev += letter;
      word = prev.toLowerCase();
      searchArrayEpisode.push(word);
    }

    searchArrayShow = [];
    prev = "";
    for (letter of result["show"]["name"]) {
      prev += letter;
      word = prev.toLowerCase();
      searchArrayShow.push(word);
    }

    s = result["show"];
    let final_result = {
      episode: {
        uid: result["uri"],
        name: result["name"],
        description: result["description"],
        duration_ms: result["duration_ms"],
        show_name: s["name"],
        show_uri: s["uri"],
        image_url: result["images"][0]["url"],
        comments: 0,
        commentsImg: [],
        release_date: result["release_date"],
        watching: 0,
        searchArray: searchArrayEpisode,
      },
      show: {
        uid: s["uri"],
        name: s["name"],
        publisher: s["publisher"],
        description: s["description"],
        image_url: s["images"][0]["url"],
        total_episodes: s["total_episodes"],
        podcasts: [],
        followers: [],
        searchArray: searchArrayShow,
      },
    };
    return final_result;
  } catch (err) {
    console.log(err);
    return false;
  }
}
async function playEpisode(episodeUid, userUid, position) {
  try {
    var spotifyAuth = await getSpotifyAuth(userUid);
    let devices = await getDevices(userUid);
    if (devices["result"] != "ok") {
      return devices;
    }
    var response = await fetch(
      host + "/me/player/play/?device_id=" + spotifyAuth.selectedDevice,
      {
        body: JSON.stringify({
          uris: [episodeUid],
          position_ms: position,
        }),
        headers: {
          Accept: "application/json",
          Authorization: "Bearer " + spotifyAuth.access_token,
          "Content-Type": "application/json",
        },
        method: "PUT",
      }
    );
    if (response["status"] == 204) {
      return { result: "ok" };
    } else if (response["status"] == 401) {
      return { result: "unauthorized" };
    }
    return { result: "devices" };
  } catch (err) {
    console.log(err);
    return { result: "devices" };
  }
}

async function pauseEpisode(userUid) {
  try {
    var spotifyAuth = await getSpotifyAuth(userUid);
    let devices = await getDevices(userUid);
    if (devices["result"] != "ok") {
      return devices;
    }
    var response = await fetch(host + "/me/player/pause", {
      headers: {
        Accept: "application/json",
        Authorization: "Bearer " + spotifyAuth.access_token,
        "Content-Type": "application/json",
      },
      method: "PUT",
    });
    if (response["status"] == 204) {
      return { result: "ok" };
    } else if (response["status"] == 401) {
      return { result: "unauthorized" };
    }
    return { result: "devices" };
  } catch (err) {
    console.log(err);
    return { result: "devices" };
  }
}

async function getDevices(userUid) {
  try {
    var spotifyAuth = await getSpotifyAuth(userUid);

    var myHeaders = new fetch.Headers();

    myHeaders.append("Content-Type", "application/json");
    myHeaders.append("Authorization", "Bearer " + spotifyAuth.access_token);

    var requestOptions = {
      method: "GET",
      headers: myHeaders,
      redirect: "follow",
    };

    var response = await fetch(host + "/me/player/devices", requestOptions);
    if (response["status"] == 200) {
      var result = await response.json();

      let devicesList = [];
      for (dev of result["devices"]) {
        devicesList.push({
          id: dev["id"],
          name: dev["name"],
          type: dev["type"],
        });
      }
      if (result["devices"] == []) {
        return { result: "devices" };
      }
      admin.firestore().collection("spotifyAuth").doc(userUid).update({
        selectedDevice: result.devices[0].id,
        devices: devicesList,
      });
      return { result: "ok" };
    } else if (response["status"] == 401) {
      return { result: "unauthorized" };
    }
  } catch (err) {
    console.log(err);
    return { result: "devices" };
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////NOTIFICATIONS//////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////

exports.sendNotificatioToDevice = functions.firestore
  .document("users/{uid}/notifications/{notificationId}")
  .onCreate(async (snapshot) => {
    let notification = snapshot.data();
    let type = notification.type;
    if (type == "follower") {
      data = {
        type: notification.type,
        timestamp: notification.timestamp,
        user: notification.user,
      };
    } else {
      data = {
        type: notification.type,
        timestamp: notification.timestamp,
        user: notification.user,
        podcast: notification.podcast,
        comment: notification.comment,
      };
    }
    let token = await getDeviceToken(uid);
    admin.messaging().sendToDevice(
      token,
      {
        data: data,
      },
      {
        contentAvailable: true,
        priority: "high",
      }
    );
  });

async function getDeviceToken(userUid) {
  ref = await admin.firestore().collection("users").doc(userUid).get();
  let userInfo = ref.data();
  return userInfo.token;
}

/*********************************************
 ***************** LISTENING *****************
 *********************************************/

exports.updateEpisodeListening = functions.database.ref('users/{userId}/lastListened')
  .onWrite(async (change, context) => {
    const userId = context.params.userId;
    const lastListened = change.before.val();
    const listeningNow = change.after.val();

    if (lastListened != null)
      await admin.firestore().collection("test").doc(lastListened).update({
        users_watching: admin.firestore.FieldValue.arrayRemove(userId)
      });

    if (listeningNow != null)
      await admin.firestore().collection("test").doc(listeningNow).update({
        users_watching: admin.firestore.FieldValue.arrayUnion(userId)
      });
  });


exports.removeEpisodeListening = functions.database.ref('users/{userId}/connections')
  .onWrite((change, context) => {
    const userId = context.params.userId;
    const connections = change.after.val();
    const isDisconnected = connections.length == 0;

    if (isDisconnected) {
      return functions.database.ref(`users/${userId}/lastListened`).set(null);
    }
  });