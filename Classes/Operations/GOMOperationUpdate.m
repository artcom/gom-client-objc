//
//  GOMOperationUpdate.m
//  Pods
//
//  Created by Julian Krumow on 08.08.14.
//
//

#import "GOMOperationUpdate.h"

@implementation GOMOperationUpdate

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate callback:(GOMClientOperationCallback)callback
{
    self = [super initWithRequest:request delegate:delegate];
    if (self) {
        
        _callback = callback;
    }
    return self;
}

- (void)handleResponse:(NSDictionary *)response error:(NSError *)error
{
    if (_callback) {
        _callback(response, error);
    }
}

@end
