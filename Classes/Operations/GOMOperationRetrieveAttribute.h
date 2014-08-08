//
//  GOMOperationRetrieveAttribute.h
//  Pods
//
//  Created by Julian Krumow on 08.08.14.
//
//

#include "GOMOperation.h"
#include "GOMAttribute.h"

typedef void (^GOMClientRetrieveAttributeCallback)(GOMAttribute *, NSError *);

@interface GOMOperationRetrieveAttribute : GOMOperation

- (instancetype)initWithRequest:(NSURLRequest *)request delegate:(id)delegate callback:(GOMClientRetrieveAttributeCallback)callback;

@end
