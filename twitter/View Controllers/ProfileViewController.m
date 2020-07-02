//
//  ProfileViewController.m
//  twitter
//
//  Created by Ogo-Oluwasobomi Popoola on 7/1/20.
//  Copyright © 2020 Emerson Malca. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileViewCell.h"
#import "APIManager.h"
#import "Tweet.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"

@interface ProfileViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *tweetArray;
@property(nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchTweets) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    [self populateView];
    [self fetchTweets];
    
}

-(void) fetchTweets{
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

-(void) populateView{
    self.usernameLabel.text = self.user.name;
    self.screenLabel.text = self.user.screenName;
    self.numFollowers.text = self.user.followerCount;
    self.numFollowing.text = self.user.followingCount;
    [self.bannerImage setImageWithURL:[self.user getBannerImage]];
    [self.posterIMage setImageWithURL: [self.user getProfileImage]];
}

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ProfileViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileViewCell"];
    Tweet *tweet = self.tweetArray[indexPath.row];
    NSLog(@"%@", tweet.createdAtString);
    cell.tweet = tweet;
    cell.usernameLabel.text = tweet.user.name;
    cell.screennameLabel.text = [NSString stringWithFormat:@"@%@", tweet.user.screenName];
    cell.tweetLabel.text = tweet.text;
    cell.createdAtLabel.text = tweet.createdAtString;
    [cell.profileImage setImageWithURL: [tweet.user getProfileImage]];
    [cell refreshData:tweet];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweetArray.count;
}

@end
