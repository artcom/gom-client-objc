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

@property (nonatomic, strong) NSMutableArray *privEntries;
@property (nonatomic, strong) NSDictionary *privNodeData;
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

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        
        [self initializeWithDictionary:dictionary];
    }
    return self;
}

- (NSArray *)entries
{
    return (NSArray *)_privEntries;
}

- (void)initializeWithDictionary:(NSDictionary *)dictionary
{
    _privNodeData = dictionary;
    _privEntries = [[NSMutableArray alloc] init];
    
    NSDictionary *nodeDictionary = dictionary[@"node"];
    if (nodeDictionary) {
        _ctime = nodeDictionary[@"ctime"];
        _mtime = nodeDictionary[@"mtime"];
        _uri = nodeDictionary[@"uri"];
        
        NSArray *entries = nodeDictionary[@"entries"];
        for (NSDictionary *entry in entries) {
            if ([GOMAttribute isAttribute:entry]) {
                GOMAttribute *attribute = [GOMAttribute attributeFromDictionary:entry];
                [_privEntries addObject:attribute];
            } else {
                GOMNode *node = [[GOMNode alloc] init];
                node.ctime = entry[@"ctime"];
                node.mtime = entry[@"mtime"];
                node.uri = entry[@"node"];
                [_privEntries addObject:node];
            }
        }
    }
}

- (id)valueForKeyPath:(NSString *)keyPath
{
    return [_privNodeData valueForKeyPath:keyPath];
}

@end
