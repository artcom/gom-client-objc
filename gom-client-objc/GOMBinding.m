//
//  GOMBinding.m
//  gom-client-objc
//
//  Created by Julian Krumow on 12.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import "GOMBinding.h"

@interface GOMBinding()

@end

@implementation GOMBinding

- (id)initWithSubscriptionUri:(NSString *)subscriptionUri
{
    self = [super init];
    if (self) {
        _subscriptionUri = subscriptionUri;
        _observerUri = nil;
        _handles = [[NSMutableArray alloc] init];
        _registered = NO;
    }
    return self;
}

- (void)addHandle:(GOMHandle *)handle
{
    [_handles addObject:handle];
}

@end
