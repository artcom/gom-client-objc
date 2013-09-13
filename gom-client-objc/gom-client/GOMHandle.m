//
//  GOMHandle.m
//  iOS-Gom-Client
//
//  Created by Julian Krumow on 12.09.13.
//
//

#import "GOMHandle.h"

@implementation GOMHandle
@synthesize binding = _binding;
@synthesize callback = _callback;
@synthesize initialRetrieved;

- (id)initWithBinding:(GOMBinding *)binding callback:(GOMHandleCallback)callback
{
    self = [super init];
    if (self) {
        _binding = binding;
        _callback = callback;
        initialRetrieved = false;
    }
    return self;
}

@end
