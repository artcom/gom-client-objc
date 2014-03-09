//
//  DictionaryXMLTests.m
//  gom-client-demo_iOS
//
//  Created by Julian Krumow on 09.03.14.
//  Copyright (c) 2014 ART+COM AG. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSDictionary+XML.h"

@interface DictionaryXMLTests : XCTestCase

@end

@implementation DictionaryXMLTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testConvertAttributeToXMLFail
{
    NSDictionary *attributesBroken = @{@"attribute1" : @"value1", @"attribute2" : @NO};
    XCTAssertThrowsSpecificNamed([attributesBroken convertToXML], NSException, @"XMLConversionException", @"should throw Exception named XMLConversionException stating: 'Attribute is not an NSString.'");
}

- (void)testConvertAttributeToXMLSuccess
{
    NSString *XML = @"<attribute name=\"attribute2\" type=\"string\">value2</attribute><attribute name=\"attribute1\" type=\"string\">value1</attribute>";
    NSDictionary *attributes = @{@"attribute1" : @"value1", @"attribute2" : @"value2"};
    NSString *result = [attributes convertToXML];
    XCTAssertTrue([result isEqualToString:XML], @"XML output should conform to specification.");
}

@end
