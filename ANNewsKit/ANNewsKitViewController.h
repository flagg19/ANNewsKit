//
//  ANNewsKitViewController.h
//  ANNewsKit
//
//  Created by Michele Amati on 8/29/12.
//  Copyright (c) 2012 apexnet.it. All rights reserved.
//

#import "NUITableViewController.h"

#import "UIImageView+WebCache.h"

#import "ANNewsKit.h"
// Custom channels
#import "ANNewsChannelFB.h"
#import "ANNewsChannelTW.h"

@interface ANNewsKitViewController : NUITableViewController <ANNewsKitDataSource, ANNewsKitDelegate>

// The core object of this controller, fetcher & "datasource" of the tableview
@property (nonatomic, retain) ANNewsKit *newsKit;

// The formatter used for news's date
@property (nonatomic, retain) NSDateFormatter *dateFormatter;

@end
