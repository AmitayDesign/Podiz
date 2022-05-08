import vimeo 
import config
import requests 
import json

def getThumbnail(client, id, picture_id, name):
    print("getting thumbnail")
    response = client.get("https://api.vimeo.com/videos/"+ id +"/pictures/" + picture_id)
    
    response = requests.get(response.json()['base_link'])
    
    file = open("thumbnails/{}_thumbnail.jpeg".format(name), "wb")
    file.write(response.content)
    file.close

if __name__ == '__main__':

    client = vimeo.VimeoClient(
            token = config.ACCESS_TOKEN,
            key = config.CLIENT_ID,
            secret = config.CLIENT_SECRET
        )

    response = client.get('https://api.vimeo.com/me/videos')

    for video in response.json()['data']:

        id = video['uri'].split("/")[-1]
        title = video['name']

        if(len(video['categories']) != 0 and video['categories'][0] == "Howto & Style"):
            category = '26'
        else:
            category = '28'

        if video['privacy']['view'] == "anybody":
            privacy = "public"
        else:
            privacy = "unlisted"

        video_data = {
            "title" : title,
            "description" : video["description"], 
            "category" : category,
            "privacy" : privacy
        }
        with open("jsons/{}.json".format(title), "w") as jsonFile:
            json.dump(video_data, jsonFile)

        picture_id = video['pictures']['uri'].split("/")[-1]
        getThumbnail(client, id, picture_id, title)