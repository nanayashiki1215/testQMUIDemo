//
//  NSArray+BGExtension.m
//  BusinessUCSDK
//
//  Created by 潘弘 on 2018/6/13.
//  Copyright © 2018年 com.Ideal. All rights reserved.
//

#import "NSArray+BGExtension.h"

@implementation NSArray (BGExtension)
- (id)bg_safeObjectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        return self[index];
    }
    return nil;
}



@end
