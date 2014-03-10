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

@property (nonatomic, strong) NSDictionary *attributeDictionary;
@property (nonatomic, strong) NSDictionary *falseAttributeDictionary;
@property (nonatomic, strong) NSDictionary *noAttributeDictionary;

@end

@implementation GOMAttributeTest

NSString * const ATTRIB_CTIME = @"2014-03-09T15:00:20+01:00";
NSString * const ATTRIB_MTIME = @"2014-03-09T15:01:20+01:00";
NSString * const ATTRIB_NODE = @"/tests/node1";
NSString * const ATTRIB_TYPE = @"string";
NSString * const ATTRIB_NAME = @"name1";
NSString * const ATTRIB_VALUE = @"value1";

- (void)setUp
{
    [super setUp];
    
    _attributeDictionary = @{
                             @"attribute" : @{
                                     @"ctime" : ATTRIB_CTIME,
                                     @"mtime" : ATTRIB_MTIME,
                                     @"node"  : ATTRIB_NODE,
                                     @"type"  : ATTRIB_TYPE,
                                     @"name"  : ATTRIB_NAME,
                                     @"value" : ATTRIB_VALUE
                                     }
                             };
    
    _falseAttributeDictionary = @{
                                  @"attribute" : @{
                                          @"ctme"    : ATTRIB_CTIME,
                                          @"mime"    : ATTRIB_MTIME,
                                          @"noodle"  : ATTRIB_NODE,
                                          @"typo"    : ATTRIB_TYPE,
                                          @"bob"     : ATTRIB_NAME,
                                          @"valerie" : ATTRIB_VALUE
                                          }
                                  };
    
    _noAttributeDictionary = @{
                               @"foo" : @NO
                               };
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testGOMAttributeCheckIsAttributeFail
{
    BOOL result = [GOMAttribute isAttribute:self.noAttributeDictionary];
    XCTAssertFalse(result, @"The result should be false.");
}

- (void)testGOMAttributeCheckIsAttributeSuccess
{
    BOOL result = [GOMAttribute isAttribute:self.attributeDictionary];
    XCTAssertTrue(result, @"The result should be true.");
}

- (void)testGOMAttributeNoAttribute
{
    GOMAttribute *attribute = [GOMAttribute attributeFromDictionary:self.noAttributeDictionary];
    XCTAssertNil(attribute, @"The result should be nil.");
}

- (void)testGOMAttributeFalseKeys
{
    GOMAttribute *attribute = [GOMAttribute attributeFromDictionary:self.falseAttributeDictionary];
    XCTAssertNil(attribute.ctime, @"attribute.ctime should be nil.");
    XCTAssertNil(attribute.mtime, @"attribute.mtime should be nil.");
    XCTAssertNil(attribute.node, @"attribute.node should be nil.");
    XCTAssertNil(attribute.type, @"attribute.type should be nil.");
    XCTAssertNil(attribute.name, @"attribute.name should be nil.");
    XCTAssertNil(attribute.value, @"attribute.value should be nil.");
}


- (void)testGOMAttributeSuccess
{
    GOMAttribute *attribute = [GOMAttribute attributeFromDictionary:self.attributeDictionary];
    XCTAssertNotNil(attribute.ctime, @"attribute.ctime should not be nil.");
    XCTAssertNotNil(attribute.mtime, @"attribute.mtime should not be nil.");
    XCTAssertTrue([attribute.node isEqualToString:ATTRIB_NODE], @"attribute.node should be equal to the reference value.");
    XCTAssertTrue([attribute.type isEqualToString:ATTRIB_TYPE], @"attribute.type should be equal to the reference value.");
    XCTAssertTrue([attribute.name isEqualToString:ATTRIB_NAME], @"attribute.name should be equal to the reference value.");
    XCTAssertTrue([attribute.value isEqualToString:ATTRIB_VALUE], @"attribute.value should be equal to the reference value.");
}

@end
