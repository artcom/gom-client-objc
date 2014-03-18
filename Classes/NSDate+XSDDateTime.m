//
//  NSDate+XSDTIme.m
//  gom-client-objc
//
//  Created by Julian Krumow on 08.03.14.
//  Copyright (c) 2014 ART+COM AG. All rights reserved.
//

#import "NSDate+XSDDateTime.h"

@implementation NSDate (XSDDateTime)

+ (NSDate *)dateFromXSDTimeString:(NSString *)dateString
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:sszzz"];
    return [formatter dateFromString:dateString];
}

@end
