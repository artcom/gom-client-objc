//
//  NSError+GOMErrors.m
//  gom-client-objc
//
//  Created by Julian Krumow on 08.08.14.
//  Copyright (c) 2014 ART+COM AG. All rights reserved.
//

#import "NSError+GOMErrors.h"

NSString * const GOMClientErrorDomain = @"de.artcom.gom-client-objc.client";
NSString * const GOMObserverErrorDomain = @"de.artcom.gom-client-objc.observer";

@implementation NSError (GOMErrors)

+ (NSError *)gomClientErrorForCode:(GOMClientErrorCode)code
{
    NSString *description = nil;
    
    switch (code) {
        case GOMClientTooManyRedirects:
            description = @"Too many redirects.";
            break;
        default:
            description = @"Unknown error.";
            break;
    }
    
    return [self createErrorWithDomain:GOMClientErrorDomain code:code description:description];
}

+ (NSError *)gomObserverErrorForCode:(GOMObserverErrorCode)code
{
    NSString *description = nil;
    
    switch (code) {
        case GOMObserverWebsocketProxyUrlNotFound:
            description = @"Websocket proxy url not found.";
            break;
        case GOMObserverWebsocketNotOpen:
            description = @"Websocket not open.";
            break;
        default:
            description = @"Unknown error.";
            break;
    }
    
    return [self createErrorWithDomain:GOMObserverErrorDomain code:code description:description];
}

+ (NSError *)createErrorWithDomain:(NSString *)domain code:(NSUInteger)code description:(NSString *)description
{
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : NSLocalizedString(description, nil)};
    return [NSError errorWithDomain:GOMObserverErrorDomain code:code userInfo:userInfo];
}

@end
