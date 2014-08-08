//
//  GOMOperationDelete.h
//  Pods
//
//  Created by Julian Krumow on 08.08.14.
//
//

#import "GOMOperation.h"

@interface GOMOperationDelete : GOMOperation

@property (nonatomic, strong, readonly) GOMClientOperationCallback callback;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate callback:(GOMClientOperationCallback)callback;

@end
