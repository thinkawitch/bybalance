//
//  BBAppDelegate.h
//  ByBalance
//
//  Created by Lion User on 17/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBHomeViewController;

@interface BBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic)  UIWindow * window;
@property (strong, nonatomic) BBHomeViewController * viewController;
@property (strong, nonatomic) IBOutlet UINavigationController *navController;

@end
