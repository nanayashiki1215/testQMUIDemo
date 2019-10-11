//
//  NSObject+LST.m
//  LiftStyle
//
//  Created by JoshShron on 14-11-18.
//  Copyright (c) 2014年 JoshShron. All rights reserved.
//

#import "NSObject+LST.h"
#import <objc/runtime.h>

@implementation NSString (JSONKit)

- (id)objectFromJSONString
{
    NSObject *object = nil;
    object = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    return object;
}

@end


@implementation NSObject (JSONKit)

- (NSString *)JSONResult
{
    NSString *result = nil;
    id object = self;
    if ([self isKindOfClass:[NSString class]]) {
        result = [NSObject jsonStringWithString:object];
    } else if ([self isKindOfClass:[NSDictionary class]]) {
        result = [NSObject jsonStringWithDictionary:object];
    } else if ([self isKindOfClass:[NSArray class]]) {
        result = [NSObject jsonStringWithArray:object];
    } else if(self != nil) {
        result = [NSObject jsonStringWithObject:object];
    }
    return result;
}

+(NSString *) jsonStringWithString:(NSString *) string{
    return [NSString stringWithFormat:@"\"%@\"",
            [[string stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"] stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""]
            ];
}

+(NSString *) jsonStringWithArray:(NSArray *)array{
    NSMutableString *reString = [NSMutableString string];
    [reString appendString:@"["];
    NSMutableArray *values = [NSMutableArray array];
    for (id valueObj in array) {
        NSString *value = [NSString jsonStringWithObject:valueObj];
        if (value) {
            [values addObject:[NSString stringWithFormat:@"%@",value]];
        }
    }
    [reString appendFormat:@"%@",[values componentsJoinedByString:@","]];
    [reString appendString:@"]"];
    return reString;
}

+(NSString *) jsonStringWithDictionary:(NSDictionary *)dictionary{
    NSArray *keys = [dictionary allKeys];
    NSMutableString *reString = [NSMutableString string];
    [reString appendString:@"{"];
    NSMutableArray *keyValues = [NSMutableArray array];
    for (int i=0; i<[keys count]; i++) {
        NSString *name = [keys objectAtIndex:i];
        id valueObj = [dictionary objectForKey:name];
        NSString *value = [NSString jsonStringWithObject:valueObj];
        if (value) {
            [keyValues addObject:[NSString stringWithFormat:@"\"%@\":%@",name,value]];
        }
    }
    [reString appendFormat:@"%@",[keyValues componentsJoinedByString:@","]];
    [reString appendString:@"}"];
    return reString;
}

+(NSString *) jsonStringWithObject:(id) object{
    NSString *value = nil;
    if (!object) {
        return value;
    }
    if ([object isKindOfClass:[NSString class]]) {
        value = [NSString jsonStringWithString:object];
    }else if([object isKindOfClass:[NSDictionary class]]){
        value = [NSString jsonStringWithDictionary:object];
    }else if([object isKindOfClass:[NSArray class]]){
        value = [NSString jsonStringWithArray:object];
    }
    return value;
}

@end


@implementation NSObject (LST)

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [self init]) {
        [self dictionaryToEntity:dictionary];
    }
    return self;
}
- (instancetype)initWithDictionary:(NSDictionary *)dictionary dictionAryay:(NSDictionary *)keys toObject:(BOOL)toObject
{
    if (self = [self init]) {
        [self dictionaryToEntity:dictionary keys:keys toObject:toObject detailClass:nil];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary dictionAryay:(NSDictionary *)keys toObject:(BOOL)toObject detailClass:(NSString *)className
{
    if (self = [self init]) {
        [self dictionaryToEntity:dictionary keys:keys toObject:toObject detailClass:className];
    }
    return self;
}

//字典转实例对象
- (void) dictionaryToEntity:(NSDictionary *)dict
{
    for (NSString *key in [self getAllProperties]) {
        id value = dict[key];
        if ([value isKindOfClass:[NSString class]]) {
            [self setValue:value forKeyPath:key];
        } else if ([value isKindOfClass:[NSNumber class]]) {
            [self setValue:[NSString stringWithFormat:@"%@",value] forKeyPath:key];
        } else if ([value isKindOfClass:[NSArray class]]) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            for (id info in value) {
                id temp = [[NSClassFromString(NSStringFromClass([self class])) alloc] init];
                [temp dictionaryToEntity:info];
                [tempArray addObject:temp];
            }
            [self setValue:tempArray forKeyPath:key];
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            id temp = [[NSClassFromString(NSStringFromClass([self class])) alloc] init];
            [temp dictionaryToEntity:value];
            [self setValue:temp forKeyPath:key];
        }
    }
}

- (void)dictionaryToEntity:(NSDictionary *)dict keys:(NSDictionary *)keys toObject:(BOOL)toObject detailClass:(NSString *)className
{
    [self dictionaryToEntity:dict];
    for (NSString *key in keys) {
        if ([dict[key] isKindOfClass:[NSArray class]] || [dict[key] isKindOfClass:[NSDictionary class]]) {
            if ([dict[key] isKindOfClass:[NSDictionary class]]) {
                if (toObject) {
                    NSObject *object = [[NSClassFromString(keys[key]) alloc] initWithDictionary:dict[keys]];
                    [self setValue:object forKeyPath:key];
                } else {
                    [self setValue:dict[key] forKeyPath:key];
                }
            } else if ([dict[key] isKindOfClass:[NSArray class]]) {
                if (className) {
                    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                    for (NSDictionary *dictionary in dict[key]) {
                        NSObject *detailOC = [[NSClassFromString(className) alloc] initWithDictionary:dictionary dictionAryay:keys toObject:toObject];
                        [tempArray addObject:detailOC];
                    }
                    [self setValue:tempArray forKeyPath:key];
                } else {
                    [self setValue:dict[key] forKeyPath:keys[key]];
                }
                
            } else {
                [self setValue:dict[key] forKeyPath:keys[key]];
            }
        } else {
            if (dict[key]) {
                if ([dict[key] isKindOfClass:[NSNull class]]) {
                    [self setValue:@"" forKeyPath:keys[key]];
                } else {
                    if ([dict[key] isKindOfClass:[NSString class]]) {
                        [self setValue:[NSString stringWithFormat:@"%@",dict[key]] forKeyPath:keys[key]];
                    } else {
                        [self setValue:dict[key] forKeyPath:key];
                    }
                }
            }
        }
    }
}

//对象转字典
- (NSDictionary *)entityToDictionaryWithKeyDic:(NSDictionary *)keyDic
{
    Class clazz = [self class];
    u_int count;
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    for (NSString *key in [self getAllProperties]) {
        id value = [self performSelector:NSSelectorFromString([NSString stringWithFormat:key])];
        if ([value isKindOfClass:[NSNull class]]) {
            value = @"";
        }
        if (value) {
            if ([[keyDic allKeys] containsObject:key]) {
                [dictionary setObject:value forKey:keyDic[key]];
            } else {
                [dictionary setObject:value forKey:key];
            }
        }
    }
    return dictionary;
}

//对象转字典
- (NSDictionary *) entityToDictionary
{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property)];
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        if (propertyValue) [props setObject:propertyValue forKey:propertyName];
    }
    free(properties);
    return props;
}

- (NSArray *)getAllProperties
{
    u_int count;
    objc_property_t *properties  =class_copyPropertyList([self class], &count);
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++)
    {
        const char* propertyName =property_getName(properties[i]);
        [propertiesArray addObject: [NSString stringWithUTF8String: propertyName]];
    }
    free(properties);
    return propertiesArray;
}

- (void)saveWithFileName:(NSString *)name
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [path stringByAppendingFormat:@"/%@.plist",name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    if ([self isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)self;
        [dic writeToFile:path atomically:YES];
    } else if ([self isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray *)self;
        [array writeToFile:path atomically:YES];
    }
}

+ (id)fileWithFileName:(NSString *)name
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [path stringByAppendingFormat:@"/%@.plist",name];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:path];
    if (!dictionary && !array) {
        return nil;
    } else if (dictionary) {
        return dictionary;
    } else {
        return array;
    }
}

+ (NSString *)pathWithName:(NSString *)name
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingFormat:@"/%@.plist",name];
}

@end
