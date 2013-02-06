//
//  User.m
//  Gitos-iPad
//
//  Created by Tri Vuong on 1/28/13.
//  Copyright (c) 2013 Crafted By Tri. All rights reserved.
//

#import "User.h"
#import "RelativeDateDescriptor.h"

@implementation User

@synthesize data;

- (id)initWithData:(NSDictionary *)userData
{
    self = [super init];
    self.data = userData;
    return self;
}

- (NSString *)getAvatarUrl
{
    return [self.data valueForKey:@"avatar_url"];
}

- (NSString *)getGistsUrl
{
    NSString *gistsUrl = [self.data valueForKey:@"gists_url"];
    return [gistsUrl stringByReplacingOccurrencesOfString:@"{/gist_id}" withString:@""];
}

- (NSString *)getReceivedEventsUrl
{
    return [self.data valueForKey:@"received_events_url"];
}

- (NSString *)getEventsUrl
{
    NSString *eventsUrl = [self.data valueForKey:@"events_url"];
    return [eventsUrl stringByReplacingOccurrencesOfString:@"{/privary}" withString:@""];
}

- (NSString *)getStarredUrl
{
    NSString *starredUrl = [self.data valueForKey:@"starred_url"];
    return [starredUrl stringByReplacingOccurrencesOfString:@"{/owner}{/repo}" withString:@""];
}

- (NSString *)getFollowingUrl
{
    return [self.data valueForKey:@"following_url"];
}

- (NSString *)getFollowersUrl
{
    return [self.data valueForKey:@"followers_url"];
}

- (NSString *)getReposUrl
{
    return [self.data valueForKey:@"repos_url"];
}

- (NSString *)getLogin
{
    return [self.data valueForKey:@"login"];
}

- (NSString *)getName
{
    return [self.data valueForKey:@"name"];
}

- (NSString *)getLocation
{
    if ([self.data valueForKey:@"location"] == (id)[NSNull null]) return @"n/a";
    return [self.data valueForKey:@"location"];
}

- (NSString *)getWebsite
{
    if ([self.data valueForKey:@"blog"] == (id)[NSNull null]) return @"n/a";
    return [self.data valueForKey:@"blog"];
}

- (NSString *)getEmail
{
    if ([self.data valueForKey:@"email"] == (id)[NSNull null]) return @"n/a";
    return [self.data valueForKey:@"email"];
}

- (NSInteger)getFollowers
{
    return [[self.data valueForKey:@"followers"] integerValue];
}

- (NSInteger)getFollowing
{
    return [[self.data valueForKey:@"following"] integerValue];
}

- (NSString *)getCompany
{
    if ([self.data valueForKey:@"company"] == (id)[NSNull null]) return @"n/a";
    return [self.data valueForKey:@"company"];
}

- (NSInteger)getNumberOfRepos
{
    return [[self.data valueForKey:@"public_repos"] integerValue];
}

- (NSString *)getCreatedAt
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZ"];
    NSDate *date  = [dateFormatter dateFromString:[self.data valueForKey:@"created_at"]];

    RelativeDateDescriptor *relativeDateDescriptor = [[RelativeDateDescriptor alloc] initWithPriorDateDescriptionFormat:@"%@ ago" postDateDescriptionFormat:@"in %@"];

    return [relativeDateDescriptor describeDate:date relativeTo:[NSDate date]];
}

@end
