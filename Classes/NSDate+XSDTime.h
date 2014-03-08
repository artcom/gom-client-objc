//
//  NSDate+XSDTIme.h
//  Pods
//
//  Created by Julian Krumow on 08.03.14.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (XSDTime)

+ (NSDate *)dateFromXSDTimeString:(NSString *)dateString;

@end
