//
//  BGFileDownModel.m
//  BusinessGo
//
//  Created by NanayaSSD on 2017/4/11.
//  Copyright © 2017年 com.Ideal. All rights reserved.
//

#import "BGFileDownModel.h"

@implementation BGFileDownModel

+(BGFileDownModel *)searchFileNameInRealm:(NSString *)fileName{
    RLMResults *file = [BGFileDownModel objectsWhere:[NSString stringWithFormat:@"fileName = '%@'",fileName]];
    return (file.count>0)?((BGFileDownModel *)file[0]):nil;
//    return nil;
}



@end
