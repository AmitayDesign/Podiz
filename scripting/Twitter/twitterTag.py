from sklearn import config_context
import config
import tweepy

API_KEYS = ["30yaF6u5hCQYWqWsGTVvTVk7h", ]
SECRET_API_KEYS = ["OEDhW1bwqM2yjpxOxawSK03JkpyuDSxQkY8T5UzCxIuSQl3cV3", ]

ACCESS_TOKENS = ["1515448385695891463-PeOfwaIBPQNqExkfRgIA51l1L3QjjX",]
SECRET_ACCESS_TOKENS = ["tXa2xygOvXVYYDa8jRjQlninQYrTvlOCcT9gmIiQXyd1X", ]

class Twitter:
    def __init__(self, index):
        auth = tweepy.OAuthHandler(API_KEYS[index], SECRET_API_KEYS[index])
        auth.set_access_token(ACCESS_TOKENS[index], SECRET_ACCESS_TOKENS[index])

        self.client = tweepy.API(auth)

    def search_tweets_by_hashtag(self, tag):
        
        limit = 300
        tweets = self.client.user_timeline(screen_name="veritasium", count=limit, tweet_mode="extended")
        #tweets = tweepy.Cursor(self.client.search_tweets, q=tag, count=100, tweet_mode="extended").items(limit)
        return tweets

    def make_comment(self, tweet_id, comment):
        self.client.create_tweet(in_reply_to_tweet_id=tweet_id, text=comment)



hashtag = "#2022"
for i in range(config.NUMBER):

    client = Twitter(i)

    response = client.search_tweets_by_hashtag(hashtag)
    print(response)
    for res in response:
        print(res)
        #client.make_comment("What you want to comment")
