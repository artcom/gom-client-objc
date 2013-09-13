//
//  GOMBinding.h
//  iOS-Gom-Client
//
//  Created by Julian Krumow on 12.09.13.
//
//

#import <Foundation/Foundation.h>
#import "GOMHandle.h"

@interface GOMBinding : NSObject

@property (nonatomic, strong) NSString *subscriptionUri;
@property (nonatomic, strong) NSString *observerUri;
@property (nonatomic, strong, readonly) NSMutableArray *handles;

@property (nonatomic, unsafe_unretained) BOOL registered;

/**
 Custom initializer to create a GOMBinding with a given subscriptionUri.
 
 @param subscriptionUri The given path to observe
 
 @return The resulting GOMBinding object
 */
- (id)initWithSubscriptionUri:(NSString *)subscriptionUri;

/**
 Adds a given GONHandle object to the binding.
 
 @param handle The given GOMHandle object to add
 */
- (void)addHandle:(GOMHandle *)handle;

@end
