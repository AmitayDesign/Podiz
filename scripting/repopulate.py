import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from numpy import true_divide

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

def splitNameIntoArray(name):
    lowerName = name.lower()
    
    prev = ""
    array = []

    for letter in lowerName:
        prev += letter
        array.append(prev)

    return array

def add_podcast(json, show_uri, show_name): #TODO change this with new parameters
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

def update_podcaster(show_id, podcast_id):
    db.collection("podcasters").document(show_id).update({"podcasts": firestore.ArrayUnion([podcast_id])})

def checkEpisode(episodeUid):
    doc = db.collection("podcasts").document(episodeUid).get()
    if(doc.exists):
        return True
    return False


if __name__ == "__main__":
    docs = db.collection("shows").stream()
    new_episodes = 0
    
    for d in docs:
        doc = d.to_dict()
        show = sp.show(d.id, market="US")
        
        show_name = show["name"]
        show_uri = show["uri"]
        size = len(doc["podcasts"])
        if(show["total_episodes"] != size):
            offset = 0
            total = show["total_episodes"]
            while offset < total:
                show_episodes = sp.show_episodes(d.id, offset=offset, market="US")["items"] 
                
                for e in show_episodes:
                    if not checkEpisode(e["uri"]):
                        add_podcast(e, show_uri, show_name)
                        update_podcaster(show_uri, e["uri"])
                        size += 1
                        new_episodes += 1
                
                offset += 50
                
    print("{} new episodes added".format(new_episodes))