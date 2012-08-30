//
//  ANNewsChannelFB.h
//  ANNewsKit
//
//  Created by Michele Amati on 8/30/12.
//  Copyright (c) 2012 apexnet.it. All rights reserved.
//

#import "ANNewsChannel.h"

typedef enum {
    FBEntityTypeUser,
    FBEntityTypeGroup,
    FBEntityTypePage,
} FBEntityType;

typedef void (^callBackBlock)(NSString *token, NSError* error);

@interface ANNewsChannelFB : ANNewsChannel {
    
}

// Used to retrive an app token needed to initialize a ANNewsChannelFB object
+ (void)getAppTokenWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret executeSynchronously:(BOOL)execSync completionBlock:(callBackBlock)completion;

// Static class vars getter/setter
+ (NSString *)getAppToken;
+ (NSString *)getClientId;
+ (NSString *)getClientSecret;
+ (void)setAppToken:(NSString *)token;
+ (void)setClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;

- (id)initWithEntityType:(FBEntityType)entityType entityId:(NSString *)entityId;

@end
