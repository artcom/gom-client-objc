//
//  GOMGnp.h
//  gom-client-objc
//
//  Created by Julian Krumow on 08.08.14.
//  Copyright (c) 2014 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GOMEntry;

@interface GOMGnp : NSObject

@property (nonatomic, strong) GOMEntry *payload;
@property (nonatomic, strong) NSString *eventType;
@property (nonatomic, strong) NSString *path;

@end
