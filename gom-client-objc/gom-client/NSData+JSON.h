//
//  NSData+JSON.h
//  gom-client-objc
//
//  Created by Julian Krumow on 17.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (JSON)

/**
 Parses the data object as JSON ans returns a Foundation object or nil.
 
 @return The resulting Foundation object or nil
 */
- (id)parseAsJSON;

@end
