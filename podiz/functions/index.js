const functions = require("firebase-functions");
const admin = require("firebase-admin");
const fetch = require("node-fetch");
const { firestore } = require("firebase-admin");

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

      await admin.firestore().collection("spotifyAuth").doc(userUid).set({
        access_token: result.access_token,
        token_type: result.token_type,
        expires_in: result.expires_in,
        refresh_token: result.refresh_token,
        scope: result.scope,
      });

      let userUid = await getUserInfo(result.access_token);

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
    if (response["status"] != 200) {
      return false;
    }
    var result = await response.json();
    await admin
      .firestore()
      .collection("spotifyAuth")
      .doc(userUid)
      .update({ access_token: result.access_token });

    return true;
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

async function getUserInfo(code) {
  try {
    var response = await fetch(host + "/me", {
      headers: {
        Accept: "application/json",
        Authorization: "Bearer " + code,
        "Content-Type": "application/json",
      },
      method: "GET",
    });

    var result = await response.json();

    var docRef = await admin
      .firestore()
      .collection("users")
      .doc(result.uri)
      .get();
    var exists = docRef.exists;

    if (exists) {
      // getUserFavoriteShow(resul.uri); TODOcheck with this
      return result.uri;
    }
    prev = "";
    searchArray = [];

    for (letter in result.display_name) {
      prev += letter;
      searchArray.push(prev);
    }

    admin.firestore().collection("users").doc(result.uri).set({
      name: result.display_name,
      email: result.email,
      image_url: result.images[0].url,
      followers: [],
      following: [],
      lastListened: "",
      comments: [],
      favPodcasts: [],
      searchArray: searchArray,
    });

    getUserFavoriteShow(resul.uri);
    return result.uri;
  } catch (err) {
    console.log(err);
  }
}

async function getUserFavoriteShow(userUid) {
  var spotifyAuth = await getSpotifyAuth(userUid);

  var response = await fetch(host + "/me/shows?offset=0&limit=50", {
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

  result = await response.json();

  for (item in result["items"]) {
    s = item["show"];
    show = {
      uid: s["uri"],
      name: s["name"],
      publisher: s["publisher"],
      description: s["description"],
      image_url: s["images"][0]["url"],
      total_episodes: s["total_episodes"],
      podcasts: [],
      followers: [],
    };

    if (!(await checkShowExists(show["uid"]))) {
      addShowToDataBase(show);
      getShowEpisodes(show["uid"], show["total_episodes"]); //TODO do this!
    }
    favPodcasts.push(show["uid"]);
  }

  let total = result["total"];
  if (total < 50) {
    admin.firestore
      .collection("users")
      .doc(userUid)
      .update({
        favPodcasts: firebase.firestore.FieldValue.arrayUnion(favPodcasts),
        followers: firebase.firestore.FieldValue.arrayUnion(favPodcasts),
      });
    return;
  }
  for (let i = 50; i < total; i += 50) {
    var response = await fetch(
      host + "/me/shows?offset=" + i.toString() + "&limit=50",
      {
        headers: {
          Accept: "application/json",
          Authorization: "Bearer " + spotifyAuth.access_token,
          "Content-Type": "application/json",
        },
        method: "GET",
      }
    );
    for (item in result["items"]) {
      s = item["show"];
      show = {
        uid: s["uri"],
        name: s["name"],
        publisher: s["publisher"],
        description: s["description"],
        image_url: s["images"][0]["url"],
        total_episodes: s["total_episodes"],
        podcasts: [],
        followers: [],
      };

      if (!(await checkShowExists(show["uid"]))) {
        addShowToDataBase(show);
        getShowEpisodes(show["uid"], show["total_episodes"]);
      }

      favPodcasts.push(show["uid"]);
    }
  }
  admin.firestore
    .collection("users")
    .doc(userUid)
    .update({
      favPodcasts: firebase.firestore.FieldValue.arrayUnion(favPodcasts),
      followers: firebase.firestore.FieldValue.arrayUnion(favPodcasts),
    });
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

async function getShowEpisodes(showUid, total_episodes) {
  var spotifyAuth = await getSpotifyAuth(userUid);
  episodeList = [];

  for (let i = 0; i < total_episodes; i += 50) {
    var response = await fetch(
      host +
        "/shows/" +
        showUid.split(":")[2] +
        "/episodes?limit=50&offset=" +
        i.toString(),
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

    for (e in result["items"]) {
      searchArray = [];
      prev = "";
      for (letter in e["name"]) {
        prev += letter;
        searchArray.push(prev);
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
        searchArray: searchArray,
      };
      addEpisodeToDataBase(episode);
      episodeList.push(e["uri"]);
    }
  }
  admin.firestore
    .collection("podcasters")
    .doc(showUid)
    .update({
      podcasts: firebase.firestore.FieldValue.arrayUnion(episodeList),
    });
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
  if (!result) {
    result = await getAccessTokenWithRefreshToken(userUid);
    if (!result) {
      return false;
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

  if (!result) {
    result = await getAccessTokenWithRefreshToken(userUid);
    if (!result) {
      return false;
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
  if (!result) {
    result = await getAccessTokenWithRefreshToken(userUid);
    if (!result) {
      return false;
    }
    result = await getDevices(userUid);
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
    if (result["item"]["type"] != "episode") {
      return false;
    }
    e = result["item"];
    s = result["item"]["show"];

    searchArrayEpisode = [];
    prev = "";
    for (letter in e["name"]) {
      prev += letter;
      searchArrayEpisode.push(prev);
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
      searchArray: searchArrayEpisode
    };

    searchArrayShow = [];
    prev = "";
    for (letter in e["name"]) {
      prev += letter;
      searchArrayShow.push(prev);
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
      searchArray: searchArrayShow
    };
    if (!(await checkEpisodeExists(result["item"]["uri"]))) {
      await addEpisodeToDataBase(episode);
    }
    if (!(await checkShowExists(episode["show_uri"]))) {
      addShowToDataBase(show);
      getShowEpisodes(episode["show_uri"], show["total_episodes"]);
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

async function playEpisode(episodeUid, userUid, position) {
  try {
    var spotifyAuth = await getSpotifyAuth(userUid);
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
    if (response["status"] != 204) {
      return false;
    }
    return true;
  } catch (err) {
    console.log(err);
    return false;
  }
}

async function pauseEpisode(userUid) {
  try {
    var spotifyAuth = await getSpotifyAuth(userUid);

    var response = await fetch(host + "/me/player/pause", {
      headers: {
        Accept: "application/json",
        Authorization: "Bearer " + spotifyAuth.access_token,
        "Content-Type": "application/json",
      },
      method: "PUT",
    });
    if (response["status"] != 204) {
      return false;
    }
    return true;
  } catch (err) {
    console.log(err);
    return false;
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
    if (response["status"] != 200) {
      return false;
    }

    var result = await response.json();

    let devicesList = [];
    for (dev of result["devices"]) {
      devicesList.push({ id: dev["id"], name: dev["name"], type: dev["type"] });
    }
    admin.firestore().collection("spotifyAuth").doc(userUid).update({
      selectedDevice: result.devices[0].id,
      devices: devicesList,
    });
    return true;
  } catch (err) {
    console.log(err);
    return false;
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
