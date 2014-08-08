//
//  GOMNode.h
//  gom-client-objc
//
//  Created by Julian Krumow on 04.03.14.
//  Copyright (c) 2014 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GOMEntry.h"

@interface GOMNode : GOMEntry

@property (nonatomic, strong) NSString *uri;
@property (nonatomic, strong) NSMutableArray *entries;

+ (BOOL)isNode:(NSDictionary *)dictionary;
+ (GOMNode *)nodeFromDictionary:(NSDictionary *)dictionary;

@end
