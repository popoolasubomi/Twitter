//
//  TweetCell.m
//  twitter
//
//  Created by Ogo-Oluwasobomi Popoola on 6/29/20.
//  Copyright © 2020 Emerson Malca. All rights reserved.
//

#import "TweetCell.h"
#import "Tweet.h"
#import "User.h"
#import "APIManager.h"
#import "UIImageView+AFNetworking.h"

static NSString * const redHeartImage = @"favor-icon-red";
static NSString * const heartImage = @"favor-icon";
static NSString * const greenRetweetImage = @"retweet-icon-green";
static NSString * const retweetImage = @"retweet-icon";

@implementation TweetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    [self.profilePicture addGestureRecognizer: profileTapGestureRecognizer];
    [self.profilePicture setUserInteractionEnabled:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void) didTapUserProfile:(UITapGestureRecognizer *)sender{
    [self.delegate tweetCell:self didTap:self.tweet.user];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result {
    NSString* textClicked = [label.text substringWithRange:result.range];
    NSURL* urlClicked = result.URL;
    UIApplication *application = [UIApplication sharedApplication];
    [application openURL:urlClicked options:@{} completionHandler:nil];
}

-(void)refreshData:(Tweet *)tweet{
    self.tweet = tweet;
    
    self.tweetLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    self.tweetLabel.delegate = self;
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:self.tweet.text];
    self.tweetLabel.attributedText = string;
    self.tweetLabel.text = self.tweet.text;
    
    self.usernameLabel.text = tweet.user.name;
    self.screennameLabel.text = [NSString stringWithFormat:@"@%@", tweet.user.screenName];
    self.numLikes.text = [NSString stringWithFormat:@"%d", tweet.favoriteCount];
    self.numRetweets.text = [NSString stringWithFormat:@"%d", tweet.retweetCount];
    self.createdAtLabel.text = tweet.createdAtString;
    [self.profilePicture setImageWithURL: [tweet.user getProfileImage]];
    [self updateButton];
}

- (void) updateButton{
    if (self.tweet.favorited) {
        [self.likeButton setImage:[UIImage imageNamed: redHeartImage] forState:UIControlStateNormal];
        [self.likeButton setSelected:YES];
    } else {
        [self.likeButton setImage:[UIImage imageNamed: heartImage] forState:UIControlStateNormal];
        [self.likeButton setSelected:NO];
    }
    
    if (self.tweet.retweeted) {
        [self.retweetButton setImage:[UIImage imageNamed: greenRetweetImage] forState:UIControlStateNormal];
        [self.retweetButton setSelected:YES];
    } else {
        [self.retweetButton setImage:[UIImage imageNamed: retweetImage] forState:UIControlStateNormal];
        [self.retweetButton setSelected:NO];
    }
}

- (IBAction)didTapFavorite:(id)sender {
    if (self.tweet.favorited) {
        self.tweet.favoriteCount -= 1;
        self.tweet.favorited = NO;
        self.numLikes.text = [NSString stringWithFormat:@"%d",self.tweet.favoriteCount];
        [[APIManager shared] unFavorite: self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                self.tweet.favorited = YES;
                NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
            }
            else{
                NSLog(@"Successfully unfavorited the following Tweet: %@", tweet.text);
                self.tweet = tweet;
            }
        }];
    } else {
        self.tweet.favoriteCount += 1;
        self.tweet.favorited = YES;
        self.numLikes.text = [NSString stringWithFormat:@"%d",self.tweet.favoriteCount];
        [[APIManager shared] favorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                self.tweet.favorited = NO;
                NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
            }
            else{
                NSLog(@"Successfully favorited the following Tweet: %@", tweet.text);
                self.tweet = tweet;
            }
        }];
    }
    [self updateButton];
}

- (IBAction)didTapRetweet:(id)sender {
    if (self.tweet.retweeted) {
        self.tweet.retweetCount -= 1;
        self.tweet.retweeted = NO;
        self.numRetweets.text = [NSString stringWithFormat:@"%d",self.tweet.retweetCount];
        [[APIManager shared] unRetweet:self.tweet completion:^(Tweet *modifiedTweet, NSError *error) {
            if(error != nil) {
                self.tweet.retweeted = YES;
                NSLog(@"Error retweeting tweet: %@", error.localizedDescription);
            } else {
                NSLog(@"Successfully unretweeted tweet: %@", self.tweet.text);
            }
        }];
    } else {
        self.tweet.retweetCount += 1;
        self.tweet.retweeted = YES;
        self.numRetweets.text = [NSString stringWithFormat:@"%d",self.tweet.retweetCount];
        [[APIManager shared] retweet:self.tweet completion:^(Tweet *modifiedTweet, NSError *error) {
            if(error != nil) {
                self.tweet.retweeted = NO;
                NSLog(@"Error unretweeting tweet: %@", error.localizedDescription);
            } else {
                 NSLog(@"Successfully unretweeted tweet: %@", self.tweet.text);
            }
        }];
    }
    [self updateButton];
}

@end
