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

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, assign) NSUInteger performedRedirects;

@end

@implementation GOMOperation

- (id)initWithRequest:(NSURLRequest *)request delegate:(id<GOMOperationDelegate>)delegate
{
    if ([self class] == [GOMOperation class]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Error, attempting to instantiate abstract class GOMOperation directly."
                                     userInfo:nil];
    }
    self = [super init];
    if (self) {
        _request = request;
        _delegate = delegate;
        _performedRedirects = 0;
        _responseData = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)run
{
    _connection = [NSURLConnection connectionWithRequest:_request delegate:self];
}

- (void)_handleOperationResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *)connectionError
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
    
    [self handleResponse:responseData error:error];
    
    [self.delegate gomOperationDidFinish:self];
}

- (void)handleResponse:(NSDictionary *)response error:(NSError *)error
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
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
    [self _handleOperationResponse:_response data:_responseData error:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self _handleOperationResponse:nil data:nil error:error];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    if (response) {
        _performedRedirects++;
        if (_performedRedirects == MaxNumberOfRedirects) {
            [connection cancel];
            NSError *error = [NSError errorWithDomain:GOMClientErrorDomain code:GOMClientTooManyRedirects userInfo:nil];
            [self _handleOperationResponse:nil data:nil error:error];
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
