//
//  GOMGnpHandlerTest.m
//  gom-client-demo_iOS
//
//  Created by Julian Krumow on 07.08.14.
//  Copyright (c) 2014 ART+COM AG. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XCTAsyncTestCase.h"
#import "GOMGnpHandler.h"
#import "GOMClient.h"

@interface GOMGnpHandlerTest : XCTAsyncTestCase <GOMGnpHandlerDelegate>

@property (nonatomic, strong) NSURL *gomUri;
@property (nonatomic, strong) GOMClient *gomClient;
@property (nonatomic, strong) GOMGnpHandler *gnpHandler;
@property (nonatomic, assign) BOOL delegateResponded;

@end

@implementation GOMGnpHandlerTest

NSString * const _GOM_URI = @"http://192.168.56.101:3080";
NSString * const WEBSOCKET_GNP_URI = @"ws://192.168.56.101:3082";

NSString * const ATTRIBUTE_TYPE = @"string";
NSString * const ATTRIBUTE_NAME = @"attribute_1";
NSString * const ATTRIBUTE_VALUE = @"value1";
NSString * const ATTRIBUTE_VALUE_NEW = @"value_new";
NSString * const ATTRIBUTE_PATH = @"/tests/node_2:attribute_1";

NSString * const NODE_PATH = @"/tests/node_2";

float const _TIMEOUT = 10.0;

- (void) gomGnpHandlerDidBecomeReady:(GOMGnpHandler *)gomGnpHandler
{
    _delegateResponded = YES;
}

- (void)gomGnpHandler:(GOMGnpHandler *)gomGnpHandler didFailWithError:(NSError *)error
{
    XCTFail(@"Error: %@", error.userInfo);
    
    _delegateResponded = YES;
}


