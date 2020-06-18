//
//  BGQMHomeHeadView.m
//  变电所运维
//
//  Created by Acrel on 2019/6/12.
//  
//

#import "BGQMHomeHeadView.h"
#define insideHeight (SCREEN_WIDTH-insideSpacing*6)/3
#define insideSpacing 5
#define insideImageWidth (insideHeight)/3
#define insideImageOpionX (insideHeight-insideHeight/5*3+15)/2+2.5

#define MAXFLOAT 0x1.fffffep+127f
#import "JZLocationConverter.h"


@import MapKit;//ios7 使用苹果自带的框架使用@import导入则不用在Build Phases 导入框架了
@import CoreLocation;

@implementation BGQMHomeHeadView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        [self setupUI];
    }
    return self;
}

- (instancetype)initHomeHeadViewWithFrame:(CGRect)frame andHeadData:(NSDictionary *)paramDic andDataArray:(NSArray *)paramArr{
    if (self = [super initWithFrame:frame]) {
        [self setupUIWithParamDic:paramDic andDataArray:paramArr];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIEdgeInsets padding = UIEdgeInsetsMake(120 + self.qmui_safeAreaInsets.top,  self.qmui_safeAreaInsets.left, self.qmui_safeAreaInsets.bottom, self.qmui_safeAreaInsets.right);
    CGFloat contentWidth = CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(padding);
    self.gridView.frame = CGRectMake(padding.left, padding.top, contentWidth, QMUIViewSelfSizingHeight);
}

-(void)setupUIWithParamDic:(NSDictionary *)headDicm andDataArray:(NSArray *)headArray{
    self.backgroundColor = COLOR_BACKGROUND;
    
//    NSDictionary *baseInfoDic = [headDic objectForKeyNotNull:@"baseInfo"];
//    NSArray *infoArray = [headDic objectForKeyNotNull:@"arrayMap"];
    NSDictionary *baseInfoDic = headDicm;
    NSArray *infoArray = headArray;
    NSString *addressStr = [NSString changgeNonulWithString:baseInfoDic[@"fAddress"]];
    NSString *contactStr = [NSString changgeNonulWithString:baseInfoDic[@"fContacts"]];
    NSString *contactPhone = [NSString changgeNonulWithString:baseInfoDic[@"fContactsPhone"]];
    self.fLatitude = [NSString changgeNonulWithString:baseInfoDic[@"fLatitude"]];
    self.fLongitude = [NSString changgeNonulWithString:baseInfoDic[@"fLongitude"]];
    
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 120)];
//    UIImage *image = [self imageWithThemeColor:UIColorTheme4];
    [self.bgView setBackgroundColor:UIColorTheme4];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headPic"]];
    imageView.frame =CGRectMake(0, 0, SCREEN_WIDTH, 120);
    
    self.addressLabel = [[UILabel alloc] qmui_initWithFont:[UIFont systemFontOfSize:FixedDeathFontLargeSize] textColor:DefColorFromRGB(129,211,211, 1)];
    self.addressLabel.frame = CGRectMake(20, 0, SCREEN_WIDTH-40, 40.f);
    self.addressLabel.textAlignment = NSTextAlignmentCenter;
//    self.addressLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.addressLabel.numberOfLines = 2;
    if (addressStr.length) {
        self.addressLabel.text = addressStr;
    }
    
    self.contactLabel = [[UILabel alloc] qmui_initWithFont:[UIFont systemFontOfSize:FixedDeathFontLargeSize] textColor:[UIColor whiteColor]];
    self.contactLabel.frame = CGRectMake(10, 50, SCREEN_WIDTH-10, 30.f);
    self.contactLabel.text = @"";
    //2019.10.8临时注释
//    if (contactStr.length) {
//        self.contactLabel.text = [NSString stringWithFormat:@"联系人：%@",contactStr];
//    }else{
//        self.contactLabel.text = [NSString stringWithFormat:@"联系人："];
//    }
    
    self.phoneLabel = [[UILabel alloc] qmui_initWithFont:[UIFont systemFontOfSize:FixedDeathFontLargeSize] textColor:[UIColor whiteColor]];
    self.phoneLabel.frame = CGRectMake(10, 80, 200, 30.f);
    
     self.phoneLabel.text = @"";
    //2019.10.8临时注释
