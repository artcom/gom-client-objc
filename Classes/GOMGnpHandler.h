//
//  GOMGnpHandler.h
//  gom-client-objc
//
//  Created by Julian Krumow on 07.08.14.
//  Copyright (c) 2014 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GOMGnpHandlerDelegate.h"
#import "GOMBinding.h"

typedef void (^GOMClientGNPCallback)(NSDictionary *);

extern NSString * const GOMGnpHandlerErrorDomain;

typedef enum {
    GOMGnpHandlerWebsocketProxyUrlNotFound,
    GOMGnpHandlerWebsocketNotOpen
} GOMGnpHandlerErrorCode;

@interface GOMGnpHandler : NSObject

@property (nonatomic, strong, readonly) NSURL *webSocketUri;
@property (nonatomic, strong, readonly) NSDictionary *bindings;
@property (nonatomic, weak) id<GOMGnpHandlerDelegate> delegate;

- (id)initWithWebsocketUri:(NSURL *)websocketUri delegate:(id<GOMGnpHandlerDelegate>)delegate;

- (void)reconnectWebsocket;
- (void)disconnectWebsocket;

- (void)registerGOMObserverForPath:(NSString *)path clientCallback:(GOMClientGNPCallback)callback;
- (void)unregisterGOMObserverForPath:(NSString *)path;

@end
