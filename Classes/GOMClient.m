//
//  GOMClient.m
//  gom-client-objc
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import "GOMClient.h"
#import "SRWebSocket.h"
#import "NSString+JSON.h"
#import "NSString+XML.h"
#import "NSData+JSON.h"
#import "NSDictionary+JSON.h"
#import "NSDictionary+XML.h"
#import "NSURLRequest+GOMClient.h"


NSString * const GOMClientErrorDomain = @"de.artcom.gom-client-objc";
NSString * const WEBSOCKETS_PROXY_PATH = @"/services/websockets_proxy:url";

@interface GOMClient () <SRWebSocketDelegate, GOMOperationDelegate>

- (void)_runGOMOperationWithRequest:(NSURLRequest *)request completionBlock:(GOMClientOperationCallback)block;
- (void)_registerGOMObserverForBinding:(GOMBinding *)binding;
- (void)_unregisterGOMObserverForBinding:(GOMBinding *)binding;
- (void)_sendCommand:(NSDictionary *)commands;

- (void)_handleWebSocketMessage:(NSDictionary* )response;
- (void)_handleInitialResponse:(NSDictionary *)response;
- (void)_handleGNPResponse:(NSDictionary *)response;
- (void)_retrieveInitial:(GOMBinding *)binding;

- (void)_reRegisterObservers;
- (void)_returnError:(NSError *)error;
- (NSError *)_gomClientErrorForCode:(GOMClientErrorCode)code;

@end

@implementation GOMClient {
    SRWebSocket *_webSocket;
    NSString *_webSocketUri;
    NSMutableDictionary *_priv_bindings;
    NSMutableArray *_operations;
}

- (id)initWithGomURI:(NSURL *)gomURI delegate:(id<GOMClientDelegate>)delegate
{
    self = [super init];
    if (self) {
        _gomRoot = gomURI;
        _priv_bindings = [[NSMutableDictionary alloc] init];
        _operations = [[NSMutableArray alloc] init];
        _delegate = delegate;
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

#pragma mark - GOM operations

- (void)retrieve:(NSString *)path completionBlock:(GOMClientOperationCallback)block
{
    NSURLRequest *request = [NSURLRequest createGetRequestWithPath:path gomRoot:self.gomRoot];
    [self _runGOMOperationWithRequest:request completionBlock:block];
}

- (void)create:(NSString *)node withAttributes:(NSDictionary *)attributes completionBlock:(GOMClientOperationCallback)block
{
    if (attributes == nil) {
        attributes = @{};
    }
    NSString *payload = [attributes convertToNodeXML];
    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest createPostRequestWithPath:node payload:payloadData gomRoot:self.gomRoot];
    [self _runGOMOperationWithRequest:request completionBlock:block];
}

- (void)updateAttribute:(NSString *)attribute withValue:(NSString *)value completionBlock:(GOMClientOperationCallback)block
{
    NSString *payload = [value convertToAttributeXML];
    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest createPutRequestWithPath:attribute payload:payloadData gomRoot:self.gomRoot];
    [self _runGOMOperationWithRequest:request completionBlock:block];
}

- (void)updateNode:(NSString *)node withAttributes:(NSDictionary *)attributes completionBlock:(GOMClientOperationCallback)block
{
    if (attributes == nil) {
        attributes = @{};
    }
    NSString *payload = [attributes convertToNodeXML];
    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest createPutRequestWithPath:node payload:payloadData gomRoot:self.gomRoot];
    [self _runGOMOperationWithRequest:request completionBlock:block];
}

- (void)destroy:(NSString *)path completionBlock:(GOMClientOperationCallback)block
{
    NSURLRequest *request = [NSURLRequest createDeleteRequestWithPath:path gomRoot:self.gomRoot];
    [self _runGOMOperationWithRequest:request completionBlock:block];
}

- (void)_runGOMOperationWithRequest:(NSURLRequest *)request completionBlock:(GOMClientOperationCallback)block
{
    GOMOperation *operation = [[GOMOperation alloc] initWithRequest:request delegate:self callback:block];
    [_operations addObject:operation];
    [operation run];
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
    } else {
        [self _retrieveInitial:binding];
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
        [self _returnError:[self _gomClientErrorForCode:GOMClientWebsocketNotOpen]];
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

- (void)_retrieveInitial:(GOMBinding *)binding
{
    [self retrieve:binding.subscriptionUri completionBlock:^(NSDictionary *response, NSError *error) {
        if (response) {
            NSMutableDictionary *gnpDictionary = [[NSMutableDictionary alloc] init];
            gnpDictionary[@"payload"] = response;
            gnpDictionary[@"event_type"] = @"initial";
            gnpDictionary[@"path"] = binding.subscriptionUri;
            [binding fireInitialCallbacksWithObject:gnpDictionary];
        } else {
            [self _returnError:error];
        }
    }];
}

- (void)reconnectWebsocket
{
    [self disconnectWebsocket];
    [self retrieve:WEBSOCKETS_PROXY_PATH completionBlock:^(NSDictionary *response, NSError *error) {
        if (response) {
            GOMAttribute *attribute = [GOMAttribute attributeFromDictionary:response];
            if (attribute) {
                _webSocketUri = attribute.value;
                if (_webSocketUri) {
                    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_webSocketUri]]];
                    _webSocket.delegate = self;
                    [_webSocket open];
                    return;
                }
            }
        }
        [self _returnError:[self _gomClientErrorForCode:(GOMClientErrorCode)error.code]];
    }];
}

- (void)disconnectWebsocket
{
    _webSocket.delegate = nil;
    
    [_webSocket close];
    _webSocket = nil;
}

#pragma mark - Error handling

- (void)_returnError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(gomClient:didFailWithError:)]) {
        [self.delegate gomClient:self didFailWithError:error];
    }
}

- (NSError *)_gomClientErrorForCode:(GOMClientErrorCode)code
{
    NSString *description = nil;
    
    switch (code) {
        case GOMClientWebsocketProxyUrlNotFound:
            description = @"Websocket proxy url not found.";
            break;
        case GOMClientWebsocketNotOpen:
            description = @"Websocket not open.";
            break;
        case GOMClientTooManyRedirects:
            description = @"Too many redirects.";
            break;
        default:
            description = @"Unknown error code.";
            break;
    }
    
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : NSLocalizedString(description, nil)};
    return [NSError errorWithDomain:GOMClientErrorDomain code:code userInfo:userInfo];
}

- (void)_reRegisterObservers
{
    if ([self.delegate respondsToSelector:@selector(gomClient:shouldReRegisterObserverWithBinding:)]) {
        for (NSString *path in _priv_bindings.allKeys) {
            GOMBinding *binding = _priv_bindings[path];
            if ([self.delegate gomClient:self shouldReRegisterObserverWithBinding:binding]) {
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
    if ([self.delegate respondsToSelector:@selector(gomClientShouldReconnect:)]) {
        if ([self.delegate gomClientShouldReconnect:self]) {
            [self reconnectWebsocket];
        }
    }
}

#pragma mark - GOMOperationDelegate

- (void)gomOperationDidFinish:(GOMOperation *)operation
{
    [_operations removeObject:operation];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    if ([self.delegate respondsToSelector:@selector(gomClientDidBecomeReady:)]) {
        [self.delegate gomClientDidBecomeReady:self];
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