//    if (contactPhone.length) {
//        self.phoneLabel.text = [NSString stringWithFormat:@"联系人电话：%@",contactPhone];
//        CGSize labelsize = [self labelAutoCalculateRectWith:self.phoneLabel.text  FontSize:FixedDeathFontLargeSize  MaxSize:CGSizeMake(350, 30)];
//        self.phoneLabel.frame = CGRectMake(10, 80, labelsize.width, 30.f);
////        self.phoneLabel.textAlignment = NSTextAlignmentCenter;
//        self.PhoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        self.PhoneBtn.frame = CGRectMake(11+self.phoneLabel.frame.size.width, 80, 30, 30);
//        self.PhoneBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//        [self.PhoneBtn setImage:[UIImage imageNamed:@"phone"] forState:UIControlStateNormal];
//        [self.PhoneBtn addTarget:self action:@selector(CLickPhoneBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
//    }else{
//        self.phoneLabel.text = @"联系人电话：";
//    }
    
    if (addressStr.length) {
        CGSize textWidth = [self sizeWithText:self.addressLabel.text font:self.addressLabel.font maxSize:CGSizeMake(SCREEN_WIDTH-40, MAXFLOAT)];
        self.addressBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.addressBtn.frame = CGRectMake((SCREEN_WIDTH-textWidth.width)/2+textWidth.width, 0, 30, 40);
        self.addressBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self.addressBtn setImage:[UIImage imageNamed:@"map"] forState:UIControlStateNormal];
        [self.addressBtn addTarget:self action:@selector(CLickAddressBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
   
    self.gridView = [[QMUIGridView alloc] initWithFrame:CGRectMake(0, 120, SCREEN_WIDTH, SCREEN_WIDTH/3*2)];
    self.gridView.columnCount = 3;
    self.gridView.rowHeight = SCREEN_WIDTH/3;
    self.gridView.separatorWidth = 0;
    self.gridView.separatorColor = [UIColor clearColor];
    self.gridView.separatorDashed = NO;
    
    // 将要布局的 item 以 addSubview: 的方式添加进去即可自动布局
//    NSArray<UIColor *> *themeColors = @[UIColorTheme1, UIColorTheme2, UIColorTheme3, UIColorTheme4, UIColorTheme5, UIColorTheme6];
//    NSArray *image = @[@"VoltageLevel",@"Transformer",@"InstalledCapacity",@"LoadFactor",@"Measurement",@"Gateway"];
//    NSArray *headArr =  headDic[@"headArr"];
    if (infoArray.count>0) {
        for (NSInteger i = 0; i < infoArray.count; i++) {
            
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor clearColor];
            //        view.backgroundColor = [themeColors[i] colorWithAlphaComponent:.9];
            
            UIView *insideView = [[UIView alloc] initWithFrame:CGRectMake(insideSpacing, insideSpacing, insideHeight, insideHeight)];
            insideView.backgroundColor = [UIColor whiteColor];
            insideView.layer.cornerRadius = insideSpacing * 2;
            insideView.layer.masksToBounds = YES;
            
            UIButton *insideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            insideBtn.frame = CGRectMake(0,0, insideView.frame.size.width,insideView.frame.size.height);
            insideBtn.backgroundColor = [UIColor clearColor];
            [insideBtn addTarget:self action:@selector(clickInsideBtn:) forControlEvents:UIControlEventTouchUpInside];
            insideBtn.tag = i+1;
            
            //        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(insideImageWidth-5, 8, insideHeight/5*3-15, insideHeight/5*3-15)];
            NSString *imageStr = [NSString changgeNonulWithString:infoArray[i][@"fIconurl"]];
            
            UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(insideImageOpionX, 8, insideHeight/5*3-15, insideHeight/5*3-15)];
            DefLog(@"%@",[getSystemIconADS stringByAppendingString:imageStr]);
            [imageview sd_setImageWithURL:[NSURL URLWithString:[getSystemIconADS stringByAppendingString:imageStr]] placeholderImage:[UIImage imageNamed:@" VoltageLevel"]];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, insideHeight/5*3, insideView.frame.size.width, insideHeight/5-10)];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor grayColor];
            [label setFont:[UIFont systemFontOfSize:FixedDeathFontMinSize]];
            label.tag = i+1000;
            NSString *labelStr = [NSString changgeNonulWithString:infoArray[i][@"fMenuname"]];
            if (labelStr.length) {
                 label.text = labelStr;
            }
            UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, insideHeight/5*4, insideView.frame.size.width, insideHeight/5-10)];
            label2.tag = i+10;
            label2.textAlignment = NSTextAlignmentCenter;
            label2.adjustsFontSizeToFitWidth = YES;
            [label2 setFont:[UIFont systemFontOfSize:FixedDeathFontMinSize]];
            NSString *unitStr = [NSString changgeNonulWithString:infoArray[i][@"unit"]];
            NSString *valueStr = [NSString changgeNonulWithString:infoArray[i][@"value"]];
            if (!valueStr.length || [valueStr isEqualToString:@"null"] ||  [valueStr isEqualToString:@"(null)"] ) {
                label2.text = @"-";
            }else if([valueStr containsString:@";"]) {
                NSArray  *arrayStr = [valueStr componentsSeparatedByString:@";"];
                NSString *strRed = arrayStr[0];
                NSString *strBlack = arrayStr[1];
                label2.text = [NSString stringWithFormat:@"%@(%@) %@",strBlack,strRed,unitStr];
                [self redXingWithLabel:label2 atIndex:strBlack.length+1 andLength:strRed.length];
            }else{
                label2.text = [NSString stringWithFormat:@"%@ %@",valueStr,unitStr];
                [self redXingWithLabel:label2 atIndex:0 andLength:valueStr.length];
            }
            [insideView addSubview:insideBtn];
            [insideView addSubview:imageview];
            [insideView addSubview:label];
            [insideView addSubview:label2];
            [view addSubview:insideView];
            [self.gridView addSubview:view];
        }
    }
    
    [self addSubview:self.bgView];
    [self.bgView addSubview:imageView];
    [self.bgView addSubview:self.addressLabel];
    [self.bgView addSubview:self.contactLabel];
    [self.bgView addSubview:self.phoneLabel];
    [self.bgView addSubview:self.PhoneBtn];
    [self.bgView addSubview:self.addressBtn];
    [self addSubview:self.gridView];
    
}

