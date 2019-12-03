//
//  BGHeadPortraitViewController.m
//  BusinessGo
//
//  Created by Beryl on 2018/1/22.
//  Copyright © 2018年 com.Ideal. All rights reserved.
//

#import "BGHeadPortraitViewController.h"
#import "UIImage+BGPhotoImage.h"
#import "TZImagePickerController.h"
#import "CSImageModel.h"
#import "SDImageCache.h"

//上传头像的尺寸
#define AvatarImg_Height 375

@interface BGHeadPortraitViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *headerImageView;//个人头像


@property (strong,nonatomic)UIImage *selectedImage;
@property (strong,nonatomic)UIActionSheet *actionSheet;

@end

@implementation BGHeadPortraitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.title = DefLocalizedString(@"Upload the Avatar");
    //    [self.backButton setTitle:@"我 " forState:UIControlStateNormal];
    [self.homeButton setImage:[UIImage imageNamed:@"gengduodian"] forState:UIControlStateNormal];
    self.homeButton.hidden = NO;
    if (self.headerImage) {
        self.headerImageView.image = self.headerImage;
    }else{
        self.headerImageView.image = [UIImage imageNamed:@"touxiang"];
    }
    self.headerImageView.backgroundColor = [UIColor whiteColor];
    UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]init];
    [longpress addTarget:self action:@selector(longPressView:)];
    self.headerImageView.userInteractionEnabled = YES;
    [self.headerImageView addGestureRecognizer:longpress];
    
}

- (void)initNavigationBarButtonItems {
    [super initNavigationBarButtonItems];
}

//读取本地图片
- (UIImage *)readImageWithPath{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imageFilePath = [path stringByAppendingPathComponent:@"MyHeaderImage"];
    return [UIImage imageWithContentsOfFile:imageFilePath];
}
#pragma mark-保存到相册
-(void)longPressView:(UILongPressGestureRecognizer *)longPressGest{
    if (longPressGest.state==UIGestureRecognizerStateBegan) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存图片", nil];
        [actionSheet showInView:self.view];
    }
}

- (void)loadImageFinished:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
    [MBProgressHUD showSuccess:@"保存图片成功"];
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
    DefLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
}


- (void)moreButtonAction:(UIButton *)moreBtn{
    self.actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册中选择",@"保存图片", nil];
    [self.actionSheet showInView:self.view];
    
}

//选图片方式
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([actionSheet isEqual:self.actionSheet]) {
        
        if (buttonIndex == 0) {
            //显示拍照
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                DefQuickAlert(@"您的设备不支持拍照", nil);
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:DefLocalizedString(@"您的设备不支持拍照") delegate:nil cancelButtonTitle:DefLocalizedString(@"确定") otherButtonTitles: nil];
//                [alertView show];
                return;
            }
            UIImagePickerController *pickerC = [[UIImagePickerController alloc] init];
            pickerC.sourceType = UIImagePickerControllerSourceTypeCamera;
            pickerC.allowsEditing = YES;
            pickerC.delegate = self;
            [self presentViewController:pickerC animated:YES completion:nil];
            //从手机相册中选择
        }else if (buttonIndex == 1){
            [self takePhotoWithPhotoLibrary];
            //查看上一张头像
        }else if (buttonIndex == 2){
            
            
            //        [MBProgressHUD showSuccess:@"保存图片成功"];
            
            
            //        BGPreHeaderViewController *vc = [[BGPreHeaderViewController alloc]init];
            //        vc.image = [self readImageWithPath];
            //        vc.block = ^(UIImage *image) {
            //
            ////            //压缩图片到符合头像的尺寸
            ////            UIImage  *picimage = [CompputeTools compressImage:image toSize:CGSizeMake(AvatarImg_Height, AvatarImg_Height)];
            ////            CSImageModel *imageModel = [[CSImageModel alloc] init];
            ////            imageModel.image = picimage;
            //           [self writeHeaderToPath:self.selectedImage];
            //            [self requestUploadHeaderImage:image];
            //
            //        };
            //        [self.navigationController pushViewController:vc animated:YES];
            [self loadImageFinished:self.headerImageView.image];
            
            
            //保存图片
        }else{
            //    [self loadImageFinished:self.headerImageView.image];
            
            
        }
        
    }else{
        
        if (buttonIndex == 0) {
            [self loadImageFinished:self.headerImageView.image];
        }
    }
    actionSheet = nil;
}

