//
//  NSString+JSON.h
//  gom-client-objc
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JSON)

/**
 Parses the string object as JSON and returns a Foundation object or nil.
 
 @return The resulting Foundation object or nil
 */
- (id)parseAsJSON;

@end
