//
//  XPADAppDelegate.m
//  XPlanAd
//
//  Created by mjlee on 14-4-1.
//  Copyright (c) 2014年 mjlee. All rights reserved.
//

#import "XPADAppDelegate.h"
#import "IIViewDeckController.h"
#import "XPLeftMenuViewCtler.h"
#import "XPTaskListVCtler.h"
#import "XPStartupGuiderVctler.h"
#import "XPAlarmClockHelper.h"
//#import <ShareSDK/ShareSDK.h>

@interface XPADAppDelegate()
@end

@implementation XPADAppDelegate

+ (XPADAppDelegate*)shareInstance
{
    return (XPADAppDelegate*)[[UIApplication sharedApplication] delegate];
}

-(void)showTaskListDeckVctler
{
    // 初始化
    _deckController = [self generateControllerStack];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:self.deckController];
    self.rootNav = nav;
    self.rootNav.navigationBarHidden = YES;
    
    // 动画
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5 ;  // 动画持续时间(秒)
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = kCATransitionFade;//淡入淡出效果
    // view插入、移出
    [self.guiderVctler.view removeFromSuperview];
    self.window.rootViewController = self.rootNav;
    [[_window layer] addAnimation:animation forKey:@"animation"];
    
    // 在这里设置已经打开过
    NSDate * today      = [NSDate date];
    [[XPUserDataHelper shareInstance] setUserDataByKey:XPUserDataKey_LastOpenDate value:today];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // sharesdk
//    [ShareSDK registerApp:@"api20"];
//    {
//        //添加新浪微博应用
//        [ShareSDK connectSinaWeiboWithAppKey:@"857364782"
//                                   appSecret:@"49ca31f2e541bfb42e49a6fe8efbba1d"
//                                 redirectUri:@"http://appgo.cn"];
//    }
    
    // core Data setup
    [[UINavigationBar appearance] setBarTintColor:XPRGBColor(236,236,236,0.88)] ;
    // _coreDataMgr= [[XPDataManager alloc] init];
    
    // alarmhelper setup
    [[XPAlarmClockHelper shareInstance] setupNotification];
    
    // show the start up guider
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NSDate * today      = [NSDate date];
    NSDate* lastOpenDate= [[XPUserDataHelper shareInstance] getUserDataByKey:XPUserDataKey_LastOpenDate];
    if([today isTheSameDay:lastOpenDate] == YES)
    {
        // 今日有打开过
        _deckController = [self generateControllerStack];
        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:self.deckController];
        self.rootNav = nav;
        self.rootNav.navigationBarHidden = YES;
        self.window.rootViewController = self.rootNav;
        [self.window makeKeyAndVisible];
    }else
    {
        // 今日没打开过
        _guiderVctler   = [self generateStartupGuider];
        self.window.rootViewController = _guiderVctler;
        [self.window makeKeyAndVisible];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // 常驻内存打开的情况
    /*NSDate * today      = [NSDate date];
     NSDate* lastOpenDate= [[XPUserDataHelper shareInstance] getUserDataByKey:XPUserDataKey_LastOpenDate];
     if([today isTheSameDay:lastOpenDate] == YES)
     {
     // 今日有打开过
     if (self.window.rootViewController != self.rootNav) {
     _deckController = [self generateControllerStack];
     UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:self.deckController];
     self.rootNav = nav;
     self.rootNav.navigationBarHidden = YES;
     self.window.rootViewController = self.rootNav;
     [self.window makeKeyAndVisible];
     }
     }else
     {
     // 今日没打开过
     _guiderVctler   = [self generateStartupGuider];
     self.window.rootViewController = _guiderVctler;
     [self.window makeKeyAndVisible];
     // 在这里设置已经打开过
     [[XPUserDataHelper shareInstance] setUserDataByKey:XPUserDataKey_LastOpenDate value:today];
     }*/
    
    NSDate * today      = [NSDate date];
    NSDate* lastOpenDate= [[XPUserDataHelper shareInstance] getUserDataByKey:XPUserDataKey_LastOpenDate];
    if([today isTheSameDay:lastOpenDate] == YES)
    {
        // 今日有打开过
        if (self.window.rootViewController != self.rootNav) {
            _deckController = [self generateControllerStack];
            UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:self.deckController];
            self.rootNav = nav;
            self.rootNav.navigationBarHidden = YES;
            self.window.rootViewController = self.rootNav;
            [self.window makeKeyAndVisible];
        }
    }else
    {
        // 今日没打开过
        _guiderVctler   = [self generateStartupGuider];
        self.window.rootViewController = _guiderVctler;
        [self.window makeKeyAndVisible];
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"时间提醒"
                                                    message:notification.alertBody
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}


#pragma mark- startguider vctler
-(XPStartupGuiderVctler*)generateStartupGuider{
    XPStartupGuiderVctler* startupvc = [[XPStartupGuiderVctler alloc] init];
    return startupvc;
}

#pragma mark- ViewDeck
- (IIViewDeckController*)generateControllerStack
{
    XPTaskListVCtler* centervc           = [[XPTaskListVCtler alloc] init];
    UINavigationController* rootNav      = [[UINavigationController alloc] initWithRootViewController:centervc];
    XPLeftMenuViewCtler*  leftController = [[XPLeftMenuViewCtler alloc] initWithStyle:UITableViewStyleGrouped];
    IIViewDeckController* deckController = [[IIViewDeckController alloc] initWithCenterViewController:rootNav
                                                                                   leftViewController:leftController
                                                                                  rightViewController:nil];
    deckController.panningMode = IIViewDeckNavigationBarPanning;
    deckController.leftSize = 100;
    deckController.openSlideAnimationDuration = 0.25f;
    deckController.closeSlideAnimationDuration= 0.25f;
    
    [deckController disablePanOverViewsOfClass:NSClassFromString(@"_UITableViewHeaderFooterContentView")];
    return deckController;
}
@end
