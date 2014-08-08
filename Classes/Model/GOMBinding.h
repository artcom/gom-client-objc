//
//  GOMBinding.h
//  gom-client-objc
//
//  Created by Julian Krumow on 12.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GOMHandle.h"


@interface GOMBinding : NSObject

@property (nonatomic, strong, readonly) NSString *subscriptionUri;
@property (nonatomic, strong, readonly) NSMutableArray *handles;
@property (nonatomic, assign) BOOL registered;

- (instancetype)initWithSubscriptionUri:(NSString *)subscriptionUri;
- (void)addHandle:(GOMHandle *)handle;

- (void)fireCallbacksWithObject:(GOMGnp *)object;
- (void)fireInitialCallbacksWithObject:(GOMGnp *)object;

@end
