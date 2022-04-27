import tweepy
import config

class Twitter:
    def __init__(self):
        self.client = tweepy.Client(
            consumer_key=config.api_key,
            consumer_secret=config.api_secret_key,
            access_token=config.access_token,
            access_token_secret=config.secret_access_token,
            bearer_token=config.bearer)
    
    def search_recent_tweets(self, query):
        response = self.client.search_recent_tweets(query)
        return response.data

    def make_comment(self, tweet_id, comment):
        self.client.create_tweet(in_reply_to_tweet_id=tweet_id, text=comment)

    def make_tweet(self, tweet):
        self.client.create_tweet(text=tweet)