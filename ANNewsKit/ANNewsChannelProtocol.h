//
//  ANNewsChannelProtocol.h
//  ANNewsKit
//
//  Created by Michele Amati on 8/29/12.
//  Copyright (c) 2012 apexnet.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANNewsItem.h"

@protocol ANNewsChannelProtocol <NSObject>

/* 
 * Here are stored the downloaded news, it MUST contain ANNewsItem objects!
 * Sadly it can't be enforced with protocols or anything else, but a type check
 * is performed before using them and an exception is rised if check fails.
 */
- (NSArray *)news;

/* 
 * After this function returns, the newsKit (caller) expect the news array to
 * be ready for use. It's executed asynchronously in a concurrent queue so you 
 * may ask for data in a synchronous way without worrying to block the app.
 * Anyway, do whatever you want but be sure not to let this function returns 
 * before news are ready
 */
- (BOOL)refreshNews;

@end
