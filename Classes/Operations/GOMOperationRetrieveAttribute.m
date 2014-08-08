//
//  GOMOperationRetrieveAttribute.m
//  Pods
//
//  Created by Julian Krumow on 08.08.14.
//
//

#import "GOMOperationRetrieveAttribute.h"

@interface GOMOperationRetrieveAttribute ()

@property (nonatomic, strong) GOMClientRetrieveAttributeCallback callback;

@end

@implementation GOMOperationRetrieveAttribute


- (instancetype)initWithRequest:(NSURLRequest *)request delegate:(id)delegate callback:(GOMClientRetrieveAttributeCallback)callback
{
    self = [super initWithRequest:request delegate:delegate];
    if (self) {
        
        self.callback = callback;
    }
    return self;
}

- (void)handleResponse:(NSDictionary *)response error:(NSError *)error
{
    GOMAttribute *attribute = [GOMAttribute attributeFromDictionary:response];
    self.callback(attribute, error);
}

@end
