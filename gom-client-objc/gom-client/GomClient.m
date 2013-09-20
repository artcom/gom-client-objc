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

@interface GOMClient () <SRWebSocketDelegate>

- (void)_registerGOMObserverForBinding:(GOMBinding *)binding;
- (void)_unregisterGOMObserverForBinding:(GOMBinding *)binding;
- (void)_sendCommand:(NSDictionary *)commands;

- (void)_handleResponse:(NSDictionary* )response;
- (void)_handleInitialResponse:(NSDictionary *)response;
- (void)_handleGNPFromResponse:(NSDictionary *)response;
- (void)_fireCallback:(GOMHandleCallback)callback withGomObject:(NSDictionary *)gomObject;
- (void)_retrieveInitial:(GOMBinding *)binding;
- (void)_reconnectWebsocket;
- (void)_disconnectWebsocket;

@end

@implementation GOMClient {
    NSURLConnection *_urlConnection;
    SRWebSocket *_webSocket;
    NSString *_webSocketUri;
}

#define WEBSOCKETS_PROXY_PATH @"/services/websockets_proxy:url"

- (id)initWithGomURI:(NSURL *)gomURI
{
    self = [super init];
    if (self) {
        _gomRoot = gomURI;
        _bindings = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self _disconnectWebsocket];
}

- (void)setDelegate:(id<GOMClientDelegate>)delegate
{
    _delegate = delegate;
    [self _reconnectWebsocket];
}

- (void)retrieve:(NSString *)path completionBlock:(GOMClientCallback)block
{
    NSURL *requestURL = [_gomRoot URLByAppendingPathComponent:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    NSDictionary *headers = @{@"Content-Type" : @"application/json", @"Accept" : @"application/json"};
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *responseData = nil;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        switch (httpResponse.statusCode) {
            case 200:
            {
                if (data) {
                    responseData = [data parseAsJSON];
                }
            }
                break;
            case 500:
                responseData = nil;
                break;
            case 404:
                responseData = nil;
                break;
            default:
                break;
        }
        if (block) {
            block(responseData);
        }
    }];
}

- (void)create:(NSString *)node withAttributes:(NSDictionary *)attributes completionBlock:(GOMClientCallback)block
{
    NSURL *requestURL = [_gomRoot URLByAppendingPathComponent:node];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    NSDictionary *headers = @{@"Content-Type" : @"application/xml", @"Accept" : @"application/json"};
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPMethod:@"POST"];
    
    if (attributes == nil) {
        attributes = @{};
    }
    NSString *payload = [NSString stringWithFormat:@"<node>%@</node>", [attributes convertToXML]];
    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:payloadData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *responseData = nil;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        switch (httpResponse.statusCode) {
            case 200:
            {
                if (data) {
                    responseData = [data parseAsJSON];
                }
            }
                break;
            case 500:
                responseData = nil;
                break;
            default:
                break;
        }
        if (block) {
            block(responseData);
        }
    }];
}

- (void)updateAttribute:(NSString *)attribute withValue:(NSString *)value completionBlock:(GOMClientCallback)block
{
    NSURL *requestURL = [_gomRoot URLByAppendingPathComponent:attribute];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    NSDictionary *headers = @{@"Content-Type" : @"application/xml", @"Accept" : @"application/json"};
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPMethod:@"PUT"];
    
    NSString *payload = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><attribute type=\"string\">%@</attribute>", value];
    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:payloadData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *responseData = nil;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        switch (httpResponse.statusCode) {
            case 200:
            {
                if (data) {
                    responseData = [data parseAsJSON];
                }
            }
                break;
            case 500:
                responseData = nil;
                break;
            default:
                break;
        }
        if (block) {
            block(responseData);
        }
    }];
}

