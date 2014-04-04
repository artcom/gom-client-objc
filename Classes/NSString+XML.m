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
    return [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><attribute type=\"string\">%@</attribute>", [self xmlEscape]];
}

- (NSString *)xmlEscape
{
    NSMutableString *escapedString = [self mutableCopy];
    [escapedString replaceOccurrencesOfString:@"&"  withString:@"&amp;"  options:NSLiteralSearch range:NSMakeRange(0, [escapedString length])];
    [escapedString replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, [escapedString length])];
    [escapedString replaceOccurrencesOfString:@"'"  withString:@"&#x27;" options:NSLiteralSearch range:NSMakeRange(0, [escapedString length])];
    [escapedString replaceOccurrencesOfString:@">"  withString:@"&gt;"   options:NSLiteralSearch range:NSMakeRange(0, [escapedString length])];
    [escapedString replaceOccurrencesOfString:@"<"  withString:@"&lt;"   options:NSLiteralSearch range:NSMakeRange(0, [escapedString length])];
    
    return escapedString;
}

@end
