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
#import "GOMObserver.h"


@interface GomClientTest : XCTAsyncTestCase

@property (nonatomic, strong) NSString *GOM_URI;

@property (nonatomic, strong) NSString *NODE_1_PATH;

@property (nonatomic, strong) NSString *ATTRIBUTE_1_1_TYPE;
@property (nonatomic, strong) NSString *ATTRIBUTE_1_1_NAME;
@property (nonatomic, strong) NSString *ATTRIBUTE_1_1_VALUE;
@property (nonatomic, strong) NSString *ATTRIBUTE_1_1_PATH;

@property (nonatomic, strong) NSString *ATTRIBUTE_1_2_TYPE;
@property (nonatomic, strong) NSString *ATTRIBUTE_1_2_NAME;
@property (nonatomic, strong) NSString *ATTRIBUTE_1_2_VALUE;
@property (nonatomic, strong) NSString *ATTRIBUTE_1_2_PATH;

@property (nonatomic, strong) NSString *NODE_2_PATH;

@property (nonatomic, strong) NSString *ATTRIBUTE_2_1_TYPE;
@property (nonatomic, strong) NSString *ATTRIBUTE_2_1_NAME;
@property (nonatomic, strong) NSString *ATTRIBUTE_2_1_VALUE;
@property (nonatomic, strong) NSString *ATTRIBUTE_2_1_VALUE_NEW;
@property (nonatomic, strong) NSString *ATTRIBUTE_2_1_PATH;

@property (nonatomic, strong) NSString *NODE_X_PATH;
@property (nonatomic, strong) NSString *ATTRIBUTE_X_PATH;

@property (nonatomic, assign) NSUInteger STATUS_200;
@property (nonatomic, assign) NSUInteger STATUS_201;
@property (nonatomic, assign) NSUInteger STATUS_404;

@property (nonatomic, assign) float TIMEOUT;

@property (nonatomic, strong) NSURL *gomUri;
@property (nonatomic, strong) GOMClient *gomClient;

@end

@implementation GomClientTest


