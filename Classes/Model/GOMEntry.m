//
//  GOMEntry.m
//  gom-client-objc
//
//  Created by Julian Krumow on 08.08.14.
//  Copyright (c) 2014 ART+COM AG. All rights reserved.
//

#import "GOMEntry.h"
#import "NSDate+XSDDateTime.h"

@implementation GOMEntry

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"ctime"] || [key isEqualToString:@"mtime"]) {
        value = [NSDate dateFromXSDTimeString:value];
    }
    [super setValue:value forKey:key];
}

@end
