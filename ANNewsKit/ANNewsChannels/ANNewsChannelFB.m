//
//  ANNewsChannelFB.m
//  ANNewsKit
//
//  Created by Michele Amati on 8/30/12.
//  Copyright (c) 2012 apexnet.it. All rights reserved.
//

#import "ANNewsChannelFB.h"


@interface ANNewsChannelFB ()

@property (nonatomic, assign) FBEntityType entityType;
@property (nonatomic, retain) NSString *entityId;
@property (nonatomic, assign) NSUInteger maxResults;

// Maps json response to ANNewsItem class items
- (NSArray *)mapResponse:(id)response;

@end


/*
 * The number of entries that the api will return. Be warned that this is not
 * necessarily the number of entries you will see.
 * - There might not be that much entries
 */
#define kDefaultMaxResults 30


@implementation ANNewsChannelFB

#pragma mark - Static vars/function implementation

static NSString *_appToken;
static NSString *_clientId;
static NSString *_clientSecret;

+ (NSString *)getAppToken
{
    @synchronized(self) {
        if (_appToken == nil) {
            // If the token is nil, check if we have the info needed to requet one
            if ([ANNewsChannelFB getClientId] && [ANNewsChannelFB getClientSecret]) {
                // If so, start the request synchronously
                [ANNewsChannelFB getAppTokenWithClientId:[ANNewsChannelFB getClientId]
                                            clientSecret:[ANNewsChannelFB getClientSecret]
                                    executeSynchronously:YES
                                         completionBlock:^(NSString *token, NSError *error) {
                                             if (error) {
                                                 NSLog(@"Error getting appToken: %@", [error localizedDescription]);
                                             }
                                             else {
                                                 NSLog(@"Got FB appToken: %@", token);
                                                 _appToken = token;
                                             }
                                         }];
            }
            else {
                NSLog(@"Missing facebook clientId or/and clientSecret, can't get appToken");
            }
        }
        return _appToken;
    }
}

+ (void)setAppToken:(NSString *)token
{
    @synchronized(self) { _appToken = token; }
}

+ (NSString *)getClientId
{
    return _clientId;
}

+ (NSString *)getClientSecret
{
    return _clientSecret;
}

+ (void)setClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret
{
    // It's logically pointless to set one and not the other
    _clientId = clientId;
    _clientSecret = clientSecret;
}

+ (void)getAppTokenWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret executeSynchronously:(BOOL)execSync completionBlock:(callBackBlock)completion
{
    if ([clientId length] > 0 && [clientSecret length] > 0) {
        // This block will handle the response in both sync and async req type 
        void (^handleResponse) (NSData *, NSError *);
        handleResponse = ^(NSData *data, NSError* error) {
            if (error == nil) {
                // Extracting the token
                NSString *responseString = [[NSString alloc] initWithBytes:[data bytes]
                                                                    length:[data length]
                                                                  encoding:NSUTF8StringEncoding];
                /*
                 * Good response looks like: access_token=111111111111111|aaaaaaaaaaaaaaaaaaaaaaaaaaa
                 * If something fails (facebook side) the response is of JSON type and contains error code and description
                 */
                if ([responseString rangeOfString:@"access_token="].location != NSNotFound) {
                    NSString *token = [responseString substringFromIndex:[@"access_token=" length]];
                    completion(token, nil);
                }
                else {
                    NSDictionary* fbErrorResponse = [[responseString objectFromJSONString] objectForKey:@"error"];
                    NSError *fbError = [[NSError alloc] initWithDomain:@"graph.facebook.com"
                                                                  code:[[fbErrorResponse objectForKey:@"code"] intValue]
                                                              userInfo:@{ NSLocalizedDescriptionKey : [fbErrorResponse objectForKey:@"message"] }];
                    completion(nil, fbError);
                }
            }
            else {
                completion(nil, error);
            }
        };

        // Building the request url
        NSString *requestString = [NSString stringWithFormat:
                                   @"https://graph.facebook.com/oauth/access_token?client_id=%@&client_secret=%@&grant_type=client_credentials",
                                   clientId,
                                   clientSecret];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString]];
        
        // Starting the selected type of request
        if (execSync) {
            NSURLResponse *response;
            NSError *error;
            NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                         returningResponse:&response
                                                                     error:&error];
            handleResponse(responseData, error);
        }
        else {
            [NSURLConnection sendAsynchronousRequest:request
                                               queue:[[NSOperationQueue alloc] init]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *err) {
                                       handleResponse(data, err);
                                   }];
        }
    }
    else {
        // Invalid inputs
        NSError *error = [[NSError alloc] initWithDomain:@"graph.facebook.com"
                                                    code:0
                                                userInfo:@{ NSLocalizedDescriptionKey : @"Invalid clientId or clientSecret" }];
        completion(nil, error);
    }
}

- (id)initWithEntityId:(NSString *)entityId
{
    if (self = [self initWithEntityType:FBEntityTypeGeneric entityId:entityId]) {
        // Custom init
        self.entityId = entityId;
    }
    return self;
}

- (id)initWithEntityType:(FBEntityType)entityType entityId:(NSString *)entityId
{
    if (self = [super init]) {
        // Custom init
        self.entityType = entityType;
        self.entityId = entityId;
        self.maxResults = kDefaultMaxResults;
    }
    return self;
}

#pragma mark - Superclass override

- (BOOL)refreshNews
{
    /*
     * Check if the token needed to sign request is setted, if not the static
     * function will try to get it. If it fails nil is returned.
     */
    if ([ANNewsChannelFB getAppToken]) {
        // If so ask facebook api
        NSString *requestString = [NSString stringWithFormat:
                                   @"https://graph.facebook.com/%@/feed?access_token=%@&limit=%d",
                                   self.entityId,
                                   [ANNewsChannelFB getAppToken],
                                   self.maxResults];
        id responseData = [self getJSONNewsSync:requestString];
        if (responseData) {
            self.news = [self mapResponse:responseData];
            return YES;
        }
        else {
            return NO;
        }
    }
    else {
        // If it's not nil out the news and return NO
        self.news = nil;
        return NO;
    }
}

#pragma mark - Private

- (NSArray *)mapResponse:(id)response
{
    if (response) {
        // "2012-08-30T08:43:42+0000"        
        static NSDateFormatter *df;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
            [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        });
        
        NSMutableArray *results = [NSMutableArray array];
        for (NSDictionary* row in [response objectForKey:@"data"]) {
            // If the row has a message (that's what we want to show)
            if ([row objectForKey:@"message"] != nil) {
                // Configure the news item
                ANNewsItem *newNews = [[ANNewsItem alloc] init];
                newNews.author = [[row objectForKey:@"from"] objectForKey:@"name"];
                newNews.text = [row objectForKey:@"message"];
                newNews.date = [df dateFromString:[row objectForKey:@"created_time"]];
                newNews.imageURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", [[row objectForKey:@"from"] objectForKey:@"id"]];
                [results addObject:newNews];
            }
        }
        return results;
    }
    else {
        return nil;
    }
}

@end
