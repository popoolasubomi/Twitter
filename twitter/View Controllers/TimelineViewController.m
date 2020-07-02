//
//  TimelineViewController.m
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "TimelineViewController.h"
#import "TweetCell.h"
#import "Tweet.h"
#import "User.h"
#import "APIManager.h"
#import "UIImageView+AFNetworking.h"
#import "ComposeViewController.h"
#import "DetailViewController.h"
#import "ProfileViewController.h"

@interface TimelineViewController () <ComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, TweetCellDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *tweetArray;
@property(nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL isMoreDataLoading;
@property (nonatomic) int count;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchTweets) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    [self fetchTweets];
}

-(void) fetchTweets{
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            self.tweetArray = (NSMutableArray *) tweets;
            [self.tableView reloadData];
        } else {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
        self.isMoreDataLoading = NO;
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    }];
}

- (void) fetchMoreTweets{
    [[APIManager shared] getMoreHomeTimeline: self.count completion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            self.tweetArray = (NSMutableArray *) tweets;
            [self.tableView reloadData];
        } else {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
    }];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    cell.delegate = self;
    Tweet *tweet = self.tweetArray[indexPath.row];
    [cell refreshData:tweet];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweetArray.count;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!self.isMoreDataLoading){
        int scrollViewContentHeight = self.tableView.contentSize.height;
        int scrollOffsetThreshold = scrollViewContentHeight - self.tableView.bounds.size.height;
        if (scrollView.contentOffset.y > scrollOffsetThreshold && self.tableView.isDragging) {
            self.isMoreDataLoading = YES;
            self.count += 20;
            NSLog(@"%d", self.count);
            [self fetchMoreTweets];
        }
    }
}

- (void)didTweet:(nonnull Tweet *)tweet {
    [self.tweetArray insertObject:tweet atIndex:0];
    [self.tableView reloadData];
}

- (IBAction)didTapLogoutButton:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    appDelegate.window.rootViewController = loginViewController;
    [[APIManager shared] logout];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([[segue identifier] isEqualToString:@"composeTweet"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        ComposeViewController *composeController = (ComposeViewController*)navigationController.topViewController;
        composeController.delegate = self;
     }
     else if ([[segue identifier] isEqualToString:@"detailsViewController"]) {
         DetailViewController *detailsPostViewController = [segue destinationViewController];
         UITableViewCell *tappedCell = sender;
         NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
         Tweet *tweet = self.tweetArray[indexPath.row];
         detailsPostViewController.tweet = tweet;
     }
     else if ([[segue identifier] isEqualToString:@"replyTweet"]){
         UINavigationController *navigationController = [segue destinationViewController];
         ComposeViewController *composeViewController = (ComposeViewController*)navigationController.topViewController;
         UITableViewCell *tappedCell = sender;
         NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
         Tweet *tweet = self.tweetArray[indexPath.row];
         composeViewController.replyTweet = tweet;
     }
    else if ([[segue identifier] isEqualToString:@"profileSegue2"]){
        ProfileViewController *profileController = [segue destinationViewController];
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Tweet *tweet = tappedCell;
        profileController.user = sender;
    }
}

- (void)tweetCell:(nonnull TweetCell *)tweetCell didTap:(nonnull User *)user {
    [self performSegueWithIdentifier:@"profileSegue2" sender:user];
}

@end
