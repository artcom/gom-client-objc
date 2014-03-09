//
//  GOMNode.h
//  Pods
//
//  Created by Julian Krumow on 04.03.14.
//  Copyright (c) 2014 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GOMNode : NSObject

@property (nonatomic, strong) NSDate *ctime;
@property (nonatomic, strong) NSDate *mtime;

@property (nonatomic, strong) NSString *uri;

@property (nonatomic, strong) NSMutableArray *entries;

+ (BOOL)isNode:(NSDictionary *)dictionary;
+ (GOMNode *)nodeFromDictionary:(NSDictionary *)dictionary;

@end
