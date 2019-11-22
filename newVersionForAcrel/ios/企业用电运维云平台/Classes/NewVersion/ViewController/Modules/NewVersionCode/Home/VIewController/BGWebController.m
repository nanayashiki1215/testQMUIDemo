//
//  BGWebController.m
//  BusinessGo
//
//  Created by feitian on 2017/4/6.
//  Copyright © 2017年 com.Ideal. All rights reserved.
//

#import "BGWebController.h"

@interface BGWebController ()<WKUIDelegate>

//@property (strong, nonatomic)  IBOutlet UIWebView *webView;
@property (strong,nonatomic) WKWebView *webView;

@end

@implementation BGWebController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.titleString;
//    self.webView.delegate =self;
//    self.navigationItem.leftBarButtonItem = [SKControllerTools createBarButtonItemWithTarget:self action:@selector(backButtonAction:) image:@"top-back" highlightImage:@"top-back"];
    if(self.urlString){
        NSString *urlString = self.urlString;
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
        self.webView.backgroundColor =[UIColor whiteColor];
//        [self.webView setScalesPageToFit:YES];
        self.webView.scrollView.bounces = NO;
        [self.webView reload];
    }else{
        [self showDifferentFile];
    }
}
//展示不同类型的文件
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
-(void)showDifferentFile{
    if (!self.Filelocaldata) {
        return;
    }
    NSString *fileType = [[self.titleString componentsSeparatedByString:@"."] lastObject];
    if ([fileType isEqualToString:@"txt"]) {
//        [self.webView loadData:self.Filelocaldata MIMEType:@"text/plain" textEncodingName:@"UTF-8" baseURL:nil];
        [self.webView loadData:self.Filelocaldata MIMEType:@"text/plain"  characterEncodingName:@"UTF-8" baseURL:nil];
    }else if ([fileType isEqualToString:@"pdf"]){
//        [self.webView loadData:self.Filelocaldata MIMEType:@"application/pdf" textEncodingName:@"UTF-8" baseURL:nil];
        [self.webView loadData:self.Filelocaldata MIMEType:@"application/pdf"  characterEncodingName:@"UTF-8" baseURL:nil];
//    }else if ([fileType isEqualToString:@"html"]){
//        [self.webView loadData:self.Filelocaldata MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:nil];
//    }else if ([fileType isEqualToString:@"docx"]){
//        [self.webView loadData:self.Filelocaldata MIMEType:@"application/vnd.openxmlformats-officedocument.wordprocessingml.document" textEncodingName:@"UTF-8" baseURL:nil];
//    }else if ([fileType isEqualToString:@"doc"]){
//        [self.webView loadData:self.Filelocaldata MIMEType:@"application/msword" textEncodingName:@"UTF-8" baseURL:nil];
//    }else if ([fileType isEqualToString:@"ppt"]){
//        [self.webView loadData:self.Filelocaldata  :@"application/vnd.ms-powerpoint" textEncodingName:@"UTF-8" baseURL:nil];
//    }else if ([fileType isEqualToString:@"pptx"]){
//        [self.webView loadData:self.Filelocaldata MIMEType:@"application/vnd.openxmlformats-officedocument.presentationml.presentation" textEncodingName:@"UTF-8" baseURL:nil];
//    }else if ([fileType isEqualToString:@"xls"]){
//        [self.webView loadData:self.Filelocaldata MIMEType:@"application/vnd.ms-excel	application/x-excel" textEncodingName:@"UTF-8" baseURL:nil];
//    }else if ([fileType isEqualToString:@"xlsx"]){
//        [self.webView loadData:self.Filelocaldata MIMEType:@"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" textEncodingName:@"UTF-8" baseURL:nil];
    }
}
#pragma clang diagnostic pop

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //[self stringByEvaluatingJavaScriptFromString:@"if(history.length>1) {history.back() }else{ alert(''+history.length)}"];
    //[self stringByEvaluatingJavaScriptFromString:@"alert(''+history.length)"];
    
//    [BGMBProgressHUD showHUDAddedTo:webView animated:YES];
    [CompputeTools waitWithTime:30 withWorkBlock:^{
        
        [self.webView stopLoading];
        
    }];
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //    [self stringByEvaluatingJavaScriptFromString:kTouchJavaScriptString];
//    [BGMBProgressHUD hideAllHUDsForView:webView animated:YES];
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
//    [BGMBProgressHUD hideAllHUDsForView:webView animated:YES];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"404" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *requestString = [[request URL] absoluteString];
    NSArray *components = [requestString componentsSeparatedByString:@":"];
    if ([components count] > 1 && [(NSString *)[components objectAtIndex:0] isEqualToString:@"testapp"]) {
        if([(NSString *)[components objectAtIndex:1] isEqualToString:@"alert"])
        {
            NSString *transString = [NSString stringWithString:[(NSString *)[components objectAtIndex:2] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"温馨提示" message:transString
                                  delegate:self cancelButtonTitle:nil
                                  otherButtonTitles:@"确定", nil];
            alert.delegate =self;
            [alert show];
        }
        return NO;
    }
    return YES;
}

@end
