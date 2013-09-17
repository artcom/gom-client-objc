//
//  GOMClientDelegate.h
//  gom-client-objc
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GOMClient;

/**
 The GOMClientDelegate protocol defines the messages sent to a GOM client delegate
 from a GOM client as long it is alive.
 */
@protocol GOMClientDelegate <NSObject>

/**
 Tells the delegate that the client has been fully initialized and set up.
 
 @param gomClient The GOM client which has become ready to use.
 */
- (void)gomClientDidBecomeReady:(GOMClient *)gomClient;

/**
 Tells the delegate that the client has encountered an error.
 
 @param gomClient The GOM client that has encountered an error
 @param error     The error object
 */
- (void)gomClient:(GOMClient *)gomClient didFailWithError:(NSError *)error;

@end
