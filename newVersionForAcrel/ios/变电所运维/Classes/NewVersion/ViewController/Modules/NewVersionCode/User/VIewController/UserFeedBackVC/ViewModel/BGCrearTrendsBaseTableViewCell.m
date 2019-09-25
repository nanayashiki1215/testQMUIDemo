//
//  BGCrearTrendsBaseTableViewCell.m
//  BusinessGo
//
//  Created by per on 16/10/17.
//  Copyright © 2016年 com.Ideal. All rights reserved.
//

#import "BGCrearTrendsBaseTableViewCell.h"
#import "BRPlaceholderTextView.h"
#import "TestSystemService.h"
#import "TZImagePickerController.h"
#import "SDPhotoBrowser.h"
#import "UIImage+BGPhotoImage.h"
const float PicCellHeigth = 92.f;
static NSString *showImageCell = @"showImageCell";
NSString *const sendImageInfo = @"imgList";
NSString *const sayInfo = @"textContent";
@interface BGCrearTrendsBaseTableViewCell ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,SDPhotoBrowserDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet BRPlaceholderTextView *trendsStringTextView;
@property (strong, nonatomic) IBOutlet UICollectionView           *showImageClection;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *showLayout;
@property (strong, nonatomic) IBOutlet UIButton *addImageButton;
@property (nonatomic, weak)UIImagePickerController *imagePickerController;
@property (nonatomic,strong)NSMutableArray *imageArray;
@property (nonatomic,strong)UICollectionViewCell *imageCell;
- (IBAction)addImageButtonAction:(UIButton *)sender;

@end

@implementation BGCrearTrendsBaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _trendsStringTextView.placeholder = DefLocalizedString(@"problemssuggestions") ;
    _trendsStringTextView.delegate = self;
    self.showLayout.itemSize = CGSizeMake(SCREEN_WIDTH / 4 - 6, 94);
    self.imageArray = [NSMutableArray array];
    [self.showImageClection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:showImageCell];
    self.showImageClection.dataSource           = self;
    self.showImageClection.delegate             = self;
    _addImageButton.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:.32f].CGColor;
    _addImageButton.layer.borderWidth = 2.f;
    _addImageButton.frame = CGRectMake(0, 0, SCREEN_WIDTH / 4 - 10, SCREEN_WIDTH / 4 - 10);
    self.imageArray = [NSMutableArray array];

}

-(void)settingSendHiddenImage:(BOOL)isHidden{
    _showImageClection.hidden = isHidden;
    _addImageButton.hidden = isHidden;
}

-(void)settingSendDic:(NSDictionary *)dic{
    _imageArray = dic[sendImageInfo];
    if (!_imageArray) {
        self.imageArray = [NSMutableArray array];
    }else{
        [self reloadImageAndButtonFrame];
    }
    _trendsStringTextView.text = dic[sayInfo];
}

#pragma mark - collectionView datasourse&&delegate
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (_imageArray.count) {
        return _imageArray.count + 1;
    }
    return 1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:showImageCell forIndexPath:indexPath];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (_imageArray.count >=9) {
        self.addImageButton.hidden = YES;
    }
    
    if (indexPath.item >= _imageArray.count) {
        [cell.contentView addSubview:_addImageButton];
        _addImageButton.center = cell.contentView.center;
    }else{
        UIImageView *imageVi = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH / 4  - 8, 92)];
        imageVi.image = _imageArray[indexPath.item];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"icon_find_phone_del"] forState:UIControlStateNormal];
        btn.frame = CGRectMake(SCREEN_WIDTH / 4  - 32, 0, 30, 30);
        btn.tag = 5000 + indexPath.item;
        [btn addTarget:self action:@selector(removeImageWithButton:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:imageVi];
        [cell.contentView addSubview:btn];
    }

    return cell;
}
-(void)removeImageWithButton:(UIButton *)btn{
    [self.trendsStringTextView resignFirstResponder];
    NSInteger index = btn.tag - 5000;
    if (index<_imageArray.count) {
        [_imageArray removeObjectAtIndex:btn.tag - 5000];
        if (self.addImagesFinishdBlock) {
            _addImagesFinishdBlock(self.gettingSendDic);
        }
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.trendsStringTextView resignFirstResponder];
    self.imageCell = [collectionView cellForItemAtIndexPath:indexPath];
    [self tapImageView:indexPath.item];
}
- (void)tapImageView:(NSInteger)selectIndex
{
    if (_imageArray.count==0) {
        return;
    }
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.currentImageIndex = selectIndex;
    browser.sourceImagesContainerView = self.imageCell.superview;
    browser.imageCount = _imageArray.count;
    browser.delegate = self;
    [browser show];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
#pragma mark - actionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:{    // 取自相机
            
            [self takePhotoWithCamera];
        }
            break;
        case 1:{    // 取自相册
            [self takePhotoWithPhotoLibrary];
        }
            break;
        default:
            break;
    }
}

