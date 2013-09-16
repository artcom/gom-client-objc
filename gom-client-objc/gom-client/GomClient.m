//
//  GOMClient.m
//  gom-client-objc
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import "GOMClient.h"
#import "GOMBinding.h"
#import "SRWebSocket.h"
#import "NSString+JSON.h"

@interface GOMClient () <SRWebSocketDelegate>

@property (nonatomic, retain) NSMutableDictionary *bindings;

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
    NSMutableArray *_messages;
    BOOL gomIsReady;
}

@synthesize gomRoot = _gomRoot;
@synthesize bindings = _bindings;

- (id)initWithGomURI:(NSURL *)gomURI
{
    self = [super init];
    if (self) {
        _gomRoot = gomURI;
        _bindings = [[NSMutableDictionary alloc] init];
        gomIsReady = false;
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

- (void)retrieveAttribute:(NSString *)attribute completionBlock:(GOMClientCallback)block
{
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    [headers setValue:@"application/json" forKey:@"Accept"];
    [headers setValue:@"application/json" forKey:@"Content-Type"];
    [self performGOMRequestWithPath:attribute method:@"GET" headers:headers payload:nil completionBlock:block];
}

- (void)retrieveNode:(NSString *)node completionBlock:(GOMClientCallback)block
{
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    [headers setValue:@"application/json" forKey:@"Accept"];
    [headers setValue:@"application/json" forKey:@"Content-Type"];
    [self performGOMRequestWithPath:node method:@"GET" headers:headers payload:nil completionBlock:block];
}

- (void)createNode:(NSString *)node withAttributes:(NSDictionary *)attributes completionBlock:(GOMClientCallback)block
{
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    [headers setValue:@"application/xml" forKey:@"Content-Type"];
    [self performGOMRequestWithPath:node method:@"CREATE" headers:headers payload:nil completionBlock:block];
}

- (void)updateAttribute:(NSString *)attribute withValue:(NSString *)value completionBlock:(GOMClientCallback)block
{
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    [headers setValue:@"text/plain" forKey:@"Accept"];
    [headers setValue:@"application/x-www-form-urlencoded" forKey:@"Content-Type"];
    
    //NSDictionary *payload = [NSDictionary dictionaryWithObjects:@[value, @"string"] forKeys:@[@"attribute", @"type"]];
    NSData *payloadData = nil; // TODO encode dictionary.
        
    [self performGOMRequestWithPath:attribute method:@"PUT" headers:headers payload:payloadData completionBlock:block];
}

- (void)updateNode:(NSString *)node withAttributes:(NSDictionary *)attributes completionBlock:(GOMClientCallback)block
{
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    [headers setValue:@"application/json" forKey:@"Accept"];
    [headers setValue:@"application/" forKey:@"Content-Type"];
    
    [self performGOMRequestWithPath:node method:@"PUT" headers:headers payload:nil completionBlock:block];
}

- (void)destroyAttribute:(NSString *)attribute completionBlock:(GOMClientCallback)block
{
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    //[headers setValue:@"application/json" forKey:@"Accept"];
    //[headers setValue:@"application/" forKey:@"Content-Type"];
    [self performGOMRequestWithPath:attribute method:@"DELETE" headers:headers payload:nil completionBlock:block];
}

- (void)destroyNode:(NSString *)node completionBlock:(GOMClientCallback)block
{
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    //[headers setValue:@"application/json" forKey:@"Accept"];
    //[headers setValue:@"application/" forKey:@"Content-Type"];
    [self performGOMRequestWithPath:node method:@"DELETE" headers:headers payload:nil completionBlock:block];
}

- (void)performGOMRequestWithPath:(NSString *)path method:(NSString *)method headers:(NSDictionary *)headers payload:(NSData *)payload completionBlock:(GOMClientCallback)block
{
    NSURL *requestURL = [_gomRoot URLByAppendingPathComponent:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPBody:payload];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSLog(@"response: %@", response.description);
        
        NSDictionary *responseData = nil;
        if (data) {
            NSError *error = nil;
            responseData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        }
        NSLog(@"dict: %@", responseData);
        
        if (block) {
            block(responseData);
        }
        
    }];
}

#pragma mark - GOM observers

- (void)registerGOMObserverForPath:(NSString *)path options:(NSDictionary *)options clientCallback:(GOMClientCallback)callback
{
    GOMBinding *binding = [[GOMBinding alloc] initWithSubscriptionUri:path];
    _bindings[path] = binding;
    
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
    
    if (payloadString) {
        
        NSString *path = response[@"path"];
        GOMBinding *binding = _bindings[path];
        if (binding) {
            for (GOMHandle *handle in binding.handles) {
                [self _fireCallback:handle.callback withGomObject:payload];
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
    // TODO: check is gom ready?
    
    // retrieve gom path which was already bound.
    
    // get gom object
    NSMutableDictionary *gomObject = nil;
    
    for (GOMHandle *handle in binding.handles) {
        [self _fireCallback:handle.callback withGomObject:gomObject];
    }
}

- (void)_reconnectWebsocket
{
    [self _disconnectWebsocket];
    [self retrieveAttribute:@"/services/websockets_proxy:url" completionBlock:^(NSDictionary *response) {
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
    NSLog(@"WebSocket closed with code: %d\n%@\nclean: %d", code, reason, wasClean);
    _webSocket = nil;
}

@end
