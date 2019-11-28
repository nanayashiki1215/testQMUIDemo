//
//  QLPreviewController+autoTitle.m
//  企业用电运维云平台
//
//  Created by Acrel on 2019/11/28.
//

#import "QLPreviewController+autoTitle.h"
#import <objc/runtime.h>

@implementation QLPreviewController (autoTitle)

-(void)setQlpTitle:(NSString *)qlpTitle{
    objc_setAssociatedObject(self, @"qlpTitle", qlpTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString *)qlpTitle{
    return objc_getAssociatedObject(self, @"qlpTitle");
}

-(void)setTitle:(NSString *)title{
    if (self.qlpTitle) {
        self.navigationItem.title = self.qlpTitle;
    }else{
        self.navigationItem.title = title;
    }
}

@end
