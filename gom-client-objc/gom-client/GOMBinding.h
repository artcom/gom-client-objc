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

@property (nonatomic, strong) NSString *subscriptionUri;
@property (nonatomic, strong) NSString *observerUri;
@property (nonatomic, strong, readonly) NSMutableArray *handles;
@property (nonatomic, unsafe_unretained) BOOL registered;

- (id)initWithSubscriptionUri:(NSString *)subscriptionUri;
- (void)addHandle:(GOMHandle *)handle;

@end
