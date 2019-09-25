//
//  CSImageModel.h
//  CloudService
//
//  Created by feitian on 15/12/23.
//  Copyright © 2015年 com.Ideal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSImageModel : NSObject

@property(nonatomic,strong)UIImage * image;
@property(nonatomic,copy)NSString * imageUrl;//网址
@property(nonatomic,copy)NSString * thumbImageUrl;//缩略图网址
@property(nonatomic,copy)NSString * imageName;//本地的图片名字

@end
