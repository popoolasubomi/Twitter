//
//  MyProfileViewController.h
//  twitter
//
//  Created by Ogo-Oluwasobomi Popoola on 7/2/20.
//  Copyright © 2020 Emerson Malca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Tweet.h"

NS_ASSUME_NONNULL_BEGIN

@interface MyProfileViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *tweetArray;
@property (nonatomic, strong) User *user;

@property (weak, nonatomic) IBOutlet UIImageView *bannerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *screennameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numFollowers;
@property (weak, nonatomic) IBOutlet UILabel *numFollowing;

@end

NS_ASSUME_NONNULL_END
