//
//  GOMAttribute.m
//  Pods
//
//  Created by Julian Krumow on 04.03.14.
//
//

#import "GOMAttribute.h"

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

- (id)valueForUndefinedKey:(NSString *)key
{
    return nil;
}

@end
