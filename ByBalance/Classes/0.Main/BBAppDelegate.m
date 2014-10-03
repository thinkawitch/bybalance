//
//  BBAppDelegate.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 10/12/13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBAppDelegate.h"
#import "BBNavigationController.h"
#import "BBHomeVC.h"
#import "BBBalanceVC.h"
#import "IGHTMLQuery.h"


@interface UISplitViewController (ByBalance)
-(UIStatusBarStyle)preferredStatusBarStyle;
@end
@implementation UISplitViewController (ByBalance)
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end


@interface BBAppDelegate ()
{
    NSTimer * bgrTimer;
    CFTimeInterval bgrStartTime;
    void (^bgFetchCompletionHandler)(UIBackgroundFetchResult);
    NSArray * toCheckAccountsInBg;
    
    NSTimer * appOpenTimer;
    CFTimeInterval appOpenStartTime;
    NSArray * toCheckAccountsOnStart;
}

- (void) startBgrTimer; //timer to wait for background reachability to establish internet connection
- (void) stopBgrTimer;
- (void) onBgrTimerTick:(NSTimer *)timer;

- (void) startAppOpenTimer; //timer to wait for ready internet connection
- (void) stopAppOpenTimer;
- (void) onAppOpenTimerTick:(NSTimer *)timer;

@end

@implementation BBAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //logger
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor grayColor] backgroundColor:nil forFlag:LOG_FLAG_VERBOSE];
    
    //save logs to file
    if (NO)
    {
        NSString * docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        DDLogFileManagerDefault * lfm = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:docsDirectory];
        //delete all log files
        if (NO)
        {
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            for (NSString *logFile in [lfm unsortedLogFilePaths])
            {
                [fileMgr removeItemAtPath:logFile error:NULL];
            }
        }
        
        DDFileLogger * fileLogger = [[DDFileLogger alloc] initWithLogFileManager:lfm];
        //DDFileLogger * fileLogger = [[DDFileLogger alloc] init];
        fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
        [DDLog addLogger:fileLogger];
    }
    
    DDLogVerbose(@"--- app started ----------------------------------------------------");
    if (application.applicationState == UIApplicationStateBackground)
    {
        DDLogVerbose(@"app started in background");
    }
    
    [SETTINGS load];
    [APP_CONTEXT start];
    //[APP_CONTEXT showAllAccounts];
    //[APP_CONTEXT clearAllHistory];
    [BALANCE_CHECKER start];
    
    //custom user agent
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:kBrowserUserAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    
    //google analytics
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 30;
#ifdef DEBUG
    //[[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
#endif
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-39554166-1"];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    
    application.statusBarHidden = NO;
    
    BBHomeVC * vc = NEWVCFROMNIB(BBHomeVC);
    self.nc1 = [[BBNavigationController alloc] initWithRootViewController:vc];
    self.nc1.navigationBar.barStyle = UIBarStyleBlack;
    self.nc1.navigationBar.translucent = NO;
    self.nc1.navigationBar.backgroundColor = [UIColor blackColor];

    if (APP_CONTEXT.isIos7)
    {
        self.nc1.delegate = (id<UINavigationControllerDelegate>)self.nc1;
        self.nc1.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    }
    
    if (APP_CONTEXT.isIpad)
    {
        self.split = [[UISplitViewController alloc] init];
        //[self.split.view setBackgroundColor:[APP_CONTEXT colorGrayMedium]];
        
        self.nc2 = [[BBNavigationController alloc] init];
        self.nc2.navigationBar.barStyle = UIBarStyleBlack;
        self.nc2.navigationBar.translucent = NO;
        self.nc2.navigationBar.backgroundColor = [UIColor blackColor];
        if (APP_CONTEXT.isIos7)
        {
            self.nc2.delegate = (id<UINavigationControllerDelegate>)self.nc2;
            self.nc2.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
        }
        
        BBBalanceVC * balanceVC = NEWVCFROMNIB(BBBalanceVC);
        balanceVC.account = nil;
        
        [self.nc2 pushViewController:balanceVC animated:NO];
        self.split.delegate = balanceVC;
        
        self.split.viewControllers = [NSArray arrayWithObjects:self.nc1, self.nc2, nil];
        self.window.rootViewController = self.split;
        
        
    }
    else
    {
        self.window.rootViewController = self.nc1;
    }
    
    [self.window makeKeyAndVisible];
    
    if (APP_CONTEXT.isIos7)
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeNewsstandContentAvailability];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
    }
    
    // Launched from push notification
    NSDictionary *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification)
    {
        DDLogVerbose(@"opened by local notification");
        //application.applicationIconBadgeNumber = 0;
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    DDLogVerbose(@"applicationWillResignActive");
    [APP_CONTEXT stopReachability];
    [self stopAppOpenTimer];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    DDLogVerbose(@"applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    DDLogVerbose(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    DDLogVerbose(@"applicationDidBecomeActive");
    
    application.applicationIconBadgeNumber = 0;
    [APP_CONTEXT startReachability];
    
    toCheckAccountsOnStart = [BALANCE_CHECKER accountsToCheckOnStart];
    if ([toCheckAccountsOnStart count] < 1)
    {
        //no accounts to check
        DDLogInfo(@"checkOnStart - no accounts to check");
        return;
    }
    
    [self startAppOpenTimer];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    DDLogVerbose(@"applicationWillTerminate");
    
    [BALANCE_CHECKER stop];
    [APP_CONTEXT stop];
    [SETTINGS save];
}

#pragma mark - App open reachability timer

- (void) startAppOpenTimer
{
    if (appOpenTimer) [self stopAppOpenTimer];
    
    appOpenTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                target:self
                                              selector:@selector(onAppOpenTimerTick:)
                                              userInfo:nil
                                               repeats:YES];
    appOpenStartTime = CACurrentMediaTime();
}

