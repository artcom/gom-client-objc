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


@interface GOMClient () <GOMOperationDelegate>

@end

@implementation GOMClient {

    NSMutableArray *_operations;
}

- (instancetype)initWithGomURI:(NSURL *)gomURI
{
    self = [super init];
    if (self) {
        _gomRoot = gomURI;
        _operations = [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark - GOM operations

- (void)retrieveAttribute:(NSString *)path completionBlock:(GOMClientRetrieveAttributeCallback)block
{
	NSURLRequest *request = [NSURLRequest createGetRequestWithPath:path gomRoot:self.gomRoot];
    [self _runGOMOperationForAttributeWithRequest:request completionBlock:block];
}

- (void)retrieveNode:(NSString *)path completionBlock:(GOMClientRetrieveNodeCallback)block
{
	NSURLRequest *request = [NSURLRequest createGetRequestWithPath:path gomRoot:self.gomRoot];
    [self _runGOMOperationForNodeWithRequest:request completionBlock:block];
}

- (void)create:(NSString *)node withAttributes:(NSDictionary *)attributes completionBlock:(GOMClientOperationCallback)block
{
    if (attributes == nil) {
        attributes = @{};
    }
    NSString *payload = [attributes convertToNodeXML];
    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest createPostRequestWithPath:node payload:payloadData gomRoot:self.gomRoot];
    [self _runGOMOperationCreateWithRequest:request completionBlock:block];
}

- (void)updateAttribute:(NSString *)attribute withValue:(NSString *)value completionBlock:(GOMClientOperationCallback)block
{
    NSString *payload = [value convertToAttributeXML];
    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest createPutRequestWithPath:attribute payload:payloadData gomRoot:self.gomRoot];
    [self _runGOMOperationUpdateWithRequest:request completionBlock:block];
}

- (void)updateNode:(NSString *)node withAttributes:(NSDictionary *)attributes completionBlock:(GOMClientOperationCallback)block
{
    if (attributes == nil) {
        attributes = @{};
    }
    NSString *payload = [attributes convertToNodeXML];
    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest createPutRequestWithPath:node payload:payloadData gomRoot:self.gomRoot];
    [self _runGOMOperationUpdateWithRequest:request completionBlock:block];
}

- (void)destroy:(NSString *)path completionBlock:(GOMClientOperationCallback)block
{
    NSURLRequest *request = [NSURLRequest createDeleteRequestWithPath:path gomRoot:self.gomRoot];
    [self _runGOMOperationDeleteWithRequest:request completionBlock:block];
}

#pragma mark - Running a GOMOperation

- (void)_runGOMOperationCreateWithRequest:(NSURLRequest *)request completionBlock:(GOMClientOperationCallback)block
{
    GOMOperation *operation = [[GOMOperationCreate alloc] initWithRequest:request delegate:self callback:block];
    [self _runGomOperation:operation];
}

- (void)_runGOMOperationUpdateWithRequest:(NSURLRequest *)request completionBlock:(GOMClientOperationCallback)block
{
    GOMOperation *operation = [[GOMOperationUpdate alloc] initWithRequest:request delegate:self callback:block];
    [self _runGomOperation:operation];
}

- (void)_runGOMOperationDeleteWithRequest:(NSURLRequest *)request completionBlock:(GOMClientOperationCallback)block
{
    GOMOperation *operation = [[GOMOperationDelete alloc] initWithRequest:request delegate:self callback:block];
    [self _runGomOperation:operation];
}

- (void)_runGOMOperationForAttributeWithRequest:(NSURLRequest *)request completionBlock:(GOMClientRetrieveAttributeCallback)block
{
    GOMOperationRetrieveAttribute *operation = [[GOMOperationRetrieveAttribute alloc] initWithRequest:request delegate:self callback:block];
    [self _runGomOperation:operation];
}

- (void)_runGOMOperationForNodeWithRequest:(NSURLRequest *)request completionBlock:(GOMClientRetrieveNodeCallback)block
{
    GOMOperationRetrieveNode *operation = [[GOMOperationRetrieveNode alloc] initWithRequest:request delegate:self callback:block];
    [self _runGomOperation:operation];
}

- (void)_runGomOperation:(GOMOperation *)operation
{
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
