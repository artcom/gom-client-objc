//
//  GomClient.m
//  gom-client-ios
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM. All rights reserved.
//

#import "GomClient.h"

#import "SRWebSocket.h"
#import "GOMBinding.h"

@interface GomClient () <SRWebSocketDelegate>

@property (nonatomic, retain) NSMutableDictionary *bindings;

@end


@implementation GomClient {
    SRWebSocket *_webSocket;
    NSMutableArray *_messages;
}

@synthesize bindings = _bindings;

- (id)init
{
    self = [super init];
    if (self) {
        _bindings = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)_reconnect
{
    _webSocket.delegate = nil;
    [_webSocket close];
    
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://192.168.56.101:3082"]]];
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

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    
    // TODO: read /services/websockets_proxy:url
    
    NSString *path = @"/areas/home/audio:volume";
    GOMBinding *binding = [[GOMBinding alloc] initWithSubscriptionUri:path];
    [_bindings setObject:binding forKey:path];
    
    GOMHandle *handle = [[GOMHandle alloc] initWithBinding:binding callback:^(NSDictionary *gomObject) {
        NSLog(@"HANDLE: fired callback with: %@", gomObject);
    }];
    [binding addHandle:handle];
    
    for (GOMBinding *binding in _bindings.allValues) {
        [self registerGOMObserverForBinding:binding];
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

- (void)handleInitialResponse:(NSDictionary *)response
{
    NSString *path = [response objectForKey:@"path"];
    GOMBinding *binding = [_bindings objectForKey:path];
    
    if (binding) {
        for (GOMHandle *handle in binding.handles) {
            [self fireCallback:handle.callback withGomObject:response];
        }
    }
}

- (void)handleGNPFromResponse:(NSDictionary *)response
{
    NSMutableDictionary *operation = nil;
    NSMutableDictionary *payload = [response valueForKey:@"payload"];
    if ([payload valueForKey:@"create"]) {
        operation = [payload valueForKey:@"create"];
    } else if ([payload valueForKey:@"update"]) {
        operation = [payload valueForKey:@"update"];
    } else if ([payload valueForKey:@"delete"]) {
        operation = [payload valueForKey:@"delete"];
    }
    
    NSString *path = [response objectForKey:@"path"];
    GOMBinding *binding = [_bindings objectForKey:path];
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

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@":( Websocket Failed With Error %@", error);
    
    _webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSString *messageString = (NSString *)message;
    NSData *messageData = [messageString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    NSMutableDictionary *response = [NSJSONSerialization JSONObjectWithData:messageData options:NSJSONReadingMutableContainers error:&error];
    
    if (response == nil) return;
    
    if ([response objectForKey:@"initial"]) {
        [self handleInitialResponse:response];
    } else if ([response objectForKey:@"payload"]) {
        [self handleGNPFromResponse:response];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed");
    _webSocket = nil;
}


@end
