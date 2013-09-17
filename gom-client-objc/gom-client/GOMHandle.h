//
//  GOMHandle.h
//  gom-client-objc
//
//  Created by Julian Krumow on 12.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GOMBinding;

typedef void (^GOMHandleCallback)(NSDictionary *);

/**
 This class represents a handle on a given GOMBinding.
 
 */
@interface GOMHandle : NSObject

@property (nonatomic, weak) GOMBinding *binding;
@property (nonatomic, strong) GOMHandleCallback callback;
@property (nonatomic, unsafe_unretained) BOOL initialRetrieved;

/**
 Custom initializer to create a handle on a given GOMBinding object.
 
 @param binding The given GOMBinding object
 @param callback The given callback function to  call
 
 @return The resulting GOMHandle object
 */
- (id)initWithBinding:(GOMBinding *)binding callback:(GOMHandleCallback)callback;

@end
