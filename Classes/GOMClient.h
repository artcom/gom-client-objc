//
//  GOMClient.h
//  gom-client-objc
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GOMClientDelegate.h"
#import "GOMOperation.h"
#import "GOMBinding.h"
#import "GOMNode.h"
#import "GOMAttribute.h"

extern NSString * const GOMClientErrorDomain;

typedef enum {
    GOMClientWebsocketProxyUrlNotFound,
    GOMClientWebsocketNotOpen,
    GOMClientTooManyRedirects
} GOMClientErrorCode;

typedef void (^GOMClientGNPCallback)(NSDictionary *);

@interface GOMClient : NSObject

@property (nonatomic, strong, readonly) NSURL *gomRoot;
@property (nonatomic, weak) id<GOMClientDelegate> delegate;
@property (nonatomic, strong, readonly) NSDictionary *bindings;

- (id)initWithGomURI:(NSURL *)gomURI delegate:(id<GOMClientDelegate>)delegate;
- (void)reconnectWebsocket;
- (void)disconnectWebsocket;

- (void)retrieve:(NSString *)path completionBlock:(GOMClientOperationCallback)block;
- (void)create:(NSString *)node withAttributes:(NSDictionary *)attributes completionBlock:(GOMClientOperationCallback)block;
- (void)updateAttribute:(NSString *)attribute withValue:(NSString *)value completionBlock:(GOMClientOperationCallback)block;
- (void)updateNode:(NSString *)node withAttributes:(NSDictionary *)attributes completionBlock:(GOMClientOperationCallback)block;
- (void)destroy:(NSString *)path completionBlock:(GOMClientOperationCallback)block;

- (void)registerGOMObserverForPath:(NSString *)path clientCallback:(GOMClientGNPCallback)callback;
- (void)unregisterGOMObserverForPath:(NSString *)path;

@end
