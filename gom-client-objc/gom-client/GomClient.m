//
//  GOMClient.m
//  gom-client-objc
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM. All rights reserved.
//

#import "GOMClient.h"

@implementation GOMClient
@synthesize gomUrl = _gomUrl;

- (id)initWithGOMUrl:(NSString *)gomUrl
{
    self = [super init];
    if (self) {
        _gomUrl = gomUrl;
    }
    return self;
}

- (void)retrieveAttribute:(NSString *)attribute
{
    
}

- (void)retrieveNode:(NSString *)node
{
    
}

- (void)createNode:(NSString *)node
{
    
}

- (void)createNode:(NSString *)node withAttributes:(NSDictionary *)attributes
{
    
}

- (void)updateAttribute:(NSString *)attribute withValue:(NSString *)value
{
    
}

- (void)updateNode:(NSString *)node withAttributes:(NSDictionary *)attributes
{
    
}

- (void)deleteNode:(NSString *)node
{
    
}

@end
