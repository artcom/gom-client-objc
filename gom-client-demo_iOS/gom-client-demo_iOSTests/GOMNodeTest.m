//
//  GOMNodeTest.m
//  gom-client-demo_iOS
//
//  Created by Julian Krumow on 09.03.14.
//  Copyright (c) 2014 ART+COM AG. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GOMNode.h"
#import "GOMAttribute.h"

NSString *NODE_CTIME = @"2014-03-09T15:00:20+01:00";
NSString *NODE_MTIME = @"2014-03-09T15:00:20+01:00";
NSString *NODE_URI = @"/tests/node1";

NSString *NODE_ATTRIBUTE_1_CTIME = @"2014-03-09T15:00:20+01:00";
NSString *NODE_ATTRIBUTE_1_MTIME = @"2014-03-09T15:00:20+01:00";
NSString *NODE_ATTRIBUTE_1_NODE = @"/tests/node1";

NSString *NODE_ATTRIBUTE_1_TYPE = @"string";
NSString *NODE_ATTRIBUTE_1_NAME = @"name1";
NSString *NODE_ATTRIBUTE_1_VALUE = @"value1";

@interface GOMNodeTest : XCTestCase

@property (nonatomic, strong) NSDictionary *attributeDictionary;
@property (nonatomic, strong) NSDictionary *nodeDictionary;
@property (nonatomic, strong) NSDictionary *falseNodeDictionary;
@property (nonatomic, strong) NSDictionary *noNodeDictionary;

@end

@implementation GOMNodeTest

- (void)setUp
{
    [super setUp];
    
    _attributeDictionary = @{
                             @"attribute" : @{
                                     @"ctime" : NODE_ATTRIBUTE_1_CTIME,
                                     @"mtime" : NODE_ATTRIBUTE_1_MTIME,
                                     @"node" : NODE_ATTRIBUTE_1_NODE,
                                     @"type" : NODE_ATTRIBUTE_1_TYPE,
                                     @"name" : NODE_ATTRIBUTE_1_NAME,
                                     @"value" : NODE_ATTRIBUTE_1_VALUE
                                     }
                             };
    
    _nodeDictionary = @{
                        @"node" : @{
                                @"ctime" : NODE_CTIME,
                                @"mtime" : NODE_MTIME,
                                @"uri" : NODE_URI,
                                @"entries" :@[
                                        self.attributeDictionary
                                        ]
                                }
                        };
    _falseNodeDictionary = @{
                             @"node" : @{
                                     @"cime" : NODE_CTIME,
                                     @"mime" : NODE_MTIME,
                                     @"yuri" : NODE_URI,
                                     @"enties" :@[
                                             self.attributeDictionary
                                             ]
                                     }
                             };
    _noNodeDictionary = @{
                          @"foo" : @NO
                          };
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testGOMNodeCheckIsNodeFail
{
    BOOL result = [GOMNode isNode:self.noNodeDictionary];
    XCTAssertFalse(result, @"The result should be false");
}

- (void)testGOMNodeCheckIsNodeSuccess
{
    BOOL result = [GOMNode isNode:self.nodeDictionary];
    XCTAssertTrue(result, @"The result should be false");
}

- (void)testGOMNodeNoNode
{
    GOMNode *node = [GOMNode nodeFromDictionary:self.noNodeDictionary];
    XCTAssertNil(node, @"The result should be nil.");
}

- (void)testGOMNodeFalseKeys
{
    GOMNode *node = [GOMNode nodeFromDictionary:self.falseNodeDictionary];
    XCTAssertNil(node.ctime, @"node.ctime should be nil.");
    XCTAssertNil(node.mtime, @"node.ctime should be nil.");
    XCTAssertNil(node.uri, @"node.uri should be nil.");
    XCTAssertTrue(node.entries.count == 0, @"There should be no object in the node's entries list.");
}

- (void)testGOMNodeSuccess
{
    // check node values
    GOMNode *node = [GOMNode nodeFromDictionary:self.nodeDictionary];
    XCTAssertNotNil(node.ctime, @"node.ctime should not be nil.");
    XCTAssertNotNil(node.mtime, @"node.ctime should not be nil.");
    XCTAssertTrue([node.uri isEqualToString:NODE_URI], @"node.uri should be equal to reference value.");
    
    // check entry array
    XCTAssertTrue(node.entries.count == 1, @"There should be one object in the node's entries list.");
    XCTAssertTrue([node.entries[0] isKindOfClass:[GOMAttribute class]], @"There should be one object of class GOMAttribute in the node's entries list.");
    
    // check attribute entry
    GOMAttribute *attribute = node.entries[0];
    XCTAssertNotNil(attribute.ctime, @"attribute.ctime should not be nil.");
    XCTAssertNotNil(attribute.mtime, @"attribute.ctime should not be nil.");
    XCTAssertTrue([attribute.node isEqualToString:NODE_ATTRIBUTE_1_NODE], @"attribute.node should be equal to reference value.");
    XCTAssertTrue([attribute.type isEqualToString:NODE_ATTRIBUTE_1_TYPE], @"attribute.type should be equal to reference value.");
    XCTAssertTrue([attribute.name isEqualToString:NODE_ATTRIBUTE_1_NAME], @"attribute.name should be equal to reference value.");
    XCTAssertTrue([attribute.value isEqualToString:NODE_ATTRIBUTE_1_VALUE], @"attribute.value should be equal to reference value.");
}

- (void)testGOMNodeKeypathSearch
{
    GOMNode *node = [GOMNode nodeFromDictionary:self.nodeDictionary];
    NSArray *attributeNames = [node valueForKeyPath:@"entries.name"];
    XCTAssertTrue(attributeNames.count == 1, @"There should be one object name in the result set.");
    XCTAssertTrue([attributeNames[0] isKindOfClass:[NSString class]], @"There should be one object of class NSString in the node's entries list.");
    XCTAssertTrue([attributeNames[0] isEqualToString:NODE_ATTRIBUTE_1_NAME], @"attribute.name should be equal to reference value.");
}

@end
