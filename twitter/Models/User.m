//
//  User.m
//  twitter
//
//  Created by Ogo-Oluwasobomi Popoola on 6/29/20.
//  Copyright © 2020 Emerson Malca. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.name = dictionary[@"name"];
        self.screenName = dictionary[@"screen_name"];
        self.profileImageUrl = dictionary[@"profile_image_url_https"];
        self.followerCount = [NSString stringWithFormat: @"%@", dictionary[@"followers_count"]];
        self.followingCount = [NSString stringWithFormat:@"%@", dictionary[@"friends_count"]];
        self.profileBannerUrl = dictionary[@"profile_banner_url"];
    }
    return self;
}

-(NSURL *)getProfileImage{
    NSString *urlString = [self.profileImageUrl stringByReplacingOccurrencesOfString:@"normal.jpg" withString:@"bigger.jpg"];
    return [NSURL URLWithString: urlString];
}

-(NSURL *)getBannerImage{
    return [NSURL URLWithString: self.profileBannerUrl];
}

@end
