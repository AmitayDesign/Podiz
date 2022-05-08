import os
import json
from re import search 

import httplib2
import os
import random
import sys
import time
import requests

from argparse import Namespace
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from googleapiclient.http import MediaFileUpload
from oauth2client.client import flow_from_clientsecrets
from oauth2client.file import Storage
from oauth2client.tools import run_flow

httplib2.RETRIES = 1

MAX_RETRIES = 10

RETRIABLE_EXCEPTIONS = (httplib2.HttpLib2Error, IOError)
RETRIABLE_STATUS_CODES = [500, 502, 503, 504]

CLIENT_SECRETS_FILE = "client_secrets.json"

YOUTUBE_UPLOAD_SCOPE = ["https://www.googleapis.com/auth/youtube.upload","https://www.googleapis.com/auth/youtube"]
YOUTUBE_API_SERVICE_NAME = "youtube"
YOUTUBE_API_VERSION = "v3"

MISSING_CLIENT_SECRETS_MESSAGE = """
WARNING: Please configure OAuth 2.0

To make this sample run you will need to populate the client_secrets.json file
found at:

   %s

with information from the API Console
https://console.developers.google.com/

For more information about the client_secrets.json file format, please visit:
https://developers.google.com/api-client-library/python/guide/aaa_client_secrets
""" % os.path.abspath(os.path.join(os.path.dirname(__file__),
                                   CLIENT_SECRETS_FILE))

VALID_PRIVACY_STATUSES = ("public", "private", "unlisted")


FOLDER = ""

def get_authenticated_service(args):
    flow = flow_from_clientsecrets(CLIENT_SECRETS_FILE,
    scope=YOUTUBE_UPLOAD_SCOPE,
    message=MISSING_CLIENT_SECRETS_MESSAGE)

    storage = Storage("%s-oauth2.json" % sys.argv[0])
    credentials = storage.get()

    if credentials is None or credentials.invalid:
        credentials = run_flow(flow, storage, args)

    return build(YOUTUBE_API_SERVICE_NAME, YOUTUBE_API_VERSION,
        http=credentials.authorize(httplib2.Http()))


def get_channel_details(youtube, **kwargs):
    return youtube.channels().list(
        part="statistics,snippet,contentDetails",
        **kwargs
    ).execute()

def upload_thumbnail(youtube, video_id, file):
    print("Uploading a thumbanil to video {}".format(video_id))
    youtube.thumbnails().set(videoId=video_id, media_body=MediaFileUpload(file)).execute()

def update_video(youtube, video_id, snippet):
    youtube.videos().update(
        part='snippet',
        body=dict(
            snippet=snippet,
            id=video_id
        )
    ).execute()
    print("video updated")

def getThumbnail(link):
    print("Get thumbnail")
    response = requests.get(link)
    
    file = open("thumbnails/{}_thumbnail.jpeg".format(name), "wb")
    file.write(response.content)
    file.close

def youtube_search(youtube, query, channel_id):
  search_response = youtube.search().list(
    q=query,
    part='id,snippet',
    maxResults=5,
    channelId=channel_id #dont change here
  ).execute()
  
  for search_result in search_response.get('items', []):
    if search_result['id']['kind'] == 'youtube#video':
        if search_result['snippet']['channelTitle'] =="CCTV Camera World" and search_result['snippet']['title'] == query: 
            return search_result['id']['videoId'], search_result["snippet"]
  return False, {}

if __name__ == '__main__':
    try:
        file = open("videos.json")
        data = json.load(file)

        args = Namespace(auth_host_name='localhost', auth_host_port=[8080, 8090], keywords='', logging_level='ERROR', noauth_local_webserver=False)
        youtube = get_authenticated_service(args)
        

        channel_id = "UCZOPeAeKoqYg-2Qi31qew2A" #change here
        
        folder = "/home/ra/nfs/vimeo/unv/" #change here the folder you want to do the script
        for filename in os.listdir(folder):
            if(filename.endswith(".json")):
                file = open(folder + "/" + filename)
                video_data = json.load(file)                
                
                name = video_data['title']
                print("Updating the video " + name)
                # request = dict(body=dict(
                #     snippet=dict(
                #         title = name.replace("T", "P"),
                #         description = video_data["description"],
                #         categoryId="28"
                #     ),
                #     status=dict(
                #         privacyStatus="public" #change the code for privacy
                #     )
                # )
                # )
            
                video_id, snippet = youtube_search(youtube, name.replace("-", " "), channel_id)
                if(video_id == False):
                    print("No results found for this video")
                    continue
                
                
                snippet['description'] = video_data["description"]
                snippet['categoryId'] = "28"
    
                update_video(youtube, video_id, snippet)

                link = video_data["thumbnails"][0]["url"]
                getThumbnail(link)
                
                upload_thumbnail(youtube, video_id, "thumbnails/{}_thumbnail.jpeg".format(name))
                
                data.update({ name :{
                    'description' : video_data['description'],
                    'vimeoId' : video_data['webpage_url'].split("/")[-1],
                    'youtubeId': video_id
                }})
       
    except HttpError as e:
        print( "An HTTP error %d occurred:\n%s" % (e.resp.status, e.content))
    
    with open("videos.json", "w") as jsonFile:
            json.dump(data, jsonFile)
    print("The following data has updated with success: \n {}", str(data))


    # vnc://ihmfwtth.synology.me:5900
    # lally26