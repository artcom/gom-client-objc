//
//  GOMObserverTest.m
//  gom-client-demo_iOS
//
//  Created by Julian Krumow on 07.08.14.
//  Copyright (c) 2014 ART+COM AG. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XCTAsyncTestCase.h"
#import "GOMObserver.h"
#import "GOMClient.h"

@interface GOMObserverTest : XCTAsyncTestCase <GOMObserverDelegate>

@property (nonatomic, strong) NSString *GOM_URI;
@property (nonatomic, strong) NSString *WEBSOCKET_GNP_URI;

@property (nonatomic, strong) NSString *ATTRIBUTE_TYPE;
@property (nonatomic, strong) NSString *ATTRIBUTE_NAME;
@property (nonatomic, strong) NSString *ATTRIBUTE_VALUE;
@property (nonatomic, strong) NSString *ATTRIBUTE_VALUE_NEW;
@property (nonatomic, strong) NSString *ATTRIBUTE_PATH;
@property (nonatomic, strong) NSString *NODE_PATH;

@property (nonatomic, assign) float TIMEOUT;

@property (nonatomic, strong) NSURL *gomUri;
@property (nonatomic, strong) GOMClient *gomClient;
@property (nonatomic, strong) GOMObserver *gomObserver;
@property (nonatomic, assign) BOOL delegateResponded;

@end

@implementation GOMObserverTest

- (void) gomObserverDidBecomeReady:(GOMObserver *)gomObserver
{
    _delegateResponded = YES;
}

- (void)gomObserver:(GOMObserver *)gomObserver didFailWithError:(NSError *)error
{
    XCTFail(@"Error: %@", error.userInfo);
    
    _delegateResponded = YES;
}


