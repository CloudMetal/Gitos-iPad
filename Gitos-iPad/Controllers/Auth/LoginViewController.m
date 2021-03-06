//
//  LoginViewController.m
//  Gitos-iPad
//
//  Created by Tri Vuong on 1/28/13.
//  Copyright (c) 2013 Crafted By Tri. All rights reserved.
//

#import "LoginViewController.h"
#import "AppInitialization.h"
#import "Authorization.h"
#import "AccountViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize usernameCell, passwordCell, oauthParams, hud, signinButton, optionsSheet;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        oauthParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [Authorization appScopes], @"scopes",
                                        CLIENT_ID, @"client_id",
                                        CLIENT_SECRET, @"client_secret",
                                        nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self performHousekeepingTasks];
    [self registerEvents];
    [self setDelegates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)performHousekeepingTasks
{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDAnimationFade;
    hud.labelText = LOADING_MESSAGE;
    hud.hidden = YES;

    [self.navigationItem setTitle:@"Sign in to Github"];
    
    [self prepLoginTable];
    [self prepAccountOptions];
}

- (void)prepLoginTable
{
    [loginTable setBackgroundView:nil];
    [loginTable setScrollEnabled:NO];
    [loginTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [loginTable setSeparatorColor:[UIColor colorWithRed:200/255.0
                                                  green:200/255.0
                                                   blue:200/255.0
                                                  alpha:1.0]];

    signinButton.buttonColor = [UIColor turquoiseColor];
    signinButton.shadowColor = [UIColor greenSeaColor];
    signinButton.shadowHeight = 3.0f;
    signinButton.cornerRadius = 6.0f;
    signinButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [signinButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [signinButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    [signinButton addTarget:self
                     action:@selector(deleteExistingAuthorizations)
           forControlEvents:UIControlEventTouchDown];
}

- (void)prepAccountOptions
{
    optionsSheet = [[UIActionSheet alloc] initWithTitle:@"Options"
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                 destructiveButtonTitle:nil
                                      otherButtonTitles:@"Forgot Password", @"Sign Up", nil];

    UIBarButtonItem *optionsButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(showAccountOptions)];

    [optionsButton setTintColor:[UIColor colorWithRed:202/255.0
                                                green:0
                                                 blue:0
                                                alpha:1]];

    [optionsButton setImage:[UIImage imageNamed:@"211-action.png"]];

    [self.navigationItem setRightBarButtonItem:optionsButton];
}

- (void)setDelegates
{
    [usernameField setDelegate:self];
    [passwordField setDelegate:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) return usernameCell;
    if (indexPath.row == 1) return passwordCell;
    return nil;
}

- (void)registerEvents
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(authenticate)
                   name:@"ExistingAuthorizationsDeleted"
                 object:nil];

    [center addObserver:self
               selector:@selector(fetchUser)
                   name:@"UserAutheticated"
                 object:nil];
}

- (void)authenticate
{
    NSString *username = [usernameField text];
    NSString *password = [passwordField text];

    NSURL *url = [NSURL URLWithString:[AppConfig getConfigValue:@"GithubApiHost"]];

    //NSLog(@"creating new authentication token");

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpClient setParameterEncoding:AFJSONParameterEncoding];
    [httpClient setAuthorizationHeaderWithUsername:username password:password];
    
    NSMutableURLRequest *postRequest = [httpClient requestWithMethod:@"POST"
                                                                path:@"/authorizations"
                                                          parameters:oauthParams];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:postRequest];
    
    [operation setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation, id responseObject) {
         [hud setHidden:NO];
         NSString *response = [operation responseString];

         NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];

         Authorization *authorization = [[Authorization alloc] initWithData:json];

         NSString *token = [authorization getToken];
         NSString *account = [AppConfig getConfigValue:@"KeychainAccountName"];

         // Delete old access_token and store new one
         [SSKeychain deletePasswordForService:@"access_token" account:account];
         [SSKeychain setPassword:token forService:@"access_token" account:account];

         [[NSNotificationCenter defaultCenter] postNotificationName:@"UserAutheticated" object:nil];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [self handleInvalidCredentials];
     }];
    
    [operation start];
    [self blurFields];
}

