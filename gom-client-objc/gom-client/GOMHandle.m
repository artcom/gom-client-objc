//
//  GOMHandle.m
//  iOS-Gom-Client
//
//  Created by Julian Krumow on 12.09.13.
//
//

#import "GOMHandle.h"

@implementation GOMHandle
@synthesize callback = _callback;
@synthesize initialRetrieved;

- (id)initWithBinding:(GOMBinding *)aBinding callback:(GOMHandleCallback)aCallback
{
    self = [super init];
    if (self) {
        self.binding = aBinding;
        self.callback = aCallback;
        initialRetrieved = false;
    }
    return self;
}

@end
