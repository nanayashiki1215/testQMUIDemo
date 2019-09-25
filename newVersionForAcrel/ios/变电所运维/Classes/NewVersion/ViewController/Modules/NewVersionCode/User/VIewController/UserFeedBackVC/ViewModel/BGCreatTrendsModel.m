//
//  BGCreatTrendsModel.m
//  BusinessGo
//
//  Created by per on 16/10/31.
//  Copyright © 2016年 com.Ideal. All rights reserved.
//

#import "BGCreatTrendsModel.h"
#import <objc/runtime.h>

@implementation BGCreatTrendsModel

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
    return;
}
- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([value isKindOfClass:[NSNull class]]) {
        return;
    }
    [super setValue:value forKey:key];
    
}
-(id)copyWithZone:(NSZone *)zone
{
    BGCreatTrendsModel *model = [[self class] allocWithZone:zone];
    
    unsigned int outCount, i;
    objc_property_t *pros =  class_copyPropertyList([self class],&outCount);
    for (i=0; i<outCount; i++) {
        objc_property_t property = pros[i];
        NSString * key = [[NSString alloc]initWithCString:property_getName(property)  encoding:NSUTF8StringEncoding];
        [model setValue:[[self valueForKey:key] copy] forKey:key];
    }
    return model;
}
-(NSMutableDictionary*)postDictionary
{
    unsigned int outCount, i;
    objc_property_t *pros =  class_copyPropertyList([self class],&outCount);
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    int number =0 ;
    for (i=0; i<outCount; i++) {
        objc_property_t property = pros[i];
        NSString * key = [[NSString alloc]initWithCString:property_getName(property)  encoding:NSUTF8StringEncoding];
        if ([self valueForKey:key]) {
            id value = [self valueForKey:key];
            number++;
            if ([value isKindOfClass:[NSString class]]){
                [dic setValue:value forKey:key];
            }else if ([value isKindOfClass:[NSValue class]]){
                [dic setValue:[value stringValue] forKey:key];
            }else if ([value isKindOfClass:[NSArray class]]){
                [dic setValue:value forKey:key];
            }
        }
    }
    return dic;
}
-(NSString *)description{
    return [NSString stringWithFormat:@"%@",[self postDictionary]];
}
@end
