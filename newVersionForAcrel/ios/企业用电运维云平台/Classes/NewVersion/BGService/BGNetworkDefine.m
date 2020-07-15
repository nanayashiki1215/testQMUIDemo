//
//  BGNetworkDefine.m
//  变电所运维
//
//  Created by Acrel on 2019/6/5.
//

#import <Foundation/Foundation.h>
#import "BGNetworkDefine.h"

@implementation BGNetworkDefine : NSObject

+(NSString *)getBaseUslString{
    NSString *urlString = [[NSUserDefaults standardUserDefaults] objectForKey:kBaseUrlString];
    return urlString?urlString:DefaultBaseUrlString;
}

+(NSString *)getAppImageUrlstr{
    NSString *urlString = [[NSUserDefaults standardUserDefaults] objectForKey:@"imageUrlString"];
    return urlString?urlString:APPImageIconADS;
}

+(NSString *)getSystemImageUrlstr{
    NSString *urlString = [[NSUserDefaults standardUserDefaults] objectForKey:@"systemImageUrlstr"];
    return urlString?urlString:SystemImageIconADS;
}

+(NSString *)getAPPLoginImageUrlstr{
    NSString *urlString = [[NSUserDefaults standardUserDefaults] objectForKey:@"APPLoginImageUrl"];
    return urlString?urlString:appLoginImageIconADS;
}


@end
