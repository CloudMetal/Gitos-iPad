//
//  RawFileViewController.m
//  Gitos-iPad
//
//  Created by Tri Vuong on 1/28/13.
//  Copyright (c) 2013 Crafted By Tri. All rights reserved.
//

#import "RawFileViewController.h"
#import "AppConfig.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "RepoTreeNode.h"
#import "RepoTreeViewController.h"

@interface RawFileViewController ()

@end

@implementation RawFileViewController

@synthesize repo, branch, fileName, mimeType, rawFileUrl, rawFileRequest, fileWebView;

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
    [self.navigationItem setTitle:self.fileName];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDAnimationFade;
    self.hud.labelText = @"Loading";
    [self fetchRawFile];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchRawFile
{
    NSString *githubRawHost = [AppConfig getConfigValue:@"GithubRawHost"];
    NSString *repoFullName = [self.repo getFullName];
    NSString *branchName = [self.branch getName];
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    NSMutableArray *blobPaths = [[NSMutableArray alloc] initWithCapacity:0];
    RepoTreeNode *node;
    RepoTreeViewController *treeController;
    
    for (int i=0; i < viewControllers.count; i++) {
        if ([[viewControllers objectAtIndex:i] isKindOfClass:[RepoTreeViewController class]]) {
            treeController = (RepoTreeViewController *)[viewControllers objectAtIndex:i];
            node = treeController.node;
            if (node != (id)[NSNull null]) {
                [blobPaths addObject:node.path];
            }
        }
    }
    
    NSMutableArray *paths = [[NSMutableArray alloc] initWithCapacity:0];
    
    [paths addObject:repoFullName];
    [paths addObject:branchName];
    
    if (blobPaths.count == 0) {
        [paths addObject:self.fileName];
    } else {
        [paths addObject:[blobPaths componentsJoinedByString:@"/"]];
        [paths addObject:self.fileName];
    }
    
    self.rawFileUrl = [NSURL URLWithString:[githubRawHost stringByAppendingFormat:@"/%@", [paths componentsJoinedByString:@"/"]]];
    
    self.rawFileRequest = [NSURLRequest requestWithURL:self.rawFileUrl];
    
    NSURLConnection *rawFileConnection = [NSURLConnection connectionWithRequest:self.rawFileRequest delegate:self];
    [rawFileConnection start];
    [self.hud show:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.mimeType = [response MIMEType];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    UIImage *image = [UIImage imageWithData:data];
    
    if (image != nil) {
        // Raw file is an image
        [fileWebView loadRequest:self.rawFileRequest];
    } else if ([self.mimeType isEqualToString:@"text/plain"]) {
        NSString *rawFilePath = [[NSBundle mainBundle] pathForResource:@"raw_file" ofType:@"html"];
        NSString *rawFileContent = [NSString stringWithContentsOfFile:rawFilePath encoding:NSUTF8StringEncoding error:nil];
        NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
        NSString *htmlString = [NSString stringWithFormat:rawFileContent, [self encodeHtmlEntities:content]];
        [fileWebView loadHTMLString:htmlString baseURL:baseURL];
    }
    [self.hud hide:YES];
}

- (NSString *)encodeHtmlEntities:(NSString *)rawHtmlString
{
    return [[rawHtmlString
             stringByReplacingOccurrencesOfString: @">" withString: @"&#62;"]
            stringByReplacingOccurrencesOfString: @"<" withString: @"&#60;"];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.hud hide:YES];
}

@end
