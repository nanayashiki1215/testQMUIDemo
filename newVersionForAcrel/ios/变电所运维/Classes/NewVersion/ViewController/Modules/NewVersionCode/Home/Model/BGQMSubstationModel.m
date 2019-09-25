//
//  BGQMSubstationList.m
//  变电所运维
//
//  Created by Acrel on 2019/6/11.
//

#import "BGQMSubstationModel.h"

//static  BGQMSubstationList* subManager;

@implementation BGQMSubstationModel

//+(instancetype)manager{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        subManager = [[BGQMSubstationList alloc]init];
//        //        [manager createData];
//    });
//    return subManager;
//}
//
//-(NSString *)fSubname{
//    _fSubname = [DefNSUD stringForKey:@"fSubname"];
//    return _fSubname;
//}
//
//-(void)setFSubname:(NSString *)fSubname{
//    _fSubname = fSubname;
//    [DefNSUD setObject:_fSubname forKey:@"fSubname"];
//    DefNSUDSynchronize
//}
//
//-(NSString *)fSubid{
//    _fSubid = [DefNSUD stringForKey:@"fSubid"];
//    return _fSubid;
//}
//
//-(void)setFSubid:(NSString *)fSubid{
//    _fSubid = fSubid;
//    [DefNSUD setObject:_fSubid forKey:@"fSubid"];
//    DefNSUDSynchronize
//}
//
//-(NSString *)quanpin{
//    _quanpin = [DefNSUD stringForKey:@"quanpin"];
//    return _quanpin;
//}
//
//-(void)setQuanpin:(NSString *)quanpin{
//    _quanpin = quanpin;
//    [DefNSUD setObject:_quanpin forKey:@"quanpin"];
//    DefNSUDSynchronize
//}
//
//-(NSString *)jianpin{
//    _jianpin = [DefNSUD stringForKey:@"jianpin"];
//    return _jianpin;
//}
//
//-(void)setJianpin:(NSString *)jianpin{
//    _jianpin = jianpin;
//    [DefNSUD setObject:_fSubname forKey:@"jianpin"];
//    DefNSUDSynchronize
//}
//
//-(void)setSubstation:(NSDictionary *)substation{
//    _substation = substation;
//    [DefNSUD setObject:_substation forKey:@"substation"];
//    DefNSUDSynchronize
//}
//
//-(NSDictionary *)substation{
//    _substation = [DefNSUD dictionaryForKey:@"substation"];
//    return _substation;
//}
-(instancetype)initWithupdateUserInfo:(NSDictionary *)info{
    if (self = [super init]) {
        self.fSubname = [info objectForKeyNotNull:@"fSubname"];
        self.fSubid = [info objectForKeyNotNull:@"fSubid"];
        self.allWord = [info objectForKeyNotNull:@"allWord"];
        self.firstWord = [info objectForKeyNotNull:@"firstWord"];
        self.FirstLetter = [self.firstWord substringToIndex:1];
        self.fAddress = [info objectForKeyNotNull:@"fAddress"];
    }
    return self;
}

//-(BGQMSubstationModel *)updateUserInfo:(NSDictionary *)info{
//    self.fSubname = [info objectForKeyNotNull:@"fSubname"];
//    self.fSubid = [info objectForKeyNotNull:@"fSubid"];
//    self.allWord = [info objectForKeyNotNull:@"allWord"];
//    self.firstWord = [info objectForKeyNotNull:@"firstWord"];
//    self.FirstLetter = [self.firstWord substringToIndex:1];
//    self.fAddress = [info objectForKeyNotNull:@"fAddress"];
////    self.substation = [info objectForKey:@"substation"];
//
////    self.lastSessionTime = [info objectForKeyNotNull:kintegral];
////    if (!self.lastSessionTime || [self.lastSessionTime isEqualToString:@""]) {
////        self.lastSessionTime = @"0";
////    }
//}
@end
