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
 This class represents...
 
 */
@interface GOMHandle : NSObject

@property (nonatomic, weak) GOMBinding *binding;
@property (nonatomic, strong) GOMHandleCallback callback;
@property (nonatomic, unsafe_unretained) BOOL initialRetrieved;

/**
 Custom initializer to create a GOMHandle with a given GOMBinding object and a callback function.
 
 @param binding The given GOMBinding object
 @param callback The given callback function to  call
 
 @return The resulting GOMHandle object
 */
- (id)initWithBinding:(GOMBinding *)binding callback:(GOMHandleCallback)callback;

@end
