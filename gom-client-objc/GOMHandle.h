//
//  GOMHandle.h
//  gom-client-objc
//
//  Created by Julian Krumow on 12.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^GOMHandleCallback)(NSDictionary *);

@class GOMBinding;
@interface GOMHandle : NSObject

@property (nonatomic, weak) GOMBinding *binding;
@property (nonatomic, strong) GOMHandleCallback callback;
@property (nonatomic, assign) BOOL initialRetrieved;

- (id)initWithBinding:(GOMBinding *)binding callback:(GOMHandleCallback)callback;

- (void)fireCallbackWithObject:(id)object;
- (void)fireInitialCallbackWithObject:(id)object;

@end
