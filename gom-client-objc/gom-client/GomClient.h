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

@interface GOMClient : NSObject

@property (nonatomic, strong, readonly) NSString *gomRoot;
@property (nonatomic, weak) id<GOMClientDelegate> delegate;

- (id)initWithGOMRoot:(NSString *)gomRoot;

- (void)retrieveAttribute:(NSString *)attribute;
- (void)retrieveNode:(NSString *)node;

- (void)createNode:(NSString *)node;
- (void)createNode:(NSString *)node withAttributes:(NSDictionary *)attributes;

- (void)updateAttribute:(NSString *)attribute withValue:(NSString *)value;
- (void)updateNode:(NSString *)node withAttributes:(NSDictionary *)attributes;

- (void)deleteNode:(NSString *)node;

- (void)registerGOMObserverForPath:(NSString *)path withCallback:(GOMClientCallback)callback;

@end
