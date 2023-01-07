const helpers = require("./helpers.js");
const admin = require("firebase-admin");
const fetch = require("node-fetch");

const { fetchSpotifyShow } = require("./shows.js");
const { fetchSpotifyEpisode } = require("./episodes.js");

exports.fetchSpotifySearch = async (accessToken, query) => {
  try {
    // fetch shows and episodes from spotify
    var response = await helpers.fetchFromHost(
      "/search?q=" + query + "&type=show,episode",
      accessToken
    );
    if (response["status"] != 200) return false;

    var search = await response.json();

    //TODO do not fetch the show again, call show/showId/episodes
    var resultList = await Promise.all([
      // add shows to firestore
      ...search.shows.items.map(async (show) => {
        var showExists = await helpers.checkShowExists(show.id);
        if (!showExists) return await fetchSpotifyShow(accessToken, show.id);
        return true;
      }),
      // add episodes to firestore
      ...search.episodes.items.map(async (episode) => {
        var episodeExists = await helpers.checkEpisodeExists(episode.id);
        if (!episodeExists)
          return await fetchSpotifyEpisode(accessToken, episode.id);
        return true;
      }),
    ]);

    var success = resultList.every((result) => result);
    return success;
  } catch (err) {
    console.log(err);
    return false;
  }
};

const encodeFormData = (data) => {
  return Object.keys(data)
    .map((key) => encodeURIComponent(key) + "=" + encodeURIComponent(data[key]))
    .join("&");
};

exports.updateEpisodeDaily = async () => {
  // ######### SPOTIFY ########
  let client_id = "5deee54ca37b4fc59abaa2869233bb3d";
  let client_secret = "93a97941742f4b37b9da3b4ddb3a2895";

  var response = await fetch("https://accounts.spotify.com/api/token", {
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      Authorization: "Basic " + btoa(client_id + ":" + client_secret),
    },
    body: encodeFormData({
      grant_type: "client_credentials",
    }),
    method: "POST",
  });
  var json = await response.json();
  let accessToken = json["access_token"];

  let number = 500;
  let showOffset = 0;
  let docsSnap = await admin
    .firestore()
    .collection("shows")
    .orderBy("publisher")
    .startAt(showOffset)
    .limit(number)
    .get();
  // let new_episodes = 0;
  while (docsSnap.size != 0) {
    docsSnap.forEach(async (d) => {
      let doc_id = d.id;
      let doc = d.data();

      let showJson = await helpers.fetchFromHost(
        "/shows/" + doc_id + "?market=US",
        accessToken
      );
      let show = await showJson.json();
      let show_name = show["name"];
      console.log(show);
      console.log(show["episodes"]["total"]);
      console.log(size);
      // if (show["total_episodes"] != size) {
      //   let offset = 0;
      //   let total = show["total_episodes"];
      //   while (offset < total) {
      //     // show_episodes = sp.show_episodes(
      //     //   d.id,
      //     //   (offset = offset),
      //     //   (market = "US")
      //     // )["items"];
      //     //get episodes
      //     for (let e in show_episodes) {
      //       if (!helpers.checkEpisodeExists(e["id"])) {
      //         helpers.addEpisodeToFirestore(e, show_id);
      //         add_podcast(e, show_id, show_name);
      //         size += 1;
      //         new_episodes += 1;
      //       }
      //     }
      //     offset += 50;
      //   }
      // }
      // console.log("{} new episodes added".format(new_episodes));
    });
    showOffset += number;
    docsSnap = await admin
      .firestore()
      .collection("shows")
      .orderBy("publisher")
      .startAt(showOffset)
      .limit(number)
      .get();
  }
};