- (CGSize)labelAutoCalculateRectWith:(NSString *)text FontSize:(CGFloat)fontSize MaxSize:(CGSize)maxSize
{
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize], NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGSize labelSize = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;
//    [paragraphStyle release];
    labelSize.height = ceil(labelSize.height);
    labelSize.width = ceil(labelSize.width);
    return labelSize;
    
}
//- (UIImage *)imageWithThemeColor:(UIColor *)color {
//
//    UIImage *resultImage = [UIImage qmui_imageWithSize:size opaque:YES scale:0 actions:^(CGContextRef contextRef) {
//        CGColorSpaceRef spaceRef = CGColorSpaceCreateDeviceRGB();
//        CGGradientRef gradient = CGGradientCreateWithColors(spaceRef, (CFArrayRef)@[(id)color.CGColor, (id)[color qmui_colorWithAlphaAddedToWhite:.86].CGColor], NULL);
//        CGContextDrawLinearGradient(contextRef, gradient, CGPointZero, CGPointMake(0, size.height), kCGGradientDrawsBeforeStartLocation);
//        CGColorSpaceRelease(spaceRef);
//        CGGradientRelease(gradient);
//    }];
//    return [resultImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1) resizingMode:UIImageResizingModeStretch];
//}

-(void)clickInsideBtn:(UIButton *)insideBtn{
    DefLog(@"点击了那个%@按钮,编号%ld，label编号:%@",insideBtn,insideBtn.tag,[self viewWithTag:101]);
    
}

