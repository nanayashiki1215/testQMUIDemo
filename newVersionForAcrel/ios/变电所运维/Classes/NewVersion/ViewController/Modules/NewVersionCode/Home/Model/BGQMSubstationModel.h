//
//  BGQMSubstationList.h
//  变电所运维
//
//  Created by Acrel on 2019/6/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
//data = {
//    endRow = 2;
//    firstPage = 1;
//    hasNextPage = 0;
//    hasPreviousPage = 0;
//    isFirstPage = 1;
//    isLastPage = 1;
//    lastPage = 1;
//    list = [
//            {
//                fAddress = "河南郑州管城回族区";
//                fApplycapacity = 300;
//                fDoor = 0;
//                fInstalledcapacity = 500;
//                fLatitude = 34.713327;
//                fLongitude = 113.775008;
//                fPhoneofalarm = "";
//                fPhoneofoperation = "";
//                fSmog = 0;
//                fSubid = 10100001;
//                fSubname = "变电所1";
//                fTransformernum = 1;
//                fVisionlive = "db4057b52a374a46a13d861ed3d64237|683946436;33d3b753d2894a11944b7df9f22c0e15;b86082143a864f618d6d09fbbaa1fe9f|683946443";
//                fVoltagestep = 10;
//                fWaterin = 0;
//                f_EpiFPrice = 1.222;
//                f_EpiGPrice = 0.364;
//                f_EpiJPrice = 0;
//                f_EpiPPrice = 0.752;
//                f_PartnerSubNo = "BPD00045"
//            }
@interface BGQMSubstationModel : NSObject{
    NSString *_fSubname;
    NSString *_fSubid;
    NSString *_quanpin;
    NSString *_jianpin;
    NSDictionary *_substation;
}
@property (nonatomic,copy) NSString *fSubname;
@property (nonatomic,copy) NSString *fSubid;
@property (nonatomic,copy) NSString *fAddress;
@property (nonatomic,copy) NSString *fLatitude;
@property (nonatomic,copy) NSString *fLongitude;
@property (nonatomic,copy) NSString *f_PartnerSubNo;
//@property (nonatomic,copy) NSDictionary *substation;
@property (nonatomic,copy) NSString *allWord;
@property (nonatomic,copy) NSString *firstWord;
@property (nonatomic,copy) NSString *FirstLetter;


//+(instancetype)manager;
//-(BGQMSubstationModel *)updateUserInfo:(NSDictionary *)info;
-(instancetype)initWithupdateUserInfo:(NSDictionary *)info;

@end

NS_ASSUME_NONNULL_END
