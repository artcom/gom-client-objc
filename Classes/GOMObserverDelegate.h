//
//  GOMObserverDelegate.h
//  gom-client-objc
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GOMObserver;
@class GOMBinding;

@protocol GOMObserverDelegate <NSObject>

- (void)gomObserverDidBecomeReady:(GOMObserver *)gomObserver;
- (void)gomObserver:(GOMObserver *)gomObserver didFailWithError:(NSError *)error;

@optional

- (BOOL)gomObserverShouldReconnect:(GOMObserver *)gomObserver;
- (BOOL)gomObserver:(GOMObserver *)gomObserver shouldReRegisterObserverWithBinding:(GOMBinding *)binding;

@end