- (void)setUp
{
    [super setUp];
    
    _GOM_URI = @"http://192.168.56.101:3080";
    _WEBSOCKET_GNP_URI = @"ws://192.168.56.101:3082";
    
    _ATTRIBUTE_TYPE = @"string";
    _ATTRIBUTE_NAME = @"attribute_1";
    _ATTRIBUTE_VALUE = @"value1";
    _ATTRIBUTE_VALUE_NEW = @"value_new";
    _ATTRIBUTE_PATH = @"/tests/node_2:attribute_1";
    
    _NODE_PATH = @"/tests/node_2";
    
    _TIMEOUT = 10.0;
    
    _gomUri = [NSURL URLWithString:_GOM_URI];
    _gomClient = [[GOMClient alloc] initWithGomURI:_gomUri];
    
    NSURL *webSocketProxyUri = [NSURL URLWithString:_WEBSOCKET_GNP_URI];
    _gomObserver = [[GOMObserver alloc] initWithWebsocketUri:webSocketProxyUri delegate:self];
    
    // wait until GNP handler responds to delegate
    while(_delegateResponded == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

- (void)tearDown
{
    _GOM_URI = @"http://192.168.56.101:3080";
    _WEBSOCKET_GNP_URI = @"ws://192.168.56.101:3082";
    
    _ATTRIBUTE_TYPE = nil;
    _ATTRIBUTE_NAME = nil;
    _ATTRIBUTE_VALUE = nil;
    _ATTRIBUTE_VALUE_NEW = nil;
    _ATTRIBUTE_PATH = nil;
    
    _NODE_PATH = nil;
    
    _TIMEOUT = 10.0;
    
    _gomClient = nil;
    _gomUri = nil;
    _gomObserver = nil;
    
    _delegateResponded = NO;
    
    [super tearDown];
}

- (void)testReceiveGNPAfterUpdate
{
    [self prepare];
    
    static GOMGnp *_initialResponse = nil;
    static GOMGnp *_updateResponse = nil;
    
    [_gomClient updateAttribute:_ATTRIBUTE_PATH withValue:_ATTRIBUTE_VALUE completionBlock:^(NSDictionary *response, NSError *error) {
        
        if (response) {
            
            [_gomObserver registerGOMObserverForPath:_ATTRIBUTE_PATH clientCallback:^(GOMGnp *response) {
                
                if ([response.eventType isEqualToString:@"initial"]) {
                    _initialResponse = response;
                    
                    // trigger GNP by updating attribute
                    [_gomClient updateAttribute:_ATTRIBUTE_PATH withValue:_ATTRIBUTE_VALUE_NEW completionBlock:nil];
                    
                } else if ([response.eventType isEqualToString:@"update"]) {
                    _updateResponse = response;
                    
                    // test case officially finished
                    [self notify:kXCTUnitWaitStatusSuccess];
                }
                
            }];
            
        }
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:_TIMEOUT];
    
    // check initial response
    XCTAssertTrue([_initialResponse.path isEqualToString:_ATTRIBUTE_PATH], @"path should be equal to the reference value.");
    XCTAssertTrue([_initialResponse.eventType isEqualToString:@"initial"], @"event_type should be equal to the reference value.");
    
    GOMAttribute *payload = (GOMAttribute *)_initialResponse.payload;
    XCTAssertNotNil(payload.ctime, @"attribute.ctime should not be nil.");
    XCTAssertNotNil(payload.mtime, @"attribute.mtime should not be nil.");
    XCTAssertTrue([payload.node isEqualToString:_NODE_PATH], @"node.uri should be equal to the reference value.");
    XCTAssertTrue([payload.type isEqualToString:_ATTRIBUTE_TYPE], @"attribute.type should be equal to the reference value.");
    XCTAssertTrue([payload.name isEqualToString:_ATTRIBUTE_NAME], @"attribute.name should be equal to the reference value.");
    XCTAssertTrue([payload.value isEqualToString:_ATTRIBUTE_VALUE], @"attribute.value should be equal to the reference value.");
    
    // check response from update
    XCTAssertTrue([_updateResponse.path isEqualToString:_ATTRIBUTE_PATH], @"path should be equal to the reference value.");
    XCTAssertTrue([_updateResponse.eventType isEqualToString:@"update"], @"event_type should be equal to the reference value.");
    
    payload = (GOMAttribute *)_updateResponse.payload;
    XCTAssertNotNil(payload.ctime, @"attribute.ctime should not be nil.");
    XCTAssertNotNil(payload.mtime, @"attribute.mtime should not be nil.");
    XCTAssertTrue([payload.node isEqualToString:_NODE_PATH], @"node.uri should be equal to the reference value.");
    XCTAssertTrue([payload.type isEqualToString:_ATTRIBUTE_TYPE], @"attribute.type should be equal to the reference value.");
    XCTAssertTrue([payload.name isEqualToString:_ATTRIBUTE_NAME], @"attribute.name should be equal to the reference value.");
    XCTAssertTrue([payload.value isEqualToString:_ATTRIBUTE_VALUE_NEW], @"attribute.value should be equal to the reference value.");
}

- (void)testReceiveGNPAfterDestroy
{
    [self prepare];
    
    static GOMGnp *_initialResponse = nil;
    static GOMGnp *_destroyResponse = nil;
    
    [_gomClient updateAttribute:_ATTRIBUTE_PATH withValue:_ATTRIBUTE_VALUE completionBlock:^(NSDictionary *response, NSError *error) {
        
        if (response) {
            
            [_gomObserver registerGOMObserverForPath:_ATTRIBUTE_PATH clientCallback:^(GOMGnp *response) {
                
                if ([response.eventType isEqualToString:@"initial"]) {
                    _initialResponse = response;
                    
                    // trigger GNP by updating attribute
                    [_gomClient destroy:_ATTRIBUTE_PATH completionBlock:nil];
                    
                } else if ([response.eventType isEqualToString:@"delete"]) {
                    _destroyResponse = response;
                    
                    // test case officially finished
                    [self notify:kXCTUnitWaitStatusSuccess];
                }
                
            }];
            
        }
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:_TIMEOUT];
    
    // check initial response
    XCTAssertTrue([_initialResponse.path isEqualToString:_ATTRIBUTE_PATH], @"path should be equal to the reference value.");
    XCTAssertTrue([_initialResponse.eventType isEqualToString:@"initial"], @"event_type should be equal to the reference value.");
    
    GOMAttribute *payload = (GOMAttribute *)_initialResponse.payload;
    XCTAssertNotNil(payload.ctime, @"attribute.ctime should not be nil.");
    XCTAssertNotNil(payload.mtime, @"attribute.mtime should not be nil.");
    XCTAssertTrue([payload.node isEqualToString:_NODE_PATH], @"node.uri should be equal to the reference value.");
    XCTAssertTrue([payload.type isEqualToString:_ATTRIBUTE_TYPE], @"attribute.type should be equal to the reference value.");
    XCTAssertTrue([payload.name isEqualToString:_ATTRIBUTE_NAME], @"attribute.name should be equal to the reference value.");
    XCTAssertTrue([payload.value isEqualToString:_ATTRIBUTE_VALUE], @"attribute.value should be equal to the reference value.");
    
    // check response from update
    XCTAssertTrue([_destroyResponse.path isEqualToString:_ATTRIBUTE_PATH], @"path should be equal to the reference value.");
    XCTAssertTrue([_destroyResponse.eventType isEqualToString:@"delete"], @"event_type should be equal to the reference value.");
    
    payload = (GOMAttribute *)_destroyResponse.payload;
    XCTAssertTrue([payload.node isEqualToString:_NODE_PATH], @"node.uri should be equal to the reference value.");
    XCTAssertTrue([payload.type isEqualToString:_ATTRIBUTE_TYPE], @"attribute.type should be equal to the reference value.");
    XCTAssertTrue([payload.name isEqualToString:_ATTRIBUTE_NAME], @"attribute.name should be equal to the reference value.");
    XCTAssertNil(payload.value, @"attribute.value should be of nil");
}

@end
