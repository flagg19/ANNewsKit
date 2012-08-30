//
//  ANNewsKit.m
//  ANNewsKit
//
//  Created by Michele Amati on 8/30/12.
//  Copyright (c) 2012 apexnet.it. All rights reserved.
//

#import "ANNewsKit.h"


@interface ANNewsKit ()

// Temporary array with unsorted news
@property (nonatomic, retain) NSMutableArray *unsortedNews;
// Array of object conforming to channel protocol
@property (nonatomic, retain) NSMutableArray *channels;
// Array of channels that are currently refreshing
@property (nonatomic, retain) NSMutableArray *refreshing;

// Callback used in the async queue that refreshes channels
- (void)channel:(id<ANNewsChannelProtocol>)channel endsRefreshStatus:(BOOL)status;

@end


@implementation ANNewsKit

- (id)init
{
    if (self = [super init]) {
        self.unsortedNews = [NSMutableArray array];
        self.sortedNews = [NSMutableArray array];
        self.channels = [NSMutableArray array];
        self.refreshing = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Property implementation

- (NSUInteger)refreshingChannels
{
    return [self.refreshing count];
}

#pragma mark - Public

- (void)reloadChannels
{
    // Clearing old channels
    [self.channels removeAllObjects];
    
    // Exiting if no datasource set
    if (self.dataSource == nil) {
        return;
    }
    
    // Asking the datasource...
    _totalChannels = [self.dataSource numberOfChannelsInNewsKit:self];
    for (int num = 0; num < self.totalChannels; num++) {
        id tempChannel = [self.dataSource newsKit:self channelForNumber:num];
        if (tempChannel == nil) {
            NSAssert(NO, @"Channel can't be nil");
        }
        [self.channels addObject:tempChannel];
    }
}

- (BOOL)refreshAllChannelsNews
{
    // TODO: Do domething better (performance wise)
    return [self refreshNewsForChannelsAtIndexes:[self.channels indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return YES;
    }]];
    
    // Old implementation, when channel were user can only refresh all channels 
    /*
    // If there are no channels or a refresh is already in progress, return NO
    if (self.channels.count == 0 || self.refreshingChannels != 0) {
        return NO;
    }
    else {
        // Clearing old news
        [self.unsortedNews removeAllObjects];
        
        // Adding the channels to be refreshed to the appropriate array
        [self.refreshing addObjectsFromArray:self.channels];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        
        // For every channel
        for (id<ANNewsChannelProtocol> channel in self.channels) {
            // Refresh its news in a concurrent async queue
            dispatch_async(queue, ^{
                BOOL status = [channel refreshNews];
                // When a channel end refreshing, notify it to the news kit (on main thred to avoid concurrency problems)
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self channel:channel endsRefreshStatus:status];
                });
            });
        }
        return YES;
    }
     */
}

- (BOOL)refreshNewsForChannelsAtIndexes:(NSIndexSet *)indexSet
{
    // If there are no channels or indexSet is invalid, return NO
    if (self.channels.count == 0 || indexSet == nil || indexSet.count == 0) {
        return NO;
    }
    
    /* Keep a ref to channels that pass the refreshability test. Can't use
     * self.refreshing directly because it may be modified elsewhere while
     * looping through it. */
    NSMutableArray *toBeRefreshed = [NSMutableArray array];
    
    // Check if selected channels exists and are not already refreshing
    BOOL refreshStarted = NO;
    NSArray *refreshCandidates = [self.channels objectsAtIndexes:indexSet];
    for (id<ANNewsChannelProtocol> channel in refreshCandidates) {
        if ([toBeRefreshed containsObject:channel] == NO) {
            [toBeRefreshed addObject:channel];
            refreshStarted = YES;
        }
    }
    // Returning YES if at least one of the proposed channel is refreshable
    if (refreshStarted == NO) {
        return NO;
    }
    
    // Clearing old news (channel not refreshed will be asked for old news)
    [self.unsortedNews removeAllObjects];
    
    // For every channel that needs refresh
    for (id<ANNewsChannelProtocol> channel in toBeRefreshed) {
        // Refresh its news in a concurrent async queue
        [self.refreshing addObject:channel];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            BOOL status = [channel refreshNews];
            // When a channel end refreshing, notifyes it to the news kit (on main thred to avoid concurrency problems)
            dispatch_async(dispatch_get_main_queue(), ^{
                [self channel:channel endsRefreshStatus:status];
            });
        });
    }
    return YES;
}

#pragma mark - Private

- (void)channel:(id<ANNewsChannelProtocol>)channel endsRefreshStatus:(BOOL)status
{
    // Consistency check
    if (self.refreshingChannels > 0) {
        [self.refreshing removeObject:channel];
    }
    else {
        NSAssert(NO, @"A channel finished refreshing while there should not be refreshing channels any more");
    }
    
    // Getting the channel news
    if (channel.news) {
        [self.unsortedNews addObjectsFromArray:channel.news];
    }
    
    // Check if it was the last channel
    if (self.refreshingChannels == 0) {
        // Sort the news array
        self.sortedNews = [self.unsortedNews sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSAssert(([a isKindOfClass:[ANNewsItem class]] && [a isKindOfClass:[ANNewsItem class]]), @"Object in unsortedNews not of ANNewsItem type!");
            return [[(ANNewsItem *)b date] compare:[(ANNewsItem *)a date]];
        }];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(newsKit:endsRefreshingChannel:remainingChannels:)]) {
        // Notify the delegate
        [self.delegate newsKit:self endsRefreshingChannel:channel remainingChannels:self.refreshingChannels];
    }
}

@end
