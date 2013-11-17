//
//  BBAppDelegate.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 10/12/13.
//  Copyright (c) 2013 sinkevitch.name. All rights reserved.
//

#import "BBAppDelegate.h"
#import "BBHomeVC.h"
#import "RotationAwareNavigationController.h"

@interface BBAppDelegate ()
@end

@implementation BBAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //logger
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor grayColor] backgroundColor:nil forFlag:LOG_FLAG_VERBOSE];
    
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
    self.nc = [[RotationAwareNavigationController alloc] initWithRootViewController:vc];
    self.nc.navigationBar.barStyle = UIBarStyleBlack;
    self.nc.navigationBar.translucent = NO;
    self.nc.navigationBar.backgroundColor = [UIColor blackColor];
    if (APP_CONTEXT.isIos7)
    {
        //self.nc.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
        //does bugs
    }
    
    self.window.rootViewController = self.nc;
    [self.window makeKeyAndVisible];
    
    if (APP_CONTEXT.isIos7)
    {
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    }
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    DDLogVerbose(@"applicationWillResignActive");
    [APP_CONTEXT stopReachability];
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
    [APP_CONTEXT startReachability];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    DDLogVerbose(@"applicationWillTerminate");
    
    [BALANCE_CHECKER stop];
    [APP_CONTEXT stop];
    [SETTINGS save];
}

/*
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    NSUInteger orientations = (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
    
    if(self.window.rootViewController){
        UIViewController *presentedViewController = [[(UINavigationController *)self.window.rootViewController viewControllers] lastObject];
        orientations = [presentedViewController supportedInterfaceOrientations];
    }
    
    return orientations;
}
*/

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    
    NSDate * date = [NSDate new];
    DDLogInfo(@"performFetchWithCompletionHandler: %@", [DATE_HELPER dateToMysqlDateTime:date]);
    
    if ([BALANCE_CHECKER isBusy])
    {
        //offline
        DDLogInfo(@"bgFetch - check already started by user");
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
    
    /*
    if (![APP_CONTEXT isOnline])
    {
        //offline
        DDLogInfo(@"bgFetch - offline");
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
     */
    
    NSTimeInterval timeNow = [date timeIntervalSinceReferenceDate];
    NSTimeInterval timePassed = 0;
    
    BBMAccount * acc = nil;
    __block BBMAccount * accToCheck = nil;
    BBMBalanceHistory * bh = nil;
    double limit = 60*20; // 20 mins
    
    //all accounts that needs to be checked
    NSMutableArray * toCheckAccounts = [[NSMutableArray alloc] initWithCapacity:20];
    NSMutableArray * toCheckTimePassed = [[NSMutableArray alloc] initWithCapacity:20];
    
    for (acc in [BBMAccount findAllSortedBy:@"order" ascending:YES])
    {
        bh = [acc lastBalance];
        
        if (!bh) timePassed = limit + 1;
        else timePassed = timeNow - [bh.date timeIntervalSinceReferenceDate];
        
        if (timePassed > limit)
        {
            [toCheckAccounts addObject:acc];
            [toCheckTimePassed addObject:[NSNumber numberWithDouble:timePassed]];
        }
    }
    
    if ([toCheckAccounts count] < 1)
    {
        //no accounts to check
        DDLogInfo(@"bgFetch - no accounts to check");
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
    
    //find account with longest time without check
    __block float xmax = -MAXFLOAT;
    //float xmin = MAXFLOAT;
    
    [toCheckTimePassed enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        float x = [object floatValue];
        if (x > xmax)
        {
            accToCheck = [toCheckAccounts objectAtIndex:idx];
            xmax = x;
        }
    }];
    
    /*
    for (NSNumber * num in toCheckTimePassed)
    {
        float x = num.floatValue;
        if (x < xmin) xmin = x;
        if (x > xmax) xmax = x;
    }
     */
    
    
    if (!accToCheck)
    {
        //no accounts to check
        DDLogInfo(@"bgFetch - accToCheck not found");
        completionHandler(UIBackgroundFetchResultFailed);
        return;
    }
    
    if ([APP_CONTEXT isOnline])
    {
        DDLogInfo(@"bgFetch already is online");
        [BALANCE_CHECKER addBgItem:accToCheck handler:completionHandler];
    }
    else
    {
        [APP_CONTEXT startReachability];
        DDLogInfo(@"bgFetch - add account to check with delay");
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            DDLogInfo(@"bgFetch isOnline: %d", [APP_CONTEXT isOnline]);
            if ([APP_CONTEXT isOnline])
            {
                [BALANCE_CHECKER addBgItem:accToCheck handler:completionHandler];
            }
            else
            {
                [APP_CONTEXT stopReachability];
            }
        });
        //[self performSelector:@selector(ddd:) withObject:accToCheck afterDelay:1.f];
    }
    
    
}

@end
