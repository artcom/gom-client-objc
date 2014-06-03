//
//  GOMOperation.m
//  gom-client-demo_iOS
//
//  Created by Julian Krumow on 06.01.14.
//  Copyright (c) 2014 ART+COM AG. All rights reserved.
//

#import "GOMOperation.h"
#import "NSData+JSON.h"
#import "GOMClient.h"

NSUInteger const MaxNumberOfRedirects = 10;

@interface GOMOperation ()

@property (nonatomic, weak)id<GOMOperationDelegate> delegate;

@property (nonatomic, strong, readonly) GOMClientOperationCallback callback;
@property (nonatomic, strong, readonly) NSURLRequest *request;
@property (nonatomic, strong, readonly) NSURLConnection *connection;
@property (nonatomic, strong, readonly) NSURLResponse *response;
@property (nonatomic, strong, readonly) NSMutableData *responseData;
@property (nonatomic, assign, readonly) NSUInteger performedRedirects;

@end

@implementation GOMOperation

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate callback:(GOMClientOperationCallback)callback
{
    self = [super init];
    if (self) {
        
        _request = request;
        _delegate = delegate;
        _callback = callback;
        _performedRedirects = 0;
        _responseData = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)run
{
    _connection = [NSURLConnection connectionWithRequest:_request delegate:self];
}

- (void)_handleOperationResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *)connectionError completionBlock:(GOMClientOperationCallback)block
{
    NSDictionary *responseData = nil;
    NSError *error = nil;
    
    if (connectionError) {
        error = connectionError;
    } else {
        NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
        
        if (statusCode >= 400) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : [NSHTTPURLResponse localizedStringForStatusCode:statusCode]};
            error = [NSError errorWithDomain:GOMClientErrorDomain code:statusCode userInfo:userInfo];
        } else if (statusCode >= 200) {
            if (data) {
                responseData = [data parseAsJSON];
            }
            if (responseData == nil) {
                responseData = @{@"success" : @YES};
            }
        }
    }
    
    if (block) {
        block(responseData, error);
    }
    
    [self.delegate gomOperationDidFinish:self];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self _handleOperationResponse:_response data:_responseData error:nil completionBlock:_callback];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self _handleOperationResponse:nil data:nil error:error completionBlock:_callback];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    if (response) {
        _performedRedirects++;
        if (_performedRedirects == MaxNumberOfRedirects) {
            [connection cancel];
            _callback(nil, [NSError errorWithDomain:GOMClientErrorDomain code:GOMClientTooManyRedirects userInfo:nil]);
            return nil;
        } else {
            NSURL *redirectedUrl = request.URL;
            NSMutableURLRequest *redirectedRequest = [connection.originalRequest mutableCopy];
            redirectedRequest.URL = redirectedUrl;
            return redirectedRequest;
        }
    } else {
        return request;
    }
}

@end
