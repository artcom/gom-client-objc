//
//  NSData+JSON.m
//  gom-client-objc
//
//  Created by Julian Krumow on 17.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import "NSData+JSON.h"

@implementation NSData (JSON)

- (id)parseAsJSON
{
    return [NSJSONSerialization JSONObjectWithData:self options:kNilOptions error:nil];
}

@end
