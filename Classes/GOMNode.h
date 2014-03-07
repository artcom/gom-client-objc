//
//  GOMNode.h
//  Pods
//
//  Created by Julian Krumow on 04.03.14.
//
//

#import <Foundation/Foundation.h>

@interface GOMNode : NSObject

@property (nonatomic, strong) NSString *ctime;
@property (nonatomic, strong) NSString *mtime;

@property (nonatomic, strong) NSString *uri;

@property (nonatomic, strong) NSMutableArray *entries;

+ (BOOL)isNode:(NSDictionary *)dictionary;
+ (GOMNode *)nodeFromDictionary:(NSDictionary *)dictionary;

@end
