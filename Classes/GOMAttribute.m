//
//  GOMAttribute.m
//  Pods
//
//  Created by Julian Krumow on 04.03.14.
//  Copyright (c) 2014 ART+COM AG. All rights reserved.
//

#import "GOMAttribute.h"
#import "NSDate+XSDDateTime.h"

@implementation GOMAttribute

+ (GOMAttribute *)attributeFromDictionary:(NSDictionary *)dictionary
{
    GOMAttribute *attribute = nil;
    if ([GOMAttribute isAttribute:dictionary]) {
        attribute = [[GOMAttribute alloc] initWithDictionary:dictionary];
    }
    return attribute;
}

+ (BOOL)isAttribute:(NSDictionary *)dictionary
{
    return (dictionary[@"attribute"] != nil);
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        [self initializeWithDictionary:dictionary];
    }
    return self;
}

- (void)initializeWithDictionary:(NSDictionary *)dictionary
{
    [self setValuesForKeysWithDictionary:dictionary[@"attribute"]];
}

#pragma mark - KVC implementations

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"ctime"] || [key isEqualToString:@"mtime"]) {
        value = [NSDate dateFromXSDTimeString:value];
    }
    [super setValue:value forKey:key];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    return [NSNull null];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    // we do nothing here.
}



@end
