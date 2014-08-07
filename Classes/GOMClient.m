//
//  GOMClient.m
//  gom-client-objc
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import "GOMClient.h"

#import "NSString+JSON.h"
#import "NSString+XML.h"
#import "NSData+JSON.h"
#import "NSDictionary+JSON.h"
#import "NSDictionary+XML.h"
#import "NSURLRequest+GOMClient.h"

NSString * const GOMClientErrorDomain = @"de.artcom.gom-client-objc.client";

@interface GOMClient () <GOMOperationDelegate>

- (void)_runGOMOperationWithRequest:(NSURLRequest *)request completionBlock:(GOMClientOperationCallback)block;

@end

@implementation GOMClient {

    NSMutableArray *_operations;
}

- (id)initWithGomURI:(NSURL *)gomURI
{
    self = [super init];
    if (self) {
        _gomRoot = gomURI;
        _operations = [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark - GOM operations

- (void)retrieve:(NSString *)path completionBlock:(GOMClientOperationCallback)block
{
    NSURLRequest *request = [NSURLRequest createGetRequestWithPath:path gomRoot:self.gomRoot];
    [self _runGOMOperationWithRequest:request completionBlock:block];
}

- (void)create:(NSString *)node withAttributes:(NSDictionary *)attributes completionBlock:(GOMClientOperationCallback)block
{
    if (attributes == nil) {
        attributes = @{};
    }
    NSString *payload = [attributes convertToNodeXML];
    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest createPostRequestWithPath:node payload:payloadData gomRoot:self.gomRoot];
    [self _runGOMOperationWithRequest:request completionBlock:block];
}

- (void)updateAttribute:(NSString *)attribute withValue:(NSString *)value completionBlock:(GOMClientOperationCallback)block
{
    NSString *payload = [value convertToAttributeXML];
    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest createPutRequestWithPath:attribute payload:payloadData gomRoot:self.gomRoot];
    [self _runGOMOperationWithRequest:request completionBlock:block];
}

- (void)updateNode:(NSString *)node withAttributes:(NSDictionary *)attributes completionBlock:(GOMClientOperationCallback)block
{
    if (attributes == nil) {
        attributes = @{};
    }
    NSString *payload = [attributes convertToNodeXML];
    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest createPutRequestWithPath:node payload:payloadData gomRoot:self.gomRoot];
    [self _runGOMOperationWithRequest:request completionBlock:block];
}

- (void)destroy:(NSString *)path completionBlock:(GOMClientOperationCallback)block
{
    NSURLRequest *request = [NSURLRequest createDeleteRequestWithPath:path gomRoot:self.gomRoot];
    [self _runGOMOperationWithRequest:request completionBlock:block];
}

- (void)_runGOMOperationWithRequest:(NSURLRequest *)request completionBlock:(GOMClientOperationCallback)block
{
    GOMOperation *operation = [[GOMOperation alloc] initWithRequest:request delegate:self callback:block];
    [_operations addObject:operation];
    [operation run];
}


#pragma mark - Error handling


#pragma mark - GOMOperationDelegate

- (void)gomOperationDidFinish:(GOMOperation *)operation
{
    [_operations removeObject:operation];
}

@end
