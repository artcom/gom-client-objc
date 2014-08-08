//
//  GOMObserver.h
//  gom-client-objc
//
//  Created by Julian Krumow on 07.08.14.
//  Copyright (c) 2014 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GOMObserverDelegate.h"
#import "GOMBinding.h"
#import "GOMGNp.h"

typedef void (^GOMClientGNPCallback)(GOMGnp *);

extern NSString * const GOMObserverErrorDomain;

typedef enum {
    GOMObserverWebsocketProxyUrlNotFound,
    GOMObserverWebsocketNotOpen
} GOMObserverErrorCode;

@interface GOMObserver : NSObject

@property (nonatomic, strong, readonly) NSURL *webSocketUri;
@property (nonatomic, strong, readonly) NSDictionary *bindings;
@property (nonatomic, weak) id<GOMObserverDelegate> delegate;

- (id)initWithWebsocketUri:(NSURL *)websocketUri delegate:(id<GOMObserverDelegate>)delegate;

- (void)reconnectWebsocket;
- (void)disconnectWebsocket;

- (void)registerGOMObserverForPath:(NSString *)path clientCallback:(GOMClientGNPCallback)callback;
- (void)unregisterGOMObserverForPath:(NSString *)path;

@end
