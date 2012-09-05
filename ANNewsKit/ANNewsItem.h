//
//  ANNewsItem.h
//  ANNewsKit
//
//  Created by Michele Amati on 8/29/12.
//  Copyright (c) 2012 apexnet.it. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANNewsItem : NSObject

@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *imageURL;

@end
