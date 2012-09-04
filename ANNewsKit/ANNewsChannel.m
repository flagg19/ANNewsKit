//
//  ANNewsChannel.m
//  ANNewsKit
//
//  Created by Michele Amati on 8/29/12.
//  Copyright (c) 2012 apexnet.it. All rights reserved.
//

#import "ANNewsChannel.h"

@interface ANNewsChannel ()

@end


@implementation ANNewsChannel

#pragma mark - Public

- (id)getJSONNewsSync:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLResponse *response;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url]
                                                 returningResponse:&response
                                                             error:&error];
    if (error == nil) {
        return [responseData objectFromJSONData];
    }
    else {
        NSLog(@"Error %@",error.localizedDescription);
        return nil;
    }
}

#pragma mark - ANNewsChannelProtocol

- (BOOL)refreshNews
{
    NSAssert(NO, @"Subclass must override this function");
    return NO;
}

@end
