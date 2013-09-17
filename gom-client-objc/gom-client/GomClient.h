//
//  GOMClient.h
//  gom-client-objc
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GOMClientDelegate.h"

typedef void (^GOMClientCallback)(NSDictionary *);

/**
 This class represents...
 
 */
@interface GOMClient : NSObject

@property (nonatomic, strong, readonly) NSURL *gomRoot;
@property (nonatomic, weak) id<GOMClientDelegate> delegate;
@property (nonatomic, strong, readonly) NSMutableDictionary *bindings;

- (id)initWithGomURI:(NSURL *)gomURI;

- (void)retrieve:(NSString *)path completionBlock:(GOMClientCallback)block;
- (void)create:(NSString *)node withAttributes:(NSDictionary *)attributes completionBlock:(GOMClientCallback)block;
- (void)updateAttribute:(NSString *)attribute withValue:(NSString *)value completionBlock:(GOMClientCallback)block;
- (void)updateNode:(NSString *)node withAttributes:(NSDictionary *)attributes completionBlock:(GOMClientCallback)block;
- (void)destroy:(NSString *)path completionBlock:(GOMClientCallback)block;

- (void)registerGOMObserverForPath:(NSString *)path options:(NSDictionary *)options clientCallback:(GOMClientCallback)callback;
- (void)unregisterGOMObserverForPath:(NSString *)path options:(NSDictionary *)options;

@end
