//
//  ANNewsChannelTW.h
//  ANNewsKit
//
//  Created by Michele Amati on 8/31/12.
//  Copyright (c) 2012 apexnet.it. All rights reserved.
//

#import "ANNewsChannel.h"

/*
 * NOTE: If you want to show many twitter "items" you may want to use only one
 * channel configured with a query that aggregate them all. Doing so will use
 * lot less connection and help not getting banned.
 * HERE: https://dev.twitter.com/docs/using-search docs on how to make queries.
 */

@interface ANNewsChannelTW : ANNewsChannel

- (id)initWithTWQuery:(NSString *)query;

@end
