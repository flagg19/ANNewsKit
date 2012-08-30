//
//  ANNewsChannel.h
//  ANNewsKit
//
//  Created by Michele Amati on 8/29/12.
//  Copyright (c) 2012 apexnet.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANNewsChannelProtocol.h"
#import "JSONKit.h"

/* Base class for building specific channels classes.
 * This is a good starting point but it's not mandatory.
 * What's realy needed for a channel to be usable in the ANNewsKit is that it
 * implements the ANNewsChannelProtocol. */

@interface ANNewsChannel : NSObject <ANNewsChannelProtocol>

@property (nonatomic, retain) NSArray *news;

// Little wrapper for sync json data retriving
- (id)getJSONNewsSync:(NSString *)urlString;

@end
