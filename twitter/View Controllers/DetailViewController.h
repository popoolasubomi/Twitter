//
//  DetailViewController.h
//  twitter
//
//  Created by Ogo-Oluwasobomi Popoola on 7/1/20.
//  Copyright © 2020 Emerson Malca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"
#import "TTTAttributedLabel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailViewController : UIViewController <TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screennameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *numRetweets;
@property (weak, nonatomic) IBOutlet UILabel *numLikes;

@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;

@property (nonatomic, strong) Tweet *tweet;
@end

NS_ASSUME_NONNULL_END
