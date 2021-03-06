//
//  CommitViewController.h
//  Gitos-iPad
//
//  Created by Tri Vuong on 2/13/13.
//  Copyright (c) 2013 Crafted By Tri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Commit.h"

@interface CommitViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) NSString *branch;
@property (nonatomic, strong) Commit *commit;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, weak) IBOutlet UIWebView *commitView;

- (void)performHouseKeepingTasks;
- (void)registerEvents;
- (void)fetchCommitDetails;
- (void)displayCommitDetails:(NSNotification *)notification;

@end
