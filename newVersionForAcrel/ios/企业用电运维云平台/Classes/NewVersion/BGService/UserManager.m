//
//  UserManager.m
//  CloudService
//
//  Created by feitian on 15/11/18.
//  Copyright © 2015年 com.Ideal. All rights reserved.
//

#import "UserManager.h"
@interface UserManager ()

@property(nonatomic,strong)UserManager *userManager;

@end

@implementation UserManager

static UserManager* manager;
+(instancetype)manager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[UserManager alloc]init];
//        [manager createData];//默认数据
    });
    return manager;
}

-(NSString *)account{
    _account = [DefNSUD stringForKey:kaccount];
    return _account;
}

-(void)setAccount:(NSString *)account{
    _account = account;
    [DefNSUD setObject:_account forKey:kaccount];
    DefNSUDSynchronize
}

-(NSString *)password{
    _password = [DefNSUD stringForKey:kpassword];
    return _password;
}

-(void)setPassword:(NSString *)password{
    _password = password;
    [DefNSUD setObject:_password forKey:kpassword];
    DefNSUDSynchronize
}

-(BOOL)isSavePwd{
    _isSavePwd = [DefNSUD boolForKey:@"isSavePwd"];
    return _isSavePwd;
}

-(void)setIsSavePwd:(BOOL)isSavePwd{
    _isSavePwd = isSavePwd;
    [DefNSUD setBool:_isSavePwd forKey:@"isSavePwd"];
    DefNSUDSynchronize
}

-(BOOL)autoLogin{
    _autoLogin = [DefNSUD boolForKey:kAutoLogin];
    return _autoLogin;
}

-(void)setAutoLogin:(BOOL)autoLogin{
    _autoLogin = autoLogin;
    [DefNSUD setBool:_autoLogin forKey:kAutoLogin];
    DefNSUDSynchronize
}

-(NSString *)imageUrl{
    _imageUrl = [DefNSUD stringForKey:kImgUrl];
    return _imageUrl;
}

-(void)setImageUrl:(NSString *)imageUrl{
    _imageUrl = imageUrl;
    [DefNSUD setObject:_imageUrl forKey:kImgUrl];
    DefNSUDSynchronize
}

//bguserId
-(NSString *)bguserId{
    _bguserId = [DefNSUD stringForKey:@"bguserId"];
    return _bguserId;
}

-(void)setBguserId:(NSString *)bguseId{
    _bguserId = bguseId;
    [DefNSUD setObject:_bguserId forKey:@"bguserId"];
    DefNSUDSynchronize
}

//bguserId
-(NSString *)homefMenuid{
    _homefMenuid = [DefNSUD stringForKey:@"homefMenuid"];
    return _homefMenuid;
}

-(void)setHomefMenuid:(NSString *)homefMenuid{
    _homefMenuid = homefMenuid;
    [DefNSUD setObject:_homefMenuid forKey:@"homefMenuid"];
    DefNSUDSynchronize
}

-(NSString *)bgnickName{
    _bgnickName = [DefNSUD stringForKey:@"bgnickName"];
    return _bgnickName;
}

-(void)setBgnickName:(NSString *)bgnickName{
    _bgnickName = bgnickName;
    [DefNSUD setObject:_bgnickName forKey:@"bgnickName"];
    DefNSUDSynchronize
}

-(NSString *)bgtelphone{
    _bgtelphone = [DefNSUD stringForKey:@"bgtelphone"];
    return _bgtelphone;
}

-(void)setBgtelphone:(NSString *)bgtelphone{
    _bgtelphone = bgtelphone;
    [DefNSUD setObject:_bgtelphone forKey:@"bgtelphone"];
    DefNSUDSynchronize
}

-(NSString *)bgaddress{
    _bgaddress = [DefNSUD stringForKey:@"bgaddress"];
    return _bgaddress;
}

-(void)setBgaddress:(NSString *)bgaddress{
    _bgaddress = bgaddress;
    [DefNSUD setObject:_bgaddress forKey:@"bgaddress"];
    DefNSUDSynchronize
}

-(NSArray *)FunURLArray{
    _FunURLArray = [DefNSUD arrayForKey:@"FunURLArray"];
    return _FunURLArray;
}

