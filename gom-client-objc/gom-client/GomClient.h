//
//  GOMClient.h
//  gom-client-objc
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM. All rights reserved.
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

- (id)initWithGOMRoot:(NSURL *)gomRoot;

- (void)retrieveAttribute:(NSString *)attribute completionBlock:(GOMClientCallback)block;
- (void)retrieveNode:(NSString *)node completionBlock:(GOMClientCallback)block;

- (void)createNode:(NSString *)node completionBlock:(GOMClientCallback)block;
- (void)createNode:(NSString *)node withAttributes:(NSDictionary *)attributes completionBlock:(GOMClientCallback)block;

- (void)updateAttribute:(NSString *)attribute withValue:(NSString *)value completionBlock:(GOMClientCallback)block;
- (void)updateNode:(NSString *)node withAttributes:(NSDictionary *)attributes completionBlock:(GOMClientCallback)block;

- (void)deleteNode:(NSString *)node completionBlock:(GOMClientCallback)block;

- (void)registerGOMObserverForPath:(NSString *)path options:(NSDictionary *)options completionBlock:(GOMClientCallback)block;

@end
