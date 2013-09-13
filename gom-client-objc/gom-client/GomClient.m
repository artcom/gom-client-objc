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

- (void)setup;
- (void)registerGOMObserverForBinding:(GOMBinding *)binding;
- (void)unregisterGOMObserverForBinding:(GOMBinding *)binding;
- (void)sendCommand:(NSDictionary *)commands;

- (void)handleResponse:(NSDictionary* )response;
- (void)handleInitialResponse:(NSDictionary *)response;
- (void)handleGNPFromResponse:(NSDictionary *)response;

- (void)fireCallback:(GOMHandleCallback)callback withGomObject:(NSDictionary *)gomObject;

- (void)retrieveInitial:(GOMBinding *)binding;

@end

@implementation GOMClient {
    SRWebSocket *_webSocket;
    NSString *_webSocketUri;
    NSMutableArray *_messages;
}

@synthesize gomRoot = _gomRoot;

- (id)initWithGOMRoot:(NSString *)gomRoot
{
    self = [super init];
    if (self) {
        _gomRoot = gomRoot;
        _bindings = [[NSMutableDictionary alloc] init];
        
        [self reconnect];
    }
    return self;
}

- (void)retrieveAttribute:(NSString *)attribute
{
    
}

- (void)retrieveNode:(NSString *)node
{
    
}

- (void)createNode:(NSString *)node
{
    
}

- (void)createNode:(NSString *)node withAttributes:(NSDictionary *)attributes
{
    
}

- (void)updateAttribute:(NSString *)attribute withValue:(NSString *)value
{
    
}

- (void)updateNode:(NSString *)node withAttributes:(NSDictionary *)attributes
{
    
}

- (void)deleteNode:(NSString *)node
{
    
}


#pragma mark - GOM observers

- (void)registerGOMObserverForPath:(NSString *)path withCallback:(GOMClientCallback)callback
{
    GOMBinding *binding = [[GOMBinding alloc] initWithSubscriptionUri:path];
    _bindings[path] = binding;
    
    GOMHandle *handle = [[GOMHandle alloc] initWithBinding:binding callback:callback];
    [binding addHandle:handle];
    [self registerGOMObserverForBinding:binding];
}

- (void)reconnect
{
    _webSocket.delegate = nil;
    [_webSocket close];
    
    
    // TODO: read /services/websockets_proxy:url
    _webSocketUri = @"ws://172.40.2.20:3082/";
    
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_webSocketUri]]];
    _webSocket.delegate = self;
    
    [_webSocket open];
    
}

- (void)disconnect
{
    _webSocket.delegate = nil;
    
    for (GOMBinding *binding in _bindings) {
        [self unregisterGOMObserverForBinding:binding];
    }
    
    [_webSocket close];
    _webSocket = nil;
}

- (void)setup {
    if ([self.delegate respondsToSelector:@selector(gomClientDidBecomeReady:)]) {
        [self.delegate gomClientDidBecomeReady:self];
    }
}

- (void)registerGOMObserverForBinding:(GOMBinding *)binding
{
    NSLog(@"registering GOM observer at path: %@", binding.subscriptionUri);
    
    if (binding.registered == NO) {
        NSMutableDictionary *commands = [[NSMutableDictionary alloc] init];
        [commands setValue:@"subscribe" forKey:@"command"];
        [commands setValue:binding.subscriptionUri forKey:@"path"];
        [self sendCommand:commands];
        binding.registered = true;
    } else {
        [self retrieveInitial:binding];
    }
}

- (void)unregisterGOMObserverForBinding:(GOMBinding *)binding
{
    NSLog(@"unregistering GNP at path: %@", binding.subscriptionUri);
    
    if (binding.registered) {
        NSMutableDictionary *commands = [[NSMutableDictionary alloc] init];
        [commands setValue:@"unsubscribe" forKey:@"command"];
        [commands setValue:binding.subscriptionUri forKey:@"path"];
        [self sendCommand:commands];
        binding.registered = false;
    }
}

- (void)sendCommand:(NSDictionary *)commands
{
    if (_webSocket && _webSocket.readyState == SR_OPEN) {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:commands options:NSJSONWritingPrettyPrinted error:&error];
        [_webSocket send:jsonData];
        
    } else {
        NSLog(@"Could not open socket.");
    }
}

- (void)handleResponse:(NSDictionary* )response
{
    if (response[@"initial"]) {
        [self handleInitialResponse:response];
    } else if (response[@"payload"]) {
        [self handleGNPFromResponse:response];
    }
}

- (void)handleInitialResponse:(NSDictionary *)response
{
    NSString *payloadString = response[@"initial"];
    NSMutableDictionary *payload = [payloadString stringToJSON];
    
    NSString *path = response[@"path"];
    GOMBinding *binding = _bindings[path];
    if (binding) {
        for (GOMHandle *handle in binding.handles) {
            [self fireCallback:handle.callback withGomObject:payload];
        }
    }
}

- (void)handleGNPFromResponse:(NSDictionary *)response
{
    NSMutableDictionary *operation = nil;
    NSString *payloadString = response[@"payload"];
    NSMutableDictionary *payload = [payloadString stringToJSON];
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
            [self fireCallback:handle.callback withGomObject:operation];
        }
    }
}

- (void)fireCallback:(GOMHandleCallback)callback withGomObject:(NSDictionary *)gomObject
{
    if (callback) {
        callback(gomObject);
    }
}

- (void)retrieveInitial:(GOMBinding *)binding
{
    // TODO: check is gom ready?
    
    // retrieve gom path which was already bound.
    
    // get gom object
    NSMutableDictionary *gomObject = nil;
    
    for (GOMHandle *handle in binding.handles) {
        [self fireCallback:handle.callback withGomObject:gomObject];
    }
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    
    [self setup];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@":( Websocket Failed With Error %@", error);
    
    _webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSString *messageString = (NSString *)message;
    NSMutableDictionary *response = [messageString stringToJSON];
    
    if (response) {
        [self handleResponse:response];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed");
    _webSocket = nil;
}

@end
