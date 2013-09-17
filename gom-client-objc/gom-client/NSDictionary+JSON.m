//
//  NSDictionary+JSON.m
//  gom-client-objc
//
//  Created by Julian Krumow on 17.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary (JSON)

- (id)convertToJSON
{
    NSError *error = nil;
    return [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:&error];
}

@end
