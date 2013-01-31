//
//  StarredViewController.h
//  Gitos-iPad
//
//  Created by Tri Vuong on 1/28/13.
//  Copyright (c) 2013 Crafted By Tri. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SpinnerView.h"
#import "User.h"

@interface StarredViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *starredReposTable;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSMutableArray *starredRepos;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic, strong) SpinnerView *spinnerView;

- (void)getUserInfo;
- (void)getStarredReposForPage:(NSInteger)page;
- (void)setupPullToRefresh;

@end
