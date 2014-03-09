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

@end

@implementation GOMNodeTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testGOMNodeSuccess
{
    NSDictionary *dictionary = @{
                                 @"node" : @{
                                         @"ctime" : @"2014-03-09T15:00:20+01:00",
                                         @"mtime" : @"2014-03-09T15:00:20+01:00",
                                         @"uri" : @"/tests/",
                                         @"entries" :@[
                                                 @{
                                                     @"attribute" : @{
                                                             @"ctime" : @"",
                                                             @"mtime" : @"2014-03-09T15:00:20+01:00",
                                                             @"node" : @"/tests/",
                                                             @"type" : @"string",
                                                             @"name" : @"name1",
                                                             @"value" : @"value1"
                                                             }
                                                     }
                                                 ]
                                         }
                                 };
    GOMNode *node = [GOMNode nodeFromDictionary:dictionary];
    XCTAssertTrue([node.uri isEqualToString:@"/tests/"], @"node.uri should be equal to reference value.");
    XCTAssertTrue(node.entries.count > 0, @"there should be one attribute in the node's entries list.");
    XCTAssertTrue([node.entries[0] isKindOfClass:[GOMAttribute class]], @"there should be one attribute in the node's entries list.");
    
    NSArray *attributeName = [node valueForKeyPath:@"entries.name"];
    XCTAssertTrue(attributeName.count > 0, @"there should be one attribute name in the result set.");
    XCTAssertTrue([attributeName[0] isEqualToString:@"name1"], @"attribute.name should be equal to reference value.");
}

@end
