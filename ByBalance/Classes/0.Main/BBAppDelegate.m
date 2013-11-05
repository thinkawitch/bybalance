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

@end
