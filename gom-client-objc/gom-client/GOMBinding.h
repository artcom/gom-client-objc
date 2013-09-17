//
//  GOMBinding.h
//  gom-client-objc
//
//  Created by Julian Krumow on 12.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GOMHandle.h"

/**
 This class represents the binding of an observer to a given GOM path.
 
 */
@interface GOMBinding : NSObject

@property (nonatomic, strong) NSString *subscriptionUri;
@property (nonatomic, strong) NSString *observerUri;
@property (nonatomic, strong, readonly) NSMutableArray *handles;

@property (nonatomic, unsafe_unretained) BOOL registered;

/**
 Custom initializer to create a GOM binding with a given subscription uri.
 
 @param subscriptionUri The given path to observe
 
 @return The resulting GOMBinding object
 */
- (id)initWithSubscriptionUri:(NSString *)subscriptionUri;

/**
 Adds a given GOMHandle object to the binding.
 
 @param handle The GOMHandle object to add
 */
- (void)addHandle:(GOMHandle *)handle;

@end
