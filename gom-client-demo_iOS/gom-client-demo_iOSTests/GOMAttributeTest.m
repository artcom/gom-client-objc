//
//  GOMAttributeTest.m
//  gom-client-demo_iOS
//
//  Created by Julian Krumow on 09.03.14.
//  Copyright (c) 2014 ART+COM AG. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GOMAttribute.h"

@interface GOMAttributeTest : XCTestCase

@end

@implementation GOMAttributeTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testGOMAttributeSuccess
{
    NSDictionary *dictionary = @{@"attribute" : @{@"ctime" : @"", @"mtime" : @"2014-03-09T15:00:20+01:00", @"node" : @"/tests/", @"type" : @"string", @"name" : @"name1", @"value" : @"value1"}};
    GOMAttribute *attribute = [GOMAttribute attributeFromDictionary:dictionary];
    
    XCTAssertTrue([attribute.name isEqualToString:@"name1"], @"attribute.name should be equal to reference value.");
}

@end
