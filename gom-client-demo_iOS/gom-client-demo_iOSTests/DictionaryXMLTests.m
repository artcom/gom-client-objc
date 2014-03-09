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

@property (nonatomic, strong) NSString *XML;
@property (nonatomic, strong) NSDictionary *attributes;
@property (nonatomic, strong) NSDictionary *attributesBroken;

@end

@implementation DictionaryXMLTests

- (void)setUp
{
    [super setUp];
    
    _XML = [NSString stringWithFormat:@"<attribute name=\"%@\" type=\"string\">%@</attribute><attribute name=\"%@\" type=\"string\">%@</attribute>", XML_ATTRIBUTE_NAME_2, XML_ATTRIBUTE_VALUE_2, XML_ATTRIBUTE_NAME_1, XML_ATTRIBUTE_VALUE_1];
    _attributes = @{XML_ATTRIBUTE_NAME_1 : XML_ATTRIBUTE_VALUE_1, XML_ATTRIBUTE_NAME_2 : XML_ATTRIBUTE_VALUE_2};
    _attributesBroken = @{XML_ATTRIBUTE_NAME_1 : XML_ATTRIBUTE_VALUE_1, XML_ATTRIBUTE_NAME_2 : @NO};
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testConvertAttributeToXMLFail
{
    XCTAssertThrowsSpecificNamed([self.attributesBroken convertToXML], NSException, @"XMLConversionException", @"should throw Exception named XMLConversionException stating: 'Attribute is not an NSString.'");
}

- (void)testConvertAttributeToXMLSuccess
{
    NSString *result = [self.attributes convertToXML];
    XCTAssertTrue([result isEqualToString:self.XML], @"XML output should conform to specification.");
}

@end
