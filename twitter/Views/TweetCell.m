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

@implementation TweetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}
-(void)refreshData:(Tweet *)tweet{
    self.tweet = tweet;
    self.usernameLabel.text = tweet.user.name;
    self.screennameLabel.text = [NSString stringWithFormat:@"@%@", tweet.user.screenName];
    self.tweetLabel.text = tweet.text;
    self.numLikes.text = [NSString stringWithFormat:@"%d", tweet.favoriteCount];
    self.numRetweets.text = [NSString stringWithFormat:@"%d", tweet.retweetCount];
    self.createdAtLabel.text = tweet.createdAtString;
    [self.profilePicture setImageWithURL: [tweet.user getProfileImage]];
    
    if (self.tweet.favorited) {
        [self.likeButton setImage:[UIImage imageNamed:@"favor-icon-red"] forState:UIControlStateNormal];
        [self.likeButton setSelected:YES];
    } else {
        [self.likeButton setImage:[UIImage imageNamed:@"favor-icon"] forState:UIControlStateNormal];
        [self.likeButton setSelected:NO];
    }
}

- (IBAction)didTapFavorite:(id)sender {
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

@end