-(void)setFunURLArray:(NSArray *)FunURLArray{
    _FunURLArray = FunURLArray;
    [DefNSUD setObject:_FunURLArray forKey:@"FunURLArray"];
    DefNSUDSynchronize
}

-(NSArray *)selectlanageArr{
    _selectlanageArr = [DefNSUD arrayForKey:@"selectlanageArr"];
    return _selectlanageArr;
}

-(void)setSelectlanageArr:(NSArray *)selectlanageArr{
    _selectlanageArr = selectlanageArr;
    [DefNSUD setObject:_selectlanageArr forKey:@"selectlanageArr"];
    DefNSUDSynchronize
}

-(void)createData{
    self.account = @"test";
    self.password = @"123456";
    self.autoLogin = YES;
}

-(void)setOrderListUrl:(NSString *)orderListUrl{
    if (![orderListUrl hasPrefix:@"http"]) {
        _orderListUrl = [NSString stringWithFormat:@"http://%@",orderListUrl];
    }
    else{
        _orderListUrl = orderListUrl;
    }
    [DefNSUD setObject:_orderListUrl forKey:@"orderListUrl"];
    DefNSUDSynchronize
    
}

-(NSString *)orderListUrl{
    _orderListUrl = [DefNSUD objectForKey:@"orderListUrl"];
    return _orderListUrl;
}

-(void)setSubList:(NSArray *)subList{
    _subList = subList;
    [DefNSUD setObject:_subList
                forKey:@"subList"];
    DefNSUDSynchronize
}

-(NSArray *)subList{
    _subList = [DefNSUD objectForKey:@"subList"];
    return _subList;
}

-(void)setVersionArr:(NSArray *)versionArr{
    _versionArr = versionArr;
    [DefNSUD setObject:_versionArr
                forKey:@"versionArr"];
    DefNSUDSynchronize
}

-(NSArray *)versionArr{
    _versionArr = [DefNSUD objectForKey:@"versionArr"];
    return _versionArr;
}


-(void)setSingleSubFullData:(NSDictionary *)singleSubFullData{
    _singleSubFullData = singleSubFullData;
    [DefNSUD setObject:_singleSubFullData
                forKey:@"singleSubFullData"];
    DefNSUDSynchronize
}

-(NSDictionary *)singleSubFullData{
    _singleSubFullData = [DefNSUD objectForKey:@"singleSubFullData"];
    return _singleSubFullData;
}

-(void)setRootMenuData:(NSDictionary *)rootMenuData{
    _rootMenuData = rootMenuData;
    [DefNSUD setObject:_rootMenuData
                forKey:@"rootMenuData"];
    DefNSUDSynchronize
}

-(NSDictionary *)rootMenuData{
    _rootMenuData = [DefNSUD objectForKey:@"rootMenuData"];
    return _rootMenuData;
}

-(NSString *)fsubID{
    _fsubID = [DefNSUD stringForKey:@"fsubID"];
    return _fsubID;
}

-(void)setFsubID:(NSString *)fsubID{
    _fsubID = fsubID;
    [DefNSUD setObject:_fsubID forKey:@"fsubID"];
    DefNSUDSynchronize
}

-(NSString *)fsubName{
    _fsubName = [DefNSUD stringForKey:@"fsubName"];
    return _fsubName;
}

-(void)setFsubName:(NSString *)fsubName{
    _fsubName = fsubName;
    [DefNSUD setObject:_fsubName forKey:@"fsubName"];
    DefNSUDSynchronize
}

-(NSString *)token{
    _token = [DefNSUD stringForKey:@"token"];
    return _token;
}

-(void)setToken:(NSString *)token{
    _token = token;
    [DefNSUD setObject:_token forKey:@"token"];
    DefNSUDSynchronize
}

-(NSString *)versionNo{
    _versionNo = [DefNSUD stringForKey:@"versionNo"];
    return _versionNo;
}

-(void)setVersionNo:(NSString *)versionNo{
    _versionNo = versionNo;
    [DefNSUD setObject:_versionNo forKey:@"versionNo"];
    DefNSUDSynchronize
}

