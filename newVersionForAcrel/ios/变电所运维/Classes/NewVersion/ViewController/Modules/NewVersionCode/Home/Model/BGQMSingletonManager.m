//
//  BGQMSingletonManager.m
//  变电所运维
//
//  Created by Acrel on 2019/6/4.
//

#import "BGQMSingletonManager.h"

@implementation BGQMSingletonManager

+(BGQMSingletonManager *)shareInstance
{
    static BGQMSingletonManager * singletonManager = nil;
    @synchronized(self){
        if (!singletonManager) {
            singletonManager = [[BGQMSingletonManager alloc]init];
        }
    }
    return singletonManager;
}



@end
