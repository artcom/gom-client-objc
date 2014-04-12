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


@interface GomClientTest : XCTAsyncTestCase

@property (nonatomic, strong) NSURL *gomUri;
@property (nonatomic, strong) GOMClient *gomClient;

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
NSString * const ATTRIBUTE_2_1_PATH = @"/tests/node_2:attribute_1";

NSString * const ATTRIBUTE_2_2_TYPE = @"string";
NSString * const ATTRIBUTE_2_2_NAME = @"attribute_2";
NSString * const ATTRIBUTE_2_2_VALUE = @"value2";
NSString * const ATTRIBUTE_2_2_PATH = @"/tests/node_2:attribute_2";

NSString * const NODE_3_PATH = @"/tests/node_3";

NSString * const ATTRIBUTE_3_1_TYPE = @"string";
NSString * const ATTRIBUTE_3_1_NAME = @"attribute_1";
NSString * const ATTRIBUTE_3_1_VALUE = @"value1";
NSString * const ATTRIBUTE_3_1_PATH = @"/tests/node_3:attribute_1";

NSString * const ATTRIBUTE_3_2_TYPE = @"string";
NSString * const ATTRIBUTE_3_2_NAME = @"attribute_2";
NSString * const ATTRIBUTE_3_2_VALUE = @"value2";
NSString * const ATTRIBUTE_3_2_PATH = @"/tests/node_3:attribute_2";

NSString * const NODE_X_PATH = @"/tests/node_x";
NSString * const ATTRIBUTE_X_PATH = @"/tests/node_1:attribute_x";

NSUInteger const STATUS_200 = 200;
NSUInteger const STATUS_201 = 201;
NSUInteger const STATUS_404 = 404;

float const SLEEP = 1.0;
float const TIMEOUT = 2.0;

- (void)setUp
{
    [super setUp];
    
    _gomUri = [NSURL URLWithString:GOM_URI];
    _gomClient = [[GOMClient alloc] initWithGomURI:_gomUri delegate:nil];
}

- (void)tearDown
{
    _gomClient = nil;
    _gomUri = nil;
    
    [super tearDown];
}

- (void)testUpdateRetrieveNode
{
    [self prepare];
    
    static NSError *_retrieveError = nil;
    static NSDictionary *_retrieveResponse = nil;
    static NSError *_updateError = nil;
    static NSDictionary *_updateResponse = nil;
    
    
    NSDictionary *attributes = @{ ATTRIBUTE_1_2_NAME : ATTRIBUTE_1_2_VALUE };
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
    static NSError *_retrieveError = nil;
    static NSDictionary *_retrieveResponse = nil;
    static NSError *_updateError = nil;
    static NSDictionary *_updateResponse = nil;
    
    [self prepare];
    
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
    static NSError *_error = nil;
    static NSDictionary *_response = nil;
    
    [self prepare];
    
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
    static NSError *_destroyError = nil;
    static NSDictionary *_destroyResponse = nil;
    static NSError *_retrieveError = nil;
    static NSDictionary *_retrieveResponse = nil;
    
    [self prepare];
    
    NSDictionary *attributes = @{ ATTRIBUTE_2_1_NAME : ATTRIBUTE_2_1_VALUE, ATTRIBUTE_2_2_NAME : ATTRIBUTE_2_2_VALUE };
    [_gomClient updateNode:NODE_2_PATH withAttributes:attributes completionBlock:^(NSDictionary *response, NSError *error) {
        
        if (response) {
            
            [_gomClient destroy:ATTRIBUTE_2_2_PATH completionBlock:^(NSDictionary *response, NSError *error) {
                
                _destroyResponse = response;
                _destroyError = error;
                
                [_gomClient retrieve:ATTRIBUTE_2_2_PATH completionBlock:^(NSDictionary *response, NSError *error) {
                    
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
    static NSError *_destroyError = nil;
    static NSDictionary *_destroyResponse = nil;
    static NSError *_retrieveError = nil;
    static NSDictionary *_retrieveResponse = nil;
    
    [self prepare];
    
    NSDictionary *attributes = @{ ATTRIBUTE_3_1_NAME : ATTRIBUTE_3_1_VALUE, ATTRIBUTE_3_2_NAME : ATTRIBUTE_3_2_VALUE };
    [_gomClient updateNode:NODE_3_PATH withAttributes:attributes completionBlock:^(NSDictionary *response, NSError *error) {
        
        if (response) {
            
            [_gomClient destroy:NODE_3_PATH completionBlock:^(NSDictionary *response, NSError *error) {
                
                _destroyResponse = response;
                _destroyError = error;
                
                [_gomClient retrieve:NODE_3_PATH completionBlock:^(NSDictionary *response, NSError *error) {
                    
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

@end
