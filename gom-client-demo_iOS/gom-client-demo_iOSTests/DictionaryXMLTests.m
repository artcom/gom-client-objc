//
//  DictionaryXMLTests.m
//  gom-client-demo_iOS
//
//  Created by Julian Krumow on 09.03.14.
//  Copyright (c) 2014 ART+COM AG. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSDictionary+XML.h"

NSString * const XML_ATTRIBUTE_NAME_1 = @"attribute1";
NSString * const XML_ATTRIBUTE_NAME_2 = @"attribute2";
NSString * const XML_ATTRIBUTE_VALUE_1 = @"value1";
NSString * const XML_ATTRIBUTE_VALUE_2 = @"value2";

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
    NSDictionary *attributesBroken = @{XML_ATTRIBUTE_NAME_1 : XML_ATTRIBUTE_VALUE_1, XML_ATTRIBUTE_NAME_2 : @NO};
    XCTAssertThrowsSpecificNamed([attributesBroken convertToXML], NSException, @"XMLConversionException", @"should throw Exception named XMLConversionException stating: 'Attribute is not an NSString.'");
}

- (void)testConvertAttributeToXMLSuccess
{
    NSString *XML_1 = [NSString stringWithFormat:@"<attribute name=\"%@\" type=\"string\">%@</attribute>", XML_ATTRIBUTE_NAME_1, XML_ATTRIBUTE_VALUE_1];
    NSString *XML_2 = [NSString stringWithFormat:@"<attribute name=\"%@\" type=\"string\">%@</attribute>", XML_ATTRIBUTE_NAME_2, XML_ATTRIBUTE_VALUE_2];
    
    NSDictionary *attributes = @{XML_ATTRIBUTE_NAME_1 : XML_ATTRIBUTE_VALUE_1, XML_ATTRIBUTE_NAME_2 : XML_ATTRIBUTE_VALUE_2};
    NSString *result = [attributes convertToXML];
    
    XCTAssertTrue([result rangeOfString:XML_1].location != NSNotFound, @"XML output should conform to specification.");
    XCTAssertTrue([result rangeOfString:XML_2].location != NSNotFound, @"XML output should conform to specification.");
}

@end
