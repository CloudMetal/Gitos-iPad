//
//  WatchEvent.m
//  Gitos-iPad
//
//  Created by Tri Vuong on 2/18/13.
//  Copyright (c) 2013 Crafted By Tri. All rights reserved.
//

#import "WatchEvent.h"

@implementation WatchEvent

- (NSString *)toString
{
    User *actor = [self getActor];
    Repo *repo = [self getRepo];

    return [NSString stringWithFormat:@"%@ starred %@", [actor getLogin], [repo getName]];
}

@end