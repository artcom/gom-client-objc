//
//  GOMOperation.h
//  gom-client-demo_iOS
//
//  Created by Julian Krumow on 06.01.14.
//  Copyright (c) 2014 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GOMEntry;
@protocol GOMOperationDelegate;

typedef void (^GOMClientOperationCallback)(NSDictionary *, NSError *);

@interface GOMOperation : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, weak)id<GOMOperationDelegate> delegate;
@property (nonatomic, strong) NSURLRequest *request;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id<GOMOperationDelegate>)delegate;
- (void)run;
- (void)handleResponse:(NSDictionary *)response error:(NSError *)error;
@end

@protocol GOMOperationDelegate <NSObject>

- (void)gomOperationDidFinish:(GOMOperation *)operation;

@end

