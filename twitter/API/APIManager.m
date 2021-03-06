//
//  APIManager.m
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "APIManager.h"
#import "Tweet.h"

static NSString * const baseURLString = @"https://api.twitter.com";
static NSString * const consumerKey = @"5lUJuO5AUpPUCez4ewYDFrtgh";
static NSString * const consumerSecret = @"s5ynGqXzstUZwFPxVyMDkYh197qvHOcVM3kwv1o2TKhS1avCdS";

@interface APIManager()

@end

@implementation APIManager

+ (instancetype)shared {
    static APIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    
    NSURL *baseURL = [NSURL URLWithString:baseURLString];
    NSString *key = consumerKey;
    NSString *secret = consumerSecret;
    // Check for launch arguments override
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-key"]) {
        key = [[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-key"];
    }
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-secret"]) {
        secret = [[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-secret"];
    }
    
    self = [super initWithBaseURL:baseURL consumerKey:key consumerSecret:secret];
    if (self) {
        
    }
    return self;
}

- (void)getHomeTimelineWithCompletion:(void(^)(NSArray *tweets, NSError *error))completion {
    [self GET:@"1.1/statuses/home_timeline.json"
   parameters:nil progress: nil success:^(NSURLSessionDataTask * _Nonnull task, NSArray *  _Nullable tweetDictionaries) {
        // Success
        NSMutableArray *tweets  = [Tweet tweetsWithArray:tweetDictionaries];
        completion(tweets, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // There was a problem
        completion(nil, error);
    }];
}

-(void)getMoreHomeTimeline:(int *) count completion:(void (^)(NSArray *tweets, NSError *))completion{
    NSString *countValue = [NSString stringWithFormat:@"%d", count];
    NSDictionary *queryDictionary = @{@"count": countValue};
    [self GET:@"1.1/statuses/home_timeline.json"
    parameters: queryDictionary progress: nil success:^(NSURLSessionDataTask * _Nonnull task, NSArray *  _Nullable tweetDictionaries) {
         // Success
         NSMutableArray *tweets  = [Tweet tweetsWithArray:tweetDictionaries];
         completion(tweets, nil);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         // There was a problem
         completion(nil, error);
     }];
}

- (void)getUserHomeTimelineWithCompletion:(void(^)(User *user, NSArray *tweets, NSError *error))completion {
    [self GET:@"1.1/statuses/user_timeline.json"
   parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSArray *  _Nullable tweetDictionaries) {
       NSData *data = [NSKeyedArchiver archivedDataWithRootObject:tweetDictionaries];
       [[NSUserDefaults standardUserDefaults] setValue:data forKey:@"othertimeline_tweets"];
       NSMutableArray *tweets  = [Tweet tweetsWithArray:tweetDictionaries];
       completion(nil, tweets, nil);
   }
      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       NSArray *tweetDictionaries = nil;
       // Fetch tweets from cache if possible
       NSData *data = [[NSUserDefaults standardUserDefaults] valueForKey:@"othertimeline_tweets"];
       if (data != nil) {
           tweetDictionaries = [NSKeyedUnarchiver unarchiveObjectWithData:data];
           NSMutableArray *tweets  = [Tweet tweetsWithArray:tweetDictionaries];
           completion(nil, tweets, error);
       } else {
           completion(nil, error, nil);
       }
   }];
}

- (void)getUserProfile:(void(^)(User *user, NSError *error))completion{
    [self GET:@"1.1/account/verify_credentials.json" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable userObject) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:userObject];
        [[NSUserDefaults standardUserDefaults] setValue:data forKey:@"user_info"];
        User *user  = [[User alloc] initWithDictionary:userObject];
        completion(user, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Didn't get user");
    }];
}

- (void)postStatusWithText:(NSString *)text replyID:(nullable NSNumber *)replyToTweetID completion:(void (^)(Tweet *, NSError *))completion{
    NSString *urlString = @"1.1/statuses/update.json";
    NSDictionary *parameters = [[NSDictionary alloc] init];
    if (replyToTweetID == nil) {
       parameters = @{@"status": text};
    } else {
       parameters = @{@"status": text, @"in_reply_to_status_id": replyToTweetID};
    }
    [self POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable tweetDictionary) {
        Tweet *tweet = [[Tweet alloc]initWithDictionary:tweetDictionary];
        completion(tweet, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)favorite:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion{
    NSString *urlString = @"1.1/favorites/create.json";
    NSDictionary *parameters = @{@"id": tweet.idStr};
    [self POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable tweetDictionary) {
        Tweet *tweet = [[Tweet alloc]initWithDictionary:tweetDictionary];
        completion(tweet, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)unFavorite:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion{
    NSString *urlString = @"1.1/favorites/destroy.json";
    NSDictionary *parameters = @{@"id": tweet.idStr};
    [self POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable tweetDictionary) {
        Tweet *tweet = [[Tweet alloc]initWithDictionary:tweetDictionary];
        completion(tweet, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)retweet:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion{
    NSString *urlString = @"1.1/statuses/retweet/";
    urlString = [urlString stringByAppendingString: tweet.idStr];
    urlString = [urlString stringByAppendingString:@".json"];
    
    NSDictionary *parameters = @{@"id": tweet.idStr};
    [self POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable actionDetailsDictionary) {
        tweet.retweetCount++;
        tweet.retweeted = true;
        completion(tweet, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)unRetweet:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion{
    NSString *urlString = @"1.1/statuses/unretweet/";
    urlString = [urlString stringByAppendingString: tweet.idStr];
    urlString = [urlString stringByAppendingString:@".json"];
    
    NSDictionary *parameters = @{@"id": tweet.idStr};
    [self POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable actionDetailsDictionary) {
        tweet.retweetCount--;
        tweet.retweeted = false;
        completion(tweet, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

@end
