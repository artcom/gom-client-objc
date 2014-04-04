//
//  NSString+XML.h
//  gom-client-objc
//
//  Created by Julian Krumow on 03.04.14.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (XML)

- (NSString *)convertToAttributeXML;
- (NSString *)escapedString;
@end