- (void)setUp
{
    [super setUp];
    
    _GOM_URI = @"http://192.168.56.101:3080";
    
    _NODE_1_PATH = @"/tests/node_1";
    
    _ATTRIBUTE_1_1_TYPE = @"string";
    _ATTRIBUTE_1_1_NAME = @"attribute_1";
    _ATTRIBUTE_1_1_VALUE = @"value1";
    _ATTRIBUTE_1_1_PATH = @"/tests/node_1:attribute_1";
    
    _ATTRIBUTE_1_2_TYPE = @"string";
    _ATTRIBUTE_1_2_NAME = @"attribute_2";
    _ATTRIBUTE_1_2_VALUE = @"value2";
    _ATTRIBUTE_1_2_PATH = @"/tests/node_1:attribute_2";
    
    _NODE_2_PATH = @"/tests/node_2";
    
    _ATTRIBUTE_2_1_TYPE = @"string";
    _ATTRIBUTE_2_1_NAME = @"attribute_1";
    _ATTRIBUTE_2_1_VALUE = @"value1";
    _ATTRIBUTE_2_1_VALUE_NEW = @"value_new";
    _ATTRIBUTE_2_1_PATH = @"/tests/node_2:attribute_1";
    
    _NODE_X_PATH = @"/tests/node_x";
    _ATTRIBUTE_X_PATH = @"/tests/node_1:attribute_x";
    
    _STATUS_200 = 200;
    _STATUS_201 = 201;
    _STATUS_404 = 404;
    
    _TIMEOUT = 10.0;
    
    _gomUri = [NSURL URLWithString:_GOM_URI];
    _gomClient = [[GOMClient alloc] initWithGomURI:_gomUri];
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
    static GOMNode *_retrievedNode = nil;
    static NSError *_updateError = nil;
    static NSDictionary *_updateResponse = nil;
    
    NSDictionary *attributes = @{ _ATTRIBUTE_1_1_NAME : _ATTRIBUTE_1_1_VALUE, _ATTRIBUTE_1_2_NAME : _ATTRIBUTE_1_2_VALUE };
    [_gomClient updateNode:_NODE_1_PATH withAttributes:attributes completionBlock:^(NSDictionary *response, NSError *error) {
        
        _updateResponse = response;
        _updateError = error;
        
        if (response) {
            
            [_gomClient retrieveNode:_NODE_1_PATH completionBlock:^(GOMNode *node, NSError *error) {
                
                _retrievedNode = node;
                _retrieveError = error;
                
                [self notify:kXCTUnitWaitStatusSuccess];
            }];
            
        }
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:_TIMEOUT];
    
    XCTAssertNil(_updateError, @"Error object must be nil.");
    XCTAssertNotNil(_updateResponse, @"Response dictionary must not be nil.");
    XCTAssertNotNil(_updateResponse[@"status"], @"There must be a status entry in the response dictionary.");
    NSNumber *statusCode = _updateResponse[@"status"];
    NSUInteger code = statusCode.integerValue;
    XCTAssertTrue(code == _STATUS_200 || code == _STATUS_201, @"Status code must be 200 or 201.");
    
    XCTAssertNil(_retrieveError, @"Error object must be nil.");
    XCTAssertNotNil(_retrievedNode, @"Response dictionary must not be nil.");
    
    XCTAssertNotNil(_retrievedNode.ctime, @"node.ctime should not be nil.");
    XCTAssertNotNil(_retrievedNode.mtime, @"node.mtime should not be nil.");
    XCTAssertTrue([_retrievedNode.uri isEqualToString:_NODE_1_PATH], @"node.uri should be equal to the reference value.");
    XCTAssertEqual(_retrievedNode.entries.count, 2, @"There should be two objects in the node's entries list.");
}

- (void)testRetrieveNodeNonexistent
{
    [self prepare];
    
    static NSError *_error = nil;
    static GOMNode *_node = nil;
    
    [_gomClient retrieveNode:_NODE_X_PATH completionBlock:^(GOMNode *node, NSError *error) {
        
        _node = node;
        _error = error;
        
        [self notify:kXCTUnitWaitStatusSuccess];
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:_TIMEOUT];
    
    XCTAssertNil(_node, @"Response dictionary must be nil.");
    XCTAssertNotNil(_error, @"Error object must not be nil.");
    XCTAssertTrue(_error.code == _STATUS_404, @"Error code must be 404");
}

- (void)testUpdateRetrieveAttribute
{
    [self prepare];
    
    static NSError *_retrieveError = nil;
    static GOMAttribute *_retrievedAttribute = nil;
    static NSError *_updateError = nil;
    static NSDictionary *_updateResponse = nil;
    
    [_gomClient updateAttribute:_ATTRIBUTE_1_1_PATH withValue:_ATTRIBUTE_1_1_VALUE completionBlock:^(NSDictionary *response, NSError *error) {
        
        _updateResponse = response;
        _updateError = error;
        
        if (response) {
            
            [_gomClient retrieveAttribute:_ATTRIBUTE_1_1_PATH completionBlock:^(GOMAttribute *attribute, NSError *error) {
                
                _retrievedAttribute = attribute;
                _retrieveError = error;
                
                [self notify:kXCTUnitWaitStatusSuccess];
            }];
            
        }
        
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:_TIMEOUT];
    
    XCTAssertNil(_updateError, @"Error object must be nil.");
    XCTAssertNotNil(_updateResponse, @"Response dictionary must not be nil.");
    XCTAssertNotNil(_updateResponse[@"status"], @"There must be a status entry in the response dictionary.");
    NSNumber *statusCode = _updateResponse[@"status"];
    NSUInteger code = statusCode.integerValue;
    XCTAssertTrue(code == _STATUS_200 || code == _STATUS_201, @"Status code must be 200 or 201.");
    
    
    XCTAssertNil(_retrieveError, @"Error object must be nil.");
    XCTAssertNotNil(_retrievedAttribute, @"Response dictionary must not be nil.");
    
    XCTAssertNotNil(_retrievedAttribute, @"Attribute entry must not be nil.");
    XCTAssertNotNil(_retrievedAttribute.ctime, @"attribute.ctime should not be nil.");
    XCTAssertNotNil(_retrievedAttribute.mtime, @"attribute.mtime should not be nil.");
    XCTAssertTrue([_retrievedAttribute.node isEqualToString:_NODE_1_PATH], @"node.uri should be equal to the reference value.");
    XCTAssertTrue([_retrievedAttribute.type isEqualToString:_ATTRIBUTE_1_1_TYPE], @"attribute.type should be equal to the reference value.");
    XCTAssertTrue([_retrievedAttribute.name isEqualToString:_ATTRIBUTE_1_1_NAME], @"attribute.name should be equal to the reference value.");
    XCTAssertTrue([_retrievedAttribute.value isEqualToString:_ATTRIBUTE_1_1_VALUE], @"attribute.value should be equal to the reference value.");
}

- (void)testRetrieveAttributeNonexistent
{
    [self prepare];
    
    static NSError *_error = nil;
    static GOMAttribute *_attribute = nil;
    
    [_gomClient retrieveAttribute:_ATTRIBUTE_X_PATH completionBlock:^(GOMAttribute *attribute, NSError *error) {
        
        _attribute = attribute;
        _error = error;
        
        [self notify:kXCTUnitWaitStatusSuccess];
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:_TIMEOUT];
    
    XCTAssertNil(_attribute, @"Response dictionary must be nil.");
    XCTAssertNotNil(_error, @"Error object must not be nil.");
    XCTAssertTrue(_error.code == _STATUS_404, @"Error code must be 404");
}

- (void)testDestroyAttribute
{
    [self prepare];
    
    static NSError *_destroyError = nil;
    static NSDictionary *_destroyResponse = nil;
    static NSError *_retrieveError = nil;
    static GOMAttribute *_retrievedAttribute = nil;
    
    NSDictionary *attributes = @{ _ATTRIBUTE_1_1_NAME : _ATTRIBUTE_1_1_VALUE, _ATTRIBUTE_1_2_NAME : _ATTRIBUTE_1_2_VALUE };
    [_gomClient updateNode:_NODE_1_PATH withAttributes:attributes completionBlock:^(NSDictionary *response, NSError *error) {
        
        if (response) {
            
            [_gomClient destroy:_ATTRIBUTE_1_2_PATH completionBlock:^(NSDictionary *response, NSError *error) {
                
                _destroyResponse = response;
                _destroyError = error;
                
                [_gomClient retrieveAttribute:_ATTRIBUTE_1_2_PATH completionBlock:^(GOMAttribute *attribute, NSError *error) {
                    
                    _retrievedAttribute = attribute;
                    _retrieveError = error;
                    
                    [self notify:kXCTUnitWaitStatusSuccess];
                }];
                
            }];
        }
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:_TIMEOUT];
    
    XCTAssertNil(_destroyError, @"Error object must be nil.");
    XCTAssertNotNil(_destroyResponse, @"Response dictionary must not be nil.");
    XCTAssertNotNil(_destroyResponse[@"success"], @"There must be a success entry in the response dictionary.");
    NSNumber *statusCode = _destroyResponse[@"success"];
    XCTAssertTrue(statusCode.boolValue, @"Success entry must be true.");
    
    XCTAssertNil(_retrievedAttribute, @"Response dictionary must be nil.");
    XCTAssertNotNil(_retrieveError, @"Error object must not be nil.");
    XCTAssertTrue(_retrieveError.code == _STATUS_404, @"Error code must be 404");
}

- (void)testDestroyNode
{
    [self prepare];
    
    static NSError *_destroyError = nil;
    static NSDictionary *_destroyResponse = nil;
    static NSError *_retrieveError = nil;
    static GOMNode *_retrievedNode = nil;
    
    NSDictionary *attributes = @{ _ATTRIBUTE_1_1_NAME : _ATTRIBUTE_1_1_VALUE, _ATTRIBUTE_1_2_NAME : _ATTRIBUTE_1_2_VALUE };
    [_gomClient updateNode:_NODE_1_PATH withAttributes:attributes completionBlock:^(NSDictionary *response, NSError *error) {
        
        if (response) {
            
            [_gomClient destroy:_NODE_1_PATH completionBlock:^(NSDictionary *response, NSError *error) {
                
                _destroyResponse = response;
                _destroyError = error;
                
                [_gomClient retrieveNode:_NODE_1_PATH completionBlock:^(GOMNode *node, NSError *error) {
                    
                    _retrievedNode = node;
                    _retrieveError = error;
                    
                    [self notify:kXCTUnitWaitStatusSuccess];
                    
                }];
            }];
            
        }
        
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:_TIMEOUT];
    
    XCTAssertNil(_destroyError, @"Error object must be nil.");
    XCTAssertNotNil(_destroyResponse, @"Response dictionary must not be nil.");
    XCTAssertNotNil(_destroyResponse[@"success"], @"There must be a success entry in the response dictionary.");
    NSNumber *statusCode = _destroyResponse[@"success"];
    XCTAssertTrue(statusCode.boolValue, @"Success entry must be true.");
    
    XCTAssertNil(_retrievedNode, @"Response dictionary must be nil.");
    XCTAssertNotNil(_retrieveError, @"Error object must not be nil.");
    XCTAssertTrue(_retrieveError.code == _STATUS_404, @"Error code must be 404");
}

@end
