//
//  ANNewsChannelFB.h
//  ANNewsKit
//
//  Created by Michele Amati on 8/30/12.
//  Copyright (c) 2012 apexnet.it. All rights reserved.
//

#import "ANNewsChannel.h"

/*
 * NOTE:
 * At the moment types are not used, since the infos we take are the same
 * for all types. The main reason for specifing a type was to help parse the
 * response.
 */

typedef enum {
    FBEntityTypeGeneric,
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

- (id)initWithEntityId:(NSString *)entityId;
- (id)initWithEntityType:(FBEntityType)entityType entityId:(NSString *)entityId;

@end
