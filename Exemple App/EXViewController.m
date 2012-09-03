//
//  EXViewController.m
//  ANNewsKit
//
//  Created by Michele Amati on 8/31/12.
//  Copyright (c) 2012 apexnet.it. All rights reserved.
//

#import "EXViewController.h"
#import "MBProgressHUD.h"


@interface EXViewController ()

// Hud used to stop the user from interacting with the app during refreshs
@property (nonatomic, retain) MBProgressHUD *HUD;

// Configure and show the HUD
- (void)showHUD;

@end


@implementation EXViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Initializing the channels that need any kind of setup
    // FB                                           
    [ANNewsChannelFB setClientId:@"111111111111111" clientSecret:@"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"];
    
    // Makeing the datasorce start asking
    [self.newsKit reloadChannels];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Here we want to start refreshing news
    if ([self.newsKit refreshAllChannelsNews]) {
        // Showing HUD only if the refresh starts
        [self showHUD];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Private

- (void)showHUD
{
    UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] lastObject];
    
    // First time HUD init & config
    if (self.HUD == nil) {
        self.HUD = [[MBProgressHUD alloc] initWithWindow:mainWindow];
        self.HUD.opacity = 0.7;
        self.HUD.minShowTime = 0.5;
        self.HUD.mode = MBProgressHUDModeDeterminate;
        self.HUD.labelText = @"Please wait...";
    }
    
    // HUD reset
    dispatch_async(dispatch_get_main_queue(), ^{
        self.HUD.progress = 0.0f;
        [mainWindow addSubview:self.HUD];
        [self.HUD show:YES];
    });
}

#pragma mark - Pull to refresh

- (void)willPullFreshDataForTableView:(NUITableView *)tableView
{
    [super willPullFreshDataForTableView:tableView];
    
    // Here we want to start refreshing news
    if ([self.newsKit refreshAllChannelsNews]) {
        // Showing HUD only if the refresh starts
        [self showHUD];
    }
}

#pragma mark - ANNewsKitDelegate

- (void)newsKit:(ANNewsKit *)newsKit endsRefreshingChannel:(id<ANNewsChannelProtocol>)channel remainingChannels:(NSUInteger)remaining
{
    [super newsKit:newsKit endsRefreshingChannel:channel remainingChannels:remaining];
    
    // Update the HUD progress
    self.HUD.progress = (float)(1.0f - ((float)remaining / (float)newsKit.totalChannels));
    
    // If it's the last channel, remove the HUD
    if (remaining == 0) {
        [self.HUD hide:YES afterDelay:0.25f];
    }
}

#pragma mark - ANNewsKitDataSource

- (NSUInteger)numberOfChannelsInNewsKit:(ANNewsKit *)newsKit
{
    return 2;
}

- (id<ANNewsChannelProtocol>)newsKit:(ANNewsKit *)newsKit channelForNumber:(NSUInteger)number
{
    if (number%2) {
        return [[ANNewsChannelTW alloc] initWithTWQuery:@"@apexnet OR #imortacci OR #apexnet OR @bocconi OR #bocconi"];
    }
    else {
        return [[ANNewsChannelFB alloc] initWithEntityType:FBEntityTypeUser entityId:@"1185713885"];
    }
}

@end
