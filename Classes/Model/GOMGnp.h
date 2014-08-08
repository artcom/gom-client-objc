//
//  GOMGnp.h
//  Pods
//
//  Created by Julian Krumow on 08.08.14.
//
//

#import <Foundation/Foundation.h>

@class GOMEntry;

@interface GOMGnp : NSObject

@property (nonatomic, strong) GOMEntry *payload;
@property (nonatomic, strong) NSString *eventType;
@property (nonatomic, strong) NSString *path;

@end
