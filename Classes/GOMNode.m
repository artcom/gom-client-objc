//
//  GOMNode.m
//  Pods
//
//  Created by Julian Krumow on 04.03.14.
//
//

#import "GOMNode.h"
#import "GOMAttribute.h"

@interface GOMNode()

@end

@implementation GOMNode

+ (GOMNode *)nodeFromDictionary:(NSDictionary *)dictionary
{
    GOMNode *node = nil;
    if ([GOMNode isNode:dictionary]) {
        node = [[GOMNode alloc] initWithDictionary:dictionary];
    }
    return node;
}

+ (BOOL)isNode:(NSDictionary *)dictionary
{
    return (dictionary[@"node"] != nil);
}

- (id)init
{
    self = [super init];
    if (self) {
        _entries = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _entries = [[NSMutableArray alloc] init];
        [self initializeWithDictionary:dictionary];
    }
    return self;
}

- (void)initializeWithDictionary:(NSDictionary *)dictionary
{
    [self setValuesForKeysWithDictionary:dictionary[@"node"]];
}


#pragma mark - KVC implementations

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"node"]) {
        self.uri = value;
    } else if ([key isEqualToString:@"entries"]) {
        for (NSDictionary *entry in value) {
            if ([GOMAttribute isAttribute:entry]) {
                GOMAttribute *attribute = [GOMAttribute attributeFromDictionary:entry];
                [_entries addObject:attribute];
            } else if ([GOMNode isNode:entry]) {
                GOMNode *node = [GOMNode nodeFromDictionary:@{@"node" : entry}];
                [_entries addObject:node];
            }
        }
    } else {
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    // we do nothing here.
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath
{
    [super setValue:value forKeyPath:keyPath];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"node"]) {
        return _uri;
    }
    return nil;
}

@end
