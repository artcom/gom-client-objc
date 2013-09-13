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

- (void)retrieveAttribute:(NSString *)attribute;
- (void)retrieveNode:(NSString *)node;

- (void)createNode:(NSString *)node;
- (void)createNode:(NSString *)node withAttributes:(NSDictionary *)attributes;

- (void)updateAttribute:(NSString *)attribute withValue:(NSString *)value;
- (void)updateNode:(NSString *)node withAttributes:(NSDictionary *)attributes;

- (void)deleteNode:(NSString *)node;

- (void)registerGOMObserverForPath:(NSString *)path options:(NSDictionary *)options callback:(GOMClientCallback)callback;

@end
