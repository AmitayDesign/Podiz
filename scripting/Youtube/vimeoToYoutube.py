from argparse import Namespace
import config
import json
import requests

#vimeo downloader
import vimeo 
from bs4 import BeautifulSoup as soup #to scrape
import requests #to scrape
import urllib.request #to download
import re #to get a specific string in the HTML code

#youtube
import httplib2
import os
import random
import sys
import time

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

def initialize_upload(youtube, options):
  tags = None
  if options.keywords:
    tags = options.keywords.split(",")

  body=dict(
    snippet=dict(
      title=options.title,
      description=options.description,
      tags=tags,
      categoryId=options.category
    ),
    status=dict(
      privacyStatus=options.privacyStatus
    )
  )

  insert_request = youtube.videos().insert(
    part=",".join(body.keys()),
    body=body,
    media_body=MediaFileUpload(options.file, chunksize=-1, resumable=True)
  )

  resumable_upload(insert_request, youtube, options.thumbnail)

def resumable_upload(insert_request, youtube, file):
  response = None
  error = None
  retry = 0
  while response is None:
    try:
      print( "Uploading file...")
      status, response = insert_request.next_chunk()
      if response is not None:
        if 'id' in response:
          print( "Video id '%s' was successfully uploaded." % response['id'])
          upload_thumbnail(youtube, response['id'], file)
        else:
          exit("The upload failed with an unexpected response: %s" % response)
    except HttpError as e:
      if e.resp.status in RETRIABLE_STATUS_CODES:
        error = "A retriable HTTP error %d occurred:\n%s" % (e.resp.status,
                                                             e.content)
      else:
        raise
    except RETRIABLE_EXCEPTIONS as e:
      error = "A retriable error occurred: %s" % e

    if error is not None:
      print(error)
      retry += 1
      if retry > MAX_RETRIES:
        exit("No longer attempting to retry.")

      max_sleep = 2 ** retry
      sleep_seconds = random.random() * max_sleep
      print( "Sleeping %f seconds and then retrying..." % sleep_seconds)
      time.sleep(sleep_seconds)

def changePrivacy(client, id):
    print("Changing the privacy of a video")
    response = client.patch("https://api.vimeo.com/videos/"+ id, data = {'privacy' : { 'view' :"anybody" }})
    print(response)
    response = client.get("https://api.vimeo.com/videos/" + id)
    print(response)
    
    direct_link = 'https://player.vimeo.com/video/' + id
    HEADERS = {
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101 Firefox/78.0",
    }
    
    result = requests.get(direct_link, headers=HEADERS)
    
    bs = soup(result.content, 'html.parser')
    bs = str(bs)

    vod = re.findall(".*\"url\":\"https://vod-progressive(.*)\.mp4\",.*", bs)
    
    return vod    

def getThumbnail(client, id, picture_id, name):
    print("getting thumbnail")
    response = client.get("https://api.vimeo.com/videos/"+ id +"/pictures/" + picture_id)
    
    response = requests.get(response.json()['base_link'])
    
    file = open("{}_thumbnail.jpeg".format(name), "wb")
    file.write(response.content)
    file.close
  

def upload_thumbnail(youtube, video_id, file):
    print("Uploading a thumbanil to video {}".format(video_id))
    youtube.thumbnails().set(videoId=video_id, media_body=file).execute()

if __name__ == '__main__':
    #https://api.vimeo.com/me/videos
    client = vimeo.VimeoClient(
        token = config.ACCESS_TOKEN,
        key = config.CLIENT_ID,
        secret = config.CLIENT_SECRET
    )
    response = client.get('https://api.vimeo.com/me/videos')
    
    totalcount = 0
    count = 0
    i = 1
    total = len(response.json()['data'])
    
    statiscs = {
        "public" : 0,
        "unlisted" : 0
        #"private" : 0,
    }

    file = open("videos.json")
    data = json.load(file)
    
    for video in response.json()['data']:
        if totalcount == 2:
            break
        totalcount += 1
        if(video['name'] in data):
            print('File already uploaded...')
            continue
        
        if(len(video['categories']) != 0 and video['categories'][0] == "Howto & Style"):
            category = '26'
        else:
            category = '28'

        if video['privacy']['view'] == "anybody":
            privacy = "public"
        else:
            privacy = "unlisted"
    

        print("File number {} of {}".format(i, total))
        print("Downloading file from Vimeo")

        id = video['uri'].split("/")[-1]
        picture_id = video['pictures']['uri'].split("/")[-1]
        
        thumbnail = getThumbnail(client, id, picture_id, video['name'])
        print(thumbnail)
        
        direct_link = 'https://player.vimeo.com/video/' + id
        HEADERS = {
            "User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101 Firefox/78.0",
        }

        result = requests.get(direct_link, headers=HEADERS)
        
        bs = soup(result.content, 'html.parser')
        bs = str(bs)

        vod = re.findall(".*\"url\":\"https://vod-progressive(.*)\.mp4\",.*", bs)
        
        if len(vod) == 0:
            vod = changePrivacy(client, id)
            if len(vod) == 0:
                count += 1
                print("Not possible to download this video " + video['name'])
                continue

        vod = vod[0]
        
        mp4 = 'https://vod-progressive' + vod + '.mp4'
      
        
        name = video['name']
        folder =  name +".mp4"
        urllib.request.urlretrieve(mp4, folder)
        
        print("Uploading to Youtube")
        args = Namespace(auth_host_name='localhost', auth_host_port=[8080, 8090], category=category, description=video['description'], file=folder, thumbnail="{}_thumbnail.jpeg".format(video['name']), keywords='', logging_level='ERROR', noauth_local_webserver=False, privacyStatus=privacy, title=name)
        youtube = get_authenticated_service(args)
        
        try:
            initialize_upload(youtube, args)

            data.update({ video['name']:{
               'date' : video['created_time'],
               'description' : video['description'],
               'category' : category,
               'privacy' : privacy
            }})
            statiscs[privacy] += 1
            # totalcount += 1

        except HttpError as e:
            print( "An HTTP error %d occurred:\n%s" % (e.resp.status, e.content) )
            count += 1
        i += 1
    
    with open("videos.json", "w") as jsonFile:
        json.dump(data, jsonFile)
    print(statiscs)
    print("Couldn't upload {} videos".format(count))