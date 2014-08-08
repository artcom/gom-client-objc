//
//  GOMGnpHandler.m
//  gom-client-objc
//
//  Created by Julian Krumow on 07.08.14.
//  Copyright (c) 2014 ART+COM AG. All rights reserved.
//

#import "GOMGnpHandler.h"
#import "SRWebSocket.h"

#import "NSString+JSON.h"
#import "NSString+XML.h"
#import "NSData+JSON.h"
#import "NSDictionary+JSON.h"
#import "NSDictionary+XML.h"

NSString * const GOMGnpHandlerErrorDomain = @"de.artcom.gom-client-objc.gnphandler";

@interface GOMGnpHandler () <SRWebSocketDelegate>

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
- (NSError *)_gomGnpHandlerForCode:(GOMGnpHandlerErrorCode)code;

@end

@implementation GOMGnpHandler

- (instancetype)initWithWebsocketUri:(NSURL *)websocketUri delegate:(id<GOMGnpHandlerDelegate>)delegate
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
        [self _returnError:[self _gomGnpHandlerForCode:GOMGnpHandlerWebsocketNotOpen]];
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
        NSMutableDictionary *gnpDictionary = [[NSMutableDictionary alloc] init];
        NSDictionary *parsedPayload = [payloadString parseAsJSON];
        gnpDictionary[@"payload"] = parsedPayload;
        gnpDictionary[@"event_type"] = @"initial";
        
        NSString *path = response[@"path"];
        gnpDictionary[@"path"] = path;
        
        GOMBinding *binding = _priv_bindings[path];
        if (binding) {
            [binding fireInitialCallbacksWithObject:gnpDictionary];
        }
    }
}

- (void)_handleGNPResponse:(NSDictionary *)response
{
    NSString *payloadString = response[@"payload"];
    
    if (payloadString) {
        NSMutableDictionary *gnpDictionary = [[NSMutableDictionary alloc] init];
        NSDictionary *parsedPayload = [payloadString parseAsJSON];
        if (parsedPayload[@"create"]) {
            gnpDictionary[@"payload"] = parsedPayload[@"create"];
            gnpDictionary[@"event_type"] = @"create";
        } else if (parsedPayload[@"update"]) {
            gnpDictionary[@"payload"] = parsedPayload[@"update"];
            gnpDictionary[@"event_type"] = @"update";
        } else if (parsedPayload[@"delete"]) {
            gnpDictionary[@"payload"] = parsedPayload[@"delete"];
            gnpDictionary[@"event_type"] = @"delete";
        }
        
        NSString *path = response[@"path"];
        gnpDictionary[@"path"] = path;
        
        GOMBinding *binding = _priv_bindings[path];
        if (gnpDictionary[@"payload"] && binding) {
            [binding fireCallbacksWithObject:gnpDictionary];
        }
    }
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
    [self _returnError:[self _gomGnpHandlerForCode:GOMGnpHandlerWebsocketProxyUrlNotFound]];
}

- (void)disconnectWebsocket
{
    _webSocket.delegate = nil;
    
    [_webSocket close];
    _webSocket = nil;
}

- (void)_returnError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(gomGnpHandler:didFailWithError:)]) {
        [self.delegate gomGnpHandler:self didFailWithError:error];
    }
}

- (NSError *)_gomGnpHandlerForCode:(GOMGnpHandlerErrorCode)code
{
    NSString *description = nil;
    
    switch (code) {
        case GOMGnpHandlerWebsocketProxyUrlNotFound:
            description = @"Websocket proxy url not found.";
            break;
        case GOMGnpHandlerWebsocketNotOpen:
            description = @"Websocket not open.";
            break;
        default:
            description = @"Unknown error code.";
            break;
    }
    
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : NSLocalizedString(description, nil)};
    return [NSError errorWithDomain:GOMGnpHandlerErrorDomain code:code userInfo:userInfo];
}

- (void)_reRegisterObservers
{
    if ([self.delegate respondsToSelector:@selector(gomGnpHandler:shouldReRegisterObserverWithBinding:)]) {
        for (NSString *path in _priv_bindings.allKeys) {
            GOMBinding *binding = _priv_bindings[path];
            if ([self.delegate gomGnpHandler:self shouldReRegisterObserverWithBinding:binding]) {
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
    if ([self.delegate respondsToSelector:@selector(gomGnpHandlerShouldReconnect:)]) {
        if ([self.delegate gomGnpHandlerShouldReconnect:self]) {
            [self reconnectWebsocket];
        }
    }
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    if ([self.delegate respondsToSelector:@selector(gomGnpHandlerDidBecomeReady:)]) {
        [self.delegate gomGnpHandlerDidBecomeReady:self];
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
