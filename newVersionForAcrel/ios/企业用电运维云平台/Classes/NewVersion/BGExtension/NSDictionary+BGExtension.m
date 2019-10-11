//
//  NSDictionary+Extension.m
//  BIMErnet
//
//  Created by feitian on 16/6/1.
//  Copyright © 2016年 HenryQi. All rights reserved.
//

#import "NSDictionary+BGExtension.h"

@implementation NSDictionary (BGExtension)

-(id)objectForKeyNotNull:(id)aKey{
    id object = [self objectForKey:aKey];
    if (object == [NSNull null])
    {
        return nil;
    }
    return object;
}

-(NSString *)bg_StringForKeyNotNull:(id)aKey{
    id object = [self objectForKey:aKey];
    if (object == [NSNull null]){
        return nil;
    }if ([object isKindOfClass:[NSString class]]) {
        if ([object isEqualToString:@"null"]){
            return nil;
        }else{
            return object;
        }
    }else if([object isKindOfClass:[NSNumber class]]){
        return [NSString stringWithFormat:@"%@",object];
    }else{
        return nil;
    }
    return object;
}

-(NSArray *)bg_safeArrayForKeyNotNull:(id)aKey{
    id object = [self objectForKey:aKey];
    if (object == [NSNull null])
    {
        return nil;
    }
    if (![object isKindOfClass:[NSArray class]]) {
        return nil;
    }else{
        return object;
    }
    return object;
}
@end