- (void)setUp
{
    [super setUp];
    
    _gomUri = [NSURL URLWithString:_GOM_URI];
    _gomClient = [[GOMClient alloc] initWithGomURI:_gomUri];
    
    NSURL *webSocketProxyUri = [NSURL URLWithString:WEBSOCKET_GNP_URI];
    _gnpHandler = [[GOMGnpHandler alloc] initWithWebsocketUri:webSocketProxyUri delegate:self];
    
    // wait until GNP handler responds to delegate
    while(_delegateResponded == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

- (void)tearDown
{
    _gomClient = nil;
    _gomUri = nil;
    _gnpHandler = nil;
    
    _delegateResponded = NO;
    
    [super tearDown];
}

- (void)testReceiveGNPAfterUpdate
{
    [self prepare];
    
    static NSDictionary *_initialResponse = nil;
    static NSDictionary *_updateResponse = nil;
    
    [_gomClient updateAttribute:ATTRIBUTE_PATH withValue:ATTRIBUTE_VALUE completionBlock:^(NSDictionary *response, NSError *error) {
        
        if (response) {
            
            [_gnpHandler registerGOMObserverForPath:ATTRIBUTE_PATH clientCallback:^(NSDictionary *response) {
                
                if ([response[@"event_type"] isEqualToString:@"initial"]) {
                    _initialResponse = response;
                    
                    // trigger GNP by updating attribute
                    [_gomClient updateAttribute:ATTRIBUTE_PATH withValue:ATTRIBUTE_VALUE_NEW completionBlock:nil];
                    
                } else if ([response[@"event_type"] isEqualToString:@"update"]) {
                    _updateResponse = response;
                    
                    // test case officially finished
                    [self notify:kXCTUnitWaitStatusSuccess];
                }
                
            }];
            
        }
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:_TIMEOUT];
    
    // check initial response
    XCTAssertTrue([_initialResponse[@"path"] isEqualToString:ATTRIBUTE_PATH], @"path should be equal to the reference value.");
    XCTAssertTrue([_initialResponse[@"event_type"] isEqualToString:@"initial"], @"event_type should be equal to the reference value.");
    
    NSDictionary *payload = _initialResponse[@"payload"];
    XCTAssertNotNil(payload[@"attribute"], @"Attribute entry must not be nil.");
    XCTAssertNotNil([payload valueForKeyPath:@"attribute.ctime"], @"attribute.ctime should not be nil.");
    XCTAssertNotNil([payload valueForKeyPath:@"attribute.mtime"], @"attribute.mtime should not be nil.");
    XCTAssertTrue([[payload valueForKeyPath:@"attribute.node"] isEqualToString:NODE_PATH], @"node.uri should be equal to the reference value.");
    XCTAssertTrue([[payload valueForKeyPath:@"attribute.type"] isEqualToString:ATTRIBUTE_TYPE], @"attribute.type should be equal to the reference value.");
    XCTAssertTrue([[payload valueForKeyPath:@"attribute.name"] isEqualToString:ATTRIBUTE_NAME], @"attribute.name should be equal to the reference value.");
    XCTAssertTrue([[payload valueForKeyPath:@"attribute.value"] isEqualToString:ATTRIBUTE_VALUE], @"attribute.value should be equal to the reference value.");
    
    // check response from update
    XCTAssertTrue([_updateResponse[@"path"] isEqualToString:ATTRIBUTE_PATH], @"path should be equal to the reference value.");
    XCTAssertTrue([_updateResponse[@"event_type"] isEqualToString:@"update"], @"event_type should be equal to the reference value.");
    
    payload = _updateResponse[@"payload"];
    XCTAssertNotNil(payload[@"attribute"], @"Attribute entry must not be nil.");
    XCTAssertNotNil([payload valueForKeyPath:@"attribute.ctime"], @"attribute.ctime should not be nil.");
    XCTAssertNotNil([payload valueForKeyPath:@"attribute.mtime"], @"attribute.mtime should not be nil.");
    XCTAssertTrue([[payload valueForKeyPath:@"attribute.node"] isEqualToString:NODE_PATH], @"node.uri should be equal to the reference value.");
    XCTAssertTrue([[payload valueForKeyPath:@"attribute.type"] isEqualToString:ATTRIBUTE_TYPE], @"attribute.type should be equal to the reference value.");
    XCTAssertTrue([[payload valueForKeyPath:@"attribute.name"] isEqualToString:ATTRIBUTE_NAME], @"attribute.name should be equal to the reference value.");
    XCTAssertTrue([[payload valueForKeyPath:@"attribute.value"] isEqualToString:ATTRIBUTE_VALUE_NEW], @"attribute.value should be equal to the reference value.");
}

- (void)testReceiveGNPAfterDestroy
{
    [self prepare];
    
    static NSDictionary *_initialResponse = nil;
    static NSDictionary *_destroyResponse = nil;
    
    [_gomClient updateAttribute:ATTRIBUTE_PATH withValue:ATTRIBUTE_VALUE completionBlock:^(NSDictionary *response, NSError *error) {
        
        if (response) {
            
            [_gnpHandler registerGOMObserverForPath:ATTRIBUTE_PATH clientCallback:^(NSDictionary *response) {
                
                if ([response[@"event_type"] isEqualToString:@"initial"]) {
                    _initialResponse = response;
                    
                    // trigger GNP by updating attribute
                    [_gomClient destroy:ATTRIBUTE_PATH completionBlock:nil];
                    
                } else if ([response[@"event_type"] isEqualToString:@"delete"]) {
                    _destroyResponse = response;
                    
                    // test case officially finished
                    [self notify:kXCTUnitWaitStatusSuccess];
                }
                
            }];
            
        }
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:_TIMEOUT];
    
    // check initial response
    XCTAssertTrue([_initialResponse[@"path"] isEqualToString:ATTRIBUTE_PATH], @"path should be equal to the reference value.");
    XCTAssertTrue([_initialResponse[@"event_type"] isEqualToString:@"initial"], @"event_type should be equal to the reference value.");
    
    NSDictionary *payload = _initialResponse[@"payload"];
    XCTAssertNotNil(payload[@"attribute"], @"Attribute entry must not be nil.");
    XCTAssertNotNil([payload valueForKeyPath:@"attribute.ctime"], @"attribute.ctime should not be nil.");
    XCTAssertNotNil([payload valueForKeyPath:@"attribute.mtime"], @"attribute.mtime should not be nil.");
    XCTAssertTrue([[payload valueForKeyPath:@"attribute.node"] isEqualToString:NODE_PATH], @"node.uri should be equal to the reference value.");
    XCTAssertTrue([[payload valueForKeyPath:@"attribute.type"] isEqualToString:ATTRIBUTE_TYPE], @"attribute.type should be equal to the reference value.");
    XCTAssertTrue([[payload valueForKeyPath:@"attribute.name"] isEqualToString:ATTRIBUTE_NAME], @"attribute.name should be equal to the reference value.");
    XCTAssertTrue([[payload valueForKeyPath:@"attribute.value"] isEqualToString:ATTRIBUTE_VALUE], @"attribute.value should be equal to the reference value.");
    
    // check response from update
    XCTAssertTrue([_destroyResponse[@"path"] isEqualToString:ATTRIBUTE_PATH], @"path should be equal to the reference value.");
    XCTAssertTrue([_destroyResponse[@"event_type"] isEqualToString:@"delete"], @"event_type should be equal to the reference value.");
    
    payload = _destroyResponse[@"payload"];
    XCTAssertNotNil(payload[@"attribute"], @"Attribute entry must not be nil.");
    XCTAssertTrue([[payload valueForKeyPath:@"attribute.node"] isEqualToString:NODE_PATH], @"node.uri should be equal to the reference value.");
    XCTAssertTrue([[payload valueForKeyPath:@"attribute.type"] isEqualToString:ATTRIBUTE_TYPE], @"attribute.type should be equal to the reference value.");
    XCTAssertTrue([[payload valueForKeyPath:@"attribute.name"] isEqualToString:ATTRIBUTE_NAME], @"attribute.name should be equal to the reference value.");
    XCTAssertTrue([[payload valueForKeyPath:@"attribute.value"] isKindOfClass:[NSNull class]], @"attribute.value should be of class NSNull");
}

@end
