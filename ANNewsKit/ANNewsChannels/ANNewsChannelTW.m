//
//  ANNewsChannelTW.m
//  ANNewsKit
//
//  Created by Michele Amati on 8/31/12.
//  Copyright (c) 2012 apexnet.it. All rights reserved.
//

#import "ANNewsChannelTW.h"


@interface ANNewsChannelTW ()

@property (nonatomic, retain) NSString *query;

@end


@implementation ANNewsChannelTW

- (id)initWithTWQuery:(NSString *)query
{
    if (self = [super init]) {
        // Custom init
        self.query = query;
    }
    return self;
}

#pragma mark - Superclass override

- (BOOL)refreshNews
{
    // Asking twitter api...
    NSString *requestString = [NSString stringWithFormat:
                               @"http://search.twitter.com/search.json?q=%@",
                               self.query];
    
    id responseData = [self getJSONNewsSync:requestString];
    if (responseData) {
        self.news = [self mapResponse:responseData];
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark - Private

- (NSArray *)mapResponse:(id)response
{
    if (response) {
        // "Fri, 31 Aug 2012 12:44:54 +0000"
        // "EEE, dd MMM yyyy HH:mm:ss Z"
        static NSDateFormatter *df;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
            [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        });
        
        NSMutableArray *results = [NSMutableArray array];
        for (NSDictionary *row in [response objectForKey:@"results"]) {
            ANNewsItem *newNews = [[ANNewsItem alloc] init];
            newNews.author = [row objectForKey:@"from_user"];
            newNews.text = [row objectForKey:@"text"];
            newNews.date = [df dateFromString:[row objectForKey:@"created_at"]];
            newNews.imageURL = [row objectForKey:@"profile_image_url"];
            [results addObject:newNews];
        }
        return results;
    }
    else {
        return nil;
    }
}

@end
