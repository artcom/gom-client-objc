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
#import "NSData+JSON.h"
#import "NSDictionary+JSON.h"
#import "NSDictionary+XML.h"


NSString* const GOMClientErrorDomain = @"de.artcom.gom-client-objc";
NSString* const WEBSOCKETS_PROXY_PATH = @"/services/websockets_proxy:url";

@interface GOMClient () <SRWebSocketDelegate>

- (NSURLRequest *)_createRequestWithPath:(NSString *)path method:(NSString *)method headerFields:(NSDictionary *)headerFields payloadData:(NSData *)payloadData;
- (void)_handleOperationResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *)connectionError completionBlock:(GOMClientOperationCallback)block;

- (void)_registerGOMObserverForBinding:(GOMBinding *)binding;
- (void)_unregisterGOMObserverForBinding:(GOMBinding *)binding;
- (void)_sendCommand:(NSDictionary *)commands;

- (void)_handleGNPResponse:(NSDictionary* )response;
- (void)_handleInitialResponse:(NSDictionary *)response;
- (void)_handleGNPFromResponse:(NSDictionary *)response;
- (void)_retrieveInitial:(GOMBinding *)binding;

- (void)_reconnectWebsocket;
- (void)_disconnectWebsocket;
- (void)_returnError:(NSError *)error;
- (NSError *)_gomClientErrorForCode:(GOMClientErrorCode)code;

@end

@implementation GOMClient {
    SRWebSocket *_webSocket;
    NSString *_webSocketUri;
}

- (id)initWithGomURI:(NSURL *)gomURI delegate:(id<GOMClientDelegate>)delegate
{
    self = [super init];
    if (self) {
        _gomRoot = gomURI;
        _bindings = [[NSMutableDictionary alloc] init];
        _delegate = delegate;
        [self _reconnectWebsocket];
    }
    return self;
}

- (void)dealloc
{
    [self _disconnectWebsocket];
}

- (void)setDelegate:(id<GOMClientDelegate>)delegate
{
    [self _disconnectWebsocket];
    _delegate = delegate;
    [self _reconnectWebsocket];
}

#pragma mark - GOM operations

- (void)retrieve:(NSString *)path completionBlock:(GOMClientOperationCallback)block
{
    NSURLRequest *request = [self _createRequestWithPath:path method:@"GET" headerFields:@{@"Content-Type" : @"application/json", @"Accept" : @"application/json"} payloadData:nil];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [self _handleOperationResponse:response data:data error:connectionError completionBlock:block];
    }];
}

- (void)create:(NSString *)node withAttributes:(NSDictionary *)attributes completionBlock:(GOMClientOperationCallback)block
{
    if (attributes == nil) {
        attributes = @{};
    }
    NSString *payload = [NSString stringWithFormat:@"<node>%@</node>", [attributes convertToXML]];
    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [self _createRequestWithPath:node method:@"POST" headerFields:@{@"Content-Type" : @"application/xml", @"Accept" : @"application/json"} payloadData:payloadData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [self _handleOperationResponse:response data:data error:connectionError completionBlock:block];
    }];
}

- (void)updateAttribute:(NSString *)attribute withValue:(NSString *)value completionBlock:(GOMClientOperationCallback)block
{
    NSString *payload = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><attribute type=\"string\">%@</attribute>", value];
    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [self _createRequestWithPath:attribute method:@"PUT" headerFields:@{@"Content-Type" : @"application/xml", @"Accept" : @"application/json"} payloadData:payloadData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [self _handleOperationResponse:response data:data error:connectionError completionBlock:block];
    }];
}

- (void)updateNode:(NSString *)node withAttributes:(NSDictionary *)attributes completionBlock:(GOMClientOperationCallback)block
{
    if (attributes == nil) {
        attributes = @{};
    }
    NSString *payload = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><node>%@</node>", [attributes convertToXML]];
    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [self _createRequestWithPath:node method:@"PUT" headerFields:@{@"Content-Type" : @"application/xml", @"Accept" : @"application/json"} payloadData:payloadData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [self _handleOperationResponse:response data:data error:connectionError completionBlock:block];
    }];
}

- (void)destroy:(NSString *)path completionBlock:(GOMClientOperationCallback)block
{
    NSURLRequest *request = [self _createRequestWithPath:path method:@"DELETE" headerFields:nil payloadData:nil];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [self _handleOperationResponse:response data:data error:connectionError completionBlock:block];
    }];
}

- (NSURLRequest *)_createRequestWithPath:(NSString *)path method:(NSString *)method headerFields:(NSDictionary *)headerFields payloadData:(NSData *)payloadData {
    NSURL *requestURL = [_gomRoot URLByAppendingPathComponent:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setHTTPMethod:method];
    
    if (headerFields) {
        [request setAllHTTPHeaderFields:headerFields];
    }
    if (payloadData) {
        [request setHTTPBody:payloadData];
    }
    return request;
}

