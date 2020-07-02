//
//  User.h
//  twitter
//
//  Created by Ogo-Oluwasobomi Popoola on 6/29/20.
//  Copyright © 2020 Emerson Malca. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *screenName;
@property (nonatomic, strong) NSString *profileImageUrl;
@property (nonatomic, strong) NSString *followerCount;
@property (nonatomic, strong) NSString *followingCount;
@property (nonatomic, strong) NSString *profileBannerUrl;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
-(NSURL *)getProfileImage;
-(NSURL *)getBannerImage;
@end

NS_ASSUME_NONNULL_END
