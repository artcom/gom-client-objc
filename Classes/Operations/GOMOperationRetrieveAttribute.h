//
//  GOMOperationRetrieveAttribute.h
//  Pods
//
//  Created by Julian Krumow on 08.08.14.
//
//

#include "GOMOperation.h"

@class GOMAttribute;

typedef void (^GOMClientRetrieveAttributeCallback)(GOMAttribute *, NSError *);

@interface GOMOperationRetrieveAttribute : GOMOperation

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate callback:(GOMClientRetrieveAttributeCallback)callback;

@end