-(void)takePhotoWithPhotoLibrary
{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:20 delegate:nil];
    imagePickerVc.allowPickingOriginalPhoto = NO;
    // 你可以通过block或者代理，来得到用户选择的照片.
    imagePickerVc.maxImagesCount = 9 - _imageArray.count;
    __weak typeof(self) weakSelf = self;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        [weakSelf.imageArray addObjectsFromArray:photos];
        [weakSelf reloadImageAndButtonFrame];
        if (weakSelf.addImagesFinishdBlock) {
            weakSelf.addImagesFinishdBlock(weakSelf.gettingSendDic);
        }
    }];
    //
    imagePickerVc.navigationBar.barTintColor = [UIColor blackColor];
    imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    imagePickerVc.allowPickingVideo = NO;
//    imagePickerVc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.curentVC presentViewController:imagePickerVc animated:YES completion:nil];
}
-(void)takePhotoWithCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
//        imagePicker.allowsEditing=YES;
        [_curentVC presentViewController:imagePicker animated:YES completion:^{
            [TestSystemService showLocationAlertWithService:SystemServiceCamera byShowAlert:YES];
        }];
    }
}
#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //图片倒置处理
    UIImage* image = [UIImage fixOrientation:[info objectForKey:UIImagePickerControllerOriginalImage]];
    if (image) {
        [self.imageArray addObject:image];
        [self reloadImageAndButtonFrame];
    }

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >=5) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        [_curentVC dismissViewControllerAnimated:YES completion:nil];
    }
    
}
#pragma mark - SDPhotoBrowserDelegate

//- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
//{
//    NSString *imageName = _imageArray[index];
//    NSURL *url = [[NSBundle mainBundle] URLForResource:imageName withExtension:nil];
//    return url;
//}

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
//    UIImageView *imageView = self.subviews[index];
    return (UIImage *)_imageArray[index];
}
#pragma mark - otherAction
- (IBAction)addImageButtonAction:(UIButton *)sender {
    [self.trendsStringTextView resignFirstResponder];
    if (_imageArray.count >=9) {
        DefQuickAlert(@"最多添加9张照片，无法添加更多。", nil);
        return;
    }
    [self addImageSheetAction];
}
-(void)addImageSheetAction{
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"相册", nil];
    [sheet showInView:self.superview.superview.superview];
}
-(void)reloadImageAndButtonFrame{
    [_showImageClection reloadData];
//    NSInteger xLine = (_imageArray.count % 4 );
//    NSInteger yLine = (_imageArray.count / 4 );
//    CGFloat  wFrame = (SCREEN_WIDTH / 4 - 2);
//    CGFloat rectX = (xLine * wFrame + 4);
//    CGFloat rectY = (yLine * 96 + 2);
//    
//    _addImageButton.frame = CGRectMake(rectX, rectY, SCREEN_WIDTH / 4 - 4, 94);
//    if (((int)_imageArray.count - 1) > 1) {
//        [_showImageClection scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:(_imageArray.count - 1) inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
//    }
}
-(NSDictionary*)gettingSendDic{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (_trendsStringTextView.text) {
        [dic setValue:_trendsStringTextView.text forKey:sayInfo];
    }
    if (_imageArray) {
        [dic setValue:_imageArray forKey:sendImageInfo];
    }
    return dic;
}


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    //不支持系统表情的输入
//    if ([[[UITextInputMode currentInputMode ]primaryLanguage] isEqualToString:@"emoji"]) {
//        DefQuickAlert(@"暂不支持系统表情", nil);
//        return NO;
//    }
    return YES;
}
@end
