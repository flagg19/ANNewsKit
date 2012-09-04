//
//  ANNewsKitViewController.m
//  ANNewsKit
//
//  Created by Michele Amati on 8/29/12.
//  Copyright (c) 2012 apexnet.it. All rights reserved.
//

#import "ANNewsKitViewController.h"
#import "MBProgressHUD.h"


@interface ANNewsKitViewController ()

@end


@implementation ANNewsKitViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.newsKit = [[ANNewsKit alloc] init];
        self.newsKit.dataSource = self;
        self.newsKit.delegate = self;
        self.tableView.paginationEnabled = NO;
        
        // Default date formatter
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss"];
    }
    return self;
}

#pragma mark - ANNewsKitDataSource

- (NSUInteger)numberOfChannelsInNewsKit:(ANNewsKit *)newsKit
{
    return 0;
}

- (id<ANNewsChannelProtocol>)newsKit:(ANNewsKit *)newsKit channelForNumber:(NSUInteger)number
{
    return nil;
}
 
#pragma mark - ANNewsKitDelegate

- (void)newsKit:(ANNewsKit *)newsKit endsRefreshingChannel:(id<ANNewsChannelProtocol>)channel remainingChannels:(NSUInteger)remaining
{
    /*
     * WARNING: If a subclass override this implementation it MUST call super!
     * ...or HUD will never dismiss.
     */
    
    // If it's the last channel, remove the HUD and refresh the table
    if (remaining == 0) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.newsKit.sortedNews count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    ANNewsItem *news = [self.newsKit.sortedNews objectAtIndex:indexPath.row];
    
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.cornerRadius = 10.0;
    cell.textLabel.text = news.text;
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:news.date];
    [cell.imageView setImageWithURL:[NSURL URLWithString:news.imageURL]
                   placeholderImage:[UIImage imageNamed:@"placeholder-avatar.png"]];
    
    return cell;
}

@end
