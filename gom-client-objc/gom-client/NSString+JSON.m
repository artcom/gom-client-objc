//
//  NSString+JSON.m
//  gom-client-objc
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM. All rights reserved.
//

#import "NSString+JSON.h"

@implementation NSString (JSON)

- (id)stringToJSON
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

@end