-(void)setHomeALLFullData:(NSDictionary *)homeALLFullData{
    _homeALLFullData = homeALLFullData;
    [DefNSUD setObject:_homeALLFullData
                forKey:@"homeALLFullData"];
    DefNSUDSynchronize
}

-(NSDictionary *)homeALLFullData{
    _homeALLFullData = [DefNSUD objectForKey:@"homeALLFullData"];
    return _homeALLFullData;
}

//[DefNSUD setObject:respObjc[kdata] forKey:@"Token"];
//DefNSUDSynchronize

//-(void)setSubModel:(BGQMSubstationModel *)subModel{
//    _subModel = subModel;
//    [DefNSUD setObject:_subModel
//                forKey:@"bgsubModel"];
//    DefNSUDSynchronize
//}
//
//-(BGQMSubstationModel *)subModel{
//    _subModel = [DefNSUD objectForKey:@"bgsubModel"];
//    return _subModel;
//}

-(void)setPrivateUnreadNumStr:(NSString *)privateUnreadNumStr{
    _privateUnreadNumStr = privateUnreadNumStr;
    [DefNSUD setObject:_privateUnreadNumStr
                forKey:@"privateUnreadNumStr"];
    DefNSUDSynchronize
}

-(NSString *)privateUnreadNumStr{
    _privateUnreadNumStr = [DefNSUD objectForKey:@"privateUnreadNumStr"];
    return _privateUnreadNumStr;
}

//存储appkey
-(void)setEmasAppKey:(NSString *)emasAppKey{
    _emasAppKey = emasAppKey;
    [DefNSUD setObject:_emasAppKey
                forKey:@"emasAppKey"];
    DefNSUDSynchronize
}

-(NSString *)emasAppKey{
    _emasAppKey = [DefNSUD objectForKey:@"emasAppKey"];
    return _emasAppKey;
}

//存储emasAppSecret
-(void)setEmasAppSecret:(NSString *)emasAppSecret{
    _emasAppSecret = emasAppSecret;
    [DefNSUD setObject:_emasAppSecret
                forKey:@"emasAppSecret"];
    DefNSUDSynchronize
}

-(NSString *)emasAppSecret{
    _emasAppSecret = [DefNSUD objectForKey:@"emasAppSecret"];
    return _emasAppSecret;
}

//存储报警未读数 未使用
-(void)setAlarmUnreadNumStr:(NSString *)alarmUnreadNumStr{
    _alarmUnreadNumStr = alarmUnreadNumStr;
    [DefNSUD setObject:_alarmUnreadNumStr
                forKey:@"alarmUnreadNumStr"];
    DefNSUDSynchronize
}

-(NSString *)alarmUnreadNumStr{
    _alarmUnreadNumStr = [DefNSUD objectForKey:@"alarmUnreadNumStr"];
    return _alarmUnreadNumStr;
}

-(void)setOrderUrlArray:(NSArray *)orderUrlArray{
    _orderUrlArray = orderUrlArray;
    [DefNSUD setObject:_orderUrlArray
                forKey:@"orderUrlArray"];
    DefNSUDSynchronize
}

-(NSArray *)orderUrlArray{
    _orderUrlArray = [DefNSUD objectForKey:@"orderUrlArray"];
    return _orderUrlArray;
}

-(void)setYytjBaiduDic:(NSDictionary *)yytjBaiduDic{
    _yytjBaiduDic = yytjBaiduDic;
    [DefNSUD setObject:_yytjBaiduDic
                forKey:@"yytjBaiduDic"];
    DefNSUDSynchronize
}

-(NSDictionary *)yytjBaiduDic{
    _yytjBaiduDic = [DefNSUD objectForKey:@"yytjBaiduDic"];
    return _yytjBaiduDic;
}

-(BOOL)isOpenTjBaidu{
    _isOpenTjBaidu = [DefNSUD boolForKey:@"isOpenTjBaidu"];
    return _isOpenTjBaidu;
}

-(void)setIsOpenTjBaidu:(BOOL)isOpenTjBaidu{
    _isOpenTjBaidu = isOpenTjBaidu;
    [DefNSUD setBool:_isOpenTjBaidu forKey:@"isOpenTjBaidu"];
    DefNSUDSynchronize
}
@end
