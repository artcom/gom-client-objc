//
//  GomObserver.h
//  gom-client-objc
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GOMObserver : NSObject

+ (id)sharedInstance;
- (void)reconnect;
- (void)disconnect;

@end
