//
//  GOMClientDelegate.h
//  gom-client-objc
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GOMClient;

/**
 This protocol represents...
 
 */
@protocol GOMClientDelegate <NSObject>

/**
 
 
 @param gomClient
 */
- (void)gomClientDidBecomeReady:(GOMClient *)gomClient;

/**
 
 @param gomClient
 @param error
 */
- (void)gomClient:(GOMClient *)gomClient didFailWithError:(NSError *)error;

@end
