//
//  GOMClientDelegate.h
//  gom-client-objc
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GOMClient;
@class GOMBinding;

@protocol GOMClientDelegate <NSObject>

- (void)gomClientDidBecomeReady:(GOMClient *)gomClient;
- (void)gomClient:(GOMClient *)gomClient didFailWithError:(NSError *)error;

@optional

- (BOOL)gomClient:(GOMClient *)gomClient shouldReRegisterObserverWithBinding:(GOMBinding *)binding;

@end
