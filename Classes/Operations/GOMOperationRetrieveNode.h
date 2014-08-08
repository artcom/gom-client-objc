//
//  GOMOperationRetrieveNode.h
//  Pods
//
//  Created by Julian Krumow on 08.08.14.
//
//

#import "GOMOperation.h"

@class GOMNode;

typedef void (^GOMClientRetrieveNodeCallback)(GOMNode *, NSError *);

@interface GOMOperationRetrieveNode : GOMOperation

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate callback:(GOMClientRetrieveNodeCallback)callback;

@end
