//
//  ComposeViewController.m
//  twitter
//
//  Created by Ogo-Oluwasobomi Popoola on 6/29/20.
//  Copyright © 2020 Emerson Malca. All rights reserved.
//

#import "ComposeViewController.h"
#import "APIManager.h"

@interface ComposeViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textField;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)tweetButton:(id)sender {
    NSString *tweetText = self.textField.text;
    if (self.replyTweet) {
        NSString *repliedToUser = @" @";
        repliedToUser = [repliedToUser stringByAppendingString:self.replyTweet.user.screenName]; // @mbatilando
        tweetText = [tweetText stringByAppendingString: repliedToUser];
    }
    NSNumberFormatter *myId = [[NSNumberFormatter alloc] init];
    myId.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *myFinalID = [myId numberFromString:self.replyTweet.idStr];
    [[APIManager shared]postStatusWithText: tweetText replyID: myFinalID completion:^(Tweet *tweet, NSError *error) {
        if(error) {
            NSLog(@"Error composing Tweet: %@", error.localizedDescription);
        } else {
            [self.delegate didTweet:tweet];
            [self dismissViewControllerAnimated: YES completion:nil];
            NSLog(@"Compose Tweet Success!");
        }
    }];
}

- (IBAction)closeButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onTapScreen:(id)sender {
    [self.view endEditing:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
