//
//  NSURLRequest+GOMClient.h
//  gom-client-objc
//
//  Created by Julian Krumow on 13.05.14.
//  Copyright (c) 2014 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (GOMClient)

+ (NSURLRequest *)createGetRequestWithPath:(NSString *)path gomRoot:(NSURL *)gomRoot;
+ (NSURLRequest *)createPutRequestWithPath:(NSString *)path payload:(NSData *)payloadData gomRoot:(NSURL *)gomRoot;
+ (NSURLRequest *)createPostRequestWithPath:(NSString *)path payload:(NSData *)payload gomRoot:(NSURL *)gomRoot;
+ (NSURLRequest *)createDeleteRequestWithPath:(NSString *)path gomRoot:(NSURL *)gomRoot;

@end
