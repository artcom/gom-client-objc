//
//  GOMOperationRetrieveNode.m
//  Pods
//
//  Created by Julian Krumow on 08.08.14.
//
//

#import "GOMOperationRetrieveNode.h"

@interface GOMOperationRetrieveNode ()

@property (nonatomic, strong) GOMClientRetrieveNodeCallback callback;

@end

@implementation GOMOperationRetrieveNode

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate callback:(GOMClientRetrieveNodeCallback)callback;
{
    self = [super initWithRequest:request delegate:delegate];
    if (self) {
        
        self.callback = callback;
    }
    return self;
}

- (void)handleResponse:(NSDictionary *)response error:(NSError *)error
{
    GOMNode *node = [GOMNode nodeFromDictionary:response];
    self.callback(node, error);
}

@end
