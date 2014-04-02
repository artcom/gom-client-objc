//
//  NSString+XML.m
//  gom-client-objc
//
//  Created by Julian Krumow on 03.04.14.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import "NSString+XML.h"

@implementation NSString (XML)

- (NSString *)convertToAttributeXML
{
    return [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><attribute type=\"string\">%@</attribute>", self];
}

@end