- (void)deleteExistingAuthorizations
{
    NSString *username = [usernameField text];
    NSString *password = [passwordField text];

    // Prompt if username of password was blank
    if (username.length == 0 || password.length == 0) {
        [AppHelper flashError:@"Please enter your username and password" inView:self.view];
        return;
    }

    [self blurFields];
    [hud show:YES];

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[AppConfig getConfigValue:@"GithubApiHost"]]];
    [httpClient setParameterEncoding:AFJSONParameterEncoding];
    [httpClient setAuthorizationHeaderWithUsername:username password:password];

    NSMutableURLRequest *getRequest = [httpClient requestWithMethod:@"GET"
                                                                path:@"/authorizations"
                                                          parameters:oauthParams];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:getRequest];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *response = [operation responseString];

        NSArray *json = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];

        for (int i=0; i < [json count]; i++) {
            Authorization *authorization = [[Authorization alloc] initWithData:[json objectAtIndex:i]];

            NSString *authorizationId = [authorization getId];

            if ([[authorization getName] isEqualToString:@"Gitos"]) {

                NSLog(@"deleting existing authorization id: %@", authorizationId);

                AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[AppConfig getConfigValue:@"GithubApiHost"]]];
                [httpClient setAuthorizationHeaderWithUsername:username password:password];

                NSMutableURLRequest *deleteRequest = [httpClient requestWithMethod:@"DELETE"
                                                                              path:[authorization getUrl]
                                                                        parameters:nil];

                AFHTTPRequestOperation *deleteOperation = [[AFHTTPRequestOperation alloc] initWithRequest:deleteRequest];

                [deleteOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    // TBD
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"%@", error);
                }];
                [deleteOperation start];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ExistingAuthorizationsDeleted" object:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
        if ([operation.response statusCode] == 403) {
            [self handleInvalidCredentials];
        }
    }];
    [operation start];
}

- (void)fetchUser
{
    NSURL *url = [NSURL URLWithString:[AppConfig getConfigValue:@"GithubApiHost"]];

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpClient setParameterEncoding:AFJSONParameterEncoding];

    NSMutableURLRequest *getRequest = [httpClient requestWithMethod:@"GET"
                                                               path:@"/user"
                                                         parameters:[AppHelper getAccessTokenParams]];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:getRequest];

    [operation setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation, id responseObject) {
         [hud setHidden:NO];
         NSString *response = [operation responseString];

         NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];

         User *currentUser = [[User alloc] initWithData:json];
         [CurrentUserManager initializeWithUser:currentUser];

         [AppInitialization run:self.view.window withUser:currentUser];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {

     }];

    [operation start];
}

- (void)handleInvalidCredentials
{
    [AppHelper flashError:@"Invalid username or password" inView:self.view];
}

- (void)showAccountOptions
{
    [optionsSheet showInView:self.view];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)blurFields
{
    if ([usernameField isFirstResponder]) [usernameField resignFirstResponder];
    if ([passwordField isFirstResponder]) [passwordField resignFirstResponder];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    AccountViewController *accountController = [[AccountViewController alloc] init];

    if (buttonIndex == 0) {
        accountController.url = [AppConfig getConfigValue:@"ForgotPasswordUrl"];
        accountController.pageTitle = @"Forgot Password";
    } else {
        accountController.url = [AppConfig getConfigValue:@"SignupUrl"];
        accountController.pageTitle = @"Sign Up";
    }

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:accountController];

    navController.modalPresentationStyle = UIModalPresentationFullScreen;

    [self.navigationController presentViewController:navController
                                            animated:YES
                                          completion:nil];
}

@end
