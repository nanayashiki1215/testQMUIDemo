///*
// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
// */
//
////
//// Testing shows:
////
//// In all cases, webView.request.URL is the previous page's URL (or empty) during the didStartLoad callback.
//// When loading a page with a redirect:
//// 1. shouldStartLoading (requestURL is target page)
//// 2. didStartLoading
//// 3. shouldStartLoading (requestURL is redirect target)
//// 4. didFinishLoad (request.URL is redirect target)
////
//// Note the lack of a second didStartLoading **
////
//// When loading a page with iframes:
//// 1. shouldStartLoading (requestURL is main page)
//// 2. didStartLoading
//// 3. shouldStartLoading (requestURL is one of the iframes)
//// 4. didStartLoading
//// 5. didFinishLoad
//// 6. didFinishLoad
////
//// Note there is no way to distinguish which didFinishLoad maps to which didStartLoad **
////
//// Loading a page by calling window.history.go(-1):
//// 1. didStartLoading
//// 2. didFinishLoad
////
//// Note the lack of a shouldStartLoading call **
//// Actually - this is fixed on iOS6. iOS6 has a shouldStart. **
////
//// Loading a page by calling location.reload()
//// 1. shouldStartLoading
//// 2. didStartLoading
//// 3. didFinishLoad
////
//// Loading a page with an iframe that fails to load:
//// 1. shouldStart (main page)
//// 2. didStart
//// 3. shouldStart (iframe)
//// 4. didStart
//// 5. didFailWithError
//// 6. didFinish
////
//// Loading a page with an iframe that fails to load due to an invalid URL:
//// 1. shouldStart (main page)
//// 2. didStart
//// 3. shouldStart (iframe)
//// 5. didFailWithError
//// 6. didFinish
////
//// This case breaks our logic since there is a missing didStart. To prevent this,
//// we check URLs in shouldStart and return NO if they are invalid.
////
//// Loading a page with an invalid URL
//// 1. shouldStart (main page)
//// 2. didFailWithError
////
//// TODO: Record order when page is re-navigated before the first navigation finishes.
////
//
//#import "CDVUIWebViewDelegate.h"
//
//// #define VerboseLog NSLog
//#define VerboseLog(...) do { \
//} while (0)
//
//typedef enum {
//    STATE_IDLE = 0,
//    STATE_WAITING_FOR_LOAD_START = 1,
//    STATE_WAITING_FOR_LOAD_FINISH = 2,
//    STATE_IOS5_POLLING_FOR_LOAD_START = 3,
//    STATE_IOS5_POLLING_FOR_LOAD_FINISH = 4,
//    STATE_CANCELLED = 5
//} State;
//
//static NSString *stripFragment(NSString* url)
//{
//    NSRange r = [url rangeOfString:@"#"];
//
//    if (r.location == NSNotFound) {
//        return url;
//    }
//    return [url substringToIndex:r.location];
//}
//
//@implementation CDVUIWebViewDelegate
//
//- (id)initWithDelegate:(NSObject <UIWebViewDelegate>*)delegate
//{
//    self = [super init];
//    if (self != nil) {
//        _delegate = delegate;
//        _loadCount = -1;
//        _state = STATE_IDLE;
//    }
//    return self;
//}
//
//- (BOOL)request:(NSURLRequest*)newRequest isEqualToRequestAfterStrippingFragments:(NSURLRequest*)originalRequest
//{
//    if (originalRequest.URL && newRequest.URL) {
//        NSString* originalRequestUrl = [originalRequest.URL absoluteString];
//        NSString* newRequestUrl = [newRequest.URL absoluteString];
//
//        NSString* baseOriginalRequestUrl = stripFragment(originalRequestUrl);
//        NSString* baseNewRequestUrl = stripFragment(newRequestUrl);
//        return [baseOriginalRequestUrl isEqualToString:baseNewRequestUrl];
//    }
//
//    return NO;
//}
//
//- (BOOL)isPageLoaded:(UIWebView*)webView
//{
//    NSString* readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
//
//    return [readyState isEqualToString:@"loaded"] || [readyState isEqualToString:@"complete"];
//}
//
//- (BOOL)isJsLoadTokenSet:(UIWebView*)webView
//{
//    NSString* loadToken = [webView stringByEvaluatingJavaScriptFromString:@"window.__cordovaLoadToken"];
//
//    return [[NSString stringWithFormat:@"%ld", (long)_curLoadToken] isEqualToString:loadToken];
//}
//
//- (void)setLoadToken:(UIWebView*)webView
//{
//    _curLoadToken += 1;
//    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.__cordovaLoadToken=%ld", (long)_curLoadToken]];
//}
//
//- (NSString*)evalForCurrentURL:(UIWebView*)webView
//{
//    return [webView stringByEvaluatingJavaScriptFromString:@"location.href"];
//}
//
//}
//
//- (void)pollForPageLoadFinish:(UIWebView*)webView
//{
//    if (_state != STATE_IOS5_POLLING_FOR_LOAD_FINISH) {
//        return;
//    }
//    if ([self isPageLoaded:webView]) {
//        VerboseLog(@"Polled for page load finish. result = YES!");

//

//

//@end
