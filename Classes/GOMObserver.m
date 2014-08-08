//
//  GOMObserver.m
//  gom-client-objc
//
//  Created by Julian Krumow on 07.08.14.
//  Copyright (c) 2014 ART+COM AG. All rights reserved.
//

#import "GOMObserver.h"
#import "SRWebSocket.h"

#import "GOMGnp.h"
#import "GOMAttribute.h"
#import "GOMNode.h"
#import "NSString+JSON.h"
#import "NSString+XML.h"
#import "NSData+JSON.h"
#import "NSDictionary+JSON.h"
#import "NSDictionary+XML.h"

NSString * const GOMObserverErrorDomain = @"de.artcom.gom-client-objc.observer";

@interface GOMObserver () <SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *webSocket;
@property (nonatomic, strong) NSMutableDictionary *priv_bindings;

- (void)_registerGOMObserverForBinding:(GOMBinding *)binding;
- (void)_unregisterGOMObserverForBinding:(GOMBinding *)binding;
- (void)_sendCommand:(NSDictionary *)commands;

- (void)_handleWebSocketMessage:(NSDictionary* )response;
- (void)_handleInitialResponse:(NSDictionary *)response;
- (void)_handleGNPResponse:(NSDictionary *)response;

- (void)_checkReconnect;
- (void)_reRegisterObservers;
- (void)_returnError:(NSError *)error;
- (NSError *)_gomObserverErrorForCode:(GOMObserverErrorCode)code;
- (GOMEntry *)_createGOMEntryFromDictionary:(NSDictionary *)dictionary;

@end

@implementation GOMObserver

- (instancetype)initWithWebsocketUri:(NSURL *)websocketUri delegate:(id<GOMObserverDelegate>)delegate
{
    self = [super init];
    if (self) {
        _webSocketUri = websocketUri;
        _delegate = delegate;
        _priv_bindings = [[NSMutableDictionary alloc] init];
        [self reconnectWebsocket];
    }
    return self;
}

- (void)dealloc
{
    [self disconnectWebsocket];
}

- (NSDictionary *)bindings
{
    return (NSDictionary *)_priv_bindings;
}

#pragma mark - GOM observers

- (void)registerGOMObserverForPath:(NSString *)path clientCallback:(GOMClientGNPCallback)callback
{
    GOMBinding *binding = _priv_bindings[path];
    if (binding == nil) {
        binding = [[GOMBinding alloc] initWithSubscriptionUri:path];
        _priv_bindings[path] = binding;
    }
    GOMHandle *handle = [[GOMHandle alloc] initWithBinding:binding callback:callback];
    [binding addHandle:handle];
    
    [self _registerGOMObserverForBinding:binding];
}

- (void)unregisterGOMObserverForPath:(NSString *)path
{
    GOMBinding *binding = _priv_bindings[path];
    [self _unregisterGOMObserverForBinding:binding];
    [_priv_bindings removeObjectForKey:path];
}

- (void)_registerGOMObserverForBinding:(GOMBinding *)binding
{
    NSLog(@"registering GOM observer at path: %@", binding.subscriptionUri);
    
    if (binding.registered == NO) {
        NSDictionary *commands = @{@"command" : @"subscribe", @"path" : binding.subscriptionUri};
        [self _sendCommand:commands];
        binding.registered = YES;
    }
}

- (void)_unregisterGOMObserverForBinding:(GOMBinding *)binding
{
    NSLog(@"unregistering GNP at path: %@", binding.subscriptionUri);
    
    if (binding.registered) {
        NSDictionary *commands = @{@"command" : @"unsubscribe", @"path" : binding.subscriptionUri};
        [self _sendCommand:commands];
        binding.registered = NO;
    }
}

- (void)_sendCommand:(NSDictionary *)commands
{
    if (_webSocket && _webSocket.readyState == SR_OPEN) {
        NSData *jsonData = [commands convertToJSON];
        [_webSocket send:jsonData];
    } else {
        [self _returnError:[self _gomObserverErrorForCode:GOMObserverWebsocketNotOpen]];
    }
}

- (void)_handleWebSocketMessage:(NSDictionary* )response
{
    if (response[@"initial"]) {
        [self _handleInitialResponse:response];
    } else if (response[@"payload"]) {
        [self _handleGNPResponse:response];
    }
}

