//
//  NSDate+XSDTIme.m
//  Pods
//
//  Created by Julian Krumow on 08.03.14.
//
//

#import "NSDate+XSDTime.h"

@implementation NSDate (XSDTime)

+ (NSDate *)dateFromXSDTimeString:(NSString *)dateString
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:sszzz"];
    return [formatter dateFromString:dateString];
}

@end
