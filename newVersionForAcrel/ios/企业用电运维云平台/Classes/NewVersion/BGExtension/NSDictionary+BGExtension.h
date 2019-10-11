//
//  NSDictionary+Extension.h
//  BIMErnet
//
//  Created by feitian on 16/6/1.
//  Copyright © 2016年 HenryQi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (BGExtension)

-(id)objectForKeyNotNull:(id)aKey;

-(NSString *)bg_StringForKeyNotNull:(id)aKey;

//数组容错
-(NSArray *)bg_safeArrayForKeyNotNull:(id)aKey;

@end