- (void)_handleInitialResponse:(NSDictionary *)response
{
    NSString *payloadString = response[@"initial"];
    
    if (payloadString) {
        GOMGnp *gnpObject = [[GOMGnp alloc] init];
        NSDictionary *parsedPayload = [payloadString parseAsJSON];
        gnpObject.payload = [self _createGOMEntryFromDictionary:parsedPayload];
        gnpObject.eventType = @"initial";
        
        NSString *path = response[@"path"];
        gnpObject.path = path;
        
        GOMBinding *binding = _priv_bindings[path];
        if (binding) {
            [binding fireInitialCallbacksWithObject:gnpObject];
        }
    }
}

- (void)_handleGNPResponse:(NSDictionary *)response
{
    NSString *payloadString = response[@"payload"];
    
    if (payloadString) {
        GOMGnp *gnpObject = [[GOMGnp alloc] init];
        NSDictionary *parsedPayload = [payloadString parseAsJSON];
        if (parsedPayload[@"create"]) {
            gnpObject.payload = [self _createGOMEntryFromDictionary:parsedPayload[@"create"]];
            gnpObject.eventType = @"create";
        } else if (parsedPayload[@"update"]) {
            gnpObject.payload = [self _createGOMEntryFromDictionary:parsedPayload[@"update"]];
            gnpObject.eventType = @"update";
        } else if (parsedPayload[@"delete"]) {
            gnpObject.payload = [self _createGOMEntryFromDictionary:parsedPayload[@"delete"]];
            gnpObject.eventType = @"delete";
        }
        
        NSString *path = response[@"path"];
        gnpObject.path = path;
        
        GOMBinding *binding = _priv_bindings[path];
        if (gnpObject.payload && binding) {
            [binding fireCallbacksWithObject:gnpObject];
        }
    }
}

- (GOMEntry *)_createGOMEntryFromDictionary:(NSDictionary *)dictionary
{
    GOMEntry *entry = nil;
    if ([GOMAttribute isAttribute:dictionary]) {
        entry = [GOMAttribute attributeFromDictionary:dictionary];
    } else {
        entry = [GOMNode nodeFromDictionary:dictionary];
    }
    return entry;
}

- (void)reconnectWebsocket
{
    [self disconnectWebsocket];
    if (_webSocketUri) {
        _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:_webSocketUri]];
        _webSocket.delegate = self;
        [_webSocket open];
        return;
    }
    [self _returnError:[self _gomObserverErrorForCode:GOMObserverWebsocketProxyUrlNotFound]];
}

- (void)disconnectWebsocket
{
    _webSocket.delegate = nil;
    
    [_webSocket close];
    _webSocket = nil;
}

- (void)_returnError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(gomObserver:didFailWithError:)]) {
        [self.delegate gomObserver:self didFailWithError:error];
    }
}

- (NSError *)_gomObserverErrorForCode:(GOMObserverErrorCode)code
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
            description = @"Unknown error code.";
            break;
    }
    
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : NSLocalizedString(description, nil)};
    return [NSError errorWithDomain:GOMObserverErrorDomain code:code userInfo:userInfo];
}

- (void)_reRegisterObservers
{
    if ([self.delegate respondsToSelector:@selector(gomObserver:shouldReRegisterObserverWithBinding:)]) {
        for (NSString *path in _priv_bindings.allKeys) {
            GOMBinding *binding = _priv_bindings[path];
            if ([self.delegate gomObserver:self shouldReRegisterObserverWithBinding:binding]) {
                binding.registered = NO;
                [self _registerGOMObserverForBinding:binding];
            } else {
                [_priv_bindings removeObjectForKey:path];
            }
        }
    } else {
        [_priv_bindings removeAllObjects];
    }
}

- (void)_checkReconnect
{
    if ([self.delegate respondsToSelector:@selector(gomObserverShouldReconnect:)]) {
        if ([self.delegate gomObserverShouldReconnect:self]) {
            [self reconnectWebsocket];
        }
    }
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    if ([self.delegate respondsToSelector:@selector(gomObserverDidBecomeReady:)]) {
        [self.delegate gomObserverDidBecomeReady:self];
    }
    
    if (_priv_bindings.count > 0) {
        [self _reRegisterObservers];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    _webSocket = nil;
    
    NSLog(@"Websocket Failed With Error %@", error);
    [self _returnError:error];
    
    [self _checkReconnect];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSString *messageString = (NSString *)message;
    NSMutableDictionary *messageDictionary = [messageString parseAsJSON];
    
    if (messageDictionary) {
        [self _handleWebSocketMessage:messageDictionary];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed with code: %ld\n%@\nclean: %d", (long)code, reason, wasClean);
    
    _webSocket = nil;
    
    if (code != 0) {
        [self _checkReconnect];
    }
}

@end
