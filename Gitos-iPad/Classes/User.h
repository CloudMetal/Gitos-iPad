//
//  User.h
//  Gitos-iPad
//
//  Created by Tri Vuong on 1/28/13.
//  Copyright (c) 2013 Crafted By Tri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Gist.h"

@interface User : NSObject

@property (nonatomic, strong) NSDictionary *data;

- (id)initWithData:(NSDictionary *)userData;

- (NSString *)getAvatarUrl;
- (NSString *)getGravatarId;
- (NSString *)getGistsUrl;
- (NSString *)getReceivedEventsUrl;
- (NSString *)getEventsUrl;
- (NSString *)getStarredUrl;
- (NSString *)getReposUrl;
- (NSString *)getOrganizationsUrl;
- (NSString *)getSubscriptionsUrl;
- (NSString *)getFollowersUrl;
- (NSString *)getFollowingUrl;
- (NSString *)getLogin;
- (NSString *)getName;
- (NSString *)getLocation;
- (NSString *)getWebsite;
- (NSString *)getEmail;
- (NSInteger)getFollowers;
- (NSInteger)getFollowing;
- (NSString *)getCompany;
- (NSInteger)getNumberOfRepos;
- (NSInteger)getNumberOfGists;
- (NSString *)getCreatedAt;
- (NSString *)getHtmlUrl;
- (BOOL)isEditable;
- (BOOL)isMyself;
- (void)update:(NSDictionary *)updatedInfo;

- (void)fetchNewsFeedForPage:(int)page;
- (void)fetchProfileInfo;
+ (void)fetchInfoForUserWithToken:(NSString *)accessToken;
- (void)fetchRecentActivityForPage:(int)page;
- (void)fetchReposForPage:(int)page;
- (void)fetchStarredReposForPage:(int)page;
- (void)fetchGistsForPage:(int)page;
- (void)fetchRelatedUsersWithUrl:(NSString *)url forPage:(int)page;
- (void)fetchFollowersForPage:(int)page;
- (void)fetchFollowingUsersForPage:(int)page;
- (void)fetchOrganizationsForPage:(int)page;

// Star/Unstar a repo
- (void)starRepo:(Repo *)repo;
- (void)unstarRepo:(Repo *)repo;
- (void)toggleStarringForRepo:(Repo *)repo withMethod:(NSString *)methodName;

// Star/Unstar a gist
- (void)starGist:(Gist *)gist;
- (void)unstarGist:(Gist *)gist;
- (void)toggleStarringForGist:(Gist *)gist withMethod:(NSString *)methodName;

// Fork a gist
- (void)forkGist:(Gist *)gist;

// Follow/Unfollow a user
- (void)checkFollowing:(User *)user;
- (void)followUser:(User *)user;
- (void)unfollowUser:(User *)user;
- (void)toggleFollowingForUser:(User *)user withMethod:(NSString *)methodName;

@end
