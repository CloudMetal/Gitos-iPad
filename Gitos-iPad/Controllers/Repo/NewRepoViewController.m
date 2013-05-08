//
//  NewRepoViewController.m
//  Gitos-iPad
//
//  Created by Tri Vuong on 5/5/13.
//  Copyright (c) 2013 Crafted By Tri. All rights reserved.
//

#import "NewRepoViewController.h"

@interface NewRepoViewController ()

@end

@implementation NewRepoViewController

@synthesize repoFormTable, nameCell, nameTextField, descriptionCell, descriptionTextField,
homePageCell, homePageTextField, visibilityCell, hud;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self performHousekeepingTasks];
}

- (void)performHousekeepingTasks
{
    [super performHousekeepingTasks];

    self.navigationItem.title = @"New Repository";

    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Create"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(submitNewRepo)];

    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDAnimationFade;
    hud.labelText = LOADING_MESSAGE;
    hud.hidden = YES;

    [self.navigationItem setRightBarButtonItem:submitButton];

    [repoFormTable setBackgroundView:nil];
    [repoFormTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [repoFormTable setSeparatorColor:[UIColor colorWithRed:200/255.0
                                                  green:200/255.0
                                                   blue:200/255.0
                                                  alpha:1.0]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) return nameCell;
    if (indexPath.row == 1) return descriptionCell;
    if (indexPath.row == 2) return homePageCell;
    if (indexPath.row == 3) return visibilityCell;

    return nil;
}

- (void)submitNewRepo
{
    if (nameTextField.text.length == 0) {
        [AppHelper flashError:@"Name cannot be blank" inView:self.view];
        return;
    }
}

@end