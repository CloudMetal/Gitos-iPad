//
//  DeleteEvent.m
//  Gitos-iPad
//
//  Created by Tri Vuong on 2/24/13.
//  Copyright (c) 2013 Crafted By Tri. All rights reserved.
//

#import "DeleteEvent.h"

@implementation DeleteEvent

- (NSMutableAttributedString *)toString
{
    User *actor = [self getActor];

    NSDictionary *payload = [self getPayload];
    
    NSMutableAttributedString *actorLogin = [self decorateEmphasizedText:[actor getLogin]];
    NSMutableAttributedString *deleted = [self toAttributedString:@" deleted "];
    NSMutableAttributedString *refType = [self toAttributedString:[NSString stringWithFormat:@"%@ ", [payload valueForKey:@"ref_type"]]];
    NSMutableAttributedString *ref = [self decorateEmphasizedText:[payload valueForKey:@"ref"]];

    [actorLogin insertAttributedString:deleted atIndex:actorLogin.length];
    [actorLogin insertAttributedString:refType atIndex:actorLogin.length];
    [actorLogin insertAttributedString:ref atIndex:actorLogin.length];
    
    return actorLogin;
}

- (NSString *)toHTMLString
{
    User *actor = [self getActor];

    NSDictionary *payload = [self getPayload];

    NSString *refType = [NSString stringWithFormat:@"%@ ", [payload valueForKey:@"ref_type"]];
    NSString *ref = [payload valueForKey:@"ref"];

    return [super toHTMLStringForObject1WithName:[actor getLogin]
                                      AndAvatar1:[actor getAvatarUrl]
                                         Object2:[@[refType, ref] componentsJoinedByString:@"/"]
                                      AndAvatar2:GITHUB_OCTOCAT
                                       andAction:@"deleted"];
}

- (NSString *)getURLPrefixForObject:(NSObject *)object
{
    return REPO_EVENT_PREFIX;
}

@end
