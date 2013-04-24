//
//  TimelineEvent.m
//  Gitos-iPad
//
//  Created by Tri Vuong on 1/28/13.
//  Copyright (c) 2013 Crafted By Tri. All rights reserved.
//

#import "TimelineEvent.h"
#import "ForkEvent.h"
#import "WatchEvent.h"
#import "CreateEvent.h"
#import "DeleteEvent.h"
#import "FollowEvent.h"
#import "GistEvent.h"
#import "IssuesEvent.h"
#import "IssueCommentEvent.h"
#import "MemberEvent.h"
#import "PushEvent.h"
#import "PullRequestEvent.h"
#import "PublicEvent.h"
#import "CommitCommentEvent.h"
#import "GollumEvent.h"

@implementation TimelineEvent

- (id)initWithData:(NSDictionary *)eventData
{
    self = [super init];
    self.data = eventData;
    self.relativeDateDescriptor = [[RelativeDateDescriptor alloc] initWithPriorDateDescriptionFormat:@"%@ ago" postDateDescriptionFormat:@"in %@"];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZ"];
    self.fontAwesomeIcons = @{
        @"ForkEvent"          : @"icon-random",
        @"WatchEvent"         : @"icon-star",
        @"CreateEvent"        : @"icon-plus",
        @"FollowEvent"        : @"icon-user",
        @"GistEvent"          : @"icon-file-alt",
        @"IssuesEvent"        : @"icon-warning-sign",
        @"MemberEvent"        : @"icon-user-md",
        @"IssueCommentEvent"  : @"icon-comment-alt",
        @"PushEvent"          : @"icon-upload",
        @"PullRequestEvent"   : @"icon-retweet",
        @"PublicEvent"        : @"icon-folder-open-alt",
        @"CommitCommentEvent" : @"icon-comments",
        @"GollumnEvent"       : @"icon-book"
    };
    return self;
}

- (NSString *)getId
{
    return [self.data valueForKey:@"id"];
}

- (NSDictionary *)getPayload
{
    return [self.data valueForKey:@"payload"];
}

- (NSDictionary *)getTarget
{
    NSDictionary *payload = [self getPayload];
    return [payload valueForKey:@"target"];
}

- (NSString *)getType
{
    return [self.data valueForKey:@"type"];
}

- (User *)getActor
{
    return [[User alloc] initWithData:[self.data valueForKey:@"actor"]];
}

- (Repo *)getRepo
{
    return [[Repo alloc] initWithData:[self.data valueForKey:@"repo"]];
}

- (NSMutableAttributedString *)toString
{
    return [[NSMutableAttributedString alloc] initWithString:@""];
}

- (NSMutableAttributedString *)toActorRepoString:(NSString *)actionName
{
    User *actor = [self getActor];
    Repo *repo = [self getRepo];

    NSMutableAttributedString *actorLogin = [self decorateEmphasizedText:[actor getLogin]];

    NSMutableAttributedString *repoName = [self decorateEmphasizedText:[repo getName]];

    NSMutableAttributedString *action = [self toAttributedString:[NSString stringWithFormat:@" %@ ", actionName]];

    [actorLogin insertAttributedString:action atIndex:actorLogin.length];
    [actorLogin insertAttributedString:repoName atIndex:actorLogin.length];
    return actorLogin;
}

- (NSString *)toActorRepoHTMLString:(NSString *)actionName
{
    User *actor = [self getActor];
    Repo *repo = [self getRepo];

    NSString *eventActorPath = [[NSBundle mainBundle] pathForResource:@"eventActor" ofType:@"html"];

    NSString *actorHTML = [NSString stringWithContentsOfFile:eventActorPath
                                                    encoding:NSUTF8StringEncoding error:nil];

    NSString *eventActionPath = [[NSBundle mainBundle] pathForResource:@"eventAction" ofType:@"html"];

    NSString *actionHTML = [NSString stringWithContentsOfFile:eventActionPath
                                                     encoding:NSUTF8StringEncoding error:nil];

    NSString *actoHTMLString = [NSString stringWithFormat:actorHTML, [actor getAvatarUrl], [actor getLogin]];
    NSString *repoHTMLString = [NSString stringWithFormat:actorHTML, GITHUB_OCTOCAT, [repo getName]];
    NSString *actionHTMLString = [NSString stringWithFormat:actionHTML, actionName];

    NSArray *strings = @[actoHTMLString, actionHTMLString, repoHTMLString];

    return [strings componentsJoinedByString:@""];
}