-(void)CLickPhoneBtnEvent:(UIButton *)btn{
    NSString *string = [self.phoneLabel.text substringFromIndex:6];
    DefLog(@"phone:%@",string);
    NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"telprompt://%@",string];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
   

}

-(void)CLickAddressBtnEvent:(UIButton *)btn{
    NSString *urlScheme = @"MapJump://";
    NSString *appName = @"MapJump";
    CLLocationCoordinate2D coordinate;
    if (self.fLatitude && self.fLongitude) {
        coordinate  = CLLocationCoordinate2DMake([self.fLatitude doubleValue], [self.fLongitude doubleValue]);
    }
    NSString *addressName = @"终点";
    if (self.addressLabel) {
        addressName = self.addressLabel.text;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择地图" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    //这个判断其实是不需要的
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"http://maps.apple.com/"]]) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"苹果地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            CLLocationCoordinate2D desCoordinate = coordinate;
            
            MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:desCoordinate addressDictionary:nil]];
            toLocation.name = addressName;//可传入目标地点名称
            [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                           launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
        }];
        
        [alert addAction:action];
    }
    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        
            CLLocationCoordinate2D desCoordinate = [JZLocationConverter gcj02ToBd09:coordinate];//火星坐标转化为百度坐标
        
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"百度地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            //我的位置代表起点位置为当前位置，也可以输入其他位置作为起点位置，如天安门
            NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=name:%@|latlng:%f,%f&mode=driving&src=JumpMapDemo", addressName,desCoordinate.latitude, desCoordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            DefLog(@"%@",urlString);
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            
        }];
        
        [alert addAction:action];
    }
    
    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        //coordinate = CLLocationCoordinate2DMake(40.057023, 116.307852);
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"高德地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            CLLocationCoordinate2D desCoordinate = coordinate;
            
            NSString *urlString = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=applicationName&sid=BGVIS1&sname=%@&did=BGVIS2&dlat=%f&dlon=%f&dev=0&m=0&t=0",addressName,desCoordinate.latitude, desCoordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//@"我的位置"可替换为@"终点名称"
            
            DefLog(@"%@",urlString);
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            
        }];
        
        [alert addAction:action];
    }
    
    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"谷歌地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            CLLocationCoordinate2D desCoordinate = coordinate;
            
            NSString *urlString = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&saddr=&daddr=%f,%f&directionsmode=driving",appName,urlScheme,desCoordinate.latitude, desCoordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            DefLog(@"%@",urlString);
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            
        }];
        
        [alert addAction:action];
    }
    
    
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]])    {
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"腾讯地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            CLLocationCoordinate2D desCoordinate = coordinate;
            
            NSString *urlString = [[NSString stringWithFormat:@"qqmap://map/routeplan?type=drive&from=我的位置&to=%@&tocoord=%f,%f&policy=1&referer=%@", addressName, desCoordinate.latitude, desCoordinate.longitude, appName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            DefLog(@"%@",urlString);
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            
        }];
        
        [alert addAction:action];
    }
    
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    
//    [[self getCurrentVC] presentViewController:alert animated:YES completion:^{
//
//    }];
    [[self findCurrentViewController] presentViewController:alert animated:YES completion:nil];
}

- (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize {
    //
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    
}

- (UIViewController *)findCurrentViewController
{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UIViewController *topViewController = [window rootViewController];
    
    while (true) {
        
        if (topViewController.presentedViewController) {
            
            topViewController = topViewController.presentedViewController;
            
        } else if ([topViewController isKindOfClass:[UINavigationController class]] && [(UINavigationController*)topViewController topViewController]) {
            
            topViewController = [(UINavigationController *)topViewController topViewController];
            
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
            
        } else {
            break;
        }
    }
    return topViewController;
}


//将字符串特定的字变成红色
- (void)redXingWithLabel:(UILabel *)tempLabel atIndex:(NSInteger)tempIndex andLength:(NSInteger)tempLength{
    NSMutableAttributedString * tempString = [[NSMutableAttributedString alloc] initWithString: tempLabel.text];
    [tempString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(tempIndex, tempLength)];
    tempLabel.attributedText = tempString;
}

@end
