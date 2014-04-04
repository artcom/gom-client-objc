//
//  NSDictionary+XML.m
//  gom-client-objc
//
//  Created by Julian Krumow on 20.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import "NSDictionary+XML.h"
#import "NSString+XML.h"

@implementation NSDictionary (XML)

- (NSString *)convertToNodeXML
{
    NSString *result = @"";
    
    for (id key in self.allKeys) {
        if ([self[key] isKindOfClass:[NSString class]]) {
            NSString *value = self[key];
            NSString *attribute = [NSString stringWithFormat:@"<attribute name=\"%@\" type=\"string\">%@</attribute>", key, [value escapedString]];
            result = [result stringByAppendingString:attribute];
        } else {
            [[NSException exceptionWithName:@"XMLConversionException"
                                     reason:@"Attribute is not an NSString."
                                   userInfo:nil]
             raise];
        }
    }
    
    return [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><node>%@</node>", result];
}
@end
