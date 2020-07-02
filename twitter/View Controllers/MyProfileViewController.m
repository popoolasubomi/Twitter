//
//  MyProfileViewController.m
//  twitter
//
//  Created by Ogo-Oluwasobomi Popoola on 7/2/20.
//  Copyright © 2020 Emerson Malca. All rights reserved.
//

#import "MyProfileViewController.h"
#import "APIManager.h"
#import "TweetCell.h"
#import "Tweet.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"
#import "AppDelegate.h"
#import "LoginViewController.h"

@interface MyProfileViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MyProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self populateViewController];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchTweets) forControlEvents:UIControlEventValueChanged];
    
    [self fetchTweets];
}

- (IBAction)logoutButton:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    appDelegate.window.rootViewController = loginViewController;
    [[APIManager shared] logout];
}

- (void) populateViewController{
    [[APIManager shared] getUserProfile:^(User *user, NSError *error) {
        if (user) {
            self.user = (User *)user;
            [self.profileImageView setImageWithURL: [self.user getProfileImage]];
            self.profileImageView.layer.cornerRadius = 40;
            self.profileImageView.layer.masksToBounds = YES;
            [self.bannerImageView setImageWithURL: [self.user getBannerImage]];
            self.usernameLabel.text = self.user.name;
            self.screennameLabel.text = [NSString stringWithFormat:@"@%@", self.user.screenName];
            self.numFollowers.text = [NSString stringWithFormat:@"%@",self.user.followerCount];
            self.numFollowing.text = [NSString stringWithFormat:@"%@",self.user.followingCount];
        } else {
            NSLog(@"error getting user: %@", error.localizedDescription);
        }
    }];
}
     
- (void) fetchTweets{
    [[APIManager shared] getUserHomeTimelineWithCompletion:^(User *user, NSArray *tweets, NSError *error) {
        if (tweets) {
            self.tweetArray = (NSMutableArray *) tweets;
            [self.tableView reloadData];
        } else {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
       [self.refreshControl endRefreshing];
       [self.tableView reloadData];
    }];
 }

     
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    Tweet *tweet = self.tweetArray[indexPath.row];
    [cell refreshData:tweet];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweetArray.count;
}

@end
