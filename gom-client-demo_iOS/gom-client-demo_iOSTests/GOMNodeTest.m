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


@interface GOMNodeTest : XCTestCase

@property (nonatomic, strong) NSDictionary *attributeDictionary;
@property (nonatomic, strong) NSDictionary *nodeDictionary;
@property (nonatomic, strong) NSDictionary *subNodeDictionary;
@property (nonatomic, strong) NSDictionary *falseNodeDictionary;
@property (nonatomic, strong) NSDictionary *noNodeDictionary;

@end

@implementation GOMNodeTest

NSString * const NODE_CTIME = @"2014-03-09T16:50:20+01:00";
NSString * const NODE_MTIME = @"2014-03-09T16:56:20+01:00";
NSString * const NODE_URI = @"/tests/node1";

NSString * const NODE_SUB_CTIME = @"2014-03-10T12:00:00+01:00";
NSString * const NODE_SUB_MTIME = @"2014-03-11T12:00:00+01:00";
NSString * const NODE_SUB_URI = @"/tests/node1/node2";

NSString * const NODE_ATTRIBUTE_1_CTIME = @"2014-03-09T18:00:10+01:00";
NSString * const NODE_ATTRIBUTE_1_MTIME = @"2014-03-09T19:00:30+01:00";
NSString * const NODE_ATTRIBUTE_1_NODE = @"/tests/node1";

NSString * const NODE_ATTRIBUTE_1_TYPE = @"string";
NSString * const NODE_ATTRIBUTE_1_NAME = @"name1";
NSString * const NODE_ATTRIBUTE_1_VALUE = @"value1";

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
    
    _subNodeDictionary = @{
                           @"ctime" : NODE_SUB_CTIME,
                           @"mtime" : NODE_SUB_MTIME,
                           @"node" : NODE_SUB_URI
                           };
    
    _nodeDictionary = @{
                        @"node" : @{
                                @"ctime" : NODE_CTIME,
                                @"mtime" : NODE_MTIME,
                                @"uri" : NODE_URI,
                                @"entries" :@[
                                        self.subNodeDictionary,
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
                                             @{},
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
    XCTAssertFalse(result, @"The dictionary should contain no valid gom node data.");
}

- (void)testGOMNodeCheckIsNodeSuccess
{
    BOOL result = [GOMNode isNode:self.nodeDictionary];
    XCTAssertTrue(result, @"The dictionary should contain valid gom node data.");
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
    XCTAssertNil(node.mtime, @"node.mtime should be nil.");
    XCTAssertNil(node.uri, @"node.uri should be nil.");
    XCTAssertTrue(node.entries.count == 0, @"There should be no object in the node's entries list.");
}

- (void)testGOMNodeSuccess
{
    // check node values
    GOMNode *node = [GOMNode nodeFromDictionary:self.nodeDictionary];
    XCTAssertNotNil(node.ctime, @"node.ctime should not be nil.");
    XCTAssertNotNil(node.mtime, @"node.mtime should not be nil.");
    XCTAssertTrue([node.uri isEqualToString:NODE_URI], @"node.uri should be equal to the reference value.");
    
    // check entry array
    XCTAssertTrue(node.entries.count == 2, @"There should be two objects in the node's entries list.");
    
    XCTAssertTrue([node.entries[0] isKindOfClass:[GOMNode class]],  @"There should be one object of class GOMNode in the node's entries list.");
    XCTAssertTrue([node.entries[1] isKindOfClass:[GOMAttribute class]], @"There should be one object of class GOMAttribute in the node's entries list.");
    
    // check node entry
    GOMNode *subNode = node.entries[0];
    XCTAssertNotNil(subNode.ctime, @"subNode.ctime should not be nil.");
    XCTAssertNotNil(subNode.mtime, @"subNode.mtime should not be nil.");
    XCTAssertTrue([subNode.uri isEqualToString:NODE_SUB_URI], @"subNode.uri should be equal to the reference value.");
    XCTAssertTrue(subNode.entries.count == 0, @"There should be no object in the subNode's entries list.");
    
    // check attribute entry
    GOMAttribute *attribute = node.entries[1];
    XCTAssertNotNil(attribute.ctime, @"attribute.ctime should not be nil.");
    XCTAssertNotNil(attribute.mtime, @"attribute.mtime should not be nil.");
    XCTAssertTrue([attribute.node isEqualToString:NODE_ATTRIBUTE_1_NODE], @"attribute.node should be equal to the reference value.");
    XCTAssertTrue([attribute.type isEqualToString:NODE_ATTRIBUTE_1_TYPE], @"attribute.type should be equal to the reference value.");
    XCTAssertTrue([attribute.name isEqualToString:NODE_ATTRIBUTE_1_NAME], @"attribute.name should be equal to the reference value.");
    XCTAssertTrue([attribute.value isEqualToString:NODE_ATTRIBUTE_1_VALUE], @"attribute.value should be equal to the reference value.");
}

- (void)testGOMNodeKeyPathSearchNames
{
    GOMNode *node = [GOMNode nodeFromDictionary:self.nodeDictionary];
    NSArray *attributeNames = [node valueForKeyPath:@"entries.name"];
    XCTAssertTrue(attributeNames.count == 2, @"There should be two objects in the result set.");
    XCTAssertTrue([attributeNames[0] isKindOfClass:[NSNull class]], @"There should be one object of class NSNull in the result list.");
    XCTAssertTrue([attributeNames[1] isKindOfClass:[NSString class]], @"There should be one object of class NSString in the result list.");
    XCTAssertTrue([attributeNames[1] isEqualToString:NODE_ATTRIBUTE_1_NAME], @"The retrieved value should be equal to the reference value.");
}

- (void)testGOMNodeKeyPathSearchNodes
{
    GOMNode *node = [GOMNode nodeFromDictionary:self.nodeDictionary];
    NSArray *subNodeUris = [node valueForKeyPath:@"entries.node"];
    XCTAssertTrue(subNodeUris.count == 2, @"There should be two objects in the result set.");
    XCTAssertTrue([subNodeUris[0] isKindOfClass:[NSNull class]], @"There should be one object of class NSNull in the result list.");
    XCTAssertTrue([subNodeUris[1] isKindOfClass:[NSString class]], @"There should be one object of class NSString in the result list.");
    XCTAssertTrue([subNodeUris[1] isEqualToString:NODE_URI], @"The retrieved value should be equal to the reference value.");
}

@end
