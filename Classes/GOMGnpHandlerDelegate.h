//
//  GOMClientDelegate.h
//  gom-client-objc
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GOMGnpHandler;
@class GOMBinding;

@protocol GOMGnpHandlerDelegate <NSObject>

- (void)gomGnpHandlerDidBecomeReady:(GOMGnpHandler *)gomGnpHandler;
- (void)gomGnpHandler:(GOMGnpHandler *)gomGnpHandler didFailWithError:(NSError *)error;

@optional

- (BOOL)gomGnpHandlerShouldReconnect:(GOMGnpHandler *)gomGnpHandler;
- (BOOL)gomGnpHandler:(GOMGnpHandler *)gomGnpHandler shouldReRegisterObserverWithBinding:(GOMBinding *)binding;

@end