#pragma mark - UIImagePickerControllerDelegate
//成功选择一张图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.selectedImage = info[UIImagePickerControllerEditedImage];
    //压缩图片到符合头像的尺寸
    UIImage  *image = [CompputeTools compressImage:self.selectedImage toSize:CGSizeMake(AvatarImg_Height, AvatarImg_Height)];
    CSImageModel *imageModel = [[CSImageModel alloc] init];
    imageModel.image = image;
    [self requestUploadHeaderImage:imageModel.image];
}

//多选图片发送
-(void)takePhotoWithPhotoLibrary
{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:20 delegate:nil];
    //
    // 你可以通过block或者代理，来得到用户选择的照片.
    //    __weak typeof(self) weakSelf = self;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        DefLog(@"photos:%@,assets:%@",photos,assets);
        for (UIImage *image in photos) {
            //压缩图片到符合头像的尺寸
            self.selectedImage = [CompputeTools bg_clipImageFromCenter:image toRect:CGSizeMake(AvatarImg_Height, AvatarImg_Height)];
            //    CSImageModel *imageModel = [[CSImageModel alloc] init];
            //    imageModel.image = image;
            [self requestUploadHeaderImage:self.selectedImage ];
        }
    }];
    imagePickerVc.navigationBar.barTintColor = [UIColor blackColor];
    imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    imagePickerVc.maxImagesCount = 1;
    //        imagePickerVc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

//点击保存，先上传图片，得到imageUrl再保存小结
- (void)requestUploadHeaderImage:(UIImage *)image {
    if (image == nil) {
        DefQuickAlert(@"请先选择图片!", nil);
        return;
    }
    
    NSString *name = [NSString stringWithFormat:@"%.0f_%.0f.jpg",image.size.width,image.size.height];
    NSDictionary *uploadImageParam = [NSDictionary dictionaryWithObject:name forKey:kfileName];
    float scal = 1.0f;
//    NSData *imageData = UIImageJPEGRepresentation([UIImage fixOrientation:image],scal);
//    if (nil == imageData){
//        imageData = UIImagePNGRepresentation(image);
//    }
    NSData *imageData = UIImagePNGRepresentation(image);
    BGWeakSelf;
    UserManager *user = [UserManager manager];
    if (!user.bguserId || !user.versionNo) {
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *param = @{@"fUserid":user.bguserId};
    NSString *baseURL = [BASE_URL stringByAppendingString:user.versionNo];
    NSString *urlString = [baseURL stringByAppendingString:@"/updateUserInfo"];
    [BGHttpService bg_httpUploadDataTo:urlString params:param fileData:imageData progress:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        
    } success:^(id respObjc) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [MBProgressHUD showSuccess:@"保存成功"];
        weakSelf.headerImageView.image = image;
        
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [MBProgressHUD showError:@"请求失败"];
    }];
//    [BGHttpService bg_httpUploadFileTo:@"" params:param file:imageData success:^(id respObjc) {
//        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
//        [MBProgressHUD showSuccess:@"保存成功"];
//    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
//        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
//        [MBProgressHUD showError:@"请求失败"];
//    }];
    
//    NSString *realURL =[BASE_URL stringByAppendingString:@"/filesUpload.do"];
//    [BGHttpService bg_httpUploadDataTo:realURL params:uploadImageParam fileData:imageData progress:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
//
//    } success:^(id respObjc) {
//        NSArray *array = respObjc;
//        DefLog(@"上传头像成功/n%@ %@",respObjc,array);
//        self.headerImageView.image = image;
//        [MBProgressHUD showSuccess:[NSString stringWithFormat:@"上传图片成功"]];
////        NSString *imageUrl = respObjc[@"data"];
////        [[SDImageCache sharedImageCache] storeImage:image forKey:imageUrl completion:nil];
////        //存储图片路径
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        [defaults setObject:imageUrl forKey:@"headerImage"];
//        [defaults synchronize];
////
//        self.selectedImage = image;
////        NSDictionary *param = @{kavatar:imageUrl};
////        [self requestSetInfo:param];
//    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
//        DefLog(@"上传头像失败/n%@",errorMsg);
//    }];
}

//设置个人信息
-(void)requestSetInfo:(NSDictionary *)param{
//     self.headerImageView.image
//    [BGHttpService bg_httpPostWithPath:realURL params:mutParams success:^(id respObjc) {
//
//    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
//        DefLog(@"设置失败：%@",errorMsg);
//    }];
}

- (void)writeHeaderToPath:(UIImage *)image{
    // 本地沙盒目录
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imageFilePath = [path stringByAppendingPathComponent:@"MyHeaderImage"];
    BOOL success = [UIImageJPEGRepresentation(image, 1) writeToFile:imageFilePath  atomically:YES];
    if (success){
        DefLog(@"写入本地成功");
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
