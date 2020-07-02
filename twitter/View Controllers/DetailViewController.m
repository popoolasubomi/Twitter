//
//  DetailViewController.m
//  twitter
//
//  Created by Ogo-Oluwasobomi Popoola on 7/1/20.
//  Copyright © 2020 Emerson Malca. All rights reserved.
//

#import "DetailViewController.h"
#import "Tweet.h"
#import "UIImageView+AFNetworking.h"
#import "User.h"
#import "APIManager.h"
#import "ComposeViewController.h"
#import "ProfileViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self populateViewController];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation

}
*/
-(void) populateViewController{
    self.usernameLabel.text = self.tweet.user.name;
    self.screennameLabel.text = [NSString stringWithFormat:@"@%@", self.tweet.user.screenName];
    self.tweetLabel.text = self.tweet.text;
    self.numLikes.text = [NSString stringWithFormat:@"%d", self.tweet.favoriteCount];
    self.numRetweets.text = [NSString stringWithFormat:@"%d", self.tweet.retweetCount];
    self.createdAtLabel.text = self.tweet.createdAtString;
    [self.posterView setImageWithURL: [self.tweet.user getProfileImage]];
    
    if (self.tweet.favorited) {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favor-icon-red"] forState:UIControlStateNormal];
        [self.favoriteButton setSelected:YES];
    } else {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favor-icon"] forState:UIControlStateNormal];
        [self.favoriteButton setSelected:NO];
    }
    
    if (self.tweet.retweeted) {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet-icon-green"] forState:UIControlStateNormal];
        [self.retweetButton setSelected:YES];
    } else {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet-icon"] forState:UIControlStateNormal];
        [self.retweetButton setSelected:NO];
    }
}

- (IBAction)retweetButton:(id)sender {
    if (self.tweet.retweeted) {
        [sender setImage:[UIImage imageNamed:@"retweet-icon"] forState:UIControlStateNormal];
        self.tweet.retweetCount -= 1;
        self.tweet.retweeted = NO;
        self.numRetweets.text = [NSString stringWithFormat:@"%d",self.tweet.retweetCount];
        [[APIManager shared] unRetweet:self.tweet completion:^(Tweet *modifiedTweet, NSError *error) {
            if(error != nil) {
                [sender setImage:[UIImage imageNamed:@"retweet-icon-green"] forState:UIControlStateNormal];
                NSLog(@"Error retweeting tweet: %@", error.localizedDescription);
            } else {
                NSLog(@"Successfully unretweeted tweet: %@", self.tweet.text);
            }
        }];
    } else {
        [sender setImage:[UIImage imageNamed:@"retweet-icon-green"] forState:UIControlStateNormal];
        self.tweet.retweetCount += 1;
         self.tweet.retweeted = YES;
        self.numRetweets.text = [NSString stringWithFormat:@"%d",self.tweet.retweetCount];
        [[APIManager shared] retweet:self.tweet completion:^(Tweet *modifiedTweet, NSError *error) {
            if(error != nil) {
                [sender setImage:[UIImage imageNamed:@"retweet-icon"] forState:UIControlStateNormal];
                NSLog(@"Error unretweeting tweet: %@", error.localizedDescription);
            } else {
                 NSLog(@"Successfully unretweeted tweet: %@", self.tweet.text);
            }
        }];
    }
}
- (IBAction)favoriteButton:(id)sender {
    if (self.tweet.favorited) {
        [sender setImage:[UIImage imageNamed:@"favor-icon"] forState:UIControlStateNormal];
        self.tweet.favoriteCount -= 1;
        self.tweet.favorited = NO;
        self.numLikes.text = [NSString stringWithFormat:@"%d",self.tweet.favoriteCount];
        [[APIManager shared] unFavorite: self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                [sender setImage:[UIImage imageNamed:@"favor-icon-red"] forState:UIControlStateNormal];
                NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
            }
            else{
                NSLog(@"Successfully unfavorited the following Tweet: %@", tweet.text);
                self.tweet = tweet;
            }
        }];
    } else {
        [sender setImage:[UIImage imageNamed:@"favor-icon-red"] forState:UIControlStateNormal];
        self.tweet.favoriteCount += 1;
        self.tweet.favorited = YES;
        self.numLikes.text = [NSString stringWithFormat:@"%d",self.tweet.favoriteCount];
        [[APIManager shared] favorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                [sender setImage:[UIImage imageNamed:@"favor-icon"] forState:UIControlStateNormal];
                NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
            }
            else{
                NSLog(@"Successfully favorited the following Tweet: %@", tweet.text);
                self.tweet = tweet;
            }
        }];
    }
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"replyTweet1"]){
        UINavigationController *navigationController = [segue destinationViewController];
        ComposeViewController *composeViewController = (ComposeViewController*)navigationController.topViewController;
        composeViewController.replyTweet = self.tweet;
        NSLog(@"Working");
    }
    else if ([[segue identifier] isEqualToString:@"profileSegue"]){
        ProfileViewController *profileController = [segue destinationViewController];
        profileController.user = self.tweet.user;
    }
}

@end