- (void) stopAppOpenTimer
{
    if (appOpenTimer)
    {
        [appOpenTimer invalidate];
        appOpenTimer = nil;
    }
}

- (void) onAppOpenTimerTick:(NSTimer *)timer
{
    CFTimeInterval elapsedTime = CACurrentMediaTime() - appOpenStartTime;
    
    if (elapsedTime < kAppOpenTimelimit)
    {
        if ([APP_CONTEXT isOnline])
        {
            [self stopAppOpenTimer];
            
            if (![BALANCE_CHECKER isBusy])
            {
                DDLogInfo(@"checkOnStart - do check");
                for (BBMAccount * oneAcc in toCheckAccountsOnStart)
                {
                    [BALANCE_CHECKER addItem:oneAcc];
                }
            }
        }
    }
    else
    {
        [self stopAppOpenTimer];
        DDLogVerbose(@"checkOnStart - reachability timeout, still offline");
    }
}

#pragma mark - Background reachability timer

- (void) startBgrTimer
{
    if (bgrTimer) [self stopBgrTimer];
    
    bgrTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1f
                                             target: self
                                           selector:@selector(onBgrTimerTick:)
                                           userInfo: nil
                                            repeats:YES];
    bgrStartTime = CACurrentMediaTime();
}

- (void) stopBgrTimer
{
    if (bgrTimer)
    {
        [bgrTimer invalidate];
        bgrTimer = nil;
    }
}

- (void) onBgrTimerTick:(NSTimer *)timer
{
    CFTimeInterval elapsedTime = CACurrentMediaTime() - bgrStartTime;
    
    if (elapsedTime < kBgrTimelimit)
    {
        if ([APP_CONTEXT isOnline])
        {
            [self stopBgrTimer];
            
            if (![BALANCE_CHECKER isBusy])
            {
                [BALANCE_CHECKER setBgCompletionHandler:bgFetchCompletionHandler];
                for (BBMAccount * oneAcc in toCheckAccountsInBg)
                {
                    [BALANCE_CHECKER addBgItem:oneAcc];
                }
            }
        }
    }
    else
    {
        [self stopBgrTimer];
        [APP_CONTEXT stopReachability];
        DDLogVerbose(@"bgFetch - background reachability timeout, still offline");
    }
}

- (void)application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //this code executes only if app is running in foreground
    //do nothing
    //DDLogVerbose(@"didReceiveLocalNotification");
    //DDLogInfo(@"%@", notification);
    [APP_CONTEXT showToastWithText:notification.alertBody];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    if (!APP_CONTEXT.isIos7) return;
    
    NSString * newToken = [deviceToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    DDLogVerbose(@"New apn token: %@", newToken);
    [BALANCE_CHECKER serverAddToken:newToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    if (!APP_CONTEXT.isIos7) return;
    
	DDLogError(@"Failed to get token, error: %@", error);
    [BALANCE_CHECKER serverRemoveToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSDate * date = [NSDate date];
    bgFetchCompletionHandler = nil;
    toCheckAccountsInBg = nil;
    DDLogInfo(@"didReceiveRemoteNotification fetchCompletionHandler: %@", [DATE_HELPER dateToMysqlDateTime:date]);
    
    if ([BALANCE_CHECKER isBusy])
    {
        DDLogInfo(@"apn_bgFetch - check already started by user");
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
    
    NSArray * toCheckAccounts = [BALANCE_CHECKER accountsToCheckInBg];
    if ([toCheckAccounts count] < 1)
    {
        //no accounts to check
        DDLogInfo(@"apn_bgFetch - no accounts to check");
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
    
    bgFetchCompletionHandler = [completionHandler copy];
    toCheckAccountsInBg = toCheckAccounts;
    
    if ([APP_CONTEXT isOnline])
    {
        DDLogInfo(@"apn_bgFetch - already is online");
        [BALANCE_CHECKER setBgCompletionHandler:completionHandler];
        for (BBMAccount * oneAcc in toCheckAccountsInBg)
        {
            [BALANCE_CHECKER addBgItem:oneAcc];
        }
    }
    else
    {
        [self startBgrTimer];
        [APP_CONTEXT startReachability];
    }
}

@end
