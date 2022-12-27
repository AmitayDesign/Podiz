import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

import spotipy
from spotipy.oauth2 import SpotifyClientCredentials

######### FIREBASE ########
cred = credentials.Certificate("podiz-130ca-firebase-adminsdk-3dnpm-82267f2e92.json")
firebase_admin.initialize_app(cred)

db = firestore.client()
##########################

######### SPOTIFY ########
client_id = "c4a97db001f24c84a165e8c9d5f59930"
client_secret = "2d20e624648b40f3ac5cc11a23181473"
client_credentials_manager = SpotifyClientCredentials(client_id=client_id,client_secret=client_secret)

sp = spotipy.Spotify(client_credentials_manager=client_credentials_manager)
##########################

# db.collection("songs").document().set({"song" : "OLa"})

def splitNameIntoArray(name):
    lowerName = name.lower()
    
    prev = ""
    array = []

    for letter in lowerName:
        prev += letter
        array.append(prev)

    return array

def add_podcaster(json):
    array = splitNameIntoArray(json["name"])
    db.collection("podcasters").document(json["uri"]).set({
        "name" : json["name"],
        "description" : json["description"],
        "total_episodes" : json["total_episodes"],
        "publisher" : json["publisher"],
        "image_url" : json["images"][-1]["url"],
        "followers" : [],
        "searchArray" : array
    })

def update_podcaster(show_id, podcast_id):
    db.collection("podcasters").document(show_id).update({"podcasts": firestore.ArrayUnion([podcast_id])})


def add_podcast(json, show_uri, show_name):
    print(json["name"])
    array = splitNameIntoArray(json["name"])
    db.collection("podcasts").document(json["uri"]).set({
        "name" : json["name"],
        "description" : json["description"],
        "duration_ms" : json["duration_ms"],
        "show_name" : show_name,
        "show_uri" : show_uri,
        "image_url" : json["images"][-1]["url"],
        "comments" : 0,
        "commentsImg":[],
        "release_date" : json["release_date"],
        "watching": 0,
        "searchArray" : array
    })


if __name__ == "__main__":
    episode_host = "https://open.spotify.com/episode/"
    episodes = ["7jVfcid2LxjqFcLVxm8kPF", "1VUT86AMdBVuoyQT5Bf645", "3yX7ZIE4T4gPI4PZTX1i3K"]
    all_podcasts = []

    podcasts = sp.episodes(episodes, market="US")


    ep = podcasts["episodes"]
    total = 0
   
    for i in range(len(ep)):
        add_podcaster(ep[i]["show"])

        id = ep[i]["show"]["id"]
        show_uri = ep[i]["show"]["uri"]
        show_name =ep[i]["show"]["name"]
        count = ep[i]["show"]["total_episodes"]
        offset = 0

        print("INFORMATION ABOUT {}".format(id))
        
        while offset < count:
            print(offset)
            print(count)
            show_episodes = sp.show_episodes(id, offset=offset, market="US")["items"]
            total += len(show_episodes)
            for e in show_episodes:
                add_podcast(e, show_uri, show_name)
                update_podcaster(show_uri, e["uri"])
            offset += 50
    print(total)