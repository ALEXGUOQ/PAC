//
//  XPADAppDelegate.h
//  XPlanAd
//
//  Created by mjlee on 14-4-1.
//  Copyright (c) 2014年 mjlee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IIViewDeckController.h"
#import "XPDataManager.h"

@class XPStartupGuiderVctler;
@interface XPADAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) XPDataManager*    coreDataMgr;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController*rootNav;
@property (strong, nonatomic) IIViewDeckController*  deckController;
@property (strong, nonatomic) XPStartupGuiderVctler* guiderVctler;

// 单例模式
+(XPADAppDelegate*)shareInstance;
-(void)showTaskListDeckVctler;

@end
