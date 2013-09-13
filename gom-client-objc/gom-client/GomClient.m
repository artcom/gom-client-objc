//
//  GOMClient.m
//  gom-client-objc
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM. All rights reserved.
//

#import "GOMClient.h"
#import "GOMBinding.h"
#import "SRWebSocket.h"
#import "NSString+JSON.h"

@interface GOMClient () <SRWebSocketDelegate>

@property (nonatomic, retain) NSMutableDictionary *bindings;

- (void)_reconnect;
- (void)_disconnect;

- (void)_registerGOMObserverForBinding:(GOMBinding *)binding;
- (void)_unregisterGOMObserverForBinding:(GOMBinding *)binding;
- (void)_sendCommand:(NSDictionary *)commands;

- (void)_handleResponse:(NSDictionary* )response;
- (void)_handleInitialResponse:(NSDictionary *)response;
- (void)_handleGNPFromResponse:(NSDictionary *)response;

- (void)_fireCallback:(GOMHandleCallback)callback withGomObject:(NSDictionary *)gomObject;

- (void)_retrieveInitial:(GOMBinding *)binding;

@end

@implementation GOMClient {
    NSURLConnection *_urlConnection;
    SRWebSocket *_webSocket;
    NSString *_webSocketUri;
    NSMutableArray *_messages;
    BOOL gomIsReady;
}

@synthesize gomRoot = _gomRoot;

- (id)initWithGOMRoot:(NSURL *)gomRoot
{
    self = [super init];
    if (self) {
        _gomRoot = gomRoot;
        _bindings = [[NSMutableDictionary alloc] init];
        gomIsReady = false;
        
        [self _reconnect];
    }
    return self;
}

- (void)retrieveAttribute:(NSString *)attribute completionBlock:(GOMClientCallback)block
{
    
    if (block) {
        block(nil);
    }
}

- (void)retrieveNode:(NSString *)node completionBlock:(GOMClientCallback)block
{
    
}

- (void)createNode:(NSString *)node completionBlock:(GOMClientCallback)block
{
    
}

- (void)createNode:(NSString *)node withAttributes:(NSDictionary *)attributes completionBlock:(GOMClientCallback)block
{
    
}

- (void)updateAttribute:(NSString *)attribute withValue:(NSString *)value completionBlock:(GOMClientCallback)block
{
    
}

- (void)updateNode:(NSString *)node withAttributes:(NSDictionary *)attributes completionBlock:(GOMClientCallback)block
{
    
}

- (void)deleteNode:(NSString *)node completionBlock:(GOMClientCallback)block
{
    
}


#pragma mark - GOM observers

- (void)_reconnect
{
    _webSocket.delegate = nil;
    [_webSocket close];
    
    [self retrieveAttribute:@"/services/websockets_proxy:url" completionBlock:^(NSDictionary *response){
        
        // TODO: check for successful request and set uri
        _webSocketUri = @"ws://172.40.2.20:3082/";
        _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_webSocketUri]]];
        _webSocket.delegate = self;
        
        [_webSocket open];
    }];
}

- (void)_disconnect
{
    _webSocket.delegate = nil;
    
    for (GOMBinding *binding in _bindings) {
        [self _unregisterGOMObserverForBinding:binding];
    }
    
    [_webSocket close];
    _webSocket = nil;
}

- (void)registerGOMObserverForPath:(NSString *)path options:(NSDictionary *)options completionBlock:(GOMClientCallback)block
{
    GOMBinding *binding = [[GOMBinding alloc] initWithSubscriptionUri:path];
    _bindings[path] = binding;
    
    GOMHandle *handle = [[GOMHandle alloc] initWithBinding:binding callback:block];
    [binding addHandle:handle];
    [self _registerGOMObserverForBinding:binding];
}

- (void)_registerGOMObserverForBinding:(GOMBinding *)binding
{
    NSLog(@"registering GOM observer at path: %@", binding.subscriptionUri);
    
    if (binding.registered == NO) {
        NSMutableDictionary *commands = [[NSMutableDictionary alloc] init];
        [commands setValue:@"subscribe" forKey:@"command"];
        [commands setValue:binding.subscriptionUri forKey:@"path"];
        [self _sendCommand:commands];
        binding.registered = true;
    } else {
        [self _retrieveInitial:binding];
    }
}

- (void)_unregisterGOMObserverForBinding:(GOMBinding *)binding
{
    NSLog(@"unregistering GNP at path: %@", binding.subscriptionUri);
    
    if (binding.registered) {
        NSMutableDictionary *commands = [[NSMutableDictionary alloc] init];
        [commands setValue:@"unsubscribe" forKey:@"command"];
        [commands setValue:binding.subscriptionUri forKey:@"path"];
        [self _sendCommand:commands];
        binding.registered = false;
    }
}

- (void)_sendCommand:(NSDictionary *)commands
{
    if (_webSocket && _webSocket.readyState == SR_OPEN) {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:commands options:kNilOptions error:&error];
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
    
    NSString *path = response[@"path"];
    GOMBinding *binding = _bindings[path];
    if (binding) {
        for (GOMHandle *handle in binding.handles) {
            [self _fireCallback:handle.callback withGomObject:payload];
        }
    }
}

- (void)_handleGNPFromResponse:(NSDictionary *)response
{
    NSMutableDictionary *operation = nil;
    NSString *payloadString = response[@"payload"];
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

- (void)_fireCallback:(GOMHandleCallback)callback withGomObject:(NSDictionary *)gomObject
{
    if (callback) {
        callback(gomObject);
    }
}

- (void)_retrieveInitial:(GOMBinding *)binding
{
    // TODO: check is gom ready?
    
    // retrieve gom path which was already bound.
    
    // get gom object
    NSMutableDictionary *gomObject = nil;
    
    for (GOMHandle *handle in binding.handles) {
        [self _fireCallback:handle.callback withGomObject:gomObject];
    }
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
    NSLog(@":( Websocket Failed With Error %@", error);
    
    _webSocket = nil;
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
    NSLog(@"WebSocket closed");
    _webSocket = nil;
}

@end
