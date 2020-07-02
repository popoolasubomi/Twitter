//
//  ProfileViewCell.m
//  twitter
//
//  Created by Ogo-Oluwasobomi Popoola on 7/1/20.
//  Copyright © 2020 Emerson Malca. All rights reserved.
//

#import "ProfileViewCell.h"
#import "TweetCell.h"
#import "Tweet.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"
@implementation ProfileViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)refreshData:(Tweet *)tweet{
    self.tweet = tweet;
    self.usernameLabel.text = tweet.user.name;
    self.screennameLabel.text = [NSString stringWithFormat:@"@%@", tweet.user.screenName];
    self.tweetLabel.text = tweet.text;
    self.createdAtLabel.text = tweet.createdAtString;
    [self.profileImage setImageWithURL: [tweet.user getProfileImage]];
}

@end
