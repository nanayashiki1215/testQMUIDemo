//
//  NSMutableDictionary+Extention.m
//  linphone
//
//  Created by feitian on 2016/11/9.
//
//

#import "NSMutableDictionary+BGExtention.h"

@implementation NSMutableDictionary (BGExtention)

-(void)setNotNullObject:(id)aobj ForKey:(id)aKey{
    if (aobj && [aobj isKindOfClass:[NSObject class]] && aKey) {
        [self setObject:aobj forKey:aKey];
    }
}

@end
