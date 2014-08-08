//
//  GOMHandle.h
//  gom-client-objc
//
//  Created by Julian Krumow on 12.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GOMBinding;
@class GOMGnp;

typedef void (^GOMHandleCallback)(GOMGnp *);

@interface GOMHandle : NSObject

@property (nonatomic, weak, readonly) GOMBinding *binding;
@property (nonatomic, strong, readonly) GOMHandleCallback callback;
@property (nonatomic, assign, readonly) BOOL initialRetrieved;

- (instancetype)initWithBinding:(GOMBinding *)binding callback:(GOMHandleCallback)callback;

- (void)fireCallbackWithObject:(id)object;
- (void)fireInitialCallbackWithObject:(id)object;

@end
