const functions = require("firebase-functions");
const admin = require("firebase-admin");
const fetch = require("node-fetch");
const { firestore } = require("firebase-admin");

const utf8 = require("utf8");

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
      console.log(response);
      var result = await response.json();

      let userID = await getUserInfo(result.access_token);

      await admin.firestore().collection("spotifyAuth").doc(userID).set({
        access_token: result.access_token,
        token_type: result.token_type,
        expires_in: result.expires_in,
        refresh_token: result.refresh_token,
        scope: result.scope,
      });

      return userID;
    } catch (err) {
      console.log(err);
      return "0";
    }
  }
);

async function getAccessTokenWithRefreshToken(userID) {
  try {
    ref = admin.firestore().collection("spotifyAuth").doc(userID).get();
    var spotifyAuth = ref.data();

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

    admin
      .firestore()
      .collection("spotifyAuth")
      .doc(userID)
      .update({ access_token: result.access_token });

    return result.access_token;
  } catch (err) {
    console.log(err);
    return false;
  }
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
    //TODO verificar o Statuscode das mensagens
    var result = await response.json();
    console.log(result);
    admin.firestore().collection("users").doc(result.uri).set({
      //TODO verificar se ja existe ou nao!!
      name: result.display_name,
      email: result.email,
      image_url: result.images[0].url,
      followers: [],
      following: [],
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
  /*
    data = {
        songUid : String
        userUid : String
    }
  */
  let result = await playEpisode(data.songUid, data.userUid);
  //catch code in here 
  if(result) {
    return;
  }
  await getAccessTokenWithRefreshToken(data.userUid);
  await playEpisode(data.songUid, data.userUid);
});

exports.pause = functions.https.onCall(async (data, context) => {
  /*
    data = {
        songUid : String
        userUid : String
    }
  */

  let result = await pauseEpisode(data.songUid, data.userUid);
  //catch code in here 
  if(result) {
    return;
  }
  await getAccessTokenWithRefreshToken(data.userUid);
  await pauseEpisode(data.songUid, data.userUid);
});

// exports.playEpisode = functions.https.onCall(async (data, context) => {
//
//   try {
//     var ref = await admin
//       .firestore()
//       .collection("spotifyAuth")
//       .doc(data.userUid)
//       .get();
//     var spotifyAuth = ref.data();

//     var response = await fetch(
//       "https://api.spotify.com/v1/me/player/play?device_id=" +
//         spotifyAuth.device,
//       {
//         body: JSON.stringify({
//           context_uri: data.album,
//           offset: { position: data.position },
//           position_ms: 0,
//         }),
//         headers: {
//           Accept: "application/json",
//           Authorization: "Bearer " + spotifyAuth.token,
//           "Content-Type": "application/json",
//         },
//         method: "PUT",
//       }
//     );
//     console.log(response);
//     return;
//   } catch (err) {
//     console.log(err);
//   }
// });

// exports.stopEpisode = functions.https.onCall(async (data, context) => {
//   if (!context.auth) {
//     throw new functions.https.HttpsError(
//       "unauthenticated",
//       "only authenticated users can add requests"
//     );
//   }
//   try {
//     var ref = await admin
//       .firestore()
//       .collection("spotifyAuth")
//       .doc(context.auth.uid)
//       .get();
//     var spotifyAuth = ref.data();

//     var response = await fetch(
//       "https://api.spotify.com/v1/me/player/pause?device_id=" +
//         spotifyAuth.device,
//       {
//         headers: {
//           Accept: "application/json",
//           Authorization: "Bearer " + spotifyAuth.token,
//           "Content-Type": "application/json",
//         },
//         method: "PUT",
//       }
//     );
//     return;
//   } catch (err) {
//     console.log(err);
//   }
// });

// exports.getDevices = functions.https.onCall(async (data, context) => {
//   if (!context.auth) {
//     throw new functions.https.HttpsError(
//       "unauthenticated",
//       "only authenticated users can add requests"
//     );
//   }

//   var ref = await admin
//     .firestore()
//     .collection("spotifyAuth")
//     .doc(context.auth.uid)
//     .get();
//   var spotifyAuth = ref.data();

//   try {
//     //result = await requestToken();
//     //console.log(result);

//     var myHeaders = new fetch.Headers();

//     myHeaders.append("Content-Type", "application/json");
//     myHeaders.append("Authorization", "Bearer " + spotifyAuth.token);

//     var requestOptions = {
//       method: "GET",
//       headers: myHeaders,
//       redirect: "follow",
//     };

//     var response = await fetch(host + "/me/player/devices/", requestOptions);

//     var result = await response.json();

//     admin
//       .firestore()
//       .collection("spotifyAuth")
//       .doc(context.auth.uid)
//       .update({ device: result.devices[0].id });

//     if (
//       result.error_description !== undefined
//       //&& result.error_description === "Invalid access token."
//     ) {
//       return false;
//     }
//     return result;
//   } catch (err) {
//     console.log(err);
//   }

//   return false;
// });