- (NSString *)getFontAwesomeIcon
{
    return [self.fontAwesomeIcons valueForKey:[self getType]];
}

- (NSString *)convertToRelativeDate:(NSString *)originalDateString
{
    NSDate *date  = [self.dateFormatter dateFromString:originalDateString];
    return [self.relativeDateDescriptor describeDate:date relativeTo:[NSDate date]];
}

- (NSString *)toDateString
{
    return [self convertToRelativeDate:[self.data valueForKey:@"created_at"]];
}

- (NSMutableAttributedString *)decorateEmphasizedText:(NSString *)rawString
{
    NSMutableAttributedString *decoratedString = [[NSMutableAttributedString alloc] initWithString:rawString];
    [decoratedString setAttributes:@{
               NSFontAttributeName:[UIFont fontWithName:@"Arial-BoldMT" size:13.0],
     NSForegroundColorAttributeName:[UIColor colorWithRed:63/255.0 green:114/255.0 blue:155/255.0 alpha:1.0]
     } range:NSMakeRange(0, decoratedString.length)];

    return decoratedString;
}

- (NSMutableAttributedString *)toAttributedString:(NSString *)rawString
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:rawString];
    [attributedString setAttributes:@{
                NSFontAttributeName:[UIFont fontWithName:@"Arial" size:13.0]
     } range:NSMakeRange(0, attributedString.length)];
    return attributedString;
}

- (NSString *)toHTMLStringForObject1WithName:(NSString *)name1 AndAvatar1:(NSString *)avatar1 Object2:(NSString *)name2 AndAvatar2:(NSString *)avatar2 andAction:(NSString *)actionName
{
    NSString *eventActorPath = [[NSBundle mainBundle] pathForResource:@"eventActor" ofType:@"html"];

    NSString *actorHTML = [NSString stringWithContentsOfFile:eventActorPath
                                                    encoding:NSUTF8StringEncoding error:nil];

    NSString *eventActionPath = [[NSBundle mainBundle] pathForResource:@"eventAction" ofType:@"html"];

    NSString *actionHTML = [NSString stringWithContentsOfFile:eventActionPath
                                                     encoding:NSUTF8StringEncoding error:nil];

    NSString *actoHTMLString = [NSString stringWithFormat:actorHTML, avatar1, name1];
    NSString *repoHTMLString = [NSString stringWithFormat:actorHTML, avatar2, name2];
    NSString *actionHTMLString = [NSString stringWithFormat:actionHTML, actionName];

    NSArray *strings = @[actoHTMLString, actionHTMLString, repoHTMLString];

    return [strings componentsJoinedByString:@""];
}

- (NSString *)toHTMLStringForObject1WithName:(NSString *)name1 AndAvatar1:(NSString *)avatar1 Object2:(NSString *)name2 AndAvatar2:(NSString *)avatar2 andAction1:(NSString *)actionName1 Object3:(NSString *)name3 AndAvatar3:(NSString *)avatar3 andAction2:(NSString *)actionName2
{
    NSString *eventActorPath = [[NSBundle mainBundle] pathForResource:@"eventActor" ofType:@"html"];

    NSString *actorHTML = [NSString stringWithContentsOfFile:eventActorPath
                                                     encoding:NSUTF8StringEncoding error:nil];

    NSString *eventActionPath = [[NSBundle mainBundle] pathForResource:@"eventAction" ofType:@"html"];

    NSString *actionHTML = [NSString stringWithContentsOfFile:eventActionPath
                                                     encoding:NSUTF8StringEncoding error:nil];

    NSString *actor1HTMLString = [NSString stringWithFormat:actorHTML, avatar1, name1];
    NSString *actor2HTMLString = [NSString stringWithFormat:actorHTML, avatar2, name2];
    NSString *actor3HTMLString = [NSString stringWithFormat:actorHTML, avatar3, name3];

    NSString *action1HTMLString = [NSString stringWithFormat:actionHTML, actionName1];
    NSString *action2HTMLString = [NSString stringWithFormat:actionHTML, actionName2];

    NSArray *strings = @[actor1HTMLString, action1HTMLString, actor2HTMLString, action2HTMLString, actor3HTMLString];

    return [strings componentsJoinedByString:@""];
}

- (NSString *)toHTMLString
{
    return @"";
}

@end
