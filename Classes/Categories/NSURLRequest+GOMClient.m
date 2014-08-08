//
//  NSURLRequest+GOMClient.m
//  gom-client-objc
//
//  Created by Julian Krumow on 13.05.14.
//  Copyright (c) 2014 ART+COM AG. All rights reserved.
//

#import "NSURLRequest+GOMClient.h"

@implementation NSURLRequest (GOMClient)


+ (NSURLRequest *)createGetRequestWithPath:(NSString *)path gomRoot:(NSURL *)gomRoot
{
    return [self _createRequestWithPath:path method:@"GET" headerFields:@{@"Content-Type" : @"application/json", @"Accept" : @"application/json"} payloadData:nil gomRoot:gomRoot];
}

+ (NSURLRequest *)createPutRequestWithPath:(NSString *)path payload:(NSData *)payloadData gomRoot:(NSURL *)gomRoot
{
    return [self _createRequestWithPath:path method:@"PUT" headerFields:@{@"Content-Type" : @"application/xml", @"Accept" : @"application/json"} payloadData:payloadData gomRoot:gomRoot];
}

+ (NSURLRequest *)createPostRequestWithPath:(NSString *)path payload:(NSData *)payloadData gomRoot:(NSURL *)gomRoot
{
    return [self _createRequestWithPath:path method:@"POST" headerFields:@{@"Content-Type" : @"application/xml", @"Accept" : @"application/json"} payloadData:payloadData gomRoot:gomRoot];
}

+ (NSURLRequest *)createDeleteRequestWithPath:(NSString *)path gomRoot:(NSURL *)gomRoot
{
    return [self _createRequestWithPath:path method:@"DELETE" headerFields:nil payloadData:nil gomRoot:gomRoot];
}

+ (NSURLRequest *)_createRequestWithPath:(NSString *)path method:(NSString *)method headerFields:(NSDictionary *)headerFields payloadData:(NSData *)payloadData gomRoot:(NSURL *)gomRoot {
    NSURL *requestURL = [gomRoot URLByAppendingPathComponent:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setHTTPMethod:method];
    
    if (headerFields) {
        [request setAllHTTPHeaderFields:headerFields];
    }
    if (payloadData) {
        [request setHTTPBody:payloadData];
    }
    return request;
}


@end
