const fetch = require("node-fetch");
const host = "https://api.spotify.com/v1";

exports.playEpisode = async (accessToken, episodeId, time) => {
  if (time == null) {
    time = 0;
  }
  let devices = await getDevices(accessToken);
  console.log(devices);
  if (devices.result == "error") return;
  var result = await fetch(
    host + "/me/player/play?device_id=" + devices.result,
    {
      body: JSON.stringify({
        uris: [episodeId],
        position_ms: time,
      }),
      headers: {
        Accept: "application/json",
        Authorization: "Bearer " + accessToken,
        "Content-Type": "application/json",
      },
      method: "PUT",
    }
  );
  var response = await result.json();
  console.log(response);
};

exports.pauseEpisode = async (accessToken) => {
  await fetch(host + "/me/player/pause", {
    headers: {
      Accept: "application/json",
      Authorization: "Bearer " + accessToken,
      "Content-Type": "application/json",
    },
    method: "PUT",
  });
};

async function getDevices(accessToken) {
  try {
    var myHeaders = new fetch.Headers();

    myHeaders.append("Content-Type", "application/json");
    myHeaders.append("Authorization", "Bearer " + accessToken);

    var requestOptions = {
      method: "GET",
      headers: myHeaders,
      redirect: "follow",
    };

    var response = await fetch(host + "/me/player/devices", requestOptions);
    console.log(response);
    if (response["status"] == 200) {
      var result = await response.json();
      console.log(result.devices[0].id);
      return { result: result.devices[0].id };
    }

    return { result: "error" };
  } catch (err) {
    console.log(err);
    return { result: "error" };
  }
}
