//
//  GOMGnp.m
//  gom-client-objc
//
//  Created by Julian Krumow on 08.08.14.
//  Copyright (c) 2014 ART+COM AG. All rights reserved.
//

#import "GOMGnp.h"

@implementation GOMGnp

+ (GOMGnp *)GnpFromDictionary:(NSDictionary *)dictionary
{
    GOMGnp *gnp = nil;
    if ([GOMGnp isGnp:dictionary]) {
        gnp = [[GOMGnp alloc] initWithDictionary:dictionary];
    }
    return gnp;
}

+ (BOOL)isGnp:(NSDictionary *)dictionary
{
    return (dictionary[@"initial"] != nil || dictionary[@"payload"] != nil);
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        [self initializeWithDictionary:dictionary];
    }
    return self;
}

- (void)initializeWithDictionary:(NSDictionary *)dictionary
{
    // TODO: finish implementation and add unit tests.
    //[self setValuesForKeysWithDictionary:dictionary[@""]];
}


@end
