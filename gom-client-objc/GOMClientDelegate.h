//
//  GOMClientDelegate.h
//  gom-client-objc
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GOMClient;

@protocol GOMClientDelegate <NSObject>

- (void)gomClientDidBecomeReady:(GOMClient *)gomClient;
- (void)gomClient:(GOMClient *)gomClient didFailWithError:(NSError *)error;

@end
