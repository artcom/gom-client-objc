//
//  GOMOperationUpdate.h
//  Pods
//
//  Created by Julian Krumow on 08.08.14.
//
//

#import "GOMOperation.h"

@interface GOMOperationUpdate : GOMOperation

@property (nonatomic, strong, readonly) GOMClientOperationCallback callback;

- (instancetype)initWithRequest:(NSURLRequest *)request delegate:(id)delegate callback:(GOMClientOperationCallback)callback;

@end
