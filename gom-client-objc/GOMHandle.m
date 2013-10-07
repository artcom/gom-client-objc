//
//  GOMHandle.m
//  gom-client-objc
//
//  Created by Julian Krumow on 12.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import "GOMHandle.h"

@implementation GOMHandle

- (id)initWithBinding:(GOMBinding *)binding callback:(GOMHandleCallback)callback
{
    self = [super init];
    if (self) {
        _binding = binding;
        _callback = callback;
        _initialRetrieved = false;
    }
    return self;
}

@end
