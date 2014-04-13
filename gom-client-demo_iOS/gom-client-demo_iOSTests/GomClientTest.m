//
//  GomClientTest.m
//  gom-client-demo_iOS
//
//  Created by Julian Krumow on 11.04.14.
//  Copyright (c) 2014 ART+COM AG. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XCTAsyncTestCase.h"
#import "GOMClient.h"


@interface GomClientTest : XCTAsyncTestCase <GOMClientDelegate>

@property (nonatomic, strong) NSURL *gomUri;
@property (nonatomic, strong) GOMClient *gomClient;
@property (nonatomic, assign) BOOL delegateResponded;

@end

@implementation GomClientTest

NSString * const GOM_URI = @"http://192.168.56.101:3080";

NSString * const NODE_1_PATH = @"/tests/node_1";

NSString * const ATTRIBUTE_1_1_TYPE = @"string";
NSString * const ATTRIBUTE_1_1_NAME = @"attribute_1";
NSString * const ATTRIBUTE_1_1_VALUE = @"value1";
NSString * const ATTRIBUTE_1_1_PATH = @"/tests/node_1:attribute_1";

NSString * const ATTRIBUTE_1_2_TYPE = @"string";
NSString * const ATTRIBUTE_1_2_NAME = @"attribute_2";
NSString * const ATTRIBUTE_1_2_VALUE = @"value2";
NSString * const ATTRIBUTE_1_2_PATH = @"/tests/node_1:attribute_2";

NSString * const NODE_2_PATH = @"/tests/node_2";

NSString * const ATTRIBUTE_2_1_TYPE = @"string";
NSString * const ATTRIBUTE_2_1_NAME = @"attribute_1";
NSString * const ATTRIBUTE_2_1_VALUE = @"value1";
NSString * const ATTRIBUTE_2_1_VALUE_NEW = @"value_new";
NSString * const ATTRIBUTE_2_1_PATH = @"/tests/node_2:attribute_1";

NSString * const NODE_X_PATH = @"/tests/node_x";
NSString * const ATTRIBUTE_X_PATH = @"/tests/node_1:attribute_x";

NSUInteger const STATUS_200 = 200;
NSUInteger const STATUS_201 = 201;
NSUInteger const STATUS_404 = 404;

float const TIMEOUT = 10.0;

- (void) gomClientDidBecomeReady:(GOMClient *)gomClient
{
    _delegateResponded = YES;
}

- (void)gomClient:(GOMClient *)gomClient didFailWithError:(NSError *)error
{
    XCTFail(@"Error: %@", error.userInfo);
    
    _delegateResponded = YES;
}