- (void)updateNode:(NSString *)node withAttributes:(NSDictionary *)attributes completionBlock:(GOMClientCallback)block
{
    NSURL *requestURL = [_gomRoot URLByAppendingPathComponent:node];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    NSDictionary *headers = @{@"Content-Type" : @"application/xml", @"Accept" : @"application/json"};
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPMethod:@"PUT"];
    
    if (attributes == nil) {
        attributes = @{};
    }
    NSString *payload = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><node>%@</node>", [attributes convertToXML]];
    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:payloadData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *responseData = nil;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        switch (httpResponse.statusCode) {
            case 200:
            {
                if (data) {
                    responseData = [data parseAsJSON];
                }
            }
                break;
            case 500:
                responseData = nil;
                break;
            default:
                break;
        }
        if (block) {
            block(responseData);
        }
    }];
    
}

- (void)destroy:(NSString *)path completionBlock:(GOMClientCallback)block
{
    NSURL *requestURL = [_gomRoot URLByAppendingPathComponent:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setHTTPMethod:@"DELETE"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        NSDictionary *responseData = nil;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        switch (httpResponse.statusCode) {
            case 200:
            {
                responseData = [NSDictionary dictionaryWithObject:@YES forKey:@"success"];
            }
                break;
            case 500:
                responseData = nil;
                break;
            case 404:
                responseData = nil;
                break;
            default:
                break;
        }
        if (block) {
            block(responseData);
        }
    }];
}

#pragma mark - GOM observers

- (void)registerGOMObserverForPath:(NSString *)path options:(NSDictionary *)options clientCallback:(GOMClientCallback)callback
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
        NSDictionary *commands = commands = @{@"command" : @"subscribe", @"path" : binding.subscriptionUri};
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
        NSDictionary *commands = commands = @{@"command" : @"unsubscribe", @"path" : binding.subscriptionUri};
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
        NSLog(@"Could not open socket.");
    }
}

- (void)_handleResponse:(NSDictionary* )response
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
            for (GOMHandle *handle in binding.handles) {
                if (handle.initialRetrieved == NO) {
                    [self _fireCallback:handle.callback withGomObject:payload];
                    handle.initialRetrieved = YES;
                }
            }
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
            for (GOMHandle *handle in binding.handles) {
                [self _fireCallback:handle.callback withGomObject:operation];
            }
        }
    }
}

- (void)_fireCallback:(GOMHandleCallback)callback withGomObject:(NSDictionary *)gomObject
{
    if (callback) {
        callback(gomObject);
    }
}

- (void)_retrieveInitial:(GOMBinding *)binding
{
    [self retrieve:binding.subscriptionUri completionBlock:^(NSDictionary *response) {
        for (GOMHandle *handle in binding.handles) {
            if (handle.initialRetrieved == NO) {
                [self _fireCallback:handle.callback withGomObject:response];
                handle.initialRetrieved = YES;
            }
        }
    }];
}



- (void)_reconnectWebsocket
{
    [self _disconnectWebsocket];
    [self retrieve:WEBSOCKETS_PROXY_PATH completionBlock:^(NSDictionary *response) {
        NSDictionary *attribute = response[@"attribute"];
        if (attribute) {
            _webSocketUri = attribute[@"value"];
            if (_webSocketUri) {
                _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_webSocketUri]]];
                _webSocket.delegate = self;
                [_webSocket open];
            }
        }
    }];
}

- (void)_disconnectWebsocket
{
    _webSocket.delegate = nil;
    
    [_bindings removeAllObjects];
    
    [_webSocket close];
    _webSocket = nil;
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
    
    if ([self.delegate respondsToSelector:@selector(gomClient:didFailWithError:)]) {
        [self.delegate gomClient:self didFailWithError:error];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSString *messageString = (NSString *)message;
    NSMutableDictionary *response = [messageString parseAsJSON];
    
    if (response) {
        [self _handleResponse:response];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed with code: %ld\n%@\nclean: %d", (long)code, reason, wasClean);
    _webSocket = nil;
}

@end
