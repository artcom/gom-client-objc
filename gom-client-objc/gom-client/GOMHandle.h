//
//  GOMHandle.h
//  iOS-Gom-Client
//
//  Created by Julian Krumow on 12.09.13.
//
//

#import <Foundation/Foundation.h>

@class GOMBinding;
@interface GOMHandle : NSObject

typedef void (^GOMHandleCallback)(NSDictionary *);

@property (nonatomic, weak) GOMBinding *binding;
@property (nonatomic, strong) GOMHandleCallback callback;
@property (nonatomic, unsafe_unretained) BOOL initialRetrieved;

/**
 Custom initializer to create a GOMHandle with a given GOMBinding object and a callback function.
 
 @param binding The given GOMBinding object
 @param callback The given callback function to  call
 
 @return The resulting GOMHandle object
 */
- (id)initWithBinding:(GOMBinding *)aBinding callback:(GOMHandleCallback)aCallback;

@end
