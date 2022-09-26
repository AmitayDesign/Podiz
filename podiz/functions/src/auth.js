const helpers = require("./helpers.js");
const { fetchSpotifyUserFavorites } = require("./user-favorites.js");

const admin = require("firebase-admin");
const fetch = require("node-fetch");

var client_id = "5deee54ca37b4fc59abaa2869233bb3d";
var client_secret = "93a97941742f4b37b9da3b4ddb3a2895";

var authenticationHost = "https://accounts.spotify.com/";

exports.getAccessTokenWithCode = async (code) => {
  try {
    var response = await fetch(authenticationHost + "api/token", {
      body: encodeFormData({
        grant_type: "authorization_code",
        code: code,
        redirect_uri: "podiz:/connect",
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
    console.log(`api/token response: ${response["status"]}`);
    console.log(`api/token result: ${result}`);
    console.log(`access_token: ${result.access_token}`);

    let userId = await fetchSpotifyUser(result.access_token);
    console.log(`userId: ${userId}`);

    admin.firestore().collection("spotifyAuth").doc(userId).set({
      access_token: result.access_token,
      token_type: result.token_type,
      expires_in: result.expires_in,
      refresh_token: result.refresh_token,
      scope: result.scope,
    });

    return {
      userId: userId,
      access_token: result.access_token,
      timeout: result.expires_in,
    };
  } catch (err) {
    console.log(err);
    return "0";
  }
};

exports.getAccessTokenWithRefreshToken = async (userId) => {
  try {
    spotifyAuth = await getSpotifyAuth(userId);

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
      admin
        .firestore()
        .collection("spotifyAuth")
        .doc(userId)
        .update({ access_token: result.access_token });
      return { result: result.access_token };
    } else if (response["status"] == 401) {
      return { result: "unauthorized" };
    }
    return { result: "error" };
  } catch (err) {
    console.log(err);
    return { result: "error" };
  }
};

async function getSpotifyAuth(userId) {
  ref = await admin.firestore().collection("spotifyAuth").doc(userId).get();
  let spotifyAuth = ref.data();
  return spotifyAuth;
}

const encodeFormData = (data) => {
  return Object.keys(data)
    .map((key) => encodeURIComponent(key) + "=" + encodeURIComponent(data[key]))
    .join("&");
};

exports.fetchSpotifyUser = fetchSpotifyUser;
async function fetchSpotifyUser(accessToken) {
  try {
    // fetch user from spotify
    var response = await helpers.fetchFromHost("/me", accessToken);
    console.log(`me response: ${response["status"]}`);
    if (response["status"] != 200) return null;
    var user = await response.json();
    console.log(`userId: ${user.id}`);

    // if user does not exist, create user in firestore
    var userExists = await helpers.checkUserExists(user.id);
    console.log(`userExists ${userExists}`);
    if (!userExists) await helpers.addUserToFirestore(user);
    console.log('user added to firestore');

    // save user favorite shows
    fetchSpotifyUserFavorites(accessToken, user.id);
    return user.id;
  } catch (e) {
    console.log('error fetch spotify user');
    console.log(e);
    return null;
  }
}
