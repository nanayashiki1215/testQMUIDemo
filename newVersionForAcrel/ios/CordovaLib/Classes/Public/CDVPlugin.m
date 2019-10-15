/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "CDVPlugin.h"
//#import "CDVPlugin+Private.h"
#import "CDVPlugin+Resources.h"
#import "CDVViewController.h"
#include <objc/message.h>

@implementation UIView (org_apache_cordova_UIView_Extension)

@dynamic scrollView;

- (UIScrollView*)scrollView
{
    SEL scrollViewSelector = NSSelectorFromString(@"scrollView");

    if ([self respondsToSelector:scrollViewSelector]) {
        return ((id (*)(id, SEL))objc_msgSend)(self, scrollViewSelector);
    }

    return nil;
}

@end

NSString* const CDVPageDidLoadNotification = @"CDVPageDidLoadNotification";
NSString* const CDVPluginHandleOpenURLNotification = @"CDVPluginHandleOpenURLNotification";
NSString* const CDVPluginHandleOpenURLWithAppSourceAndAnnotationNotification = @"CDVPluginHandleOpenURLWithAppSourceAndAnnotationNotification";
NSString* const CDVPluginResetNotification = @"CDVPluginResetNotification";
NSString* const CDVLocalNotification = @"CDVLocalNotification";
NSString* const CDVRemoteNotification = @"CDVRemoteNotification";
NSString* const CDVRemoteNotificationError = @"CDVRemoteNotificationError";
NSString* const CDVViewWillAppearNotification = @"CDVViewWillAppearNotification";
NSString* const CDVViewDidAppearNotification = @"CDVViewDidAppearNotification";
NSString* const CDVViewWillDisappearNotification = @"CDVViewWillDisappearNotification";
NSString* const CDVViewDidDisappearNotification = @"CDVViewDidDisappearNotification";
NSString* const CDVViewWillLayoutSubviewsNotification = @"CDVViewWillLayoutSubviewsNotification";
NSString* const CDVViewDidLayoutSubviewsNotification = @"CDVViewDidLayoutSubviewsNotification";
NSString* const CDVViewWillTransitionToSizeNotification = @"CDVViewWillTransitionToSizeNotification";

@interface CDVPlugin ()

@property (readwrite, assign) BOOL hasPendingOperation;

@end

@implementation CDVPlugin
@synthesize viewController, commandDelegate, hasPendingOperation;


// Do not override these methods. Use pluginInitialize instead.


- (void)dispose
{
    viewController = nil;
    commandDelegate = nil;
}


/*
// NOTE: for onPause and onResume, calls into JavaScript must not call or trigger any blocking UI, like alerts
- (void) onPause {}
- (void) onResume {}
- (void) onOrientationWillChange {}
- (void) onOrientationDidChange {}
*/

/* NOTE: calls into JavaScript must not call or trigger any blocking UI, like alerts */


/*
    NOTE: calls into JavaScript must not call or trigger any blocking UI, like alerts
 */


- (id)appDelegate
{
    return [[UIApplication sharedApplication] delegate];
}

@end
