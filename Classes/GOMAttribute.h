//
//  GOMAttribute.h
//  Pods
//
//  Created by Julian Krumow on 04.03.14.
//
//

#import <Foundation/Foundation.h>

@interface GOMAttribute : NSObject

@property (nonatomic, strong) NSString *ctime;
@property (nonatomic, strong) NSString *mtime;

@property (nonatomic, strong) NSString *node;
@property (nonatomic, strong) NSString *type;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *value;

+ (BOOL)isAttribute:(NSDictionary *)dictionary;
+ (GOMAttribute *)attibuteFromDictionary:(NSDictionary *)dictionary;

@end
