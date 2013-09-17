//
//  NSDictionary+JSON.h
//  gom-client-objc
//
//  Created by Julian Krumow on 17.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSON)

/**
 Converts the dictionary to JSON data.
 
 @return The resulting JSON data or nil
 */
- (NSData *)convertToJSON;

@end
