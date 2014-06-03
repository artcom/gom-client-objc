//
//  GOMOperation.h
//  gom-client-demo_iOS
//
//  Created by Julian Krumow on 06.01.14.
//  Copyright (c) 2014 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^GOMClientOperationCallback)(NSDictionary *, NSError *);

@interface GOMOperation : NSObject <NSURLConnectionDataDelegate>

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate callback:(GOMClientOperationCallback)callback;
- (void)run;

@end

@protocol GOMOperationDelegate <NSObject>

- (void)gomOperationDidFinish:(GOMOperation *)operation;

@end