- (void)_handleOperationResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *)connectionError completionBlock:(GOMClientOperationCallback)block
{
    NSDictionary *responseData = nil;
    NSError *error = nil;
    
    if (connectionError) {
        error = connectionError;
    } else {
        NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
        if (statusCode == 200) {
            if (data) {
                responseData = [data parseAsJSON];
            }
            if (responseData == nil) {
                responseData = @{@"success" : @YES};
            }
        } else if (statusCode >= 400) {
            
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : [NSHTTPURLResponse localizedStringForStatusCode:statusCode]};
            error = [NSError errorWithDomain:GOMClientErrorDomain code:statusCode userInfo:userInfo];
        }
    }
    
    if (block) {
        block(responseData, error);
    }
}

#pragma mark - GOM observers

- (void)registerGOMObserverForPath:(NSString *)path options:(NSDictionary *)options clientCallback:(GOMClientGNPCallback)callback
{
    GOMBinding *binding = _bindings[path];
    if (binding == nil) {
        binding = [[GOMBinding alloc] initWithSubscriptionUri:path];
        _bindings[path] = binding;
    }
    GOMHandle *handle = [[GOMHandle alloc] initWithBinding:binding callback:callback];
    [binding addHandle:handle];
    
    [self _registerGOMObserverForBinding:binding];
}

- (void)unregisterGOMObserverForPath:(NSString *)path options:(NSDictionary *)options
{
    GOMBinding *binding = _bindings[path];
    [self _unregisterGOMObserverForBinding:binding];
    [_bindings removeObjectForKey:path];
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

- (void)_handleGNPResponse:(NSDictionary* )response
{
    if (response[@"initial"]) {
        [self _handleInitialResponse:response];
    } else if (response[@"payload"]) {
        [self _handleGNPFromResponse:response];
    }
}

- (void)_handleInitialResponse:(NSDictionary *)response
{
    NSString *payloadString = response[@"initial"];
    NSMutableDictionary *payload = [payloadString parseAsJSON];
    
    if (payloadString) {
        NSString *path = response[@"path"];
        GOMBinding *binding = _bindings[path];
        if (binding) {
            [binding fireInitialCallbacksWithObject:payload];
        }
    }
}

- (void)_handleGNPFromResponse:(NSDictionary *)response
{
    NSMutableDictionary *operation = nil;
    NSString *payloadString = response[@"payload"];
    
    if (payloadString) {
        NSMutableDictionary *payload = [payloadString parseAsJSON];
        if (payload[@"create"]) {
            operation = payload [@"create"];
        } else if (payload[@"update"]) {
            operation = payload[@"update"];
        } else if (payload[@"delete"]) {
            operation = payload[@"delete"];
        }
        NSString *path = response[@"path"];
        GOMBinding *binding = _bindings[path];
        if (operation && binding) {
            [binding fireCallbacksWithObject:operation];
        }
    }
}


- (void)_retrieveInitial:(GOMBinding *)binding
{
    [self retrieve:binding.subscriptionUri completionBlock:^(NSDictionary *response, NSError *error) {
        if (response) {
            [binding fireInitialCallbacksWithObject:response];
        } else {
            [self _returnError:error];
        }
    }];
}

- (void)_reconnectWebsocket
{
    [self _disconnectWebsocket];
    [self retrieve:WEBSOCKETS_PROXY_PATH completionBlock:^(NSDictionary *response, NSError *error) {
        if (response) {
            NSDictionary *attribute = response[@"attribute"];
            if (attribute) {
                _webSocketUri = attribute[@"value"];
                if (_webSocketUri) {
                    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_webSocketUri]]];
                    _webSocket.delegate = self;
                    [_webSocket open];
                    return;
                }
            }
        }
        [self _returnError:[self _gomClientErrorForCode:GOMClientWebsocketProxyUrlNotFound]];
    }];
}

- (void)_disconnectWebsocket
{
    _webSocket.delegate = nil;
    
    [_bindings removeAllObjects];
    
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
        default:
            description = @"Unknown error code.";
            break;
    }
    
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : NSLocalizedString(description, nil)};
    return [NSError errorWithDomain:GOMClientErrorDomain code:code userInfo:userInfo];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    if ([self.delegate respondsToSelector:@selector(gomClientDidBecomeReady:)]) {
        [self.delegate gomClientDidBecomeReady:self];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@"Websocket Failed With Error %@", error);
    _webSocket = nil;
    
    [self _returnError:error];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSString *messageString = (NSString *)message;
    NSMutableDictionary *response = [messageString parseAsJSON];
    
    if (response) {
        [self _handleGNPResponse:response];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed with code: %ld\n%@\nclean: %d", (long)code, reason, wasClean);
    _webSocket = nil;
}

@end
