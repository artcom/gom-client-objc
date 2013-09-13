//
//  GOMHandle.m
//  iOS-Gom-Client
//
//  Created by Julian Krumow on 12.09.13.
//
//

#import "GOMHandle.h"

@implementation GOMHandle


- (id)initWithBinding:(GOMBinding *)aBinding callback:(GOMHandleCallback)aCallback
{
    self = [super init];
    if (self) {
        self.binding = aBinding;
        self.callback = aCallback;
        self.initialRetrieved = false;
    }
    return self;
}

@end
