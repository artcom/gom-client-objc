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

@property (nonatomic, strong) NSString *XML;
@property (nonatomic, strong) NSDictionary *attributes;
@property (nonatomic, strong) NSDictionary *attributesBroken;

@end

@implementation DictionaryXMLTests

- (void)setUp
{
    [super setUp];
    
    _XML = @"<attribute name=\"attribute2\" type=\"string\">value2</attribute><attribute name=\"attribute1\" type=\"string\">value1</attribute>";
    _attributes = @{@"attribute1" : @"value1", @"attribute2" : @"value2"};
    _attributesBroken = @{@"attribute1" : @"value1", @"attribute2" : @NO};
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
