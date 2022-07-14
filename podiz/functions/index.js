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
  //Working and tested!!!
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
      console.log(response);
      var result = await response.json();

      let userUid = await getUserInfo(result.access_token);

      await admin.firestore().collection("spotifyAuth").doc(userUid).set({
        access_token: result.access_token,
        token_type: result.token_type,
        expires_in: result.expires_in,
        refresh_token: result.refresh_token,
        scope: result.scope,
      });

      return userUid;
    } catch (err) {
      console.log(err);
      return "0";
    }
  }
);

async function getAccessTokenWithRefreshToken(userUid) {
  //need to test
  try {
    spotifyAuth = getSpotifyAuth(userUid);

    var response = await fetch(authenticationHost + "api/token", {
      headers: {
        Accept: "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      form: encodeFormData({
        grant_type: "refresh_token",
        code: spotifyAuth.refresh_token,
        client_id: client_id,
        client_secret: client_secret,
      }),
      method: "POST",
    });

    var result = await response.json();

    await admin
      .firestore()
      .collection("spotifyAuth")
      .doc(userUid)
      .update({ access_token: result.access_token });

    return result.access_token;
  } catch (err) {
    console.log(err);
    return "0";
  }
}

async function getSpotifyAuth(userUid) {
  ref = await admin.firestore().collection("spotifyAuth").doc(userUid).get();
  let spotifyAuth = ref.data();
  return spotifyAuth;
}

async function getUserInfo(code) {
  //working and tested
  try {
    var response = await fetch(host + "/me", {
      headers: {
        Accept: "application/json",
        Authorization: "Bearer " + code,
        "Content-Type": "application/json",
      },
      method: "GET",
    });
    //TODO verificar o Statuscode das mensagens
    var result = await response.json();

    admin.firestore().collection("users").doc(result.uri).set({
      //TODO verificar se ja existe ou nao!!
      name: result.display_name,
      email: result.email,
      image_url: result.images[0].url,
      followers: [],
      following: [],
      lastListened: "",
      comments: [],
      favPodcasts: []
    });
    return result.uri;
  } catch (err) {
    console.log(err);
  }
}

const encodeFormData = (data) => {
  return Object.keys(data)
    .map((key) => encodeURIComponent(key) + "=" + encodeURIComponent(data[key]))
    .join("&");
};

/*********************************************
 ********************LOGICAL*******************
 *********************************************/

exports.play = functions.https.onCall(async (data, context) => {
  //need to test
  /*
    data = {
        episodeUid : String
        userUid : String
    }
  */
  let episodeUid = data.episodeUid;
  let userUid = data.userUid;
  let result = await playEpisode(episodeUid, userUid);
  //catch code in here
  if (result) {
    return true;
  }
  // await getAccessTokenWithRefreshToken(userUid); // catch here
  // await playEpisode(episodeUid, userUid);
  return false;
});

exports.pause = functions.https.onCall(async (data, context) => {
  //need to test
  /*
    data = {
        episodeUid : String
        userUid : String
    }
  */
  let userUid = data.userUid;
  let result = await pauseEpisode(userUid);
  //catch code in here
  if (result) {
    return true;
  }
  // await getAccessTokenWithRefreshToken(userUid); // catch here
  // await pauseEpisode(userUid);
  return false;
});

exports.devices = functions.https.onCall(async (data, context) => {
  //need to test
  /*
    data = {
        userUid : String
    }
  */
  let userUid = data.userUid;
  result = await getDevices(userUid);
  // if (result) {
  //   await getAccessTokenWithRefreshToken(userUid); // catch here
  //   await getDevices(userUid);
  // }
});

async function playEpisode(episodeUid, userUid) {
  try {
    var spotifyAuth = await getSpotifyAuth(userUid);

    var response = await fetch(host + "/me/player/play", {
      //TODO add device
      body: JSON.stringify({
        uris: [episodeUid],
        position_ms: 0,
      }),
      headers: {
        Accept: "application/json",
        Authorization: "Bearer " + spotifyAuth.access_token,
        "Content-Type": "application/json",
      },
      method: "PUT",
    });
    return;
  } catch (err) {
    console.log(err);
  }
}

async function pauseEpisode(userUid) {
  try {
    var spotifyAuth = getSpotifyAuth(userUid);

    var response = await fetch(host + "/me/player/pause", {
      headers: {
        Accept: "application/json",
        Authorization: "Bearer " + spotifyAuth.access_token,
        "Content-Type": "application/json",
      },
      method: "PUT",
    });
    console.log(response);
    return;
  } catch (err) {
    console.log(err);
  }
}

async function getDevices(userUid) {
  try {
    var spotifyAuth = getSpotifyAuth(userUid);

    var myHeaders = new fetch.Headers();

    myHeaders.append("Content-Type", "application/json");
    myHeaders.append("Authorization", "Bearer " + spotifyAuth.access_token);

    var requestOptions = {
      method: "GET",
      headers: myHeaders,
      redirect: "follow",
    };

    var response = await fetch(host + "/me/player/devices/", requestOptions);

    var result = await response.json();
    console.log(result);
    admin
      .firestore()
      .collection("spotifyAuth")
      .doc(userUid)
      .update({
        device: result.devices[0].id,
        selectedDevice: result.devices[0].id,
      }); //change the update!!!

    if (
      result.error_description !== undefined
      //&& result.error_description === "Invalid access token."
    ) {
      return false;
    }
    return result;
  } catch (err) {
    console.log(err);
  }
  return false;
}
