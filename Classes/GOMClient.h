//
//  GOMClient.h
//  gom-client-objc
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GOMOperation.h"
#import "GOMNode.h"
#import "GOMAttribute.h"

extern NSString * const GOMClientErrorDomain;

typedef enum {
    GOMClientTooManyRedirects
} GOMClientErrorCode;


@interface GOMClient : NSObject

@property (nonatomic, strong, readonly) NSURL *gomRoot;

- (id)initWithGomURI:(NSURL *)gomURI;

- (void)retrieve:(NSString *)path completionBlock:(GOMClientOperationCallback)block;
- (void)create:(NSString *)node withAttributes:(NSDictionary *)attributes completionBlock:(GOMClientOperationCallback)block;
- (void)updateAttribute:(NSString *)attribute withValue:(NSString *)value completionBlock:(GOMClientOperationCallback)block;
- (void)updateNode:(NSString *)node withAttributes:(NSDictionary *)attributes completionBlock:(GOMClientOperationCallback)block;
- (void)destroy:(NSString *)path completionBlock:(GOMClientOperationCallback)block;

@end
