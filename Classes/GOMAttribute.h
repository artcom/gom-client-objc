//
//  GOMAttribute.h
//  Pods
//
//  Created by Julian Krumow on 04.03.14.
//
//

#import <Foundation/Foundation.h>

@interface GOMAttribute : NSObject

@property (nonatomic, strong) NSDate *ctime;
@property (nonatomic, strong) NSDate *mtime;

@property (nonatomic, strong) NSString *node;
@property (nonatomic, strong) NSString *type;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *value;

+ (BOOL)isAttribute:(NSDictionary *)dictionary;
+ (GOMAttribute *)attributeFromDictionary:(NSDictionary *)dictionary;

@end
