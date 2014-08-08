//
//  NSError+GOMErrors.h
//  gom-client-objc
//
//  Created by Julian Krumow on 08.08.14.
//  Copyright (c) 2014 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const GOMClientErrorDomain;
extern NSString * const GOMObserverErrorDomain;

typedef enum {
    GOMClientTooManyRedirects
} GOMClientErrorCode;

typedef enum {
    GOMObserverWebsocketProxyUrlNotFound,
    GOMObserverWebsocketNotOpen
} GOMObserverErrorCode;

@interface NSError (GOMErrors)

+ (NSError *)gomClientErrorForCode:(GOMClientErrorCode)code;
+ (NSError *)gomObserverErrorForCode:(GOMObserverErrorCode)code;
+ (NSError *)createErrorWithDomain:(NSString *)domain code:(NSUInteger)code description:(NSString *)description;

@end