- (void)setUp
{
    [super setUp];
    
    _gomUri = [NSURL URLWithString:GOM_URI];
    _gomClient = [[GOMClient alloc] initWithGomURI:_gomUri delegate:self];
    
    // wait until GOM client responds to delegate
    while(_delegateResponded == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

- (void)tearDown
{
    _gomClient = nil;
    _gomUri = nil;
    _delegateResponded = NO;
    
    [super tearDown];
}

- (void)testUpdateRetrieveNode
{
    [self prepare];
    
    static NSError *_retrieveError = nil;
    static NSDictionary *_retrieveResponse = nil;
    static NSError *_updateError = nil;
    static NSDictionary *_updateResponse = nil;
    
    NSDictionary *attributes = @{ ATTRIBUTE_1_1_NAME : ATTRIBUTE_1_1_VALUE, ATTRIBUTE_1_2_NAME : ATTRIBUTE_1_2_VALUE };
    [_gomClient updateNode:NODE_1_PATH withAttributes:attributes completionBlock:^(NSDictionary *response, NSError *error) {
        
        _updateResponse = response;
        _updateError = error;
        
        if (response) {
            
            [_gomClient retrieve:NODE_1_PATH completionBlock:^(NSDictionary *response, NSError *error) {
                
                _retrieveResponse = response;
                _retrieveError = error;
                
                [self notify:kXCTUnitWaitStatusSuccess];
            }];
            
        }
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:TIMEOUT];
    
    XCTAssertNil(_updateError, @"Error object must be nil.");
    XCTAssertNotNil(_updateResponse, @"Response dictionary must not be nil.");
    XCTAssertNotNil(_updateResponse[@"status"], @"There must be a status entry in the response dictionary.");
    NSNumber *statusCode = _updateResponse[@"status"];
    NSUInteger code = statusCode.integerValue;
    XCTAssertTrue(code == STATUS_200 || code == STATUS_201, @"Status code must be 200 or 201.");
    
    XCTAssertNil(_retrieveError, @"Error object must be nil.");
    XCTAssertNotNil(_retrieveResponse, @"Response dictionary must not be nil.");
    
    XCTAssertNotNil(_retrieveResponse[@"node"], @"Node entry must not be nil.");
    XCTAssertNotNil([_retrieveResponse valueForKeyPath:@"node.ctime"], @"node.ctime should not be nil.");
    XCTAssertNotNil([_retrieveResponse valueForKeyPath:@"node.mtime"], @"node.mtime should not be nil.");
    XCTAssertTrue([[_retrieveResponse valueForKeyPath:@"node.uri"] isEqualToString:NODE_1_PATH], @"node.uri should be equal to the reference value.");
    XCTAssertEqual([[_retrieveResponse valueForKeyPath:@"node.entries"] count], 2, @"There should be two objects in the node's entries list.");
}

- (void)testRetrieveNodeNonexistent
{
    [self prepare];
    
    static NSError *_error = nil;
    static NSDictionary *_response = nil;
    
    [_gomClient retrieve:NODE_X_PATH completionBlock:^(NSDictionary *response, NSError *error) {
        
        _response = response;
        _error = error;
        
        [self notify:kXCTUnitWaitStatusSuccess];
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:TIMEOUT];
    
    XCTAssertNil(_response, @"Response dictionary must be nil.");
    XCTAssertNotNil(_error, @"Error object must not be nil.");
    XCTAssertTrue(_error.code == STATUS_404, @"Error code must be 404");
}

- (void)testUpdateRetrieveAttribute
{
    [self prepare];
    
    static NSError *_retrieveError = nil;
    static NSDictionary *_retrieveResponse = nil;
    static NSError *_updateError = nil;
    static NSDictionary *_updateResponse = nil;
    
    [_gomClient updateAttribute:ATTRIBUTE_1_1_PATH withValue:ATTRIBUTE_1_1_VALUE completionBlock:^(NSDictionary *response, NSError *error) {
        
        _updateResponse = response;
        _updateError = error;
        
        if (response) {
            
            [_gomClient retrieve:ATTRIBUTE_1_1_PATH completionBlock:^(NSDictionary *response, NSError *error) {
                
                _retrieveResponse = response;
                _retrieveError = error;
                
                [self notify:kXCTUnitWaitStatusSuccess];
            }];
            
        }
        
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:TIMEOUT];
    
    XCTAssertNil(_updateError, @"Error object must be nil.");
    XCTAssertNotNil(_updateResponse, @"Response dictionary must not be nil.");
    XCTAssertNotNil(_updateResponse[@"status"], @"There must be a status entry in the response dictionary.");
    NSNumber *statusCode = _updateResponse[@"status"];
    NSUInteger code = statusCode.integerValue;
    XCTAssertTrue(code == STATUS_200 || code == STATUS_201, @"Status code must be 200 or 201.");
    
    
    XCTAssertNil(_retrieveError, @"Error object must be nil.");
    XCTAssertNotNil(_retrieveResponse, @"Response dictionary must not be nil.");
    
    XCTAssertNotNil(_retrieveResponse[@"attribute"], @"Attribute entry must not be nil.");
    XCTAssertNotNil([_retrieveResponse valueForKeyPath:@"attribute.ctime"], @"attribute.ctime should not be nil.");
    XCTAssertNotNil([_retrieveResponse valueForKeyPath:@"attribute.mtime"], @"attribute.mtime should not be nil.");
    XCTAssertTrue([[_retrieveResponse valueForKeyPath:@"attribute.node"] isEqualToString:NODE_1_PATH], @"node.uri should be equal to the reference value.");
    XCTAssertTrue([[_retrieveResponse valueForKeyPath:@"attribute.type"] isEqualToString:ATTRIBUTE_1_1_TYPE], @"attribute.type should be equal to the reference value.");
    XCTAssertTrue([[_retrieveResponse valueForKeyPath:@"attribute.name"] isEqualToString:ATTRIBUTE_1_1_NAME], @"attribute.name should be equal to the reference value.");
    XCTAssertTrue([[_retrieveResponse valueForKeyPath:@"attribute.value"] isEqualToString:ATTRIBUTE_1_1_VALUE], @"attribute.value should be equal to the reference value.");
}

- (void)testRetrieveAttributeNonexistent
{
    [self prepare];
    
    static NSError *_error = nil;
    static NSDictionary *_response = nil;
    
    [_gomClient retrieve:ATTRIBUTE_X_PATH completionBlock:^(NSDictionary *response, NSError *error) {
        
        _response = response;
        _error = error;
        
        [self notify:kXCTUnitWaitStatusSuccess];
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:TIMEOUT];
    
    XCTAssertNil(_response, @"Response dictionary must be nil.");
    XCTAssertNotNil(_error, @"Error object must not be nil.");
    XCTAssertTrue(_error.code == STATUS_404, @"Error code must be 404");
}

- (void)testDestroyAttribute
{
    [self prepare];
    
    static NSError *_destroyError = nil;
    static NSDictionary *_destroyResponse = nil;
    static NSError *_retrieveError = nil;
    static NSDictionary *_retrieveResponse = nil;
    
    NSDictionary *attributes = @{ ATTRIBUTE_1_1_NAME : ATTRIBUTE_1_1_VALUE, ATTRIBUTE_1_2_NAME : ATTRIBUTE_1_2_VALUE };
    [_gomClient updateNode:NODE_1_PATH withAttributes:attributes completionBlock:^(NSDictionary *response, NSError *error) {
        
        if (response) {
            
            [_gomClient destroy:ATTRIBUTE_1_2_PATH completionBlock:^(NSDictionary *response, NSError *error) {
                
                _destroyResponse = response;
                _destroyError = error;
                
                [_gomClient retrieve:ATTRIBUTE_1_2_PATH completionBlock:^(NSDictionary *response, NSError *error) {
                    
                    _retrieveResponse = response;
                    _retrieveError = error;
                    
                    [self notify:kXCTUnitWaitStatusSuccess];
                }];
                
            }];
        }
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:TIMEOUT];
    
    XCTAssertNil(_destroyError, @"Error object must be nil.");
    XCTAssertNotNil(_destroyResponse, @"Response dictionary must not be nil.");
    XCTAssertNotNil(_destroyResponse[@"success"], @"There must be a success entry in the response dictionary.");
    NSNumber *statusCode = _destroyResponse[@"success"];
    XCTAssertTrue(statusCode.boolValue, @"Success entry must be true.");
    
    XCTAssertNil(_retrieveResponse, @"Response dictionary must be nil.");
    XCTAssertNotNil(_retrieveError, @"Error object must not be nil.");
    XCTAssertTrue(_retrieveError.code == STATUS_404, @"Error code must be 404");
}

- (void)testDestroyNode
{
    [self prepare];
    
    static NSError *_destroyError = nil;
    static NSDictionary *_destroyResponse = nil;
    static NSError *_retrieveError = nil;
    static NSDictionary *_retrieveResponse = nil;
    
    NSDictionary *attributes = @{ ATTRIBUTE_1_1_NAME : ATTRIBUTE_1_1_VALUE, ATTRIBUTE_1_2_NAME : ATTRIBUTE_1_2_VALUE };
    [_gomClient updateNode:NODE_1_PATH withAttributes:attributes completionBlock:^(NSDictionary *response, NSError *error) {
        
        if (response) {
            
            [_gomClient destroy:NODE_1_PATH completionBlock:^(NSDictionary *response, NSError *error) {
                
                _destroyResponse = response;
                _destroyError = error;
                
                [_gomClient retrieve:NODE_1_PATH completionBlock:^(NSDictionary *response, NSError *error) {
                    
                    _retrieveResponse = response;
                    _retrieveError = error;
                    
                    [self notify:kXCTUnitWaitStatusSuccess];
                    
                }];
            }];
            
        }
        
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:TIMEOUT];
    
    XCTAssertNil(_destroyError, @"Error object must be nil.");
    XCTAssertNotNil(_destroyResponse, @"Response dictionary must not be nil.");
    XCTAssertNotNil(_destroyResponse[@"success"], @"There must be a success entry in the response dictionary.");
    NSNumber *statusCode = _destroyResponse[@"success"];
    XCTAssertTrue(statusCode.boolValue, @"Success entry must be true.");
    
    XCTAssertNil(_retrieveResponse, @"Response dictionary must be nil.");
    XCTAssertNotNil(_retrieveError, @"Error object must not be nil.");
    XCTAssertTrue(_retrieveError.code == STATUS_404, @"Error code must be 404");
}

- (void)testReceiveGNPAfterUpdate
{
    [self prepare];
    
    static NSDictionary *_initialResponse = nil;
    static NSDictionary *_updateResponse = nil;
    
    [_gomClient updateAttribute:ATTRIBUTE_2_1_PATH withValue:ATTRIBUTE_2_1_VALUE completionBlock:^(NSDictionary *response, NSError *error) {
        
        if (response) {
            
            [_gomClient registerGOMObserverForPath:ATTRIBUTE_2_1_PATH options:nil clientCallback:^(NSDictionary *response) {
                
                if ([response[@"event_type"] isEqualToString:@"initial"]) {
                    _initialResponse = response;
                    
                    // trigger GNP by updating attribute
                    [_gomClient updateAttribute:ATTRIBUTE_2_1_PATH withValue:ATTRIBUTE_2_1_VALUE_NEW completionBlock:nil];
                    
                } else if ([response[@"event_type"] isEqualToString:@"update"]) {
                    _updateResponse = response;
                    
                    // test case officially finished
                    [self notify:kXCTUnitWaitStatusSuccess];
                }
                
            }];
            
        }
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:TIMEOUT];
    
    // check initial response
    XCTAssertTrue([_initialResponse[@"path"] isEqualToString:ATTRIBUTE_2_1_PATH], @"path should be equal to the reference value.");
    XCTAssertTrue([_initialResponse[@"event_type"] isEqualToString:@"initial"], @"event_type should be equal to the reference value.");
    
    NSDictionary *payload = _initialResponse[@"payload"];
    XCTAssertNotNil(payload[@"attribute"], @"Attribute entry must not be nil.");
    XCTAssertNotNil([payload valueForKeyPath:@"attribute.ctime"], @"attribute.ctime should not be nil.");
    XCTAssertNotNil([payload valueForKeyPath:@"attribute.mtime"], @"attribute.mtime should not be nil.");
    XCTAssertTrue([[payload valueForKeyPath:@"attribute.node"] isEqualToString:NODE_2_PATH], @"node.uri should be equal to the reference value.");
    XCTAssertTrue([[payload valueForKeyPath:@"attribute.type"] isEqualToString:ATTRIBUTE_2_1_TYPE], @"attribute.type should be equal to the reference value.");
    XCTAssertTrue([[payload valueForKeyPath:@"attribute.name"] isEqualToString:ATTRIBUTE_2_1_NAME], @"attribute.name should be equal to the reference value.");
    XCTAssertTrue([[payload valueForKeyPath:@"attribute.value"] isEqualToString:ATTRIBUTE_2_1_VALUE], @"attribute.value should be equal to the reference value.");
    
    // check response from update
    XCTAssertTrue([_updateResponse[@"path"] isEqualToString:ATTRIBUTE_2_1_PATH], @"path should be equal to the reference value.");
    XCTAssertTrue([_updateResponse[@"event_type"] isEqualToString:@"update"], @"event_type should be equal to the reference value.");
    
    payload = _updateResponse[@"payload"];
    XCTAssertNotNil(payload[@"attribute"], @"Attribute entry must not be nil.");
    XCTAssertNotNil([payload valueForKeyPath:@"attribute.ctime"], @"attribute.ctime should not be nil.");
    XCTAssertNotNil([payload valueForKeyPath:@"attribute.mtime"], @"attribute.mtime should not be nil.");
    XCTAssertTrue([[payload valueForKeyPath:@"attribute.node"] isEqualToString:NODE_2_PATH], @"node.uri should be equal to the reference value.");
    XCTAssertTrue([[payload valueForKeyPath:@"attribute.type"] isEqualToString:ATTRIBUTE_2_1_TYPE], @"attribute.type should be equal to the reference value.");
    XCTAssertTrue([[payload valueForKeyPath:@"attribute.name"] isEqualToString:ATTRIBUTE_2_1_NAME], @"attribute.name should be equal to the reference value.");
    XCTAssertTrue([[payload valueForKeyPath:@"attribute.value"] isEqualToString:ATTRIBUTE_2_1_VALUE_NEW], @"attribute.value should be equal to the reference value.");
}

@end
