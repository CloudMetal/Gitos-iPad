//
//  NewsfeedViewController.h
//  Gitos-iPad
//
//  Created by Tri Vuong on 1/28/13.
//  Copyright (c) 2013 Crafted By Tri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterViewController.h"

@interface NewsfeedViewController : GitosViewController <UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *newsFeedTable;
}

@property (nonatomic, strong) NSMutableArray *newsFeed;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic, strong) MBProgressHUD *hud;

- (void)performHouseKeepingTasks;
- (void)registerEvents;
- (void)prepareTableView;
- (void)setupPullToRefresh;
- (void)reloadNewsfeed;
- (void)fetchUserNewsFeed;
- (void)displayUserNewsFeed:(NSNotification *)notication;

@end
