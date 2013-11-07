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

@implementation BBAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [SETTINGS load];
    [APP_CONTEXT start];
    //[APP_CONTEXT showAllAccounts];
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
    //if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
    //    self.nc.edgesForExtendedLayout = UIRectEdgeNone;
    //}
    self.nc.navigationBar.barStyle = UIBarStyleBlack;
    self.nc.navigationBar.translucent = NO;
    self.nc.navigationBar.backgroundColor = [UIColor blackColor];
    self.window.rootViewController = self.nc;
    [self.window makeKeyAndVisible];
    
    if (APP_CONTEXT.doBgFetch)
    {
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"applicationWillTerminate");
    
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
    NSLog(@"performFetchWithCompletionHandler: %@", [DATE_HELPER dateToMysqlDateTime:date]);
    
    if ([BALANCE_CHECKER isBusy])
    {
        //offline
        NSLog(@"do check strated by user");
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
    
    if (![APP_CONTEXT isOnline])
    {
        //offline
        NSLog(@"offline");
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
    
    NSTimeInterval timeNow = [date timeIntervalSinceReferenceDate];
    
    BBMAccount * acc = nil;
    BBMAccount * accToCheck = nil;
    BBMBalanceHistory * bh = nil;
    double limit = 60*20; // 20 mins
    for (acc in [NSMutableArray arrayWithArray:[BBMAccount findAllSortedBy:@"order" ascending:YES]])
    {
        bh = [acc lastBalance];
        if (!bh)
        {
            accToCheck = acc;
            break;
        }
        
        if (timeNow - [bh.date timeIntervalSinceReferenceDate] > limit)
        {
            accToCheck = acc;
            break;
        }
    }
    
    if (!accToCheck)
    {
        //no accounts to check
        NSLog(@"no accounts to check");
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
    
    [BALANCE_CHECKER addBgItem:accToCheck handler:completionHandler];
    
    
    /*
    BBMAccount * acc = [BBMAccount findFirstByAttribute:@"username" withValue:@"297527406"];
    if (acc)
    {
        BBMBalanceHistory * bh = [BBMBalanceHistory createEntity];
        bh.date = [NSDate date];
        bh.account = acc;
        bh.extracted = [NSNumber numberWithBool:YES];
        bh.incorrectLogin = [NSNumber numberWithBool:NO];
        bh.balance = [[NSDecimalNumber alloc] initWithInt:1];
        bh.packages = [NSNumber numberWithInt:1];
        bh.megabytes = [[NSDecimalNumber alloc] initWithInt:1];
        bh.days = [[NSDecimalNumber alloc] initWithInt:1];
        bh.credit = [[NSDecimalNumber alloc] initWithInt:1];
        bh.minutes = [NSNumber numberWithInt:1];
        bh.sms = [NSNumber numberWithInt:1];
        
        [APP_CONTEXT saveDatabase];
        
        completionHandler(UIBackgroundFetchResultNewData);
    }
    else
    {
        completionHandler(UIBackgroundFetchResultFailed);
    }
    */
    
}

@end
