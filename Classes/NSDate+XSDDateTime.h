//
//  NSDate+XSDTIme.h
//  gom-client-objc
//
//  Created by Julian Krumow on 08.03.14.
//  Copyright (c) 2014 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (XSDDateTime)

+ (NSDate *)dateFromXSDTimeString:(NSString *)dateString;

@end
