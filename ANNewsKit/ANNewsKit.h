//
//  ANNewsKit.h
//  ANNewsKit
//
//  Created by Michele Amati on 8/30/12.
//  Copyright (c) 2012 apexnet.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANNewsChannelProtocol.h"

@class ANNewsKit;


@protocol ANNewsKitDataSource <NSObject>
@required
// Ask for the number of different channels
- (NSUInteger)numberOfChannelsInNewsKit:(ANNewsKit *)newsKit;
// Ask for a configured "channel"
- (id<ANNewsChannelProtocol>)newsKit:(ANNewsKit *)newsKit channelForNumber:(NSUInteger)number;
@end


@protocol ANNewsKitDelegate <NSObject>
// Invoked when a channel ends its refreshing, check the remainingChennels value to know when all channels has being refreshed
- (void)newsKit:(ANNewsKit *)newsKit endsRefreshingChannel:(id<ANNewsChannelProtocol>)channel remainingChannels:(NSUInteger)remaining;
@end


@interface ANNewsKit : NSObject

// Here are stored all the newsItems of all channels after sorting
@property (nonatomic, retain) NSArray *sortedNews;
// The data source...
@property (nonatomic, retain) id<ANNewsKitDataSource> dataSource;
// The delegate...
@property (nonatomic, retain) id<ANNewsKitDelegate> delegate;
// Total number of channels
@property (nonatomic, readonly) NSUInteger totalChannels;
// Number of channels actually refreshing
@property (nonatomic, readonly) NSUInteger refreshingChannels;

// Cause the datasource to be asked for channels
- (void)reloadChannels;
// Every channel will refresh its news, return NO if refresh can't start
- (BOOL)refreshAllChannelsNews;
/* Refresh the news of the channels at given index set, returns YES if at least
 * one channel is elegible for refreshing */
- (BOOL)refreshNewsForChannelsAtIndexes:(NSIndexSet *)indexSet;

@end
